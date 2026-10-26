package util

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/smithy-go"
)

const (
	MaxImageBytes    int64 = 5 << 20 // 5 MB per image
	MaxProductImages       = 5
	UploadURLTTL           = 15 * time.Minute
)

// Only these types are accepted, and the extension is chosen by us, never by the client.
var imageExtensions = map[string]string{
	"image/jpeg": "jpg",
	"image/png":  "png",
	"image/webp": "webp",
}

var (
	ErrUnsupportedImageType = errors.New("unsupported image type")
	ErrImageMissing         = errors.New("image was not uploaded")
	ErrImageInvalid         = errors.New("uploaded file is not a valid image")
)

type ImageStorage struct {
	client     *s3.Client
	presigner  *s3.PresignClient
	bucket     string
	publicBase string
}

// NewImageStorage uses the standard AWS credential chain: environment
// credentials, shared AWS config, or an attached IAM role.
func NewImageStorage(ctx context.Context, bucket, publicBase string) (*ImageStorage, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, err
	}
	if cfg.Region == "" {
		return nil, errors.New("AWS_REGION is not set")
	}

	client := s3.NewFromConfig(cfg, func(o *s3.Options) {
		// Newer SDK versions add a checksum to every upload by default, which
		// makes presigned URLs fail when the app uploads without that checksum.
		o.RequestChecksumCalculation = aws.RequestChecksumCalculationWhenRequired
	})

	if publicBase == "" {
		publicBase = fmt.Sprintf("https://%s.s3.%s.amazonaws.com", bucket, cfg.Region)
	}

	return &ImageStorage{
		client:     client,
		presigner:  s3.NewPresignClient(client),
		bucket:     bucket,
		publicBase: strings.TrimRight(publicBase, "/"),
	}, nil
}

type SignedUpload struct {
	Path    string            // object key, this is what gets stored in the database
	URL     string            // short-lived URL the app uploads to
	Headers map[string]string // headers the app MUST send, exactly as given
}

// NewUpload creates a server-chosen object key under the seller's own prefix
// and presigns a PUT URL for it. The content type and the exact byte length
// are part of the signature, so S3 rejects an upload that differs from what
// the app declared.
func (s *ImageStorage) NewUpload(sellerID int32, contentType string, size int64) (*SignedUpload, error) {
	ext, ok := imageExtensions[contentType]
	if !ok {
		return nil, ErrUnsupportedImageType
	}
	if size <= 0 || size > MaxImageBytes {
		return nil, ErrImageInvalid
	}

	random := make([]byte, 16)
	if _, err := rand.Read(random); err != nil {
		return nil, err
	}
	object := fmt.Sprintf("products/%d/%s.%s", sellerID, hex.EncodeToString(random), ext)

	req, err := s.presigner.PresignPutObject(context.Background(), &s3.PutObjectInput{
		Bucket:        aws.String(s.bucket),
		Key:           aws.String(object),
		ContentType:   aws.String(contentType),
		ContentLength: aws.Int64(size),
	}, s3.WithPresignExpires(UploadURLTTL))
	if err != nil {
		return nil, err
	}

	return &SignedUpload{
		Path:    object,
		URL:     req.URL,
		Headers: map[string]string{"Content-Type": contentType},
	}, nil
}

// VerifyImage confirms the object exists, is within the size limit, and that
// its first bytes really are the image type it claims to be.
func (s *ImageStorage) VerifyImage(ctx context.Context, object string) error {
	head, err := s.client.HeadObject(ctx, &s3.HeadObjectInput{
		Bucket: aws.String(s.bucket),
		Key:    aws.String(object),
	})
	if err != nil {
		return translateS3Error(err)
	}

	contentType := aws.ToString(head.ContentType)
	size := aws.ToInt64(head.ContentLength)
	if _, ok := imageExtensions[contentType]; !ok || size <= 0 || size > MaxImageBytes {
		return ErrImageInvalid
	}

	obj, err := s.client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(s.bucket),
		Key:    aws.String(object),
		Range:  aws.String("bytes=0-511"),
	})
	if err != nil {
		return translateS3Error(err)
	}
	defer obj.Body.Close()

	first, err := io.ReadAll(obj.Body)
	if err != nil {
		return err
	}
	if http.DetectContentType(first) != contentType {
		return ErrImageInvalid
	}
	return nil
}

func (s *ImageStorage) DeleteImage(ctx context.Context, object string) error {
	_, err := s.client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(s.bucket),
		Key:    aws.String(object),
	})
	return err
}

// PublicURL turns a stored object key into a full URL. Older rows that
// already hold a full URL are returned unchanged.
func (s *ImageStorage) PublicURL(stored string) string {
	if stored == "" || strings.HasPrefix(stored, "http://") || strings.HasPrefix(stored, "https://") {
		return stored
	}
	if !strings.HasPrefix(stored, "products/") {
		return stored
	}
	return s.publicBase + "/" + stored
}

func translateS3Error(err error) error {
	var apiErr smithy.APIError
	if errors.As(err, &apiErr) {
		switch apiErr.ErrorCode() {
		case "NotFound", "NoSuchKey":
			return ErrImageMissing
		}
	}
	return err
}
