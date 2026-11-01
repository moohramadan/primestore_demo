package api

import (
	"errors"
	"testing"
)

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
		{
			name:     "uppercase hex is rejected",
			path:     "products/12/0123456789ABCDEF0123456789ABCDEF.jpg",
			sellerID: 12,
		},
		{
			name:     "33 character key is rejected",
			path:     "products/12/0123456789abcdef0123456789abcdef0.jpg",
			sellerID: 12,
		},
		{
			name:     "seller 1 cannot use seller 12 prefix",
			path:     "products/12/0123456789abcdef0123456789abcdef.jpg",
			sellerID: 1,
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

func TestParseMoney(t *testing.T) {
	tests := []struct {
		input  string
		want   int64
		wantOK bool
	}{
		{input: "1500", want: 150000, wantOK: true},
		{input: "1500.5", want: 150050, wantOK: true},
		{input: "1500.55", want: 150055, wantOK: true},
		{input: "0.01", want: 1, wantOK: true},
		{input: "  12  ", want: 1200, wantOK: true},
		{input: "12345678.99", want: 1234567899, wantOK: true},
		{input: "1500.555"},
		{input: "123456789"}, // 9 whole digits is one too many
		{input: "-5"},
		{input: ".5"},
		{input: "1."},
		{input: "abc"},
		{input: ""},
	}

	for _, test := range tests {
		t.Run(test.input, func(t *testing.T) {
			got, ok := parseMoney(test.input)
			if ok != test.wantOK || got != test.want {
				t.Errorf("parseMoney(%q) = (%d, %t), want (%d, %t)", test.input, got, ok, test.want, test.wantOK)
			}
		})
	}
}

func TestPercentOff(t *testing.T) {
	tests := []struct {
		name     string
		original int64
		sale     int64
		want     int32
	}{
		{name: "sale equals original", original: 150000, sale: 150000, want: 0},
		{name: "one cent off rounds to zero", original: 150000, sale: 149999, want: 0},
		{name: "1299 off 1500 is 13.4 percent", original: 150000, sale: 129900, want: 13},
		{name: "exactly twenty percent rounds half up", original: 150000, sale: 120000, want: 20},
		{name: "half rounds up", original: 200, sale: 199, want: 1},
		{name: "almost free", original: 150000, sale: 1, want: 100},
		{name: "zero original is safe", original: 0, sale: 0, want: 0},
		{name: "sale above original is safe", original: 100, sale: 200, want: 0},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := percentOff(test.original, test.sale); got != test.want {
				t.Errorf("percentOff(%d, %d) = %d, want %d", test.original, test.sale, got, test.want)
			}
		})
	}
}

func TestParsePrices(t *testing.T) {
	tests := []struct {
		name         string
		original     string
		sale         string
		want         priceInput
		wantErr      error
		wantDiscount int32
	}{
		{name: "no sale", original: "1500", want: priceInput{Original: 150000}},
		{name: "blank sale means no sale", original: "1500", sale: "   ", want: priceInput{Original: 150000}},
		{
			name:         "valid sale",
			original:     "1500",
			sale:         "1299",
			want:         priceInput{Original: 150000, Sale: 129900, HasSale: true},
			wantDiscount: 13,
		},
		{
			name:     "sale equal to original is allowed",
			original: "1500",
			sale:     "1500",
			want:     priceInput{Original: 150000, Sale: 150000, HasSale: true},
		},
		{name: "sale above original", original: "1500", sale: "1600", wantErr: errSaleAbovePrice},
		{name: "zero sale", original: "1500", sale: "0", wantErr: errInvalidSalePrice},
		{name: "bad sale", original: "1500", sale: "abc", wantErr: errInvalidSalePrice},
		{name: "zero original", original: "0", wantErr: errInvalidPrice},
		{name: "empty original", original: "", wantErr: errInvalidPrice},
		{name: "too many decimals", original: "1500.555", wantErr: errInvalidPrice},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := parsePrices(test.original, test.sale)
			if !errors.Is(err, test.wantErr) {
				t.Fatalf("parsePrices(%q, %q) error = %v, want %v", test.original, test.sale, err, test.wantErr)
			}
			if err != nil {
				return
			}
			if got != test.want {
				t.Errorf("parsePrices(%q, %q) = %+v, want %+v", test.original, test.sale, got, test.want)
			}
			if got.DiscountPercent() != test.wantDiscount {
				t.Errorf("DiscountPercent() = %d, want %d", got.DiscountPercent(), test.wantDiscount)
			}
		})
	}
}
