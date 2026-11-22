package http

import (
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"reflect"
	"strconv"
	"strings"

	"github.com/go-playground/validator/v10"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/auth"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/interfaces/dto"
)

const maxBody = 1 << 20

var validate = func() *validator.Validate {
	v := validator.New()
	v.RegisterTagNameFunc(func(f reflect.StructField) string {
		name := strings.SplitN(f.Tag.Get("json"), ",", 2)[0]
		if name == "-" {
			return ""
		}
		return name
	})
	return v
}()

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if v != nil {
		_ = json.NewEncoder(w).Encode(v)
	}
}

// decode reads a JSON body into dst and runs struct validation.
func decode(r *http.Request, dst any) error {
	dec := json.NewDecoder(io.LimitReader(r.Body, maxBody))
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		if errors.Is(err, io.EOF) {
			return domain.Invalid("request body is required")
		}
		return domain.Invalid("invalid JSON: " + err.Error())
	}
	if err := validate.Struct(dst); err != nil {
		var ve validator.ValidationErrors
		if errors.As(err, &ve) {
			fields := map[string]string{}
			for _, fe := range ve {
				fields[fieldPath(fe)] = describe(fe)
			}
			return &domain.ValidationError{Message: "validation failed", Fields: fields}
		}
		return domain.Invalid(err.Error())
	}
	return nil
}

func fieldPath(fe validator.FieldError) string {
	ns := fe.Namespace()
	if i := strings.Index(ns, "."); i >= 0 {
		return ns[i+1:]
	}
	return fe.Field()
}

func describe(fe validator.FieldError) string {
	switch fe.Tag() {
	case "required":
		return "is required"
	case "email":
		return "must be a valid email"
	case "uuid":
		return "must be a valid id"
	case "min":
		return "must be at least " + fe.Param()
	case "max":
		return "must be at most " + fe.Param()
	case "len":
		return "must have length " + fe.Param()
	case "oneof":
		return "must be one of: " + fe.Param()
	}
	return "is invalid"
}

type errorWriter struct{ log *slog.Logger }

func (e errorWriter) write(w http.ResponseWriter, r *http.Request, err error) {
	status, body := http.StatusInternalServerError, dto.ErrorDetail{Code: "INTERNAL", Message: "internal server error"}
	var ve *domain.ValidationError
	var ce *domain.ConflictError
	var fe *domain.ForbiddenError
	switch {
	case errors.As(err, &ve):
		status, body = http.StatusBadRequest, dto.ErrorDetail{Code: "VALIDATION_ERROR", Message: ve.Message, Details: ve.Fields}
	case errors.As(err, &ce):
		status, body = http.StatusConflict, dto.ErrorDetail{Code: "CONFLICT", Message: ce.Message}
	case errors.As(err, &fe):
		status, body = http.StatusForbidden, dto.ErrorDetail{Code: "FORBIDDEN", Message: fe.Message}
	case errors.Is(err, domain.ErrNotFound):
		status, body = http.StatusNotFound, dto.ErrorDetail{Code: "NOT_FOUND", Message: "resource not found"}
	case auth.IsInvalidCredentials(err):
		status, body = http.StatusUnauthorized, dto.ErrorDetail{Code: "INVALID_CREDENTIALS", Message: "invalid email or password"}
	case errors.Is(err, domain.ErrUnauthorized):
		status, body = http.StatusUnauthorized, dto.ErrorDetail{Code: "UNAUTHORIZED", Message: "authentication required"}
	case errors.Is(err, domain.ErrInactive):
		status, body = http.StatusForbidden, dto.ErrorDetail{Code: "ACCOUNT_INACTIVE", Message: "this account or gym is inactive"}
	case errors.Is(err, domain.ErrForbidden):
		status, body = http.StatusForbidden, dto.ErrorDetail{Code: "FORBIDDEN", Message: "forbidden"}
	case errors.Is(err, domain.ErrConflict):
		status, body = http.StatusConflict, dto.ErrorDetail{Code: "CONFLICT", Message: "conflict"}
	default:
		e.log.Error("unhandled error", "method", r.Method, "path", r.URL.Path, "error", err)
	}
	writeJSON(w, status, dto.ErrorBody{Error: body})
}

func queryInt(r *http.Request, key string, def int) int {
	if v, err := strconv.Atoi(r.URL.Query().Get(key)); err == nil {
		return v
	}
	return def
}

func queryDate(r *http.Request, key string) (*domain.Date, error) {
	v := r.URL.Query().Get(key)
	if v == "" {
		return nil, nil
	}
	d, err := domain.ParseDate(v)
	if err != nil {
		return nil, domain.InvalidField(key, err.Error())
	}
	return &d, nil
}
