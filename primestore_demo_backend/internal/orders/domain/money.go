package domain

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

// Money is an amount in cents. Never use float64 for money.
type Money int64

// ParseMoney turns "1500.00", "10.5" or "10" into cents.
func ParseMoney(s string) (Money, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, fmt.Errorf("invalid money %q: empty", s)
	}

	whole, frac, hasFrac := strings.Cut(s, ".")
	if !allDigits(whole) {
		return 0, fmt.Errorf("invalid money %q: bad whole part", s)
	}

	if hasFrac {
		if len(frac) == 0 || len(frac) > 2 || !allDigits(frac) {
			return 0, fmt.Errorf("invalid money %q: fraction must be 1 or 2 digits", s)
		}
		if len(frac) == 1 {
			frac += "0" // "10.5" means 50 cents, not 5
		}
	} else {
		frac = "00"
	}

	w, err := strconv.ParseInt(whole, 10, 64)
	if err != nil {
		return 0, fmt.Errorf("invalid money %q: %w", s, err)
	}
	f, err := strconv.ParseInt(frac, 10, 64)
	if err != nil {
		return 0, fmt.Errorf("invalid money %q: %w", s, err)
	}

	if w > (math.MaxInt64-99)/100 {
		return 0, fmt.Errorf("invalid money %q: too large", s)
	}
	return Money(w*100 + f), nil
}

// allDigits is true for a non-empty string made only of 0-9.
func allDigits(s string) bool {
	if s == "" {
		return false
	}
	for i := 0; i < len(s); i++ {
		if s[i] < '0' || s[i] > '9' {
			return false
		}
	}
	return true
}

// String formats cents as "1500.00".
func (m Money) String() string {
	sign := ""
	if m < 0 {
		sign = "-"
		m = -m
	}
	return fmt.Sprintf("%s%d.%02d", sign, m/100, m%100)
}

// Mul is the line total: unit price times quantity.
func (m Money) Mul(qty int32) Money { return m * Money(qty) }

// Add is used for subtotals.
func (m Money) Add(o Money) Money { return m + o }
