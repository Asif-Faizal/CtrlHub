// Package waha implements messaging.Provider against the WAHA HTTP API
// (https://waha.devlike.pro). Endpoints used:
//
//	GET    /api/sessions/{session}
//	POST   /api/sessions                    {"name": ..., "start": true}
//	POST   /api/sessions/{session}/start
//	POST   /api/sessions/{session}/restart
//	DELETE /api/sessions/{session}          (logs out and removes the session)
//	GET    /api/{session}/auth/qr?format=image  with Accept: application/json
//	POST   /api/sendText                    {"session", "chatId", "text"}
//
// All requests carry the X-Api-Key header.
package waha

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/messaging"
)

type Client struct {
	baseURL string
	apiKey  string
	http    *http.Client
}

func New(baseURL, apiKey string) *Client {
	return &Client{
		baseURL: strings.TrimRight(baseURL, "/"),
		apiKey:  apiKey,
		http:    &http.Client{Timeout: 30 * time.Second},
	}
}

func (c *Client) Name() string { return "waha" }

type apiError struct {
	Status int
	Body   string
}

func (e *apiError) Error() string { return fmt.Sprintf("waha: HTTP %d: %s", e.Status, e.Body) }

func (c *Client) do(ctx context.Context, method, path string, body any, out any) error {
	var rdr io.Reader
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			return err
		}
		rdr = bytes.NewReader(b)
	}
	req, err := http.NewRequestWithContext(ctx, method, c.baseURL+path, rdr)
	if err != nil {
		return err
	}
	req.Header.Set("X-Api-Key", c.apiKey)
	req.Header.Set("Accept", "application/json")
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := c.http.Do(req)
	if err != nil {
		return fmt.Errorf("waha: %w", err)
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(io.LimitReader(resp.Body, 4<<20))
	if resp.StatusCode == http.StatusNotFound {
		return messaging.ErrSessionNotFound
	}
	if resp.StatusCode >= 300 {
		msg := string(data)
		if len(msg) > 300 {
			msg = msg[:300]
		}
		return &apiError{Status: resp.StatusCode, Body: msg}
	}
	if out != nil && len(data) > 0 {
		if err := json.Unmarshal(data, out); err != nil {
			return fmt.Errorf("waha: decode %s %s: %w", method, path, err)
		}
	}
	return nil
}

type sessionDTO struct {
	Name   string `json:"name"`
	Status string `json:"status"`
	Me     *struct {
		ID       string `json:"id"`
		PushName string `json:"pushName"`
	} `json:"me"`
}

func (s sessionDTO) info() messaging.SessionInfo {
	info := messaging.SessionInfo{Status: s.Status}
	if s.Me != nil {
		info.Phone = strings.SplitN(s.Me.ID, "@", 2)[0]
	}
	return info
}

func sessionPath(session string) string { return "/api/sessions/" + url.PathEscape(session) }

func (c *Client) SessionStatus(ctx context.Context, session string) (messaging.SessionInfo, error) {
	var s sessionDTO
	if err := c.do(ctx, http.MethodGet, sessionPath(session), nil, &s); err != nil {
		return messaging.SessionInfo{}, err
	}
	return s.info(), nil
}

func (c *Client) StartSession(ctx context.Context, session string) (messaging.SessionInfo, error) {
	cur, err := c.SessionStatus(ctx, session)
	if err == messaging.ErrSessionNotFound {
		var s sessionDTO
		if err := c.do(ctx, http.MethodPost, "/api/sessions", map[string]any{"name": session, "start": true}, &s); err != nil {
			return messaging.SessionInfo{}, err
		}
		return s.info(), nil
	}
	if err != nil {
		return messaging.SessionInfo{}, err
	}
	switch cur.Status {
	case "STOPPED":
		err = c.do(ctx, http.MethodPost, sessionPath(session)+"/start", nil, nil)
	case "FAILED":
		err = c.do(ctx, http.MethodPost, sessionPath(session)+"/restart", nil, nil)
	default:
		return cur, nil
	}
	if err != nil {
		return messaging.SessionInfo{}, err
	}
	return c.SessionStatus(ctx, session)
}

func (c *Client) QRCode(ctx context.Context, session string) (messaging.QRCode, error) {
	var qr messaging.QRCode
	err := c.do(ctx, http.MethodGet, "/api/"+url.PathEscape(session)+"/auth/qr?format=image", nil, &qr)
	return qr, err
}

func (c *Client) Disconnect(ctx context.Context, session string) error {
	err := c.do(ctx, http.MethodDelete, sessionPath(session), nil, nil)
	if err == messaging.ErrSessionNotFound {
		return nil
	}
	return err
}

func (c *Client) SendText(ctx context.Context, session, phone, text string) (string, error) {
	var resp struct {
		ID json.RawMessage `json:"id"`
	}
	err := c.do(ctx, http.MethodPost, "/api/sendText", map[string]string{
		"session": session,
		"chatId":  phone + "@c.us",
		"text":    text,
	}, &resp)
	if err != nil {
		return "", err
	}
	return parseMessageID(resp.ID), nil
}

// parseMessageID handles both engines' shapes: a plain string id or an object
// with a "_serialized" field.
func parseMessageID(raw json.RawMessage) string {
	if len(raw) == 0 {
		return ""
	}
	var s string
	if json.Unmarshal(raw, &s) == nil {
		return s
	}
	var obj struct {
		Serialized string `json:"_serialized"`
	}
	if json.Unmarshal(raw, &obj) == nil {
		return obj.Serialized
	}
	return ""
}
