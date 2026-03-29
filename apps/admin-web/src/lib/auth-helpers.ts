"use client";

// Separate helper to avoid circular imports between api.ts and auth.ts
const REFRESH_KEY = "fairgo_admin_refresh";

export function updateRefreshToken(token: string): void {
  if (typeof window !== "undefined") {
    localStorage.setItem(REFRESH_KEY, token);
  }
}
