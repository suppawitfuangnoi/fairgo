"use client";

import { useState, useEffect, useCallback } from "react";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";

interface AnalyticsData {
  period: string;
  overview: {
    totalTrips: number;
    completedTrips: number;
    cancelledTrips: number;
    completionRate: number;
    newUsers: number;
    newDrivers: number;
    avgRating: number;
    totalRatings: number;
  };
  revenue: {
    totalGMV: number;
    totalCommission: number;
    totalDriverEarnings: number;
  };
  vehicleTypes: { type: string; count: number }[];
  paymentMethods: { method: string; count: number; amount: number }[];
  tripsByDay: { day: string; count: number; gmv: number }[];
  topZones: { zone: string; count: number }[];
}

const PERIODS = [
  { key: "24h", label: "24 Hours" },
  { key: "7d", label: "7 Days" },
  { key: "30d", label: "30 Days" },
  { key: "90d", label: "90 Days" },
];

const VEHICLE_COLORS: Record<string, string> = {
  TAXI: "bg-primary",
  MOTORCYCLE: "bg-amber-400",
  TUKTUK: "bg-emerald-400",
};

const PAYMENT_COLORS: Record<string, string> = {
  CASH: "bg-emerald-400",
  WALLET: "bg-primary",
  CARD: "bg-purple-400",
};

function StatCard({ icon, label, value, sub, color, bg }: {
  icon: string; label: string; value: string; sub?: string; color: string; bg: string;
}) {
  return (
    <div className="bg-white rounded-2xl p-5 shadow-card flex items-center gap-4">
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

export default function AnalyticsPage() {
  const [data, setData] = useState<AnalyticsData | null>(null);
  const [loading, setLoading] = useState(true);
  const [period, setPeriod] = useState("7d");
  const [error, setError] = useState("");

  const load = useCallback(async (p: string) => {
    setLoading(true);
    setError("");
    try {
      const token = getToken();
      if (!token) return;
      const res = await apiFetch<{ data: AnalyticsData }>(
        `/api/v1/admin/analytics?period=${p}`,
        { token }
      );
      setData(res.data);
    } catch (e) {
      console.error(e);
      setError("Failed to load analytics data");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(period); }, [period, load]);

  const maxDayCount = data ? Math.max(...data.tripsByDay.map((d) => d.count), 1) : 1;
  const maxZoneCount = data ? Math.max(...data.topZones.map((z) => z.count), 1) : 1;
  const totalVehicle = data ? data.vehicleTypes.reduce((s, v) => s + v.count, 0) : 0;
  const totalPayment = data ? data.paymentMethods.reduce((s, p) => s + p.count, 0) : 0;

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-xl font-bold text-fairgo-dark">Reports & Analytics</h1>
          <p className="text-sm text-gray-400 mt-0.5">Platform performance data</p>
        </div>
        <div className="flex gap-1.5">
          {PERIODS.map((p) => (
            <button
              key={p.key}
              onClick={() => setPeriod(p.key)}
              className={`text-xs px-3 py-1.5 rounded-lg font-medium transition ${
                period === p.key ? "bg-primary text-white" : "bg-white text-gray-500 border border-gray-200 hover:bg-gray-50"
              }`}
            >
              {p.label}
            </button>
          ))}
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-100 text-red-600 text-sm rounded-xl p-4">{error}</div>
      )}

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard icon="local_taxi" label="Total Trips" bg="bg-primary/10" color="text-primary"
          value={loading ? "—" : (data?.overview.totalTrips ?? 0).toLocaleString()}
          sub={`${data?.overview.completionRate ?? 0}% completion`} />
        <StatCard icon="payments" label="Total GMV" bg="bg-emerald-50" color="text-emerald-500"
          value={loading ? "—" : `฿${((data?.revenue.totalGMV ?? 0) / 1000).toFixed(1)}K`}
          sub={`฿${((data?.revenue.totalCommission ?? 0) / 1000).toFixed(1)}K commission`} />
        <StatCard icon="person_add" label="New Users" bg="bg-amber-50" color="text-amber-500"
          value={loading ? "—" : (data?.overview.newUsers ?? 0).toLocaleString()}
          sub={`${data?.overview.newDrivers ?? 0} new drivers`} />
        <StatCard icon="star" label="Avg Rating" bg="bg-purple-50" color="text-purple-500"
          value={loading ? "—" : (data?.overview.avgRating ?? 0).toFixed(2)}
          sub={`${(data?.overview.totalRatings ?? 0).toLocaleString()} ratings`} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2 bg-white rounded-2xl p-5 shadow-card">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2 className="font-semibold text-fairgo-dark">Trip Volume by Day</h2>
              <p className="text-xs text-gray-400">Trips trend over period</p>
            </div>
            {!loading && data && (
              <span className="text-xs text-gray-400">GMV ฿{(data.revenue.totalGMV / 1000).toFixed(1)}K</span>
            )}
          </div>
          {loading ? (
            <div className="h-36 flex items-center justify-center text-gray-300">
              <span className="material-icons-round animate-spin">refresh</span>
            </div>
          ) : data && data.tripsByDay.length > 0 ? (
            <div className="flex items-end gap-1 h-36">
              {data.tripsByDay.slice(-14).map((d, i) => (
                <div key={i} className="flex-1 flex flex-col items-center gap-1 relative group">
                  <div
                    className="w-full bg-primary/20 rounded-t-sm hover:bg-primary/40 transition-colors relative"
                    style={{ height: `${Math.max(4, (d.count / maxDayCount) * 100)}%` }}
                    title={`${d.day}: ${d.count} trips`}
                  >
                    <div className="absolute bottom-0 left-0 right-0 bg-primary rounded-t-sm opacity-70" style={{ height: "60%" }} />
                  </div>
                  {data.tripsByDay.length <= 10 && (
                    <span className="text-[8px] text-gray-400">{d.day.slice(5)}</span>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <div className="h-36 flex items-center justify-center text-sm text-gray-400">No data for this period</div>
          )}
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-card">
          <h2 className="font-semibold text-fairgo-dark mb-1">Top Pickup Zones</h2>
          <p className="text-xs text-gray-400 mb-4">Most requested areas</p>
          {loading ? (
            <div className="space-y-3">{[1,2,3,4,5].map(i => <div key={i} className="h-8 bg-gray-100 rounded animate-pulse" />)}</div>
          ) : data && data.topZones.length > 0 ? (
            <div className="space-y-3">
              {data.topZones.map((zone, i) => (
                <div key={i}>
                  <div className="flex items-center justify-between text-xs mb-1">
                    <span className="text-gray-600 truncate max-w-[140px]">{zone.zone || "Unknown"}</span>
                    <span className="font-semibold text-fairgo-dark">{zone.count}</span>
                  </div>
                  <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                    <div className="h-full bg-primary rounded-full transition-all duration-500"
                      style={{ width: `${(zone.count / maxZoneCount) * 100}%` }} />
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-sm text-gray-400 text-center py-8">No zone data</div>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-2xl p-5 shadow-card">
          <h2 className="font-semibold text-fairgo-dark mb-1">Vehicle Type Distribution</h2>
          <p className="text-xs text-gray-400 mb-4">Trip share by vehicle</p>
          {loading ? <div className="h-32 bg-gray-100 rounded animate-pulse" /> :
            data && data.vehicleTypes.length > 0 ? (
              <div className="space-y-3">
                {data.vehicleTypes.map((v) => {
                  const pct = totalVehicle > 0 ? Math.round((v.count / totalVehicle) * 100) : 0;
                  return (
                    <div key={v.type}>
                      <div className="flex items-center justify-between text-xs mb-1">
                        <div className="flex items-center gap-2">
                          <div className={`w-2.5 h-2.5 rounded-full ${VEHICLE_COLORS[v.type] || "bg-gray-300"}`} />
                          <span className="text-gray-600">{v.type}</span>
                        </div>
                        <span className="font-semibold text-fairgo-dark">{pct}% ({v.count.toLocaleString()})</span>
                      </div>
                      <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                        <div className={`h-full ${VEHICLE_COLORS[v.type] || "bg-gray-300"} rounded-full transition-all duration-500`}
                          style={{ width: `${pct}%` }} />
                      </div>
                    </div>
                  );
                })}
              </div>
            ) : <div className="text-sm text-gray-400 text-center py-8">No vehicle data</div>
          }
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-card">
          <h2 className="font-semibold text-fairgo-dark mb-1">Payment Methods</h2>
          <p className="text-xs text-gray-400 mb-4">Revenue by payment type</p>
          {loading ? <div className="h-32 bg-gray-100 rounded animate-pulse" /> :
            data && data.paymentMethods.length > 0 ? (
              <div className="space-y-3">
                {data.paymentMethods.map((p) => {
                  const pct = totalPayment > 0 ? Math.round((p.count / totalPayment) * 100) : 0;
                  return (
                    <div key={p.method}>
                      <div className="flex items-center justify-between text-xs mb-1">
                        <div className="flex items-center gap-2">
                          <div className={`w-2.5 h-2.5 rounded-full ${PAYMENT_COLORS[p.method] || "bg-gray-300"}`} />
                          <span className="text-gray-600">{p.method}</span>
                        </div>
                        <span className="font-semibold text-fairgo-dark">{pct}% · ฿{(p.amount/1000).toFixed(1)}K</span>
                      </div>
                      <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                        <div className={`h-full ${PAYMENT_COLORS[p.method] || "bg-gray-300"} rounded-full transition-all duration-500`}
                          style={{ width: `${pct}%` }} />
                      </div>
                    </div>
                  );
                })}
              </div>
            ) : <div className="text-sm text-gray-400 text-center py-8">No payment data</div>
          }
        </div>
      </div>

      <div className="bg-white rounded-2xl p-5 shadow-card">
        <h2 className="font-semibold text-fairgo-dark mb-1">Revenue Breakdown</h2>
        <p className="text-xs text-gray-400 mb-4">Platform vs driver earnings split</p>
        {loading ? <div className="h-8 bg-gray-100 rounded animate-pulse" /> :
          data && data.revenue.totalGMV > 0 ? (
            <div className="space-y-3">
              <div className="h-6 bg-gray-100 rounded-full overflow-hidden flex">
                <div className="h-full bg-primary flex items-center justify-center text-white text-[9px] font-bold transition-all duration-500"
                  style={{ width: `${(data.revenue.totalCommission / data.revenue.totalGMV) * 100}%` }}>
                  {Math.round((data.revenue.totalCommission / data.revenue.totalGMV) * 100)}%
                </div>
                <div className="h-full bg-emerald-400 flex items-center justify-center text-white text-[9px] font-bold transition-all duration-500"
                  style={{ width: `${(data.revenue.totalDriverEarnings / data.revenue.totalGMV) * 100}%` }}>
                  {Math.round((data.revenue.totalDriverEarnings / data.revenue.totalGMV) * 100)}%
                </div>
              </div>
              <div className="flex flex-wrap gap-4 text-xs text-gray-500">
                <div className="flex items-center gap-1.5"><div className="w-2.5 h-2.5 rounded-full bg-primary" />Platform: ฿{data.revenue.totalCommission.toLocaleString(undefined, {maximumFractionDigits: 0})}</div>
                <div className="flex items-center gap-1.5"><div className="w-2.5 h-2.5 rounded-full bg-emerald-400" />Drivers: ฿{data.revenue.totalDriverEarnings.toLocaleString(undefined, {maximumFractionDigits: 0})}</div>
                <div className="flex items-center gap-1.5"><div className="w-2.5 h-2.5 rounded-full bg-gray-300" />Total GMV: ฿{data.revenue.totalGMV.toLocaleString(undefined, {maximumFractionDigits: 0})}</div>
              </div>
            </div>
          ) : <div className="text-sm text-gray-400 text-center py-4">No revenue data yet</div>
        }
      </div>
    </div>
  );
}
