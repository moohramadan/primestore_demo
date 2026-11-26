package adapters

import (
	"context"
	"fmt"

	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/internal/orders"
	"primestore_demo_backend/internal/orders/domain"
)

// CatalogAdapter implements orders.Catalog using the existing product tables.
type CatalogAdapter struct {
	q        *db.Queries
	imageURL func(path string) string
}

var _ orders.Catalog = (*CatalogAdapter)(nil)

// NewCatalogAdapter creates the adapter. imageURL turns a stored image path into
// a public URL (pass images.PublicURL); nil means "use the path as is".
func NewCatalogAdapter(q *db.Queries, imageURL func(path string) string) *CatalogAdapter {
	if imageURL == nil {
		imageURL = func(path string) string { return path }
	}
	return &CatalogAdapter{q: q, imageURL: imageURL}
}

// GetVariants returns the variants that exist. Ids that do not exist are simply
// missing from the result.
func (a *CatalogAdapter) GetVariants(ctx context.Context, ids []int32) (map[int32]orders.VariantInfo, error) {
	result := make(map[int32]orders.VariantInfo, len(ids))
	if len(ids) == 0 {
		return result, nil
	}

	rows, err := a.q.GetVariantsForOrder(ctx, ids)
	if err != nil {
		return nil, fmt.Errorf("get variants: %w", err)
	}

	for _, r := range rows {
		price, err := domain.ParseMoney(r.UnitPrice)
		if err != nil {
			return nil, fmt.Errorf("variant %d price: %w", r.VariantID, err)
		}

		image := ""
		if r.ImageUrl != "" {
			image = a.imageURL(r.ImageUrl)
		}

		result[r.VariantID] = orders.VariantInfo{
			VariantID:   r.VariantID,
			ProductID:   r.ProductID,
			SellerID:    r.SellerID.Int32, // 0 when the product has no seller
			ProductName: r.ProductName,
			Color:       r.Color.String,
			Size:        r.Size.String,
			ImageURL:    image,
			UnitPrice:   price,
			Stock:       r.Stock,
		}
	}
	return result, nil
}
