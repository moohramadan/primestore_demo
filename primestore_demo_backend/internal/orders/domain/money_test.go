package domain

import "testing"

func TestParseMoney(t *testing.T) {
	tests := []struct {
		name    string
		in      string
		want    Money
		wantErr bool
	}{
		{name: "whole and two decimal places", in: "1500.00", want: 150000},
		{name: "five cents", in: "0.05", want: 5},
		{name: "whole number", in: "10", want: 1000},
		{name: "one decimal place", in: "10.5", want: 1050},
		{name: "zero", in: "0", want: 0},
		{name: "too many decimal places", in: "1.234", wantErr: true},
		{name: "empty", in: "", wantErr: true},
		{name: "non-numeric", in: "abc", wantErr: true},
		{name: "multiple decimal points", in: "1.2.3", wantErr: true},
		{name: "negative amount", in: "-5.00", wantErr: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := ParseMoney(tt.in)
			if (err != nil) != tt.wantErr {
				t.Fatalf("ParseMoney(%q) error = %v, wantErr %t", tt.in, err, tt.wantErr)
			}
			if err == nil && got != tt.want {
				t.Errorf("ParseMoney(%q) = %d, want %d", tt.in, got, tt.want)
			}
		})
	}
}

func TestMoneyStringRoundTrip(t *testing.T) {
	inputs := []string{"1500.00", "0.05", "10", "10.5", "0"}

	for _, input := range inputs {
		t.Run(input, func(t *testing.T) {
			want, err := ParseMoney(input)
			if err != nil {
				t.Fatalf("ParseMoney(%q) error = %v", input, err)
			}

			got, err := ParseMoney(want.String())
			if err != nil {
				t.Fatalf("ParseMoney(%q) error = %v", want.String(), err)
			}
			if got != want {
				t.Errorf("ParseMoney(%q) = %d, want %d", want.String(), got, want)
			}
		})
	}
}
