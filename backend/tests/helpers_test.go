//go:build integration

// Integration tests run the full HTTP stack against a real MySQL database.
// Run with: TEST_MYSQL_DSN='root:pw@tcp(127.0.0.1:3306)/' go test -tags integration ./tests/...
package tests

import (
	"bytes"
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/go-sql-driver/mysql"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/app"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/config"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/infrastructure/database"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/infrastructure/mockwhatsapp"
)

const (
	adminEmail    = "platform@test.local"
	adminPassword = "platform-pass-123"
	automationKey = "test-automation-key-0123456789"
)

type env struct {
	t        *testing.T
	srv      *httptest.Server
	db       *sql.DB
	provider *mockwhatsapp.Provider
}

func randHex(n int) string {
	b := make([]byte, n)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

// setup creates a throwaway database, migrates it and starts the API.
func setup(t *testing.T) *env {
	t.Helper()
	base := os.Getenv("TEST_MYSQL_DSN")
	if base == "" {
		t.Skip("TEST_MYSQL_DSN not set")
	}
	cfg, err := mysql.ParseDSN(base)
	if err != nil {
		t.Fatal(err)
	}
	dbName := "ctrlhub_test_" + randHex(4)
	root, err := sql.Open("mysql", cfg.FormatDSN())
	if err != nil {
		t.Fatal(err)
	}
	if _, err := root.Exec("CREATE DATABASE " + dbName); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		_, _ = root.Exec("DROP DATABASE " + dbName)
		root.Close()
	})
	cfg.DBName = dbName
	dsn := cfg.FormatDSN()
	if err := database.Migrate(dsn); err != nil {
		t.Fatal(err)
	}
	db, err := database.Open(context.Background(), dsn)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { db.Close() })

	c := config.Config{
		DatabaseDSN: dsn, JWTSecret: strings.Repeat("s", 40), AccessTokenTTL: 15 * time.Minute,
		RefreshTokenTTL: time.Hour, SetupTokenTTL: time.Hour, AppBaseURL: "http://web.test",
		PlatformAdminEmail: adminEmail, PlatformAdminPassword: adminPassword, PlatformAdminName: "Root",
		AutomationAPIKey: automationKey, MessagingProvider: "mock", DefaultCountryCode: "91", LoginRatePerMinute: 1000,
	}
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	provider := mockwhatsapp.New(0)
	a := app.New(c, db, provider, log)
	if err := a.Seed(context.Background(), c); err != nil {
		t.Fatal(err)
	}
	srv := httptest.NewServer(a.Handler)
	t.Cleanup(srv.Close)
	return &env{t: t, srv: srv, db: db, provider: provider}
}

type resp struct {
	Status int
	Body   []byte
}

func (r resp) json(t *testing.T, v any) {
	t.Helper()
	if err := json.Unmarshal(r.Body, v); err != nil {
		t.Fatalf("decode %s: %v", r.Body, err)
	}
}

func (r resp) m(t *testing.T) map[string]any {
	var v map[string]any
	r.json(t, &v)
	return v
}

func (e *env) do(method, path, token string, body any, headers ...string) resp {
	e.t.Helper()
	var rdr io.Reader
	if body != nil {
		b, _ := json.Marshal(body)
		rdr = bytes.NewReader(b)
	}
	req, _ := http.NewRequest(method, e.srv.URL+path, rdr)
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	for i := 0; i+1 < len(headers); i += 2 {
		req.Header.Set(headers[i], headers[i+1])
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		e.t.Fatal(err)
	}
	defer res.Body.Close()
	b, _ := io.ReadAll(res.Body)
	return resp{Status: res.StatusCode, Body: b}
}

func (e *env) expect(r resp, status int) resp {
	e.t.Helper()
	if r.Status != status {
		e.t.Fatalf("expected HTTP %d, got %d: %s", status, r.Status, r.Body)
	}
	return r
}

func (e *env) auto(method, path string, body any) resp {
	return e.do(method, path, "", body, "X-Automation-Key", automationKey)
}

type session struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	User         struct {
		ID          string   `json:"id"`
		Role        string   `json:"role"`
		Dashboard   string   `json:"dashboard"`
		TenantID    string   `json:"tenant_id"`
		TenantCode  string   `json:"tenant_code"`
		Permissions []string `json:"permissions"`
	} `json:"user"`
}

func (e *env) login(email, password string) session {
	e.t.Helper()
	var s session
	e.expect(e.do("POST", "/api/v1/auth/login", "", map[string]string{"email": email, "password": password}), 200).json(e.t, &s)
	return s
}

func (e *env) platform() session { return e.login(adminEmail, adminPassword) }

type gym struct {
	ID, Code    string
	AdminToken  string
	AdminUserID string
}

// onboard creates a gym through the platform API and completes the admin's
// password setup link, then logs the admin in.
func (e *env) onboard(platformToken, name, adminMail string) gym {
	e.t.Helper()
	r := e.expect(e.do("POST", "/api/v1/platform/tenants", platformToken, map[string]any{
		"gym": map[string]any{"name": name, "owner_name": "Owner " + name, "contact_number": "9876543210",
			"email": strings.ToLower(strings.ReplaceAll(name, " ", "")) + "@gym.test", "city": "Kochi",
			"state": "Kerala", "country": "India", "timezone": "Asia/Kolkata",
			"opening_hours": map[string]string{"mon-sat": "05:00-22:00"}},
		"admin": map[string]any{"name": "Admin " + name, "email": adminMail, "phone": "9000000001"},
	}), 201)
	var out struct {
		Tenant   struct{ ID, Code string }
		Admin    struct{ ID string }
		SetupURL string `json:"setup_url"`
	}
	r.json(e.t, &out)
	u, _ := url.Parse(out.SetupURL)
	e.expect(e.do("POST", "/api/v1/auth/setup-password", "", map[string]string{
		"token": u.Query().Get("token"), "password": "gym-admin-pass-1"}), 200)
	s := e.login(adminMail, "gym-admin-pass-1")
	return gym{ID: out.Tenant.ID, Code: out.Tenant.Code, AdminToken: s.AccessToken, AdminUserID: out.Admin.ID}
}

// addUser creates a staff account with a direct password and logs it in.
func (e *env) addUser(adminToken, role, email string) session {
	e.t.Helper()
	e.expect(e.do("POST", "/api/v1/gym/users", adminToken, map[string]any{
		"name": role + " user", "email": email, "role": role, "password": "staff-pass-123"}), 201)
	return e.login(email, "staff-pass-123")
}

func (e *env) createMember(token, name, phone string, optIn bool, dob string) string {
	e.t.Helper()
	body := map[string]any{"full_name": name, "phone": phone, "whatsapp_opt_in": optIn, "marketing_opt_in": optIn}
	if dob != "" {
		body["date_of_birth"] = dob
	}
	r := e.expect(e.do("POST", "/api/v1/gym/members", token, body), 201)
	return r.m(e.t)["id"].(string)
}

func (e *env) createPlan(token, name string, days int, price int64) string {
	e.t.Helper()
	body := map[string]any{"name": name, "duration_type": "MONTHLY", "price_minor": price}
	if days > 0 {
		body["duration_type"], body["duration_days"] = "CUSTOM", days
	}
	return e.expect(e.do("POST", "/api/v1/gym/plans", token, body), 201).m(e.t)["id"].(string)
}

func (e *env) assign(token, memberID, planID string, extra map[string]any) map[string]any {
	e.t.Helper()
	body := map[string]any{"member_id": memberID, "plan_id": planID}
	for k, v := range extra {
		body[k] = v
	}
	return e.expect(e.do("POST", "/api/v1/gym/memberships", token, body), 201).m(e.t)
}

func todayIST() time.Time {
	loc, _ := time.LoadLocation("Asia/Kolkata")
	n := time.Now().In(loc)
	return time.Date(n.Year(), n.Month(), n.Day(), 0, 0, 0, 0, time.UTC)
}

func ymd(t time.Time) string { return t.Format("2006-01-02") }

func must(t *testing.T, cond bool, format string, args ...any) {
	t.Helper()
	if !cond {
		t.Fatalf(format, args...)
	}
}

var _ = fmt.Sprintf
