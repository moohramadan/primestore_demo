package store

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"github.com/lib/pq"

	"primestore_demo_backend/internal/orders/domain"
	"primestore_demo_backend/internal/orders/service"
	"primestore_demo_backend/internal/orders/store/gen"
)

var _ service.OrderStore = (*Store)(nil)

const (
	pgUniqueViolation   = "23505"
	orderNumberUniqueIx = "orders_order_number_key"
)

// CreateOrder saves an order and everything that must change with it in ONE
// transaction: the order row, its items, the first status history row, the
// order.placed outbox event, the idempotency key, and the emptied cart. Either
// all of it is saved or none of it is.
func (s *Store) CreateOrder(ctx context.Context, order domain.Order, idempotencyKey string) (domain.Order, error) {
	tx, err := s.conn.BeginTx(ctx, nil)
	if err != nil {
		return domain.Order{}, fmt.Errorf("create order: begin transaction: %w", err)
	}
	defer tx.Rollback() // no-op after a successful Commit

	q := s.q.WithTx(tx)

	row, err := q.InsertOrder(ctx, gen.InsertOrderParams{
		OrderNumber:    order.OrderNumber,
		UserID:         order.UserID,
		Status:         string(order.Status),
		PaymentStatus:  string(order.PaymentStatus),
		StockRef:       order.StockRef,
		ShipFullName:   order.Address.FullName,
		ShipPhone:      order.Address.Phone,
		ShipLine1:      order.Address.Line1,
		ShipLine2:      order.Address.Line2,
		ShipCity:       order.Address.City,
		ShipState:      order.Address.State,
		ShipPostalCode: order.Address.PostalCode,
		ShipCountry:    order.Address.Country,
		Subtotal:       order.Subtotal.String(),
		DeliveryFee:    order.DeliveryFee.String(),
		Total:          order.Total.String(),
	})
	if err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && pqErr.Code == pgUniqueViolation && pqErr.Constraint == orderNumberUniqueIx {
			return domain.Order{}, fmt.Errorf("order number %s: %w", order.OrderNumber, domain.ErrOrderNumberTaken)
		}
		return domain.Order{}, fmt.Errorf("create order: insert order: %w", err)
	}

	for _, item := range order.Items {
		err := q.InsertOrderItem(ctx, gen.InsertOrderItemParams{
			OrderID:      row.ID,
			VariantID:    item.VariantID,
			ProductID:    item.ProductID,
			SellerID:     item.SellerID,
			ProductName:  item.ProductName,
			VariantLabel: item.VariantLabel,
			ImageUrl:     item.ImageURL,
			UnitPrice:    item.UnitPrice.String(),
			Quantity:     item.Quantity,
			LineTotal:    item.LineTotal.String(),
		})
		if err != nil {
			return domain.Order{}, fmt.Errorf("create order: insert item (variant %d): %w", item.VariantID, err)
		}
	}

	err = q.InsertStatusHistory(ctx, gen.InsertStatusHistoryParams{
		OrderID:    row.ID,
		FromStatus: sql.NullString{}, // NULL: the order did not exist before
		ToStatus:   string(order.Status),
		ChangedBy:  sql.NullInt32{Int32: order.UserID, Valid: true},
	})
	if err != nil {
		return domain.Order{}, fmt.Errorf("create order: insert status history: %w", err)
	}

	// The key is written in the same transaction as the order, so it can never
	// point at an order that does not exist. A second request with the same key
	// conflicts here and the whole transaction is undone.
	inserted, err := q.InsertIdempotencyKey(ctx, gen.InsertIdempotencyKeyParams{
		UserID:         order.UserID,
		IdempotencyKey: idempotencyKey,
		OrderID:        row.ID,
	})
	if err != nil {
		return domain.Order{}, fmt.Errorf("create order: insert idempotency key: %w", err)
	}
	if inserted == 0 {
		return domain.Order{}, domain.ErrIdempotencyKeyReused
	}

	saved := order
	saved.ID = row.ID
	saved.CreatedAt = row.CreatedAt

	payload, err := domain.OrderPlacedPayload(saved)
	if err != nil {
		return domain.Order{}, fmt.Errorf("create order: build event: %w", err)
	}
	err = q.InsertOutboxEvent(ctx, gen.InsertOutboxEventParams{
		EventType:   domain.EventOrderPlaced,
		AggregateID: saved.ID,
		Payload:     payload,
	})
	if err != nil {
		return domain.Order{}, fmt.Errorf("create order: insert outbox event: %w", err)
	}

	if err := q.ClearCart(ctx, order.UserID); err != nil {
		return domain.Order{}, fmt.Errorf("create order: clear cart: %w", err)
	}

	if err := tx.Commit(); err != nil {
		return domain.Order{}, fmt.Errorf("create order: commit: %w", err)
	}
	return saved, nil
}

// FindOrderByIdempotencyKey returns the order this user created with this key,
// or domain.ErrNotFound.
func (s *Store) FindOrderByIdempotencyKey(ctx context.Context, userID int32, key string) (domain.Order, error) {
	row, err := s.q.GetOrderByIdempotencyKey(ctx, gen.GetOrderByIdempotencyKeyParams{
		UserID:         userID,
		IdempotencyKey: key,
	})
	if errors.Is(err, sql.ErrNoRows) {
		return domain.Order{}, domain.ErrNotFound
	}
	if err != nil {
		return domain.Order{}, fmt.Errorf("find order by idempotency key: %w", err)
	}

	items, err := s.q.ListOrderItems(ctx, row.ID)
	if err != nil {
		return domain.Order{}, fmt.Errorf("list order items: %w", err)
	}
	return toDomainOrder(row, items)
}

// toDomainOrder converts database rows into the domain order. Money arrives as
// NUMERIC text ("1500.00") and becomes cents here, at the boundary.
func toDomainOrder(row gen.Order, itemRows []gen.OrderItem) (domain.Order, error) {
	subtotal, err := domain.ParseMoney(row.Subtotal)
	if err != nil {
		return domain.Order{}, fmt.Errorf("order %d subtotal: %w", row.ID, err)
	}
	deliveryFee, err := domain.ParseMoney(row.DeliveryFee)
	if err != nil {
		return domain.Order{}, fmt.Errorf("order %d delivery fee: %w", row.ID, err)
	}
	total, err := domain.ParseMoney(row.Total)
	if err != nil {
		return domain.Order{}, fmt.Errorf("order %d total: %w", row.ID, err)
	}

	items := make([]domain.OrderItem, len(itemRows))
	for i, r := range itemRows {
		unitPrice, err := domain.ParseMoney(r.UnitPrice)
		if err != nil {
			return domain.Order{}, fmt.Errorf("order %d item %d unit price: %w", row.ID, r.ID, err)
		}
		lineTotal, err := domain.ParseMoney(r.LineTotal)
		if err != nil {
			return domain.Order{}, fmt.Errorf("order %d item %d line total: %w", row.ID, r.ID, err)
		}
		items[i] = domain.OrderItem{
			VariantID:    r.VariantID,
			ProductID:    r.ProductID,
			SellerID:     r.SellerID,
			ProductName:  r.ProductName,
			VariantLabel: r.VariantLabel,
			ImageURL:     r.ImageUrl,
			UnitPrice:    unitPrice,
			Quantity:     r.Quantity,
			LineTotal:    lineTotal,
		}
	}

	return domain.Order{
		ID:            row.ID,
		OrderNumber:   row.OrderNumber,
		UserID:        row.UserID,
		Status:        domain.Status(row.Status),
		PaymentStatus: domain.PaymentStatus(row.PaymentStatus),
		StockRef:      row.StockRef,
		Address: domain.AddressSnapshot{
			FullName:   row.ShipFullName,
			Phone:      row.ShipPhone,
			Line1:      row.ShipLine1,
			Line2:      row.ShipLine2,
			City:       row.ShipCity,
			State:      row.ShipState,
			PostalCode: row.ShipPostalCode,
			Country:    row.ShipCountry,
		},
		Subtotal:    subtotal,
		DeliveryFee: deliveryFee,
		Total:       total,
		CreatedAt:   row.CreatedAt,
		Items:       items,
	}, nil
}
