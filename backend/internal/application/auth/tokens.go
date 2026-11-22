package auth

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

const issuer = "ctrlhub"

type Claims struct {
	Role     string `json:"role"`
	TenantID string `json:"tid,omitempty"`
	jwt.RegisteredClaims
}

type TokenIssuer struct {
	secret []byte
	ttl    time.Duration
}

func NewTokenIssuer(secret string, ttl time.Duration) *TokenIssuer {
	return &TokenIssuer{secret: []byte(secret), ttl: ttl}
}

func (t *TokenIssuer) Issue(p domain.Principal, now time.Time) (string, error) {
	c := Claims{
		Role:     string(p.Role),
		TenantID: p.TenantID,
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   p.UserID,
			Issuer:    issuer,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(t.ttl)),
		},
	}
	return jwt.NewWithClaims(jwt.SigningMethodHS256, c).SignedString(t.secret)
}

// Parse validates the signature and expiry and returns the user id.
func (t *TokenIssuer) Parse(token string) (string, error) {
	var c Claims
	_, err := jwt.ParseWithClaims(token, &c, func(*jwt.Token) (any, error) { return t.secret, nil },
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}), jwt.WithIssuer(issuer), jwt.WithExpirationRequired())
	if err != nil {
		return "", domain.ErrUnauthorized
	}
	if c.Subject == "" {
		return "", domain.ErrUnauthorized
	}
	return c.Subject, nil
}

// RandomToken returns a URL-safe random secret and its SHA-256 hex hash.
func RandomToken() (plain, hash string, err error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", "", err
	}
	plain = base64.RawURLEncoding.EncodeToString(b)
	return plain, HashToken(plain), nil
}

func HashToken(plain string) string {
	sum := sha256.Sum256([]byte(plain))
	return hex.EncodeToString(sum[:])
}

const bcryptCost = 12

func HashPassword(pw string) (string, error) {
	if err := ValidatePassword(pw); err != nil {
		return "", err
	}
	h, err := bcrypt.GenerateFromPassword([]byte(pw), bcryptCost)
	return string(h), err
}

func ValidatePassword(pw string) error {
	if len(pw) < 8 {
		return domain.InvalidField("password", "must be at least 8 characters")
	}
	if len(pw) > 72 {
		return domain.InvalidField("password", "must be at most 72 bytes")
	}
	return nil
}

// dummyHash is compared against when a user does not exist so login timing
// does not reveal which emails are registered.
var dummyHash, _ = bcrypt.GenerateFromPassword([]byte("timing-equalizer-password"), bcryptCost)

func checkPassword(hash, pw string) bool {
	if hash == "" {
		_ = bcrypt.CompareHashAndPassword(dummyHash, []byte(pw))
		return false
	}
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(pw)) == nil
}

var errInvalidCredentials = errors.New("invalid email or password")
