"use client";
import { useState, useEffect } from "react";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";

interface Trip {
  id: string; status: string; lockedFare: number; createdAt: string;
  rideRequest: { pickupAddress: string; dropoffAddress: string; vehicleType: string; customerProfile: { user: { name: string } } };
  driverProfile: { user: { name: string }; vehicles: { plateNumber: string }[] };
}

const VI: Record<string, string> = { TAXI: "local_taxi", MOTORCYCLE: "two_wheeler", TUKTUK: "electric_rickshaw" };
const STATUS_FILTER = ["ALL", "IN_PROGRESS", "DRIVER_EN_ROUTE", "COMPLETED", "CANCELLED"];
const BADGE: Record<string, string> = { COMPLETED: "badge-completed", IN_PROGRESS: "badge-intransit", DRIVER_EN_ROUTE: "badge-intransit", DRIVER_ASSIGNED: "badge-intransit", DRIVER_ARRIVED: "badge-intransit", CANCELLED: "badge-suspended" };

export default function TripsPage() {
  const [trips, setTrips] = useState<Trip[]>([]);
  const [status, setStatus] = useState("ALL");
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState<Trip | null>(null);

  const load = async () => {
    try {
      const token = getToken(); if (!token) return;
      const res = await apiFetch<{ data: { trips: Trip[] } }>("/api/v1/admin/trips?limit=30", { token });
      setTrips(res.data?.trips || res.data as any || []);
    } catch { setTrips([]); } finally { setLoading(false); }
  };
  useEffect(() => { load(); }, []);

  const filtered = trips.filter(t => status === "ALL" || t.status === status);

  return (
    <div className="p-6 space-y-5 max-w-7xl mx-auto">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div><h1 className="text-xl font-bold text-fairgo-dark">Trip Monitoring</h1><p className="text-sm text-gray-400">{trips.filter(t => ["IN_PROGRESS","DRIVER_EN_ROUTE","DRIVER_ASSIGNED"].includes(t.status)).length} active trips</p></div>
        <button onClick={load} className="flex items-center gap-1.5 text-xs text-gray-500 bg-white border border-gray-200 rounded-xl px-3 py-2 hover:bg-gray-50 transition shadow-card">
          <span className="material-icons-round text-sm">refresh</span>Refresh
        </button>
      </div>

      {/* Live Map */}
      <div className="bg-white rounded-2xl shadow-card overflow-hidden">
        <div className="p-4 border-b border-gray-100 flex items-center justify-between">
          <h2 className="font-semibold text-fairgo-dark">Live Map</h2>
          <span className="flex items-center gap-1.5 text-xs text-emerald-500"><div className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />Live tracking</span>
        </div>
        <div className="map-bg h-48 relative overflow-hidden">
          {[{ t: "25%", l: "20%" },{ t: "50%", l: "55%" },{ t: "15%", l: "72%" }].map((p,i) => (
            <div key={i} className="absolute w-8 h-8 bg-primary rounded-full flex items-center justify-center shadow-lg border-2 border-white" style={{ top: p.t, left: p.l }}>
              <span className="material-icons-round text-white text-sm">local_taxi</span>
            </div>
          ))}
          <div className="absolute top-1/2 left-0 right-0 h-px bg-white/40" />
          <div className="absolute top-0 bottom-0 left-1/2 w-px bg-white/40" />
          <div className="absolute bottom-3 right-3 bg-white/90 backdrop-blur rounded-xl px-3 py-1.5 text-xs font-medium text-fairgo-dark shadow">
            {trips.filter(t => ["IN_PROGRESS","DRIVER_EN_ROUTE"].includes(t.status)).length} cars on road
          </div>
        </div>
      </div>

      {/* Status filter */}
      <div className="flex gap-2 overflow-x-auto pb-1">
        {STATUS_FILTER.map(s => (
          <button key={s} onClick={() => setStatus(s)}
            className={`flex-shrink-0 px-4 py-2 text-xs font-semibold rounded-xl transition ${status === s ? "bg-primary text-white shadow-sm" : "bg-white text-gray-500 border border-gray-200 hover:border-primary/30 hover:text-primary"}`}>
            {s.replace(/_/g, " ")}
            <span className={`ml-1.5 ${status === s ? "text-white/80" : "text-gray-400"}`}>
              {s === "ALL" ? trips.length : trips.filter(t => t.status === s).length}
            </span>
          </button>
        ))}
      </div>

      <div className="bg-white rounded-2xl shadow-card overflow-hidden">
        {loading ? <div className="flex justify-center py-12"><div className="w-8 h-8 border-4 border-primary/30 border-t-primary rounded-full animate-spin" /></div> : (
          <table className="w-full">
            <thead><tr className="bg-gray-50 text-xs font-semibold text-gray-400 uppercase">
              <th className="text-left px-4 py-3">Trip ID</th><th className="text-left px-4 py-3">Passenger</th>
              <th className="text-left px-4 py-3">Driver</th><th className="text-left px-4 py-3">Route</th>
              <th className="text-left px-4 py-3">Vehicle</th><th className="text-right px-4 py-3">Fare</th>
              <th className="text-left px-4 py-3">Status</th><th className="text-left px-4 py-3">Time</th>
            </tr></thead>
            <tbody className="divide-y divide-gray-50">
              {filtered.length === 0 && <tr><td colSpan={8} className="py-10 text-center text-sm text-gray-400">No trips found</td></tr>}
              {filtered.map(t => (
                <tr key={t.id} className="hover:bg-gray-50/50 transition cursor-pointer" onClick={() => setSelected(t)}>
                  <td className="px-4 py-3 font-mono text-xs text-gray-400">{t.id.substring(0, 8)}…</td>
                  <td className="px-4 py-3 text-sm font-medium">{t.rideRequest?.customerProfile?.user?.name || "N/A"}</td>
                  <td className="px-4 py-3 text-sm text-gray-500">{t.driverProfile?.user?.name || "N/A"}</td>
                  <td className="px-4 py-3 max-w-[180px]">
                    <p className="text-xs text-gray-400 truncate">From: {t.rideRequest?.pickupAddress?.substring(0, 20)}</p>
                    <p className="text-xs text-fairgo-dark truncate">To: {t.rideRequest?.dropoffAddress?.substring(0, 20)}</p>
                  </td>
                  <td className="px-4 py-3">
                    <span className="material-icons-round text-gray-400 text-base">{VI[t.rideRequest?.vehicleType] || "directions_car"}</span>
                  </td>
                  <td className="px-4 py-3 text-sm font-bold text-primary text-right">฿{t.lockedFare?.toFixed(0)}</td>
                  <td className="px-4 py-3"><span className={BADGE[t.status] || "badge-pending"}>{t.status?.replace(/_/g, " ")}</span></td>
                  <td className="px-4 py-3 text-xs text-gray-400">{new Date(t.createdAt).toLocaleTimeString("th-TH", { hour: "2-digit", minute: "2-digit" })}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
