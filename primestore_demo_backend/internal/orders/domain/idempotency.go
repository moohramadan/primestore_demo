package domain

import "fmt"

const (
	MinIdempotencyKeyLength = 8
	MaxIdempotencyKeyLength = 64
)

// ValidateIdempotencyKey checks the key a client sends with a checkout request.
// A UUID is the expected value. The limits keep keys printable and bounded (the
// column is VARCHAR(100)).
func ValidateIdempotencyKey(key string) error {
	if len(key) < MinIdempotencyKeyLength || len(key) > MaxIdempotencyKeyLength {
		return fmt.Errorf("length %d (allowed %d to %d): %w",
			len(key), MinIdempotencyKeyLength, MaxIdempotencyKeyLength, ErrInvalidIdempotencyKey)
	}
	for i := 0; i < len(key); i++ {
		c := key[i]
		ok := (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' || c == '_'
		if !ok {
			return fmt.Errorf("character %q at position %d: %w", c, i, ErrInvalidIdempotencyKey)
		}
	}
	return nil
}
