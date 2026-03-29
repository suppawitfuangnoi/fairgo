"use client";

import { useState, useEffect } from "react";
import dynamic from "next/dynamic";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";
import { useAdminSocket } from "@/hooks/useSocket";

const LiveMap = dynamic(() => import("@/components/LiveMap"), { ssr: false, loading: () => (
  <div className="h-56 flex items-center justify-center">
    <div className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin" />
  </div>
) });

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

function StatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    COMPLETED: "bg-emerald-100 text-emerald-700",
    IN_PROGRESS: "bg-primary/10 text-primary",
    DRIVER_EN_ROUTE: "bg-primary/10 text-primary",
    DRIVER_ASSIGNED: "bg-primary/10 text-primary",
    DRIVER_ARRIVED: "bg-primary/10 text-primary",
    CANCELLED: "bg-red-100 text-red-600",
  };
  const label: Record<string, string> = {
    COMPLETED: "Completed",
    IN_PROGRESS: "Ongoing",
    DRIVER_EN_ROUTE: "En Route",
    DRIVER_ASSIGNED: "Assigned",
    DRIVER_ARRIVED: "Arrived",
    CANCELLED: "Cancelled",
  };
  return (
    <span className={`px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider rounded-full ${styles[status] || "bg-slate-100 text-slate-500"}`}>
      {label[status] || status.replace(/_/g, " ")}
    </span>
  );
}

function KpiCard({
  icon, label, value, change, changePositive,
}: { icon: string; label: string; value: string; change?: string; changePositive?: boolean }) {
  return (
    <div className="bg-white rounded-xl p-6 border border-slate-100 shadow-sm">
      <div className="flex items-center justify-between mb-4">
        <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center text-primary">
          <span className="material-symbols-outlined text-xl">{icon}</span>
        </div>
        {change && (
          <span className={`text-xs font-bold px-2 py-1 rounded-full ${changePositive ? "text-emerald-600 bg-emerald-100" : "text-red-500 bg-red-100"}`}>
            {change}
          </span>
        )}
      </div>
      <p className="text-sm font-medium text-slate-500">{label}</p>
      <h3 className="text-2xl font-bold mt-1 text-slate-900">{value}</h3>
    </div>
  );
}

// SVG line chart data points for "Trips vs Revenue"
const CHART_POINTS = [
  { x: 0, y: 200, label: "Mon" },
  { x: 114, y: 120, label: "Tue" },
  { x: 228, y: 150, label: "Wed" },
  { x: 342, y: 80, label: "Thu" },
  { x: 456, y: 100, label: "Fri" },
  { x: 570, y: 50, label: "Sat" },
  { x: 684, y: 70, label: "Sun" },
  { x: 800, y: 40, label: "" },
];

const chartPath = CHART_POINTS.map((p, i) => `${i === 0 ? "M" : "L"}${p.x},${p.y}`).join(" ");
const areaPath = `${chartPath} L800,250 L0,250 Z`;

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [trips, setTrips] = useState<RecentTrip[]>([]);
  const [loading, setLoading] = useState(true);
  const [chartPeriod, setChartPeriod] = useState("Daily");
  const { isConnected, drivers } = useAdminSocket();

  const load = async () => {
    try {
      const token = getToken(); if (!token) return;
      const res = await apiFetch<{ data: { stats: DashboardStats; recentActivity: RecentTrip[] } }>("/api/v1/admin/dashboard", { token });
      setStats(res.data.stats); setTrips(res.data.recentActivity || []);
    } catch (e) { console.error(e); } finally { setLoading(false); }
  };
  useEffect(() => { load(); const iv = setInterval(load, 30000); return () => clearInterval(iv); }, []);

  const fmt = (n: number) => n >= 1000 ? `${(n / 1000).toFixed(1)}k` : n.toString();

  return (
    <div className="p-8 space-y-8 max-w-screen-xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold tracking-tight text-slate-900">Overview Dashboard</h2>
          <p className="text-sm text-slate-400 mt-0.5">Real-time platform metrics</p>
        </div>
        <div className="flex items-center gap-3">
          <div className={`flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full ${isConnected ? "bg-emerald-100 text-emerald-600" : "bg-slate-100 text-slate-500"}`}>
            <div className={`w-1.5 h-1.5 rounded-full ${isConnected ? "bg-emerald-500 animate-pulse" : "bg-slate-400"}`} />
            {isConnected ? "Live" : "Polling"}
          </div>
          <button onClick={load} className="flex items-center gap-1.5 text-xs text-slate-500 bg-white border border-slate-200 rounded-xl px-3 py-2 hover:bg-slate-50 transition shadow-sm">
            <span className="material-symbols-outlined text-sm">refresh</span>Refresh
          </button>
        </div>
      </div>

      {/* KPI Cards — 4 columns */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <KpiCard
          icon="route"
          label="Active Trips"
          value={loading ? "—" : fmt(stats?.activeTrips ?? 0)}
          change="+12.5%"
          changePositive
        />
        <KpiCard
          icon="payments"
          label="Total Revenue"
          value={loading ? "—" : `฿${(stats?.totalRevenue ?? 0).toLocaleString()}`}
          change="+8.2%"
          changePositive
        />
        <KpiCard
          icon="person_add"
          label="New Users"
          value={loading ? "—" : fmt(stats?.totalUsers ?? 0)}
          change="-3.1%"
          changePositive={false}
        />
        <KpiCard
          icon="airline_stops"
          label="Active Drivers"
          value={loading ? "—" : (isConnected ? drivers.length : (stats?.onlineDrivers ?? stats?.activeDrivers ?? 0)).toLocaleString()}
          change="+5.4%"
          changePositive
        />
      </div>

      {/* Trips vs Revenue Chart */}
      <div className="bg-white rounded-xl border border-slate-100 shadow-sm p-6">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h4 className="text-lg font-bold text-slate-900">Trips vs Revenue</h4>
            <p className="text-sm text-slate-500">Performance insights over the last 7 days</p>
          </div>
          <div className="flex gap-2">
            <button className="px-3 py-1.5 text-xs font-bold rounded-lg border border-slate-200 hover:bg-slate-50">Export CSV</button>
            {["Daily", "Weekly"].map(p => (
              <button
                key={p}
                onClick={() => setChartPeriod(p)}
                className={`px-3 py-1.5 text-xs font-bold rounded-lg transition ${chartPeriod === p ? "bg-primary text-white" : "border border-slate-200 hover:bg-slate-50"}`}
              >
                {p}
              </button>
            ))}
          </div>
        </div>
        <div className="w-full" style={{ height: 288 }}>
          <svg className="w-full h-64" viewBox="0 0 800 250" preserveAspectRatio="none">
            <defs>
              <linearGradient id="chart-gradient" x1="0" x2="0" y1="0" y2="1">
                <stop offset="0%" stopColor="#13c8ec" stopOpacity="0.2" />
                <stop offset="100%" stopColor="#13c8ec" stopOpacity="0" />
              </linearGradient>
            </defs>
            {/* Grid lines */}
            {[50, 100, 150, 200].map(y => (
              <line key={y} x1="0" x2="800" y1={y} y2={y} stroke="#f1f5f9" strokeWidth="1" />
            ))}
            {/* Area fill */}
            <path d={areaPath} fill="url(#chart-gradient)" />
            {/* Line */}
            <path d={chartPath} fill="none" stroke="#13c8ec" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
            {/* Points */}
            {CHART_POINTS.slice(1).map((p, i) => (
              <circle key={i} cx={p.x} cy={p.y} r="4" fill="#13c8ec" stroke="white" strokeWidth="2" />
            ))}
          </svg>
          <div className="flex justify-between px-2 mt-2">
            {["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map(d => (
              <span key={d} className="text-xs font-bold text-slate-400">{d}</span>
            ))}
          </div>
        </div>
      </div>

      {/* Live Map + Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        {/* Live Map */}
        <div className="lg:col-span-3 bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
          <div className="p-4 border-b border-slate-100 flex items-center justify-between">
            <div>
              <h2 className="font-semibold text-slate-900">Live Trip Map</h2>
              <p className="text-xs text-slate-400">
                {isConnected ? `${drivers.length} drivers online` : `${stats?.activeTrips ?? 0} active trips`}
              </p>
            </div>
            <span className="flex items-center gap-1.5 text-xs font-medium">
              {isConnected
                ? <><div className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" /><span className="text-emerald-500">Socket Live</span></>
                : <><div className="w-2 h-2 rounded-full bg-amber-400" /><span className="text-amber-500">HTTP Poll</span></>
              }
            </span>
          </div>
          <div className="h-56 overflow-hidden">
            <LiveMap drivers={drivers} height="224px" />
          </div>
        </div>

        {/* Recent Activity Table */}
        <div className="lg:col-span-2 bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden flex flex-col">
          <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
            <h4 className="text-base font-bold text-slate-900">Recent Activity</h4>
            <a href="/dashboard/trips" className="text-sm font-bold text-primary hover:underline">View All Trips</a>
          </div>
          <div className="overflow-y-auto flex-1 divide-y divide-slate-50">
            {!loading && trips.length === 0 && (
              <div className="py-8 text-center text-sm text-slate-400">No recent trips</div>
            )}
            {trips.slice(0, 8).map(t => (
              <div key={t.id} className="px-5 py-3 hover:bg-slate-50/60 transition">
                <div className="flex items-start justify-between gap-2">
                  <div className="flex items-center gap-2 min-w-0">
                    <div className="w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                      <span className="material-symbols-outlined text-primary" style={{ fontSize: 14 }}>
                        {VI[t.rideRequest?.vehicleType] || "directions_car"}
                      </span>
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs font-semibold text-slate-900 truncate">
                        {t.rideRequest?.customerProfile?.user?.name || "N/A"}
                      </p>
                      <p className="text-[10px] text-slate-400 truncate">
                        → {t.rideRequest?.dropoffAddress?.substring(0, 22) || "N/A"}
                      </p>
                      <p className="text-[10px] text-slate-400 truncate">
                        {t.driverProfile?.user?.name || "Unassigned"}
                      </p>
                    </div>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-xs font-bold text-slate-900 mb-1">฿{t.lockedFare?.toFixed(0) || "—"}</p>
                    <StatusBadge status={t.status} />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Full Recent Activity Table */}
      <div className="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
        <div className="px-6 py-5 border-b border-slate-100 flex items-center justify-between">
          <h4 className="text-lg font-bold text-slate-900">Trip Activity Log</h4>
          <a href="/dashboard/trips" className="text-sm font-bold text-primary hover:underline">View All</a>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50">
              <tr>
                {["User", "Driver", "Route", "Fare", "Status", "Time"].map(h => (
                  <th key={h} className="px-6 py-3 text-xs font-bold text-slate-500 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {!loading && trips.length === 0 && (
                <tr><td colSpan={6} className="px-6 py-8 text-center text-sm text-slate-400">No trips found</td></tr>
              )}
              {trips.slice(0, 8).map(t => (
                <tr key={t.id} className="hover:bg-slate-50/60 transition-colors">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center font-bold text-primary text-xs">
                        {(t.rideRequest?.customerProfile?.user?.name || "?")[0].toUpperCase()}
                      </div>
                      <span className="text-sm font-semibold text-slate-900">{t.rideRequest?.customerProfile?.user?.name || "N/A"}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center font-bold text-slate-500 text-xs">
                        {(t.driverProfile?.user?.name || "?")[0].toUpperCase()}
                      </div>
                      <span className="text-sm font-semibold text-slate-900">{t.driverProfile?.user?.name || "Unassigned"}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex flex-col">
                      <span className="text-xs font-bold text-slate-400">From</span>
                      <span className="text-sm text-slate-900 truncate max-w-[160px]">
                        {t.rideRequest?.pickupAddress?.split(",")[0] || "N/A"}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm font-bold text-slate-900">
                    ฿{t.lockedFare?.toFixed(2) || "—"}
                  </td>
                  <td className="px-6 py-4">
                    <StatusBadge status={t.status} />
                  </td>
                  <td className="px-6 py-4 text-xs font-medium text-slate-400">
                    {t.createdAt ? new Date(t.createdAt).toLocaleTimeString("th-TH", { hour: "2-digit", minute: "2-digit" }) : "—"}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <footer className="text-center text-slate-400 text-xs py-4">
        © 2024 FAIRGO Co., Ltd. Thailand. All rights reserved.
      </footer>
    </div>
  );
}
