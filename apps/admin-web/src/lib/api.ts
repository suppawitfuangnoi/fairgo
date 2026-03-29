import { getRefreshToken, updateAccessToken, clearAuth } from "./auth";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

interface ApiOptions {
  method?: string;
  body?: unknown;
  token?: string;
}

// Refresh the access token using the stored refresh token.
// Returns the new access token, or null on failure.
async function refreshAccessToken(): Promise<string | null> {
  const refreshToken = getRefreshToken();
  if (!refreshToken) return null;

  try {
    const res = await fetch(`${API_URL}/api/v1/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
      cache: "no-store",
    });

    if (!res.ok) {
      clearAuth();
      return null;
    }

    const data = await res.json();
    const newAccessToken: string = data?.data?.accessToken;
    if (newAccessToken) {
      updateAccessToken(newAccessToken);
      // Also rotate the refresh token if the server returns a new one
      if (data?.data?.refreshToken) {
        const { updateRefreshToken } = await import("./auth-helpers");
        updateRefreshToken(data.data.refreshToken);
      }
      return newAccessToken;
    }
    return null;
  } catch {
    return null;
  }
}

export async function apiFetch<T>(endpoint: string, options: ApiOptions = {}): Promise<T> {
  const { method = "GET", body } = options;
  // Use token from options if explicitly passed, otherwise get from storage
  let token = options.token;

  const doFetch = async (accessToken: string | undefined): Promise<Response> => {
    const headers: Record<string, string> = {
      "Content-Type": "application/json",
    };
    if (accessToken) {
      headers["Authorization"] = `Bearer ${accessToken}`;
    }
    return fetch(`${API_URL}${endpoint}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
      cache: "no-store",
    });
  };

  let res = await doFetch(token);

  // Auto-refresh on 401
  if (res.status === 401) {
    const newToken = await refreshAccessToken();
    if (newToken) {
      token = newToken;
      res = await doFetch(token);
    } else {
      // Refresh failed — redirect to login
      if (typeof window !== "undefined") {
        window.location.href = "/login";
      }
      throw new Error("Session expired. Please sign in again.");
    }
  }

  const data = await res.json();

  if (!res.ok) {
    throw new Error(data.error || "API request failed");
  }

  return data;
}
