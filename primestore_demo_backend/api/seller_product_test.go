package api

import "testing"

func TestIsSellerImagePath(t *testing.T) {
	tests := []struct {
		name     string
		path     string
		sellerID int32
		want     bool
	}{
		{
			name:     "valid jpeg",
			path:     "products/12/0123456789abcdef0123456789abcdef.jpg",
			sellerID: 12,
			want:     true,
		},
		{
			name:     "valid webp",
			path:     "products/12/0123456789abcdef0123456789abcdef.webp",
			sellerID: 12,
			want:     true,
		},
		{
			name:     "different seller",
			path:     "products/13/0123456789abcdef0123456789abcdef.jpg",
			sellerID: 12,
		},
		{
			name:     "invalid extension",
			path:     "products/12/0123456789abcdef0123456789abcdef.gif",
			sellerID: 12,
		},
		{
			name:     "invalid key",
			path:     "products/12/0123456789abcdef.jpg",
			sellerID: 12,
		},
		{
			name:     "nested filename",
			path:     "products/12/nested/0123456789abcdef0123456789abcdef.jpg",
			sellerID: 12,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := isSellerImagePath(test.path, test.sellerID); got != test.want {
				t.Errorf("isSellerImagePath(%q, %d) = %t, want %t", test.path, test.sellerID, got, test.want)
			}
		})
	}
}
