// Package audit records administrative actions in audit_logs.
package audit

import (
	"context"
	"encoding/json"
	"log/slog"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	InsertAudit(ctx context.Context, e domain.AuditEntry) error
}

type ipKey struct{}

// WithIP stores the client IP so audit entries can include it.
func WithIP(ctx context.Context, ip string) context.Context {
	return context.WithValue(ctx, ipKey{}, ip)
}

type Logger struct {
	repo Repo
	log  *slog.Logger
}

func New(repo Repo, log *slog.Logger) *Logger { return &Logger{repo: repo, log: log} }

// Record writes an audit entry. Failures are logged but never block the action.
func (l *Logger) Record(ctx context.Context, actor domain.Principal, tenantID, action, entityType, entityID string, meta map[string]any) {
	e := domain.AuditEntry{Action: action, EntityType: entityType, EntityID: entityID}
	if actor.UserID != "" {
		e.ActorUserID = &actor.UserID
	}
	if tenantID != "" {
		e.TenantID = &tenantID
	}
	if ip, ok := ctx.Value(ipKey{}).(string); ok {
		e.IP = ip
	}
	if meta != nil {
		e.Metadata, _ = json.Marshal(meta)
	}
	if err := l.repo.InsertAudit(ctx, e); err != nil {
		l.log.Error("audit log write failed", "action", action, "error", err)
	}
}
