package domain

import (
	"errors"
	"fmt"
)

var (
	ErrNotFound     = errors.New("not found")
	ErrConflict     = errors.New("conflict")
	ErrForbidden    = errors.New("forbidden")
	ErrUnauthorized = errors.New("unauthorized")
	ErrInactive     = errors.New("account or tenant inactive")
)

// ValidationError carries field-level messages that are safe to show to clients.
type ValidationError struct {
	Message string
	Fields  map[string]string
}

func (e *ValidationError) Error() string { return e.Message }

func Invalid(msg string) error { return &ValidationError{Message: msg} }

func InvalidField(field, msg string) error {
	return &ValidationError{Message: fmt.Sprintf("%s: %s", field, msg), Fields: map[string]string{field: msg}}
}

// ConflictError is a conflict with a client-facing message.
type ConflictError struct{ Message string }

func (e *ConflictError) Error() string { return e.Message }
func (e *ConflictError) Unwrap() error { return ErrConflict }

func Conflict(msg string) error { return &ConflictError{Message: msg} }

// ForbiddenError is a forbidden action with a client-facing message.
type ForbiddenError struct{ Message string }

func (e *ForbiddenError) Error() string { return e.Message }
func (e *ForbiddenError) Unwrap() error { return ErrForbidden }

func Forbidden(msg string) error { return &ForbiddenError{Message: msg} }
