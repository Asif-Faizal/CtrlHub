// Tokens live in localStorage so a reload keeps the session. The access token
// is short-lived; the refresh token is rotated on every use by the backend.
const ACCESS = "ctrlhub.access";
const REFRESH = "ctrlhub.refresh";

export const tokenStore = {
  access: () => localStorage.getItem(ACCESS),
  refresh: () => localStorage.getItem(REFRESH),
  set(access: string, refresh: string) {
    localStorage.setItem(ACCESS, access);
    localStorage.setItem(REFRESH, refresh);
  },
  clear() {
    localStorage.removeItem(ACCESS);
    localStorage.removeItem(REFRESH);
  },
};
