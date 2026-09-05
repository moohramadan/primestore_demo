package util

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

var ErrInvalidToken = errors.New("invalid token")

type UserClaims struct {
	UserID int64 `json:"user_id"`
	jwt.RegisteredClaims
}

type OTPClaims struct {
	UserID int64  `json:"user_id"`
	OTP    string `json:"otp"`
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
	})
	if err != nil || !token.Valid {
		return nil, ErrInvalidToken
	}
	return claims, nil
}

func (maker *TokenMaker) CreateOTPToken(userID int64, otp string, duration time.Duration) (string, error) {
	claims := OTPClaims{
		UserID: userID,
		OTP:    otp,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(duration)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
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
	})
	if err != nil || !token.Valid {
		return nil, ErrInvalidToken
	}
	return claims, nil
}

