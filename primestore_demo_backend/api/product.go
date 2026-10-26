package api

import (
	"context"
	"database/sql"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type categoryResponse struct {
	ID   int64  `json:"id"`
	Name string `json:"name"`
	Icon string `json:"icon"`
}

type variantResponse struct {
	ID              int64   `json:"id"`
	Color           string  `json:"color"`
	Size            string  `json:"size"`
	Price           string  `json:"price"`
	SalePrice       *string `json:"sale_price"`
	DiscountPercent int32   `json:"discount_percent"`
	Stock           int32   `json:"stock"`
}

type imageResponse struct {
	ID        int64  `json:"id"`
	ImageURL  string `json:"image_url"`
	SortOrder int32  `json:"sort_order"`
}

type productResponse struct {
	ID            int64             `json:"id"`
	Name          string            `json:"name"`
	Description   string            `json:"description"`
	CategoryName  string            `json:"category_name"`
	IsFeatured    bool              `json:"is_featured"`
	BrandName     string            `json:"brand_name"`
	BrandVerified bool              `json:"brand_verified"`
	Images        []imageResponse   `json:"images"`
	Variants      []variantResponse `json:"variants"`
}

func (server *Server) listCategories(ctx *gin.Context) {
	categories, err := server.store.ListCategories(ctx)
	if err != nil {
		internalError(ctx, err, "something went wrong")
		return
	}

	res := make([]categoryResponse, len(categories))
	for i, c := range categories {
		res[i] = categoryResponse{
			ID:   int64(c.ID),
			Name: c.Name,
			Icon: c.Icon.String,
		}
	}
	ctx.JSON(http.StatusOK, res)
}

func (server *Server) listFeaturedProducts(ctx *gin.Context) {
	products, err := server.store.ListFeaturedProducts(ctx)
	if err != nil {
		internalError(ctx, err, "something went wrong")
		return
	}

	bases := make([]productBase, len(products))
	for i, p := range products {
		bases[i] = productBase{
			ID:            p.ID,
			Name:          p.Name,
			Description:   p.Description,
			CategoryName:  p.CategoryName,
			IsFeatured:    p.IsFeatured,
			BrandName:     p.BrandName,
			BrandVerified: p.BrandVerified,
		}
	}

	res, err := server.buildProductResponses(ctx, bases)
	if err != nil {
		internalError(ctx, err, "something went wrong")
		return
	}

	ctx.JSON(http.StatusOK, res)
}

func (server *Server) listProductsByCategory(ctx *gin.Context) {
	categoryID, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil || categoryID <= 0 {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid category id"})
		return
	}

	products, err := server.store.ListProductsByCategory(ctx, sql.NullInt32{
		Int32: int32(categoryID),
		Valid: true,
	})
	if err != nil {
		internalError(ctx, err, "could not fetch products")
		return
	}

	bases := make([]productBase, len(products))
	for i, product := range products {
		bases[i] = productBase{
			ID:            product.ID,
			Name:          product.Name,
			Description:   product.Description,
			CategoryName:  product.CategoryName,
			IsFeatured:    product.IsFeatured,
			BrandName:     product.BrandName,
			BrandVerified: product.BrandVerified,
		}
	}

	res, err := server.buildProductResponses(ctx, bases)
	if err != nil {
		internalError(ctx, err, "could not fetch products")
		return
	}
	ctx.JSON(http.StatusOK, res)
}

type productBase struct {
	ID            int32
	Name          string
	Description   sql.NullString
	CategoryName  string
	IsFeatured    bool
	BrandName     sql.NullString
	BrandVerified sql.NullBool
}

func (server *Server) buildProductResponses(ctx context.Context, bases []productBase) ([]productResponse, error) {
	res := make([]productResponse, 0, len(bases))
	if len(bases) == 0 {
		return res, nil
	}

	ids := make([]int32, len(bases))
	for i, b := range bases {
		ids[i] = b.ID
	}

	images, err := server.store.ListProductImagesByProductIDs(ctx, ids)
	if err != nil {
		return nil, err
	}
	variants, err := server.store.ListProductVariantsByProductIDs(ctx, ids)
	if err != nil {
		return nil, err
	}

	imagesByProduct := make(map[int32][]imageResponse)
	for _, img := range images {
		imagesByProduct[img.ProductID] = append(imagesByProduct[img.ProductID], imageResponse{
			ID:        int64(img.ID),
			ImageURL:  server.images.PublicURL(img.ImageUrl),
			SortOrder: img.SortOrder,
		})
	}

	variantsByProduct := make(map[int32][]variantResponse)
	for _, v := range variants {
		var salePrice *string
		if v.SalePrice.Valid {
			value := v.SalePrice.String
			salePrice = &value
		}
		variantsByProduct[v.ProductID] = append(variantsByProduct[v.ProductID], variantResponse{
			ID:              int64(v.ID),
			Color:           v.Color.String,
			Size:            v.Size.String,
			Price:           v.Price,
			SalePrice:       salePrice,
			DiscountPercent: v.DiscountPercent,
			Stock:           v.Stock,
		})
	}
	for _, b := range bases {
		imgs := imagesByProduct[b.ID]
		if imgs == nil {
			imgs = []imageResponse{}
		}

		vars := variantsByProduct[b.ID]
		if vars == nil {
			vars = []variantResponse{}
		}

		res = append(res, productResponse{
			ID:            int64(b.ID),
			Name:          b.Name,
			Description:   b.Description.String,
			CategoryName:  b.CategoryName,
			IsFeatured:    b.IsFeatured,
			BrandName:     b.BrandName.String,
			BrandVerified: b.BrandVerified.Bool,
			Images:        imgs,
			Variants:      vars,
		})
	}

	return res, nil

}
