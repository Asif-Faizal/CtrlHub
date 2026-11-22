package messaging

import (
	"context"
	"errors"
)

// ErrSessionNotFound is returned by providers when the session does not exist.
var ErrSessionNotFound = errors.New("whatsapp session not found")

type SessionInfo struct {
	Status string // STOPPED, STARTING, SCAN_QR_CODE, WORKING, FAILED
	Phone  string // digits only, empty until WORKING
}

type QRCode struct {
	Mimetype string `json:"mimetype"`
	Data     string `json:"data"` // base64
}

// Provider is the WhatsApp transport. The rest of the application only talks
// to this interface, never to WAHA directly.
type Provider interface {
	Name() string
	// StartSession creates the session if needed and starts it.
	StartSession(ctx context.Context, session string) (SessionInfo, error)
	SessionStatus(ctx context.Context, session string) (SessionInfo, error)
	QRCode(ctx context.Context, session string) (QRCode, error)
	// Disconnect logs the device out and removes the session.
	Disconnect(ctx context.Context, session string) error
	SendText(ctx context.Context, session, phone, text string) (messageID string, err error)
}
