import { NextRequest, NextResponse } from "next/server";

const STATIC_ORIGINS = [
  "http://localhost:3000",
  "http://localhost:3001",
  "http://localhost:4000",
  "http://localhost:8080",
  "http://localhost:8081",
];

function getAllowedOrigins(): string[] {
  const origins = [...STATIC_ORIGINS];
  if (process.env.ADMIN_WEB_URL) {
    origins.push(process.env.ADMIN_WEB_URL.replace(/\/$/, ""));
  }
  if (process.env.CUSTOMER_APP_URL && process.env.CUSTOMER_APP_URL !== "*") {
    origins.push(process.env.CUSTOMER_APP_URL.replace(/\/$/, ""));
  }
  return origins;
}

export function middleware(request: NextRequest) {
  const origin = request.headers.get("origin") || "";
  const isAllowed =
    getAllowedOrigins().includes(origin) ||
    !origin ||
    process.env.CUSTOMER_APP_URL === "*";

  // Handle preflight OPTIONS requests
  if (request.method === "OPTIONS") {
    const response = new NextResponse(null, { status: 204 });
    if (isAllowed) {
      response.headers.set("Access-Control-Allow-Origin", origin);
    }
    response.headers.set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
    response.headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    response.headers.set("Access-Control-Max-Age", "86400");
    return response;
  }

  // Add CORS headers to all responses
  const response = NextResponse.next();
  if (isAllowed && origin) {
    response.headers.set("Access-Control-Allow-Origin", origin);
  }
  response.headers.set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
  response.headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  return response;
}

export const config = {
  matcher: "/api/:path*",
};
