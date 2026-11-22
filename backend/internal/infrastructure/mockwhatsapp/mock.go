// Package mockwhatsapp is a MOCK messaging.Provider used when no WAHA
// credentials are configured (MESSAGING_PROVIDER=mock) and in tests.
// It never contacts WhatsApp: sessions become WORKING a few seconds after
// they are started and sent messages are only kept in memory.
package mockwhatsapp

import (
	"bytes"
	"context"
	"encoding/base64"
	"image"
	"image/color"
	"image/png"
	"sync"
	"time"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/messaging"
)

type SentMessage struct {
	Session string
	Phone   string
	Text    string
}

type session struct {
	startedAt time.Time
}

type Provider struct {
	mu        sync.Mutex
	sessions  map[string]*session
	sent      []SentMessage
	connectIn time.Duration
	now       func() time.Time
}

// New returns a mock provider whose sessions connect after connectIn.
func New(connectIn time.Duration) *Provider {
	return &Provider{sessions: map[string]*session{}, connectIn: connectIn, now: time.Now}
}

func (p *Provider) Name() string { return "mock" }

func (p *Provider) StartSession(_ context.Context, name string) (messaging.SessionInfo, error) {
	p.mu.Lock()
	defer p.mu.Unlock()
	if _, ok := p.sessions[name]; !ok {
		p.sessions[name] = &session{startedAt: p.now()}
	}
	return p.statusLocked(name), nil
}

func (p *Provider) SessionStatus(_ context.Context, name string) (messaging.SessionInfo, error) {
	p.mu.Lock()
	defer p.mu.Unlock()
	if _, ok := p.sessions[name]; !ok {
		return messaging.SessionInfo{}, messaging.ErrSessionNotFound
	}
	return p.statusLocked(name), nil
}

func (p *Provider) statusLocked(name string) messaging.SessionInfo {
	s := p.sessions[name]
	if p.now().Sub(s.startedAt) >= p.connectIn {
		return messaging.SessionInfo{Status: "WORKING", Phone: "910000000000"}
	}
	return messaging.SessionInfo{Status: "SCAN_QR_CODE"}
}

func (p *Provider) QRCode(_ context.Context, name string) (messaging.QRCode, error) {
	p.mu.Lock()
	_, ok := p.sessions[name]
	p.mu.Unlock()
	if !ok {
		return messaging.QRCode{}, messaging.ErrSessionNotFound
	}
	return messaging.QRCode{Mimetype: "image/png", Data: placeholderQR()}, nil
}

func (p *Provider) Disconnect(_ context.Context, name string) error {
	p.mu.Lock()
	defer p.mu.Unlock()
	delete(p.sessions, name)
	return nil
}

func (p *Provider) SendText(_ context.Context, name, phone, text string) (string, error) {
	p.mu.Lock()
	defer p.mu.Unlock()
	s, ok := p.sessions[name]
	if !ok || p.now().Sub(s.startedAt) < p.connectIn {
		return "", messaging.ErrSessionNotFound
	}
	p.sent = append(p.sent, SentMessage{Session: name, Phone: phone, Text: text})
	return "mock-" + uuid.NewString(), nil
}

// Sent returns a copy of all messages "sent" so far.
func (p *Provider) Sent() []SentMessage {
	p.mu.Lock()
	defer p.mu.Unlock()
	return append([]SentMessage(nil), p.sent...)
}

// placeholderQR draws a checkerboard so the UI has an image to render. It is
// not a scannable QR code.
func placeholderQR() string {
	const n, cell = 21, 8
	img := image.NewGray(image.Rect(0, 0, n*cell, n*cell))
	for y := 0; y < n*cell; y++ {
		for x := 0; x < n*cell; x++ {
			c := color.Gray{Y: 255}
			if ((x/cell)*7+(y/cell)*3)%5 < 2 {
				c = color.Gray{Y: 0}
			}
			img.SetGray(x, y, c)
		}
	}
	var buf bytes.Buffer
	_ = png.Encode(&buf, img)
	return base64.StdEncoding.EncodeToString(buf.Bytes())
}
