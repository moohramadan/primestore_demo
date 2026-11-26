package domain

import (
	"bytes"
	"errors"
	"regexp"
	"strings"
	"testing"
	"time"
)

func TestOrderNumberAlphabet(t *testing.T) {
	if len(orderNumberAlphabet) != 32 {
		t.Fatalf("alphabet has %d symbols, want 32 (a power of two keeps the mapping unbiased)", len(orderNumberAlphabet))
	}
	for _, banned := range "0O1I" {
		if strings.ContainsRune(orderNumberAlphabet, banned) {
			t.Errorf("alphabet contains %q, which is easy to misread", banned)
		}
	}
	seen := map[rune]bool{}
	for _, r := range orderNumberAlphabet {
		if seen[r] {
			t.Errorf("alphabet repeats %q", r)
		}
		seen[r] = true
	}
}

func TestNewOrderNumberFormatAndValue(t *testing.T) {
	now := time.Date(2026, 11, 17, 10, 0, 0, 0, time.UTC)

	// Bytes 0..5 map to the first six symbols of the alphabet.
	got, err := NewOrderNumber(now, bytes.NewReader([]byte{0, 1, 2, 3, 4, 5}))
	if err != nil {
		t.Fatalf("NewOrderNumber() error = %v", err)
	}
	if got != "PS-20261117-ABCDEF" {
		t.Errorf("NewOrderNumber() = %q, want PS-20261117-ABCDEF", got)
	}

	// Any bytes give a valid number (bytes above 31 wrap around the alphabet).
	got, err = NewOrderNumber(now, bytes.NewReader([]byte{255, 254, 253, 100, 7, 33}))
	if err != nil {
		t.Fatalf("NewOrderNumber() error = %v", err)
	}
	if !regexp.MustCompile(`^PS-\d{8}-[A-HJ-NP-Z2-9]{6}$`).MatchString(got) {
		t.Errorf("NewOrderNumber() = %q, does not match the expected format", got)
	}
}

func TestNewOrderNumberUsesTheUTCDate(t *testing.T) {
	// 01:00 on 18 November in UTC+2 is still 17 November in UTC.
	local := time.Date(2026, 11, 18, 1, 0, 0, 0, time.FixedZone("UTC+2", 2*60*60))

	got, err := NewOrderNumber(local, bytes.NewReader(make([]byte, 6)))
	if err != nil {
		t.Fatalf("NewOrderNumber() error = %v", err)
	}
	if !strings.HasPrefix(got, "PS-20261117-") {
		t.Errorf("NewOrderNumber() = %q, want the UTC date 20261117", got)
	}
}

func TestNewOrderNumberRandomFailure(t *testing.T) {
	now := time.Date(2026, 11, 17, 10, 0, 0, 0, time.UTC)

	if _, err := NewOrderNumber(now, bytes.NewReader([]byte{1, 2})); err == nil {
		t.Error("a short random source should be an error")
	}

	boom := errors.New("entropy exhausted")
	if _, err := NewOrderNumber(now, errReader{boom}); !errors.Is(err, boom) {
		t.Errorf("NewOrderNumber() error = %v, want it to wrap %v", err, boom)
	}
}

type errReader struct{ err error }

func (r errReader) Read([]byte) (int, error) { return 0, r.err }
