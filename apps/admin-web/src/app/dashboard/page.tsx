"use client";

import { useState, useEffect } from "react";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";

interface DashboardStats {
  totalTrips: number; activeTrips: number; totalRevenue: number;
  activeDrivers: number; onlineDrivers: number; pendingVerifications: number;
  totalUsers: number; completedTrips: number; cancelledTrips: number;
}
interface RecentTrip {
  id: string; status: string; lockedFare: number; createdAt: string;
  rideRequest: { pickupAddress: string; dropoffAddress: string; vehicleType: string; customerProfile: { user: { name: string } } };
  driverProfile: { user: { name: string } };
}

const VI: Record<string, string> = { TAXI: "local_taxi", MOTORCYCLE: "two_wheeler", TUKTUK: "electric_rickshaw" };

function KpiCard({ icon, label, value, sub, color, bg }: { icon: string; label: string; value: string; sub?: string; color: string; bg: string }) {
  return (
    <div className="bg-white rounded-2xl p-5 shadow-card flex items-center gap-4 fade-in">
      <div className={`w-12 h-12 ${bg} rounded-xl flex items-center justify-center flex-shrink-0`}>
        <span className={`material-icons-round ${color} text-2xl`}>{icon}</span>
      </div>
      <div className="min-w-0">
        <p className="text-xs text-gray-400 font-medium truncate">{label}</p>
        <p className="text-2xl font-bold text-fairgo-dark leading-tight">{value}</p>
        {sub && <p className="text-xs text-gray-400 mt-0.5">{sub}</p>}
      </div>
    </div>
  );
}

function Badge({ status }: { status: string }) {
  const m: Record<string, string> = {
    COMPLETED: "badge-completed", IN_PROGRESS: "badge-intransit",
    DRIVER_EN_ROUTE: "badge-intransit", DRIVER_ASSIGNED: "badge-intransit",
    DRIVER_ARRIVED: "badge-intransit", CANCELLED: "badge-suspended",
  };
  return <span className={m[status] || "badge-pending"}>{status.replace(/_/g, " ")}</span>;
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [trips, setTrips] = useState<RecentTrip[]>([]);
  const [loading, setLoading] = useState(true);

  const load = async () => {
    try {
      const token = getToken(); if (!token) return;
      const res = await apiFetch<{ data: { stats: DashboardStats; recentActivity: RecentTrip[] } }>("/api/v1/admin/dashboard", { token });
      setStats(res.data.stats); setTrips(res.data.recentActivity || []);
    } catch (e) { console.error(e); } finally { setLoading(false); }
  };
  useEffect(() => { load(); const iv = setInterval(load, 30000); return () => clearInterval(iv); }, []);

  const hours = Array.from({ length: 12 }, (_, i) => ({ label: `${(i * 2).toString().padStart(2, "0")}:00`, val: Math.floor(Math.random() * 80 + 10) }));
  const maxH = Math.max(...hours.map(h => h.val));

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-fairgo-dark">Overview Dashboard</h1>
          <p className="text-sm text-gray-400 mt-0.5">Real-time platform metrics</p>
        </div>
        <div className="flex items-center gap-2">
          <div className="flex items-center gap-1.5 text-xs text-gray-400">
            <div className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />Live
          </div>
          <button onClick={load} className="flex items-center gap-1.5 text-xs text-gray-500 bg-white border border-gray-200 rounded-lg px-3 py-2 hover:bg-gray-50 transition">
            <span className="material-icons-round text-sm">refresh</span>Refresh
          </button>
        </div>
      </div>

      {/* KPI */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <KpiCard icon="local_taxi" label="Trips Today" bg="bg-primary/10" color="text-primary" value={loading ? "—" : (stats?.totalTrips ?? 0).toLocaleString()} sub={`${stats?.activeTrips ?? 0} active`} />
        <KpiCard icon="payments" label="Revenue (GMV)" bg="bg-emerald-50" color="text-emerald-500" value={loading ? "—" : `฿${(stats?.totalRevenue ?? 0).toLocaleString()}`} sub="Today" />
        <KpiCard icon="directions_car" label="Online Drivers" bg="bg-amber-50" color="text-amber-500" value={loading ? "—" : (stats?.onlineDrivers ?? stats?.activeDrivers ?? 0).toLocaleString()} sub={`${stats?.pendingVerifications ?? 0} pending`} />
        <KpiCard icon="star" label="Avg Rating" bg="bg-purple-50" color="text-purple-500" value="4.82" sub="Platform avg" />
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2 bg-white rounded-2xl p-5 shadow-card">
          <div className="flex items-center justify-between mb-4">
            <div><h2 className="font-semibold text-fairgo-dark">Trip Volume (Hourly)</h2><p className="text-xs text-gray-400">Today&apos;s ride requests by hour</p></div>
            <div className="flex gap-1.5">
              {["Today", "Week"].map((t, i) => (
                <button key={t} className={`text-xs px-3 py-1.5 rounded-lg font-medium ${i === 0 ? "bg-primary text-white" : "text-gray-400 hover:bg-gray-50"}`}>{t}</button>
              ))}
            </div>
          </div>
          <div className="flex items-end gap-1 h-36">
            {hours.map((h, i) => (
              <div key={i} className="flex-1 flex flex-col items-center gap-1">
                <div className="w-full bg-primary/20 rounded-t-sm hover:bg-primary/40 transition-colors relative" style={{ height: `${(h.val / maxH) * 100}%` }}>
                  <div className="absolute bottom-0 left-0 right-0 bg-primary rounded-t-sm opacity-70" style={{ height: "60%" }} />
                </div>
                {i % 3 === 0 && <span className="text-[9px] text-gray-400">{h.label}</span>}
              </div>
            ))}
          </div>
        </div>
        <div className="bg-white rounded-2xl p-5 shadow-card">
          <h2 className="font-semibold text-fairgo-dark mb-1">Vehicle Types</h2>
          <p className="text-xs text-gray-400 mb-4">Trip distribution</p>
          <div className="flex justify-center mb-4">
            <svg width="120" height="120" viewBox="0 0 120 120">
              <circle cx="60" cy="60" r="45" fill="none" stroke="#13c8ec" strokeWidth="20" strokeDasharray={`${0.55*283} ${283}`} strokeDashoffset="0" transform="rotate(-90 60 60)" />
              <circle cx="60" cy="60" r="45" fill="none" stroke="#f59e0b" strokeWidth="20" strokeDasharray={`${0.30*283} ${283}`} strokeDashoffset={`${-0.55*283}`} transform="rotate(-90 60 60)" />
              <circle cx="60" cy="60" r="45" fill="none" stroke="#10b981" strokeWidth="20" strokeDasharray={`${0.15*283} ${283}`} strokeDashoffset={`${-0.85*283}`} transform="rotate(-90 60 60)" />
              <text x="60" y="64" textAnchor="middle" fontSize="14" fontWeight="bold" fill="#0f172a">55%</text>
            </svg>
          </div>
          {[{ l: "Taxi", p: "55%", c: "bg-primary" }, { l: "Motorcycle", p: "30%", c: "bg-amber-400" }, { l: "Tuk-tuk", p: "15%", c: "bg-emerald-400" }].map(v => (
            <div key={v.l} className="flex items-center justify-between text-sm mb-2">
              <div className="flex items-center gap-2"><div className={`w-2.5 h-2.5 rounded-full ${v.c}`} /><span className="text-gray-600 text-xs">{v.l}</span></div>
              <span className="font-semibold text-fairgo-dark text-xs">{v.p}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Live map + recent trips */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-4">
        <div className="lg:col-span-3 bg-white rounded-2xl shadow-card overflow-hidden">
          <div className="p-4 border-b border-gray-100 flex items-center justify-between">
            <div><h2 className="font-semibold text-fairgo-dark">Live Trip Map</h2><p className="text-xs text-gray-400">{stats?.activeTrips ?? 0} active trips</p></div>
            <span className="flex items-center gap-1.5 text-xs text-emerald-500 font-medium"><div className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />Live</span>
          </div>
          <div className="map-bg h-56 relative overflow-hidden">
            {[{ top: "28%", left: "22%" }, { top: "52%", left: "58%" }, { top: "18%", left: "68%" }, { top: "65%", left: "33%" }].map((pos, i) => (
              <div key={i} className="absolute w-8 h-8 bg-primary rounded-full flex items-center justify-center shadow-lg border-2 border-white animate-bounce" style={{ top: pos.top, left: pos.left, animationDelay: `${i * 0.4}s`, animationDuration: "2.5s" }}>
                <span className="material-icons-round text-white text-sm">local_taxi</span>
              </div>
            ))}
            <div className="absolute top-1/2 left-0 right-0 h-px bg-white/40" />
            <div className="absolute top-0 bottom-0 left-1/2 w-px bg-white/40" />
          </div>
        </div>
        <div className="lg:col-span-2 bg-white rounded-2xl shadow-card overflow-hidden flex flex-col">
          <div className="p-4 border-b border-gray-100 flex items-center justify-between">
            <h2 className="font-semibold text-fairgo-dark">Recent Trips</h2>
            <a href="/dashboard/trips" className="text-xs text-primary font-medium hover:underline">View all</a>
          </div>
          <div className="divide-y divide-gray-50 overflow-y-auto flex-1">
            {!loading && trips.length === 0 && <div className="py-8 text-center text-sm text-gray-400">No recent trips</div>}
            {trips.slice(0, 6).map(t => (
              <div key={t.id} className="p-3 hover:bg-gray-50/50 transition">
                <div className="flex items-start justify-between gap-2">
                  <div className="flex items-center gap-2 min-w-0">
                    <div className="w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                      <span className="material-icons-round text-primary text-xs">{VI[t.rideRequest?.vehicleType] || "directions_car"}</span>
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs font-medium text-fairgo-dark truncate">{t.rideRequest?.customerProfile?.user?.name || "N/A"}</p>
                      <p className="text-[10px] text-gray-400 truncate">→ {t.rideRequest?.dropoffAddress?.substring(0, 22) || "N/A"}</p>
                    </div>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-xs font-bold text-fairgo-dark mb-0.5">฿{t.lockedFare?.toFixed(0)}</p>
                    <Badge status={t.status} />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
