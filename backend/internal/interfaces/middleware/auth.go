package middleware

import (
	"context"
	"crypto/subtle"
	"net/http"
	"strings"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type principalKey struct{}

func WithPrincipal(ctx context.Context, p domain.Principal) context.Context {
	return context.WithValue(ctx, principalKey{}, p)
}

// PrincipalFrom returns the authenticated principal. Handlers behind
// Authenticate can rely on it being present.
func PrincipalFrom(ctx context.Context) domain.Principal {
	p, _ := ctx.Value(principalKey{}).(domain.Principal)
	return p
}

type Authenticator interface {
	Authenticate(ctx context.Context, accessToken string) (domain.Principal, error)
}

// ErrorWriter renders an error response; provided by the http package.
type ErrorWriter func(w http.ResponseWriter, r *http.Request, err error)

func Authenticate(a Authenticator, writeErr ErrorWriter) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			h := r.Header.Get("Authorization")
			token, ok := strings.CutPrefix(h, "Bearer ")
			if !ok || token == "" {
				writeErr(w, r, domain.ErrUnauthorized)
				return
			}
			p, err := a.Authenticate(r.Context(), token)
			if err != nil {
				writeErr(w, r, err)
				return
			}
			next.ServeHTTP(w, r.WithContext(WithPrincipal(r.Context(), p)))
		})
	}
}

func RequirePlatformAdmin(writeErr ErrorWriter) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if !PrincipalFrom(r.Context()).IsPlatformAdmin {
				writeErr(w, r, domain.Forbidden("platform administrator access required"))
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

// RequireTenant admits only gym users; their tenant comes from the database.
func RequireTenant(writeErr ErrorWriter) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			p := PrincipalFrom(r.Context())
			if p.IsPlatformAdmin || p.TenantID == "" {
				writeErr(w, r, domain.Forbidden("gym account required"))
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

func RequirePermission(perm domain.Permission, writeErr ErrorWriter) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if !PrincipalFrom(r.Context()).Can(perm) {
				writeErr(w, r, domain.Forbidden("missing permission "+string(perm)))
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

// AutomationKey protects the machine-to-machine endpoints used by n8n.
func AutomationKey(key string, writeErr ErrorWriter) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			got := r.Header.Get("X-Automation-Key")
			if key == "" || subtle.ConstantTimeCompare([]byte(got), []byte(key)) != 1 {
				writeErr(w, r, domain.ErrUnauthorized)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}
