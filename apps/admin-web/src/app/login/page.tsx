"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { apiFetch } from "@/lib/api";
import { setAuth } from "@/lib/auth";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const res = await apiFetch<{
        success: boolean;
        data: {
          accessToken: string;
          refreshToken: string;
          user: Record<string, unknown>;
        };
      }>("/api/v1/auth/admin-login", {
        method: "POST",
        body: { email, password },
      });

      setAuth(res.data.accessToken, res.data.user);
      router.push("/dashboard");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Login failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex bg-fairgo-bg">
      {/* Left panel */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-primary to-primary-700 flex-col items-center justify-center p-12 relative overflow-hidden">
        <div className="absolute inset-0 opacity-10"
          style={{ backgroundImage: 'linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)', backgroundSize: '40px 40px' }}
        />
        <div className="relative z-10 text-center">
          <div className="w-20 h-20 bg-white/20 backdrop-blur rounded-3xl flex items-center justify-center mx-auto mb-6 shadow-xl">
            <span className="material-icons-round text-white text-4xl">directions_car</span>
          </div>
          <h1 className="text-4xl font-extrabold text-white tracking-tight mb-2">FAIRGO</h1>
          <p className="text-white/80 text-lg font-medium mb-8">Admin Management Portal</p>
          <div className="space-y-3 text-left max-w-xs">
            {["Real-time trip monitoring", "Driver verification & management", "Pricing policy control", "Analytics & reports"].map(f => (
              <div key={f} className="flex items-center gap-3 text-white/90 text-sm">
                <span className="material-icons-round text-white/60 text-base">check_circle</span>
                {f}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Right panel */}
      <div className="flex-1 flex items-center justify-center p-6">
        <div className="w-full max-w-sm">
          {/* Mobile logo */}
          <div className="text-center mb-8 lg:hidden">
            <div className="w-14 h-14 bg-primary rounded-2xl flex items-center justify-center mx-auto mb-3">
              <span className="material-icons-round text-white text-3xl">directions_car</span>
            </div>
            <h1 className="text-2xl font-extrabold text-fairgo-dark">FAIRGO</h1>
            <p className="text-xs text-primary font-semibold uppercase tracking-widest mt-1">Admin Portal</p>
          </div>

          <div className="bg-white rounded-2xl shadow-card p-7">
            <h2 className="text-xl font-bold text-fairgo-dark mb-1">Sign In</h2>
            <p className="text-sm text-gray-400 mb-6">Enter your admin credentials to continue</p>

            <form onSubmit={handleLogin} className="space-y-4">
              {error && (
                <div className="flex items-center gap-2 bg-red-50 border border-red-100 text-red-600 text-sm rounded-xl p-3">
                  <span className="material-icons-round text-sm">error_outline</span>
                  {error}
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold text-gray-500 mb-1.5 uppercase tracking-wide">Email Address</label>
                <div className="relative">
                  <span className="absolute left-3.5 top-1/2 -translate-y-1/2 material-icons-round text-gray-300 text-lg">mail</span>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none transition text-sm bg-gray-50 focus:bg-white"
                    placeholder="admin@fairgo.app"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-500 mb-1.5 uppercase tracking-wide">Password</label>
                <div className="relative">
                  <span className="absolute left-3.5 top-1/2 -translate-y-1/2 material-icons-round text-gray-300 text-lg">lock</span>
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none transition text-sm bg-gray-50 focus:bg-white"
                    placeholder="••••••••"
                    required
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-primary hover:bg-primary-600 text-white font-semibold py-3 rounded-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 shadow-sm mt-2"
              >
                {loading ? (
                  <>
                    <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    Signing in...
                  </>
                ) : (
                  <>
                    <span className="material-icons-round text-lg">login</span>
                    Sign In to Dashboard
                  </>
                )}
              </button>
            </form>
          </div>

          <p className="mt-5 text-center text-xs text-gray-400">
            &copy; 2025 FAIRGO Co., Ltd. Thailand
          </p>
        </div>
      </div>
    </div>
  );
}
