package domain

import (
	"errors"
	"strings"
	"testing"
)

func TestValidateIdempotencyKey(t *testing.T) {
	tests := []struct {
		name    string
		key     string
		wantErr bool
	}{
		{"uuid", "3f2b8c1e-9d4a-4e7b-8a6f-1c2d3e4f5a6b", false},
		{"shortest allowed", "abcd1234", false},
		{"longest allowed", strings.Repeat("a", MaxIdempotencyKeyLength), false},
		{"underscore and dash", "order_2026-11-17", false},
		{"empty", "", true},
		{"too short", "abc123", true},
		{"too long", strings.Repeat("a", MaxIdempotencyKeyLength+1), true},
		{"contains a space", "abcd 1234", true},
		{"contains a slash", "abcd/1234", true},
		{"contains a newline", "abcd1234\n", true},
		{"non-ASCII letter", "abcd123é", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := ValidateIdempotencyKey(tt.key)
			if (err != nil) != tt.wantErr {
				t.Fatalf("ValidateIdempotencyKey(%q) error = %v, wantErr %t", tt.key, err, tt.wantErr)
			}
			if tt.wantErr && !errors.Is(err, ErrInvalidIdempotencyKey) {
				t.Errorf("error = %v, want errors.Is(_, ErrInvalidIdempotencyKey)", err)
			}
		})
	}
}
