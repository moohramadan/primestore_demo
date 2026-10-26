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

func (server *Server) createProduct(ctx *gin.Context) {
	var req createProductRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	profile := ctx.MustGet(sellerProfileKey).(db.SellerProfile)

	// --- prices -----------------------------------------------------------
	original, ok := parseMoney(req.OriginalPrice)
	if !ok || original <= 0 {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "original_price must be a positive amount with up to 2 decimals"})
		return
	}
	var discount int32
	var salePrice sql.NullString
	if strings.TrimSpace(req.SalePrice) != "" {
		sale, ok := parseMoney(req.SalePrice)
		if !ok || sale <= 0 {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "sale_price must be a positive amount with up to 2 decimals"})
			return
		}
		if sale > original {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "sale_price cannot be higher than original_price"})
			return
		}
		discount = int32(((original-sale)*100 + original/2) / original) // rounded percent off
		salePrice = sql.NullString{String: formatCents(sale), Valid: true}
	}

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

	price := formatCents(original)
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
		res, err = server.buildProductResponses(ctx, []productBase{{
			ID:            row.ID,
			Name:          row.Name,
			Description:   row.Description,
			IsFeatured:    row.IsFeatured,
			BrandName:     row.BrandName,
			BrandVerified: row.BrandVerified,
		}})
		if err == nil && len(res) == 1 {
			ctx.JSON(http.StatusCreated, gin.H{"product": res[0]})
			return
		}
	}
	log.Printf("product %d saved but response could not be built: %v", product.ID, err)
	ctx.JSON(http.StatusCreated, gin.H{"product": gin.H{"id": product.ID}})
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
