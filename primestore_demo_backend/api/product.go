package api

import (
	"net/http"

	"github.com/gin-gonic/gin"
	db "primestore_demo_backend/db/sqlc"
)

type categoryResponse struct {
	ID   int64  `json:"id"`
	Name string `json:"name"`
	Icon string `json:"icon"`
}

type variantResponse struct {
	ID              int64  `json:"id"`
	Color           string `json:"color"`
	Size            string `json:"size"`
	Price           string `json:"price"`
	DiscountPercent int32  `json:"discount_percent"`
	Stock           int32  `json:"stock"`
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
	IsFeatured    bool              `json:"is_featured"`
	BrandName     string            `json:"brand_name"`
	BrandVerified bool              `json:"brand_verified"`
	Images        []imageResponse   `json:"images"`
	Variants      []variantResponse `json:"variants"`
}

func (server *Server) listCategories(ctx *gin.Context) {
	categories, err := server.store.ListCategories(ctx)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
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

func (server *Server) buildProductResponse(ctx *gin.Context, p db.ListFeaturedProductsRow) (productResponse, error) {
	images, err := server.store.ListProductImages(ctx, p.ID)
	if err != nil {
		return productResponse{}, err
	}
	variants, err := server.store.ListProductVariants(ctx, p.ID)
	if err != nil {
		return productResponse{}, err
	}

	imgRes := make([]imageResponse, len(images))
	for i, img := range images {
		imgRes[i] = imageResponse{ID: int64(img.ID), ImageURL: img.ImageUrl, SortOrder: img.SortOrder}
	}

	varRes := make([]variantResponse, len(variants))
	for i, v := range variants {
		varRes[i] = variantResponse{
			ID:              int64(v.ID),
			Color:           v.Color.String,
			Size:            v.Size.String,
			Price:           v.Price,
			DiscountPercent: v.DiscountPercent,
			Stock:           v.Stock,
		}
	}

	return productResponse{
		ID:            int64(p.ID),
		Name:          p.Name,
		Description:   p.Description.String,
		IsFeatured:    p.IsFeatured,
		BrandName:     p.BrandName.String,
		BrandVerified: p.BrandVerified.Bool,
		Images:        imgRes,
		Variants:      varRes,
	}, nil
}

func (server *Server) listFeaturedProducts(ctx *gin.Context) {
	products, err := server.store.ListFeaturedProducts(ctx)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	res := make([]productResponse, 0, len(products))
	for _, p := range products {
		built, err := server.buildProductResponse(ctx, p)
		if err != nil {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		res = append(res, built)
	}
	ctx.JSON(http.StatusOK, res)
}
