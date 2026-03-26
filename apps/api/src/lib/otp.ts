/**
 * Mock OTP Service for FAIRGO
 * In production, integrate with SMS providers like Twilio, Firebase Auth, or Thai providers (ThaiBulkSMS)
 */

// In-memory OTP store (use Redis in production)
const otpStore = new Map<string, { code: string; expiresAt: number }>();

const OTP_EXPIRY_MS = 5 * 60 * 1000; // 5 minutes
const MOCK_OTP = "123456"; // Fixed OTP for development

export function generateOTP(phone: string): string {
  const code = process.env.NODE_ENV === "production"
    ? Math.floor(100000 + Math.random() * 900000).toString()
    : MOCK_OTP;

  otpStore.set(phone, {
    code,
    expiresAt: Date.now() + OTP_EXPIRY_MS,
  });

  // In production: send SMS here
  console.log(`[OTP] Phone: ${phone}, Code: ${code}`);

  return code;
}

export function verifyOTP(phone: string, code: string): boolean {
  const stored = otpStore.get(phone);
  if (!stored) return false;
  if (Date.now() > stored.expiresAt) {
    otpStore.delete(phone);
    return false;
  }
  if (stored.code !== code) return false;

  otpStore.delete(phone);
  return true;
}
