package util

import (
	"context"
	"errors"

	"google.golang.org/api/idtoken"
)

// GoogleClaims holds the fields we need out of a verified Google ID token.
type GoogleClaims struct {
	Subject       string // Google's stable per-user ID ("sub" claim)
	Email         string
	EmailVerified bool
	Name          string
}

// VerifyGoogleIDToken validates the signature, issuer, expiry and audience of
// a Google-issued ID token and returns the claims we care about.
//
// audience must match the OAuth client ID the token was issued for. Pass the
// Web application client ID here (see Part 1) — the same value the Flutter
// app uses as serverClientId — so both Android and iOS tokens verify the
// same way.
func VerifyGoogleIDToken(ctx context.Context, rawIDToken, audience string) (*GoogleClaims, error) {
	if audience == "" {
		return nil, errors.New("google client id (audience) is not configured")
	}

	payload, err := idtoken.Validate(ctx, rawIDToken, audience)
	if err != nil {
		return nil, err
	}

	sub, _ := payload.Claims["sub"].(string)
	email, _ := payload.Claims["email"].(string)
	emailVerified, _ := payload.Claims["email_verified"].(bool)
	name, _ := payload.Claims["name"].(string)

	if sub == "" || email == "" {
		return nil, errors.New("google token missing required claims")
	}

	return &GoogleClaims{
		Subject:       sub,
		Email:         email,
		EmailVerified: emailVerified,
		Name:          name,
	}, nil
}
