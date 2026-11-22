// Package dto holds HTTP request/response shapes that are not application inputs.
package dto

type ErrorBody struct {
	Error ErrorDetail `json:"error"`
}

type ErrorDetail struct {
	Code    string            `json:"code"`
	Message string            `json:"message"`
	Details map[string]string `json:"details,omitempty"`
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,max=72"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required,max=200"`
}

type SetupPasswordRequest struct {
	Token    string `json:"token" validate:"required,max=200"`
	Password string `json:"password" validate:"required,min=8,max=72"`
}

type ChangePasswordRequest struct {
	CurrentPassword string `json:"current_password" validate:"required,max=72"`
	NewPassword     string `json:"new_password" validate:"required,min=8,max=72"`
}

type StatusRequest struct {
	Status string `json:"status" validate:"required,oneof=ACTIVE INACTIVE"`
}

type RejectRequest struct {
	Reason string `json:"reason" validate:"max=500"`
}

type SetupLinkResponse struct {
	SetupURL string `json:"setup_url"`
}
