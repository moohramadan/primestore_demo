package api

import (
	"database/sql"
	"errors"
	"fmt"
	"log"
	"net/http"
	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/util"
	"regexp"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
)

type brandResponse struct {
	ID         int64  `json:"id"`
	Name       string `json:"name"`
	IsVerified bool   `json:"is_verified"`
}

func (server *Server) listBrands(ctx *gin.Context) {
	brands, err := server.store.ListBrands(ctx)
	if err != nil {
		internalError(ctx, err, "could not fetch brands")
		return
	}

	res := make([]brandResponse, len(brands))
	for i, b := range brands {
		res[i] = brandResponse{ID: int64(b.ID), Name: b.Name, IsVerified: b.IsVerified}
	}
	ctx.JSON(http.StatusOK, res)
}

func (server *Server) listSellerProducts(ctx *gin.Context) {
	profile := ctx.MustGet(sellerProfileKey).(db.SellerProfile)
	rows, err := server.store.ListSellerProducts(ctx, sql.NullInt32{
		Int32: profile.ID,
		Valid: true,
	})
	if err != nil {
		internalError(ctx, err, "could not fetch seller products")
		return
	}

	bases := make([]productBase, len(rows))
	for i, row := range rows {
		bases[i] = productBase{
			ID:            row.ID,
			CategoryID:    row.CategoryID,
			BrandID:       row.BrandID,
			Name:          row.Name,
			Description:   row.Description,
			CategoryName:  row.CategoryName,
			IsFeatured:    row.IsFeatured,
			BrandName:     sql.NullString{String: row.BrandName, Valid: row.BrandName != ""},
			BrandVerified: sql.NullBool{Bool: row.BrandVerified, Valid: true},
		}
	}
	products, err := server.buildProductResponses(ctx, bases)
	if err != nil {
		internalError(ctx, err, "could not fetch seller products")
		return
	}
	ctx.JSON(http.StatusOK, products)
}

// ---------------------------------------------------------------------------
// Step 1: the app asks for signed upload URLs
// ---------------------------------------------------------------------------

type uploadFile struct {
	ContentType string `json:"content_type" binding:"required"`
	Size        int64  `json:"size" binding:"required,min=1,max=5242880"` // must match util.MaxImageBytes
}

type uploadURLsRequest struct {
	// max=5 must match util.MaxProductImages (struct tags cannot use constants).
	Files []uploadFile `json:"files" binding:"required,min=1,max=5,dive"`
}

type deleteUploadedImageRequest struct {
	Path string `json:"path" binding:"required"`
}

type uploadURLResponse struct {
	Path      string            `json:"path"`
	UploadURL string            `json:"upload_url"`
	Headers   map[string]string `json:"headers"`
}

func (server *Server) createProductUploadURLs(ctx *gin.Context) {
	var req uploadURLsRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	profile := ctx.MustGet(sellerProfileKey).(db.SellerProfile)

	uploads := make([]uploadURLResponse, 0, len(req.Files))
	for _, f := range req.Files {
		upload, err := server.images.NewUpload(profile.ID, f.ContentType, f.Size)
		if errors.Is(err, util.ErrUnsupportedImageType) {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "only JPEG, PNG and WebP images are allowed"})
			return
		}
		if errors.Is(err, util.ErrImageInvalid) {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "each image must be between 1 byte and 5 MB"})
			return
		}
		if err != nil {
			internalError(ctx, err, "could not prepare image upload")
			return
		}
		uploads = append(uploads, uploadURLResponse{
			Path:      upload.Path,
			UploadURL: upload.URL,
			Headers:   upload.Headers,
		})
	}

	ctx.JSON(http.StatusOK, gin.H{
		"uploads":            uploads,
		"expires_in_seconds": int(util.UploadURLTTL.Seconds()),
	})
}

func (server *Server) deleteUnusedProductImage(ctx *gin.Context) {
	var req deleteUploadedImageRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	profile := ctx.MustGet(sellerProfileKey).(db.SellerProfile)
	if !isSellerImagePath(req.Path, profile.ID) {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid image path"})
		return
	}

	referenced, err := server.store.IsProductImageReferenced(ctx, req.Path)
	if err != nil {
		internalError(ctx, err, "could not check image usage")
		return
	}
	if referenced {
		ctx.JSON(http.StatusConflict, gin.H{"error": "image is used by a saved product"})
		return
	}
	if err := server.images.DeleteImage(ctx, req.Path); err != nil {
		internalError(ctx, err, "could not delete unused image")
		return
	}

	ctx.Status(http.StatusNoContent)
}

// ---------------------------------------------------------------------------
// Step 2: the app saves the product, referring to the uploaded images by path
// ---------------------------------------------------------------------------

type productVariantInput struct {
	Color string `json:"color" binding:"max=50"`
	Size  string `json:"size" binding:"max=20"`
	Stock int32  `json:"stock" binding:"min=0,max=1000000"`
}

type createProductRequest struct {
	Name          string                `json:"name" binding:"required,max=150"`
	Description   string                `json:"description"`
	CategoryID    int32                 `json:"category_id" binding:"required"`
	BrandID       int32                 `json:"brand_id"` // 0 means no brand
	OriginalPrice string                `json:"original_price" binding:"required"`
	SalePrice     string                `json:"sale_price"`
	ImagePaths    []string              `json:"image_paths" binding:"required,min=1,max=5,dive,required"`
	Variants      []productVariantInput `json:"variants" binding:"required,min=1,max=100,dive"`
}

type updateProductVariantInput struct {
	ID        int32  `json:"id" binding:"required,min=1"`
	Color     string `json:"color" binding:"max=50"`
	Size      string `json:"size" binding:"max=20"`
	Price     string `json:"price" binding:"required"`
	SalePrice string `json:"sale_price"`
	Stock     int32  `json:"stock" binding:"min=0,max=1000000"`
}

type updateSellerProductRequest struct {
	Name        string                      `json:"name" binding:"required,max=150"`
	Description string                      `json:"description"`
	CategoryID  int32                       `json:"category_id" binding:"required,min=1"`
	BrandID     int32                       `json:"brand_id"`
	Variants    []updateProductVariantInput `json:"variants" binding:"required,min=1,max=100,dive"`
}

var moneyPattern = regexp.MustCompile(`^\d{1,8}(\.\d{1,2})?$`)

// parseMoney turns "1500" or "1500.5" into whole cents without using floats.
func parseMoney(s string) (int64, bool) {
	s = strings.TrimSpace(s)
	if !moneyPattern.MatchString(s) {
		return 0, false
	}
	whole, frac, _ := strings.Cut(s, ".")
	frac = (frac + "00")[:2]
	w, _ := strconv.ParseInt(whole, 10, 64)
	f, _ := strconv.ParseInt(frac, 10, 64)
	return w*100 + f, true
}

func formatCents(c int64) string {
	return fmt.Sprintf("%d.%02d", c/100, c%100)
}

// priceInput is a validated original price and optional sale price, in cents.
type priceInput struct {
	Original int64
	Sale     int64
	HasSale  bool
}

var (
	errInvalidPrice     = errors.New("price must be a positive amount with up to 2 decimals")
	errInvalidSalePrice = errors.New("sale price must be a positive amount with up to 2 decimals")
	errSaleAbovePrice   = errors.New("sale price cannot be higher than the original price")
)

// parsePrices validates an original price and an optional sale price.
// An empty (or whitespace-only) sale price means "no sale".
func parsePrices(originalRaw, saleRaw string) (priceInput, error) {
	original, ok := parseMoney(originalRaw)
	if !ok || original <= 0 {
		return priceInput{}, errInvalidPrice
	}
	prices := priceInput{Original: original}
	if strings.TrimSpace(saleRaw) == "" {
		return prices, nil
	}
	sale, ok := parseMoney(saleRaw)
	if !ok || sale <= 0 {
		return priceInput{}, errInvalidSalePrice
	}
	if sale > original {
		return priceInput{}, errSaleAbovePrice
	}
	prices.Sale = sale
	prices.HasSale = true
	return prices, nil
}

// percentOff returns how much cheaper sale is than original, as a whole percent
// rounded to the nearest integer (halves round up). Returns 0 for bad input.
func percentOff(original, sale int64) int32 {
	if original <= 0 || sale < 0 || sale > original {
		return 0
	}
	return int32(((original-sale)*100 + original/2) / original)
}

func (p priceInput) DiscountPercent() int32 {
	if !p.HasSale {
		return 0
	}
	return percentOff(p.Original, p.Sale)
}

func (p priceInput) saleNullString() sql.NullString {
	if !p.HasSale {
		return sql.NullString{}
	}
	return sql.NullString{String: formatCents(p.Sale), Valid: true}
}

func (server *Server) createProduct(ctx *gin.Context) {
	var req createProductRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	profile := ctx.MustGet(sellerProfileKey).(db.SellerProfile)

	// --- prices -----------------------------------------------------------
	prices, err := parsePrices(req.OriginalPrice, req.SalePrice)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	salePrice := prices.saleNullString()
	discount := prices.DiscountPercent()

	// --- variants ---------------------------------------------------------
	// The unique index cannot catch duplicates when size is NULL, so check here.
	seenVariant := make(map[string]bool, len(req.Variants))
	for i := range req.Variants {
		v := &req.Variants[i]
		v.Color = strings.TrimSpace(v.Color)
		v.Size = strings.TrimSpace(v.Size)
		key := strings.ToLower(v.Color + "::" + v.Size)
		if seenVariant[key] {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "duplicate variant: " + v.Color + " " + v.Size})
			return
		}
		seenVariant[key] = true
	}

	// --- images -----------------------------------------------------------
	// Paths must be ones this seller was issued: products/<their id>/<32 hex>.<ext>
	seenPath := make(map[string]bool, len(req.ImagePaths))
	for _, p := range req.ImagePaths {
		if !isSellerImagePath(p, profile.ID) || seenPath[p] {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid image path"})
			return
		}
		seenPath[p] = true
	}
	// Done before the transaction so no database transaction waits on the network.
	for _, p := range req.ImagePaths {
		err := server.images.VerifyImage(ctx, p)
		if errors.Is(err, util.ErrImageMissing) || errors.Is(err, util.ErrImageInvalid) {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "an image was not uploaded correctly, please upload it again"})
			return
		}
		if err != nil {
			internalError(ctx, err, "could not verify uploaded images")
			return
		}
	}

	// --- save everything or nothing ---------------------------------------
	tx, err := server.conn.BeginTx(ctx, nil)
	if err != nil {
		internalError(ctx, err, "could not create product")
		return
	}
	defer tx.Rollback()
	qtx := server.store.WithTx(tx)

	description := strings.TrimSpace(req.Description)
	product, err := qtx.CreateProduct(ctx, db.CreateProductParams{
		SellerID:    sql.NullInt32{Int32: profile.ID, Valid: true},
		CategoryID:  sql.NullInt32{Int32: req.CategoryID, Valid: true},
		BrandID:     sql.NullInt32{Int32: req.BrandID, Valid: req.BrandID != 0},
		Name:        strings.TrimSpace(req.Name),
		Description: sql.NullString{String: description, Valid: description != ""},
	})
	if err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && pqErr.Code == "23503" { // foreign key violation
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "unknown category or brand"})
			return
		}
		internalError(ctx, err, "could not create product")
		return
	}

	for i, p := range req.ImagePaths {
		err := qtx.CreateProductImage(ctx, db.CreateProductImageParams{
			ProductID: product.ID,
			ImageUrl:  p,
			SortOrder: int32(i),
		})
		if err != nil {
			internalError(ctx, err, "could not save product images")
			return
		}
	}

	price := formatCents(prices.Original)
	for _, v := range req.Variants {
		err := qtx.CreateProductVariant(ctx, db.CreateProductVariantParams{
			ProductID:       product.ID,
			Color:           sql.NullString{String: v.Color, Valid: v.Color != ""},
			Size:            sql.NullString{String: v.Size, Valid: v.Size != ""},
			Price:           price,
			SalePrice:       salePrice,
			DiscountPercent: discount,
			Stock:           v.Stock,
		})
		if err != nil {
			internalError(ctx, err, "could not save product variants")
			return
		}

	}

	if err := tx.Commit(); err != nil {
		internalError(ctx, err, "could not create product")
		return
	}

	// The product is saved at this point. If building the response fails, still
	// report success so the app does not retry and create a duplicate.
	row, err := server.store.GetProduct(ctx, product.ID)
	if err == nil {
		var res []productResponse
		res, err = server.buildProductResponses(ctx, []productBase{newProductBase(row)})
		if err == nil && len(res) == 1 {
			ctx.JSON(http.StatusCreated, gin.H{"product": res[0]})
			return
		}
	}
	log.Printf("product %d saved but response could not be built: %v", product.ID, err)
	ctx.JSON(http.StatusCreated, gin.H{"product": gin.H{"id": product.ID}})
}

func (server *Server) updateSellerProduct(ctx *gin.Context) {
	productID64, err := strconv.ParseInt(ctx.Param("id"), 10, 32)
	if err != nil || productID64 <= 0 {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid product id"})
		return
	}

	var req updateSellerProductRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "product name is required"})
		return
	}

	profile := ctx.MustGet(sellerProfileKey).(db.SellerProfile)
	productID := int32(productID64)
	seenVariantIDs := make(map[int32]struct{}, len(req.Variants))
	seenVariantValues := make(map[string]struct{}, len(req.Variants))
	// Prices are parsed once during validation and reused when saving.
	variantPrices := make([]priceInput, len(req.Variants))
	for i := range req.Variants {
		variant := &req.Variants[i]
		variant.Color = strings.TrimSpace(variant.Color)
		variant.Size = strings.TrimSpace(variant.Size)
		if _, exists := seenVariantIDs[variant.ID]; exists {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "duplicate variant id"})
			return
		}
		seenVariantIDs[variant.ID] = struct{}{}
		key := strings.ToLower(variant.Color + "::" + variant.Size)
		if _, exists := seenVariantValues[key]; exists {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "duplicate variant"})
			return
		}
		seenVariantValues[key] = struct{}{}

		prices, err := parsePrices(variant.Price, variant.SalePrice)
		if err != nil {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		variantPrices[i] = prices
	}

	tx, err := server.conn.BeginTx(ctx, nil)
	if err != nil {
		internalError(ctx, err, "could not update product")
		return
	}
	defer tx.Rollback()
	qtx := server.store.WithTx(tx)

	productRows, err := qtx.UpdateSellerProduct(ctx, db.UpdateSellerProductParams{
		ID:          productID,
		SellerID:    sql.NullInt32{Int32: profile.ID, Valid: true},
		Name:        req.Name,
		Description: sql.NullString{String: strings.TrimSpace(req.Description), Valid: strings.TrimSpace(req.Description) != ""},
		CategoryID:  sql.NullInt32{Int32: req.CategoryID, Valid: true},
		BrandID:     sql.NullInt32{Int32: req.BrandID, Valid: req.BrandID > 0},
	})
	if err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && pqErr.Code == "23503" {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "unknown category or brand"})
			return
		}
		internalError(ctx, err, "could not update product")
		return
	}
	if productRows == 0 {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "product not found"})
		return
	}

	for i, variant := range req.Variants {
		prices := variantPrices[i]

		rows, err := qtx.UpdateSellerProductVariant(ctx, db.UpdateSellerProductVariantParams{
			ID:              variant.ID,
			ProductID:       productID,
			SellerID:        sql.NullInt32{Int32: profile.ID, Valid: true},
			Color:           sql.NullString{String: variant.Color, Valid: variant.Color != ""},
			Size:            sql.NullString{String: variant.Size, Valid: variant.Size != ""},
			Price:           formatCents(prices.Original),
			SalePrice:       prices.saleNullString(),
			DiscountPercent: prices.DiscountPercent(),
			Stock:           variant.Stock,
		})
		if err != nil {
			var pqErr *pq.Error
			if errors.As(err, &pqErr) && pqErr.Code == "23505" {
				ctx.JSON(http.StatusBadRequest, gin.H{"error": "variant color and size must be unique"})
				return
			}
			internalError(ctx, err, "could not update product variants")
			return
		}
		if rows != 1 {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "one or more variants do not belong to this product"})
			return
		}
	}

	if err := tx.Commit(); err != nil {
		internalError(ctx, err, "could not update product")
		return
	}

	row, err := server.store.GetProduct(ctx, productID)
	if err != nil {
		internalError(ctx, err, "product was updated but could not be reloaded")
		return
	}
	products, err := server.buildProductResponses(ctx, []productBase{newProductBase(row)})
	if err != nil {
		internalError(ctx, err, "product was updated but could not be reloaded")
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"product": products[0]})
}

func isSellerImagePath(path string, sellerID int32) bool {
	prefix := fmt.Sprintf("products/%d/", sellerID)
	if !strings.HasPrefix(path, prefix) {
		return false
	}

	filename := strings.TrimPrefix(path, prefix)
	extension := ""
	for _, candidate := range []string{".jpg", ".png", ".webp"} {
		if strings.HasSuffix(filename, candidate) {
			extension = candidate
			break
		}
	}
	if extension == "" {
		return false
	}

	stem := strings.TrimSuffix(filename, extension)
	if len(stem) != 32 {
		return false
	}
	for _, char := range stem {
		if (char < '0' || char > '9') && (char < 'a' || char > 'f') {
			return false
		}
	}
	return true
}
