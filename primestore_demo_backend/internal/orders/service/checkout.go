package service

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"log"
	"strings"
	"time"

	"primestore_demo_backend/internal/orders"
	"primestore_demo_backend/internal/orders/domain"
)

const (
	maxOrderNumberAttempts = 3
	maxCommitAttempts      = 3

	// Compensation (release) and commit run on a context that survives the client
	// disconnecting, bounded by this timeout.
	detachedTimeout = 5 * time.Second
)

// OrderStore is what checkout needs from order storage.
type OrderStore interface {
	// FindOrderByIdempotencyKey returns the order this user already created with
	// this key, or domain.ErrNotFound.
	FindOrderByIdempotencyKey(ctx context.Context, userID int32, key string) (domain.Order, error)

	// CreateOrder saves the order and everything that must change with it in ONE
	// transaction: the items, a status history row, the order.placed outbox event,
	// the idempotency key, and the buyer's cart (emptied). It returns the saved
	// order (with its id and creation time). Errors:
	//   domain.ErrOrderNumberTaken   the order number is already used
	//   domain.ErrIdempotencyKeyReused  this user already used this key
	CreateOrder(ctx context.Context, order domain.Order, idempotencyKey string) (domain.Order, error)
}

// CheckoutDeps are the collaborators of the checkout use case.
type CheckoutDeps struct {
	Cart      CartStore
	Orders    OrderStore
	Catalog   orders.Catalog
	Inventory orders.Inventory
	Addresses orders.Addresses
}

// CheckoutConfig holds settings and the knobs tests use. Every field is
// optional: the zero value gives production defaults.
type CheckoutConfig struct {
	DeliveryFee domain.Money        // flat fee added to every order
	Now         func() time.Time    // default time.Now
	Random      io.Reader           // default crypto/rand.Reader
	Sleep       func(time.Duration) // default time.Sleep (used between commit retries)
}

// CheckoutService turns a cart into an order.
type CheckoutService struct {
	cart        CartStore
	orderStore  OrderStore
	catalog     orders.Catalog
	inventory   orders.Inventory
	addresses   orders.Addresses
	deliveryFee domain.Money
	now         func() time.Time
	random      io.Reader
	sleep       func(time.Duration)
}

func NewCheckoutService(deps CheckoutDeps, cfg CheckoutConfig) *CheckoutService {
	s := &CheckoutService{
		cart:        deps.Cart,
		orderStore:  deps.Orders,
		catalog:     deps.Catalog,
		inventory:   deps.Inventory,
		addresses:   deps.Addresses,
		deliveryFee: cfg.DeliveryFee,
		now:         cfg.Now,
		random:      cfg.Random,
		sleep:       cfg.Sleep,
	}
	if s.now == nil {
		s.now = time.Now
	}
	if s.random == nil {
		s.random = rand.Reader
	}
	if s.sleep == nil {
		s.sleep = time.Sleep
	}
	return s
}

// CheckoutResult is the outcome of a checkout request.
type CheckoutResult struct {
	Order domain.Order
	// Replayed is true when the idempotency key had already produced this order,
	// so nothing new was created.
	Replayed bool
}

// Checkout places an order for everything in the user's cart, to be delivered to
// addressID. idempotencyKey makes the call safe to retry: the same key always
// returns the same order and never creates a second one.
//
// The steps are a saga across modules:
//
//	replay check -> read cart -> catalog prices and address -> build order
//	-> Reserve stock -> ONE transaction (order, items, history, event, key, empty cart)
//	-> Commit the reservation
//
// If anything fails after Reserve, the stock is released again.
func (s *CheckoutService) Checkout(ctx context.Context, userID int32, addressID int64, idempotencyKey string) (CheckoutResult, error) {
	if err := checkUser(userID); err != nil {
		return CheckoutResult{}, err
	}
	if err := domain.ValidateIdempotencyKey(idempotencyKey); err != nil {
		return CheckoutResult{}, err
	}
	if addressID < 1 {
		return CheckoutResult{}, fmt.Errorf("address %d: %w", addressID, domain.ErrNotFound)
	}

	// 1. A repeated request returns the order it already created.
	existing, err := s.orderStore.FindOrderByIdempotencyKey(ctx, userID, idempotencyKey)
	if err == nil {
		return CheckoutResult{Order: existing, Replayed: true}, nil
	}
	if !errors.Is(err, domain.ErrNotFound) {
		return CheckoutResult{}, fmt.Errorf("checkout: %w", err)
	}

	// 2. The cart.
	entries, err := s.cart.ListCartItems(ctx, userID)
	if err != nil {
		return CheckoutResult{}, fmt.Errorf("checkout: %w", err)
	}
	if len(entries) == 0 {
		return CheckoutResult{}, domain.ErrEmptyCart
	}

	// 3. Prices come from the catalog, never from the client or the cart.
	ids := make([]int32, len(entries))
	for i, e := range entries {
		ids[i] = e.VariantID
	}
	variants, err := s.catalog.GetVariants(ctx, ids)
	if err != nil {
		return CheckoutResult{}, fmt.Errorf("checkout: %w", err)
	}
	address, err := s.addresses.Get(ctx, userID, addressID)
	if err != nil {
		return CheckoutResult{}, fmt.Errorf("checkout: %w", err)
	}

	// 4. The order, fully validated and priced, before any stock is touched.
	order, err := s.buildOrder(userID, entries, variants, address)
	if err != nil {
		return CheckoutResult{}, fmt.Errorf("checkout: %w", err)
	}

	// 5. Take the stock. All items or none.
	ref, err := s.newReservationRef()
	if err != nil {
		return CheckoutResult{}, fmt.Errorf("checkout: %w", err)
	}
	reserve := make([]orders.ReserveItem, len(entries))
	for i, e := range entries {
		reserve[i] = orders.ReserveItem{VariantID: e.VariantID, Quantity: e.Quantity}
	}
	if err := s.inventory.Reserve(ctx, ref, reserve); err != nil {
		if errors.Is(err, domain.ErrNotFound) { // the variant vanished since step 3
			return CheckoutResult{}, fmt.Errorf("checkout: %w", domain.ErrItemUnavailable)
		}
		return CheckoutResult{}, fmt.Errorf("checkout: reserve stock: %w", err)
	}
	order.StockRef = ref

	// 6. Save everything in one transaction.
	saved, err := s.saveOrder(ctx, order, idempotencyKey)
	if err != nil {
		s.release(ctx, ref) // give the stock back, whatever went wrong

		if errors.Is(err, domain.ErrIdempotencyKeyReused) {
			// A parallel request with the same key won the race: return its order.
			winner, findErr := s.orderStore.FindOrderByIdempotencyKey(ctx, userID, idempotencyKey)
			if findErr != nil {
				return CheckoutResult{}, fmt.Errorf("checkout: %w", findErr)
			}
			return CheckoutResult{Order: winner, Replayed: true}, nil
		}
		return CheckoutResult{}, fmt.Errorf("checkout: save order: %w", err)
	}

	// 7. Make the reservation permanent.
	if err := s.commit(ctx, ref); err != nil {
		if errors.Is(err, domain.ErrReservationExpired) {
			// The hold was released before we could commit it, so this order has no
			// stock behind it. It must not be fulfilled.
			log.Printf("checkout: reservation %s expired before commit: order %s (id %d) has no stock held and needs cancelling",
				ref, saved.OrderNumber, saved.ID)
			return CheckoutResult{}, fmt.Errorf("checkout: order %s: %w", saved.OrderNumber, err)
		}
		// The stock is still held and the order is real. Report success, and make
		// the problem visible for the reconciler.
		log.Printf("checkout: could not commit reservation %s for order %s (id %d): %v",
			ref, saved.OrderNumber, saved.ID, err)
	}

	return CheckoutResult{Order: saved}, nil
}

func (s *CheckoutService) buildOrder(userID int32, entries []domain.CartEntry, variants map[int32]orders.VariantInfo, address orders.Address) (domain.Order, error) {
	items := make([]domain.OrderItem, 0, len(entries))
	for _, e := range entries {
		v, ok := variants[e.VariantID]
		if !ok || v.UnitPrice <= 0 { // deleted, or without a usable price
			return domain.Order{}, &domain.ItemUnavailableError{VariantID: e.VariantID}
		}
		items = append(items, domain.OrderItem{
			VariantID:    v.VariantID,
			ProductID:    v.ProductID,
			SellerID:     v.SellerID,
			ProductName:  v.ProductName,
			VariantLabel: variantLabel(v.Color, v.Size),
			ImageURL:     v.ImageURL,
			UnitPrice:    v.UnitPrice,
			Quantity:     e.Quantity,
		})
	}

	order, err := domain.NewOrder(userID, items, s.deliveryFee, domain.AddressSnapshot{
		FullName:   address.FullName,
		Phone:      address.Phone,
		Line1:      address.Line1,
		Line2:      address.Line2,
		City:       address.City,
		State:      address.State,
		PostalCode: address.PostalCode,
		Country:    address.Country,
	})
	if err != nil {
		return domain.Order{}, err
	}

	order.OrderNumber, err = domain.NewOrderNumber(s.now(), s.random)
	if err != nil {
		return domain.Order{}, err
	}
	return order, nil
}

// saveOrder calls the store, retrying with a fresh order number on the rare
// collision.
func (s *CheckoutService) saveOrder(ctx context.Context, order domain.Order, idempotencyKey string) (domain.Order, error) {
	for attempt := 1; ; attempt++ {
		saved, err := s.orderStore.CreateOrder(ctx, order, idempotencyKey)
		if err == nil {
			return saved, nil
		}
		if !errors.Is(err, domain.ErrOrderNumberTaken) || attempt >= maxOrderNumberAttempts {
			return domain.Order{}, err
		}

		number, nerr := domain.NewOrderNumber(s.now(), s.random)
		if nerr != nil {
			return domain.Order{}, nerr
		}
		order.OrderNumber = number
	}
}

// release gives the reserved stock back. It runs on a context that is not
// cancelled when the client disconnects, so compensation always gets its chance.
// If it still fails, the reservation expires by itself and the sweeper releases it.
func (s *CheckoutService) release(ctx context.Context, ref string) {
	ctx, cancel := detached(ctx)
	defer cancel()

	if err := s.inventory.Release(ctx, ref); err != nil {
		log.Printf("checkout: could not release reservation %s (the sweeper will): %v", ref, err)
	}
}

// commit makes the reservation permanent, retrying transient failures. An
// expired reservation is final and is never retried.
func (s *CheckoutService) commit(ctx context.Context, ref string) error {
	ctx, cancel := detached(ctx)
	defer cancel()

	var err error
	for attempt := 1; attempt <= maxCommitAttempts; attempt++ {
		err = s.inventory.Commit(ctx, ref)
		if err == nil || errors.Is(err, domain.ErrReservationExpired) {
			return err
		}
		if attempt < maxCommitAttempts {
			s.sleep(time.Duration(attempt) * 50 * time.Millisecond)
		}
	}
	return err
}

func detached(ctx context.Context) (context.Context, context.CancelFunc) {
	return context.WithTimeout(context.WithoutCancel(ctx), detachedTimeout)
}

func (s *CheckoutService) newReservationRef() (string, error) {
	raw := make([]byte, 16)
	if _, err := io.ReadFull(s.random, raw); err != nil {
		return "", fmt.Errorf("reservation ref: %w", err)
	}
	return hex.EncodeToString(raw), nil
}

// variantLabel joins the color and size that exist: "Red / M", "Red", or "".
func variantLabel(color, size string) string {
	var parts []string
	if color != "" {
		parts = append(parts, color)
	}
	if size != "" {
		parts = append(parts, size)
	}
	return strings.Join(parts, " / ")
}
