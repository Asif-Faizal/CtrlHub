package waha

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/messaging"
)

// fakeWAHA mimics the documented WAHA endpoints used by the adapter.
type fakeWAHA struct {
	mu       sync.Mutex
	sessions map[string]string // name -> status
	calls    []string
	lastSend map[string]string
}

func newFake() *fakeWAHA { return &fakeWAHA{sessions: map[string]string{}} }

func (f *fakeWAHA) handler(t *testing.T) http.Handler {
	mux := http.NewServeMux()
	auth := func(next http.HandlerFunc) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			if r.Header.Get("X-Api-Key") != "secret" {
				w.WriteHeader(http.StatusUnauthorized)
				_, _ = w.Write([]byte(`{"message":"Unauthorized","statusCode":401}`))
				return
			}
			f.mu.Lock()
			f.calls = append(f.calls, r.Method+" "+r.URL.Path)
			f.mu.Unlock()
			next(w, r)
		}
	}
	mux.HandleFunc("GET /api/sessions/{name}", auth(func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		st, ok := f.sessions[r.PathValue("name")]
		if !ok {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		resp := map[string]any{"name": r.PathValue("name"), "status": st, "me": nil}
		if st == "WORKING" {
			resp["me"] = map[string]string{"id": "919876543210@c.us", "pushName": "Gym"}
		}
		_ = json.NewEncoder(w).Encode(resp)
	}))
	mux.HandleFunc("POST /api/sessions", auth(func(w http.ResponseWriter, r *http.Request) {
		var body struct {
			Name  string `json:"name"`
			Start bool   `json:"start"`
		}
		_ = json.NewDecoder(r.Body).Decode(&body)
		if !body.Start {
			t.Error("session should be created with start=true")
		}
		f.mu.Lock()
		f.sessions[body.Name] = "STARTING"
		f.mu.Unlock()
		w.WriteHeader(http.StatusCreated)
		_ = json.NewEncoder(w).Encode(map[string]any{"name": body.Name, "status": "STARTING", "me": nil})
	}))
	mux.HandleFunc("POST /api/sessions/{name}/start", auth(func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		f.sessions[r.PathValue("name")] = "SCAN_QR_CODE"
		f.mu.Unlock()
		_, _ = w.Write([]byte(`{}`))
	}))
	mux.HandleFunc("DELETE /api/sessions/{name}", auth(func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		delete(f.sessions, r.PathValue("name"))
		f.mu.Unlock()
		_, _ = w.Write([]byte(`{}`))
	}))
	mux.HandleFunc("GET /api/{session}/auth/qr", auth(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Accept") != "application/json" || r.URL.Query().Get("format") != "image" {
			t.Errorf("qr must request base64 json image, got accept=%q format=%q", r.Header.Get("Accept"), r.URL.Query().Get("format"))
		}
		_, _ = w.Write([]byte(`{"mimetype":"image/png","data":"aGVsbG8="}`))
	}))
	mux.HandleFunc("POST /api/sendText", auth(func(w http.ResponseWriter, r *http.Request) {
		var body map[string]string
		_ = json.NewDecoder(r.Body).Decode(&body)
		f.mu.Lock()
		f.lastSend = body
		f.mu.Unlock()
		_, _ = w.Write([]byte(`{"id":{"fromMe":true,"_serialized":"true_919876543210@c.us_ABC"}}`))
	}))
	return mux
}

func TestClientLifecycle(t *testing.T) {
	f := newFake()
	srv := httptest.NewServer(f.handler(t))
	defer srv.Close()
	c := New(srv.URL, "secret")
	ctx := context.Background()

	if _, err := c.SessionStatus(ctx, "gym_001"); err != messaging.ErrSessionNotFound {
		t.Fatalf("expected ErrSessionNotFound, got %v", err)
	}
	info, err := c.StartSession(ctx, "gym_001")
	if err != nil || info.Status != "STARTING" {
		t.Fatalf("start: %+v %v", info, err)
	}

	f.mu.Lock()
	f.sessions["gym_001"] = "STOPPED"
	f.mu.Unlock()
	info, err = c.StartSession(ctx, "gym_001")
	if err != nil || info.Status != "SCAN_QR_CODE" {
		t.Fatalf("restart stopped: %+v %v", info, err)
	}

	qr, err := c.QRCode(ctx, "gym_001")
	if err != nil || qr.Mimetype != "image/png" || qr.Data != "aGVsbG8=" {
		t.Fatalf("qr: %+v %v", qr, err)
	}

	f.mu.Lock()
	f.sessions["gym_001"] = "WORKING"
	f.mu.Unlock()
	info, err = c.SessionStatus(ctx, "gym_001")
	if err != nil || info.Status != "WORKING" || info.Phone != "919876543210" {
		t.Fatalf("status: %+v %v", info, err)
	}

	id, err := c.SendText(ctx, "gym_001", "919800000000", "hello")
	if err != nil || id != "true_919876543210@c.us_ABC" {
		t.Fatalf("send: %q %v", id, err)
	}
	if f.lastSend["chatId"] != "919800000000@c.us" || f.lastSend["session"] != "gym_001" || f.lastSend["text"] != "hello" {
		t.Errorf("sendText body = %v", f.lastSend)
	}

	if err := c.Disconnect(ctx, "gym_001"); err != nil {
		t.Fatal(err)
	}
	if err := c.Disconnect(ctx, "gym_001"); err != nil {
		t.Fatalf("disconnect should be idempotent: %v", err)
	}
}

func TestClientRejectsWrongKey(t *testing.T) {
	f := newFake()
	srv := httptest.NewServer(f.handler(t))
	defer srv.Close()
	_, err := New(srv.URL, "wrong").SessionStatus(context.Background(), "x")
	if _, ok := err.(*apiError); !ok {
		t.Fatalf("expected apiError for 401, got %v", err)
	}
}

func TestParseMessageID(t *testing.T) {
	if parseMessageID(json.RawMessage(`"abc"`)) != "abc" {
		t.Error("string id")
	}
	if parseMessageID(json.RawMessage(`{"_serialized":"x"}`)) != "x" {
		t.Error("object id")
	}
	if parseMessageID(nil) != "" {
		t.Error("empty id")
	}
}
