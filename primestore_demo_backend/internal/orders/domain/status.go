package domain

// Status is the order status. These values must match the CHECK constraint on
// orders.status in migration 000014.
type Status string

const (
	StatusPlaced    Status = "placed"
	StatusCancelled Status = "cancelled"
	StatusFulfilled Status = "fulfilled"
)

var transitions = map[Status][]Status{
	StatusPlaced:    {StatusCancelled, StatusFulfilled},
	StatusCancelled: {},
	StatusFulfilled: {},
}

// CanTransitionTo reports whether s may transition to next.
func (s Status) CanTransitionTo(next Status) bool {
	for _, allowed := range transitions[s] {
		if next == allowed {
			return true
		}
	}
	return false
}

// Valid reports whether s is a recognized order status.
func (s Status) Valid() bool {
	_, ok := transitions[s]
	return ok
}
