package domain

import "testing"

func TestStatusTransitions(t *testing.T) {
	tests := []struct {
		name string
		from Status
		to   Status
		want bool
	}{
		{name: "placed to placed", from: StatusPlaced, to: StatusPlaced},
		{name: "placed to cancelled", from: StatusPlaced, to: StatusCancelled, want: true},
		{name: "placed to fulfilled", from: StatusPlaced, to: StatusFulfilled, want: true},
		{name: "cancelled to placed", from: StatusCancelled, to: StatusPlaced},
		{name: "cancelled to cancelled", from: StatusCancelled, to: StatusCancelled},
		{name: "cancelled to fulfilled", from: StatusCancelled, to: StatusFulfilled},
		{name: "fulfilled to placed", from: StatusFulfilled, to: StatusPlaced},
		{name: "fulfilled to cancelled", from: StatusFulfilled, to: StatusCancelled},
		{name: "fulfilled to fulfilled", from: StatusFulfilled, to: StatusFulfilled},
		{name: "shipped to fulfilled", from: Status("shipped"), to: StatusFulfilled},
		{name: "placed to shipped", from: StatusPlaced, to: Status("shipped")},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := tt.from.CanTransitionTo(tt.to); got != tt.want {
				t.Errorf("%q.CanTransitionTo(%q) = %t, want %t", tt.from, tt.to, got, tt.want)
			}
		})
	}
}

func TestStatusValid(t *testing.T) {
	tests := []struct {
		name   string
		status Status
		want   bool
	}{
		{name: "placed", status: StatusPlaced, want: true},
		{name: "cancelled", status: StatusCancelled, want: true},
		{name: "fulfilled", status: StatusFulfilled, want: true},
		{name: "empty", status: ""},
		{name: "shipped", status: Status("shipped")},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := tt.status.Valid(); got != tt.want {
				t.Errorf("%q.Valid() = %t, want %t", tt.status, got, tt.want)
			}
		})
	}
}

func TestTransitionTargetsAreValid(t *testing.T) {
	for from, targets := range transitions {
		for _, target := range targets {
			if !target.Valid() {
				t.Errorf("transition from %q targets invalid status %q", from, target)
			}
		}
	}
}
