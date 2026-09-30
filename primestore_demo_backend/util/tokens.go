package util

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"github.com/golang-jwt/jwt/v5"
	"time"
)

const (
	audienceAccess      = "access"
	audienceEmailOTP    = "email-otp"
	audienceEmailChange = "email-change"
)

var ErrInvalidToken = errors.New("invalid token")

type UserClaims struct {
	UserID int64 `json:"user_id"`
	jwt.RegisteredClaims
}

type OTPClaims struct {
	UserID   int64  `json:"user_id"`
	OTPHash  string `json:"otp_hash"`
	NewEmail string `json:"new_email,omitempty"` // only set on email-change tokens
	jwt.RegisteredClaims
}

type TokenMaker struct {
	secretKey string
}

func NewTokenMaker(secretKey string) *TokenMaker {
	return &TokenMaker{secretKey: secretKey}
}

func (maker *TokenMaker) CreateToken(userID int64, duration time.Duration) (string, error) {
	claims := UserClaims{
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(duration)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Audience:  jwt.ClaimStrings{audienceAccess},
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(maker.secretKey))
}

func (maker *TokenMaker) VerifyToken(tokenStr string) (*UserClaims, error) {
	claims := &UserClaims{}
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return []byte(maker.secretKey), nil
	}, jwt.WithAudience(audienceAccess))
	if err != nil || !token.Valid {
		return nil, ErrInvalidToken
	}
	return claims, nil
}

func (maker *TokenMaker) CreateOTPToken(userID int64, otp string, duration time.Duration) (string, error) {
	claims := OTPClaims{
		UserID:  userID,
		OTPHash: maker.hashOTP(userID, otp),
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(duration)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Audience:  jwt.ClaimStrings{audienceEmailOTP},
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(maker.secretKey))
}

func (maker *TokenMaker) VerifyOTPToken(tokenStr string) (*OTPClaims, error) {
	claims := &OTPClaims{}
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return []byte(maker.secretKey), nil
	}, jwt.WithAudience(audienceEmailOTP))
	if err != nil || !token.Valid {
		return nil, ErrInvalidToken
	}
	return claims, nil
}

// CreateEmailChangeToken is the email-change counterpart to CreateOTPToken:
// same OTP-hash mechanism (so hashOTP/OTPMatches are reused as-is), but
// tagged with a different audience so an email-change code can't be replayed
// against the signup-verification endpoint or vice versa. It also carries
// the new email address, since that's what the confirm step needs to apply.
func (maker *TokenMaker) CreateEmailChangeToken(userID int64, newEmail string, otp string, duration time.Duration) (string, error) {
	claims := OTPClaims{
		UserID:   userID,
		OTPHash:  maker.hashOTP(userID, otp),
		NewEmail: newEmail,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(duration)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Audience:  jwt.ClaimStrings{audienceEmailChange},
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(maker.secretKey))
}

func (maker *TokenMaker) VerifyEmailChangeToken(tokenStr string) (*OTPClaims, error) {
	claims := &OTPClaims{}
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return []byte(maker.secretKey), nil
	}, jwt.WithAudience(audienceEmailChange))
	if err != nil || !token.Valid {
		return nil, ErrInvalidToken
	}
	return claims, nil
}

func GenerateRefreshToken() (string, error) {
	bytes := make([]byte, 32)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return hex.EncodeToString(bytes), nil
}

func (maker *TokenMaker) hashOTP(userID int64, otp string) string {
	mac := hmac.New(sha256.New, []byte(maker.secretKey))
	fmt.Fprintf(mac, "%d:%s", userID, otp)
	return hex.EncodeToString(mac.Sum(nil))
}

func (maker *TokenMaker) OTPMatches(claims *OTPClaims, otp string) bool {
	expected := maker.hashOTP(claims.UserID, otp)
	return hmac.Equal([]byte(expected), []byte(claims.OTPHash))
}