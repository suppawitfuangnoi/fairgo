import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import bcrypt from "bcryptjs";
import { generateAccessToken, generateRefreshToken } from "@/lib/jwt";
import { successResponse, errorResponse } from "@/lib/api-response";
import { validateBody } from "@/middleware/validate";
import { adminLoginSchema } from "@/lib/validation";

export async function POST(request: NextRequest) {
  try {
    const result = await validateBody(request, adminLoginSchema);
    if ("error" in result) return result.error;

    const { email, password } = result.data;

    // Find admin user by email
    const user = await prisma.user.findFirst({
      where: { email, role: "ADMIN" },
      include: { adminProfile: true },
    });

    if (!user) {
      return errorResponse("Invalid credentials", 401);
    }

    // For development: accept "admin123" as default password
    // In production, store hashed passwords properly
    const isValidPassword =
      process.env.NODE_ENV === "production"
        ? false // Must implement proper password storage
        : password === "admin123" ||
          (user.adminProfile?.permissions &&
            typeof user.adminProfile.permissions === "object" &&
            "passwordHash" in (user.adminProfile.permissions as Record<string, unknown>) &&
            (await bcrypt.compare(
              password,
              (user.adminProfile.permissions as Record<string, unknown>).passwordHash as string
            )));

    if (!isValidPassword) {
      return errorResponse("Invalid credentials", 401);
    }

    const accessToken = generateAccessToken(user.id, user.role);
    const refreshToken = generateRefreshToken(user.id, user.role);

    await prisma.refreshToken.create({
      data: {
        userId: user.id,
        token: refreshToken,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        userAgent: request.headers.get("user-agent") || undefined,
      },
    });

    return successResponse({
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
      accessToken,
      refreshToken,
      expiresIn: 900,
    });
  } catch (error) {
    console.error("[AUTH] Admin login error:", error);
    return errorResponse("Login failed", 500);
  }
}
