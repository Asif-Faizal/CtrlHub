package config

import (
	"errors"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	Env      string
	HTTPAddr string

	DatabaseDSN string

	JWTSecret       string
	AccessTokenTTL  time.Duration
	RefreshTokenTTL time.Duration
	SetupTokenTTL   time.Duration

	// AppBaseURL is used to build password setup links (web dashboard URL).
	AppBaseURL     string
	AllowedOrigins []string

	PlatformAdminEmail    string
	PlatformAdminPassword string
	PlatformAdminName     string

	AutomationAPIKey string

	MessagingProvider  string // "mock" or "waha"
	WAHABaseURL        string
	WAHAAPIKey         string
	DefaultCountryCode string

	LoginRatePerMinute int
}

func Load() (Config, error) {
	c := Config{
		Env:                   getenv("APP_ENV", "development"),
		HTTPAddr:              getenv("HTTP_ADDR", ":8080"),
		DatabaseDSN:           os.Getenv("DATABASE_DSN"),
		JWTSecret:             os.Getenv("JWT_SECRET"),
		AccessTokenTTL:        getduration("ACCESS_TOKEN_TTL", 15*time.Minute),
		RefreshTokenTTL:       getduration("REFRESH_TOKEN_TTL", 30*24*time.Hour),
		SetupTokenTTL:         getduration("SETUP_TOKEN_TTL", 48*time.Hour),
		AppBaseURL:            strings.TrimRight(getenv("APP_BASE_URL", "http://localhost:8081"), "/"),
		AllowedOrigins:        splitCSV(getenv("CORS_ALLOWED_ORIGINS", "http://localhost:5173,http://localhost:8081")),
		PlatformAdminEmail:    os.Getenv("PLATFORM_ADMIN_EMAIL"),
		PlatformAdminPassword: os.Getenv("PLATFORM_ADMIN_PASSWORD"),
		PlatformAdminName:     getenv("PLATFORM_ADMIN_NAME", "Platform Admin"),
		AutomationAPIKey:      os.Getenv("AUTOMATION_API_KEY"),
		MessagingProvider:     strings.ToLower(getenv("MESSAGING_PROVIDER", "mock")),
		WAHABaseURL:           strings.TrimRight(getenv("WAHA_BASE_URL", "http://waha:3000"), "/"),
		WAHAAPIKey:            os.Getenv("WAHA_API_KEY"),
		DefaultCountryCode:    getenv("DEFAULT_COUNTRY_CODE", "91"),
		LoginRatePerMinute:    getint("LOGIN_RATE_PER_MINUTE", 10),
	}
	return c, c.validate()
}

func (c Config) validate() error {
	var errs []error
	if c.DatabaseDSN == "" {
		errs = append(errs, errors.New("DATABASE_DSN is required"))
	}
	if len(c.JWTSecret) < 32 {
		errs = append(errs, errors.New("JWT_SECRET must be at least 32 characters"))
	}
	if len(c.AutomationAPIKey) < 24 {
		errs = append(errs, errors.New("AUTOMATION_API_KEY must be at least 24 characters"))
	}
	switch c.MessagingProvider {
	case "mock":
	case "waha":
		if c.WAHAAPIKey == "" {
			errs = append(errs, errors.New("WAHA_API_KEY is required when MESSAGING_PROVIDER=waha"))
		}
	default:
		errs = append(errs, fmt.Errorf("MESSAGING_PROVIDER must be mock or waha, got %q", c.MessagingProvider))
	}
	return errors.Join(errs...)
}

func getenv(key, def string) string {
	if v, ok := os.LookupEnv(key); ok && v != "" {
		return v
	}
	return def
}

func getint(key string, def int) int {
	if v, err := strconv.Atoi(os.Getenv(key)); err == nil {
		return v
	}
	return def
}

func getduration(key string, def time.Duration) time.Duration {
	if v, err := time.ParseDuration(os.Getenv(key)); err == nil {
		return v
	}
	return def
}

func splitCSV(s string) []string {
	var out []string
	for _, p := range strings.Split(s, ",") {
		if p = strings.TrimSpace(p); p != "" {
			out = append(out, p)
		}
	}
	return out
}
