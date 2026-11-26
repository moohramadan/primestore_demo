package domain

import (
	"fmt"
	"io"
	"time"
)

// 32 symbols, so a random byte maps to one without bias (256 is a multiple of 32).
// 0, O, 1 and I are left out because they are easy to misread over the phone.
const orderNumberAlphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

// NewOrderNumber returns a human-readable order number such as
// "PS-20261117-K7M2QX": the UTC date plus six random symbols. random is
// normally crypto/rand.Reader. Collisions are possible but rare, and the
// database's unique constraint is the real guarantee.
func NewOrderNumber(now time.Time, random io.Reader) (string, error) {
	raw := make([]byte, 6)
	if _, err := io.ReadFull(random, raw); err != nil {
		return "", fmt.Errorf("order number: read random bytes: %w", err)
	}

	suffix := make([]byte, len(raw))
	for i, b := range raw {
		suffix[i] = orderNumberAlphabet[int(b)%len(orderNumberAlphabet)]
	}
	return "PS-" + now.UTC().Format("20060102") + "-" + string(suffix), nil
}
