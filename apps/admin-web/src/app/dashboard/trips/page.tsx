"use client";
import { useState, useEffect } from "react";
import dynamic from "next/dynamic";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";
import { useAdminSocket } from "@/hooks/useSocket";
import { useLang } from "@/lib/lang-context";

const LiveMap = dynamic(() => import("@/components/LiveMap"), { ssr: false, loading: () => (
  <div className="h-full flex items-center justify-center bg-slate-100">
    <div className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin" />
  </div>
) });

interface Trip {
  id: string; status: string; lockedFare: number; createdAt: string;
  rideRequest: { pickupAddress: string; dropoffAddress: string; vehicleType: string; customerProfile: { user: { name: string } } };
  driverProfile: { user: { name: string }; vehicles: { plateNumber: string }[] };
}

const VI: Record<string, string> = { TAXI: "local_taxi", MOTORCYCLE: "two_wheeler", TUKTUK: "electric_rickshaw" };
const STATUS_FILTERS = ["ALL", "IN_PROGRESS", "DRIVER_EN_ROUTE", "COMPLETED", "CANCELLED"];
const ACTIVE_STATUSES = ["IN_PROGRESS", "DRIVER_EN_ROUTE", "DRIVER_ASSIGNED", "DRIVER_ARRIVED"];

function StatusBadge({ status }: { status: string }) {
  const map: Record<string, { cls: string; label: string }> = {
    COMPLETED:      { cls: "bg-emerald-100 text-emerald-700", label: "Completed" },
    IN_PROGRESS:    { cls: "bg-primary/10 text-primary", label: "Ongoing" },
    DRIVER_EN_ROUTE:{ cls: "bg-primary/10 text-primary", label: "En Route" },
    DRIVER_ASSIGNED:{ cls: "bg-amber-100 text-amber-700", label: "Assigned" },
    DRIVER_ARRIVED: { cls: "bg-blue-100 text-blue-700", label: "Arrived" },
    CANCELLED:      { cls: "bg-red-100 text-red-600", label: "Cancelled" },
  };
  const s = map[status] || { cls: "bg-slate-100 text-slate-500", label: status.replace(/_/g, " ") };
  return <span className={`px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider rounded-full ${s.cls}`}>{s.label}</span>;
}

function elapsed(dateStr: string): string {
  const mins = Math.floor((Date.now() - new Date(dateStr).getTime()) / 60000);
  if (mins < 60) return `${mins} min ago`;
  return `${Math.floor(mins / 60)}h ${mins % 60}m ago`;
}

export default function TripsPage() {
  const [trips, setTrips] = useState<Trip[]>([]);
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState<Trip | null>(null);
  const { drivers, isConnected } = useAdminSocket();
  const { t } = useLang();

  const load = async () => {
    try {
      const token = getToken(); if (!token) return;
      const res = await apiFetch<{ data: { trips: Trip[] } }>("/api/v1/admin/trips?limit=50", { token });
      setTrips(res.data?.trips || (res.data as unknown as Trip[]) || []);
    } catch { setTrips([]); } finally { setLoading(false); }
  };

  useEffect(() => { load(); const iv = setInterval(load, 15000); return () => clearInterval(iv); }, []);

  const activeCount = trips.filter(t => ACTIVE_STATUSES.includes(t.status)).length;

  const filtered = trips.filter(t => {
    const statusOk = statusFilter === "ALL" || t.status === statusFilter;
    const searchOk = !search
      || t.id.includes(search)
      || t.driverProfile?.user?.name?.toLowerCase().includes(search.toLowerCase())
      || t.rideRequest?.customerProfile?.user?.name?.toLowerCase().includes(search.toLowerCase());
    return statusOk && searchOk;
  });

  return (
    // Full-height layout: map fills left, sidebar on right
    <div className="flex h-[calc(100vh-64px)] overflow-hidden bg-fairgo-bg">

      {/* ── MAP SECTION ── */}
      <section className="flex-1 relative">
        {/* Live Map */}
        <div className="absolute inset-0">
          <LiveMap drivers={drivers} height="100%" />
        </div>

        {/* Fleet Status overlay */}
        <div className="absolute top-6 left-6 z-10 flex flex-col gap-3">
          <div className="bg-white rounded-xl shadow-lg border border-slate-200 p-4 min-w-[200px]">
            <div className="flex justify-between items-center mb-3">
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500">Fleet Status</h3>
              <span className={`flex h-2 w-2 rounded-full ${isConnected ? "bg-emerald-500 animate-ping" : "bg-amber-400"}`} />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs text-slate-500">Active Trips</p>
                <p className="text-2xl font-bold text-primary">{activeCount}</p>
              </div>
              <div>
                <p className="text-xs text-slate-500">Drivers Live</p>
                <p className="text-2xl font-bold text-slate-700">{isConnected ? drivers.length : "—"}</p>
              </div>
            </div>
          </div>

          {/* Map controls */}
          <div className="flex items-center gap-2">
            <button className="bg-white p-2 rounded-lg shadow-lg text-slate-600 hover:text-primary transition-colors" title="My location">
              <span className="material-symbols-outlined text-lg">my_location</span>
            </button>
            <div className="flex flex-col bg-white rounded-lg shadow-lg">
              <button className="p-2 border-b border-slate-100 hover:text-primary text-slate-600">
                <span className="material-symbols-outlined text-lg">add</span>
              </button>
              <button className="p-2 hover:text-primary text-slate-600">
                <span className="material-symbols-outlined text-lg">remove</span>
              </button>
            </div>
          </div>
        </div>

        {/* Map view toggles */}
        <div className="absolute bottom-6 left-6 z-10 flex gap-2">
          <div className="bg-white p-1 rounded-xl shadow-lg flex gap-1">
            {["Map", "Satellite", "Terrain"].map((v, i) => (
              <button key={v} className={`px-3 py-1.5 rounded-lg text-xs font-bold transition ${i === 0 ? "bg-slate-100 text-slate-700" : "text-slate-400 hover:bg-slate-50"}`}>{v}</button>
            ))}
          </div>
        </div>
      </section>

      {/* ── TRIPS SIDEBAR ── */}
      <aside className="w-[400px] flex-shrink-0 bg-white border-l border-slate-200 flex flex-col z-20 shadow-xl">

        {/* Sidebar header */}
        <div className="p-5 border-b border-slate-100">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-bold text-slate-900">{t.tripsOngoingTrips}</h2>
            <button onClick={load} className="text-primary text-sm font-semibold flex items-center gap-1 hover:opacity-80">
              <span className="material-symbols-outlined text-sm">refresh</span>
              {t.refresh}
            </button>
          </div>

          {/* Status filter pills */}
          <div className="flex gap-2 overflow-x-auto pb-2" style={{ scrollbarWidth: "none" }}>
            {STATUS_FILTERS.map(s => {
              const count = s === "ALL" ? trips.length : trips.filter(t => t.status === s).length;
              return (
                <button
                  key={s}
                  onClick={() => setStatusFilter(s)}
                  className={`flex-shrink-0 px-3 py-1.5 rounded-lg text-xs font-bold transition whitespace-nowrap ${
                    statusFilter === s ? "bg-primary text-white" : "bg-slate-100 text-slate-600 hover:bg-slate-200"
                  }`}
                >
                  {s === "ALL" ? `All Trips (${count})` : s.replace(/_/g, " ")}
                  {s !== "ALL" && count > 0 && (
                    <span className={`ml-1 ${statusFilter === s ? "text-white/80" : "text-slate-400"}`}>({count})</span>
                  )}
                </button>
              );
            })}
          </div>

          {/* Search */}
          <div className="relative mt-3">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm">filter_list</span>
            <input
              type="text"
              placeholder={t.tripsSearchPlaceholder}
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="w-full bg-slate-50 border border-slate-200 rounded-xl pl-10 pr-4 py-2 text-sm focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none transition"
            />
          </div>
        </div>

        {/* Trip list */}
        <div className="flex-1 overflow-y-auto divide-y divide-slate-100">
          {loading ? (
            <div className="flex justify-center py-12">
              <div className="w-8 h-8 border-2 border-primary/30 border-t-primary rounded-full animate-spin" />
            </div>
          ) : filtered.length === 0 ? (
            <div className="py-12 text-center">
              <span className="material-symbols-outlined text-3xl text-slate-300 block mb-2">directions_car</span>
              <p className="text-sm text-slate-400">{t.tripsNoTrips}</p>
            </div>
          ) : (
            filtered.map(t => (
              <div
                key={t.id}
                onClick={() => setSelected(t)}
                className={`p-4 hover:bg-slate-50 cursor-pointer transition-colors ${
                  selected?.id === t.id ? "bg-primary/5 border-l-4 border-l-primary" : ""
                }`}
              >
                {/* Trip ID + fare */}
                <div className="flex justify-between items-start mb-3">
                  <div className="flex items-center gap-2">
                    <span className="bg-primary/15 text-primary text-[10px] font-black px-2 py-0.5 rounded">
                      ID: {t.id.substring(0, 6).toUpperCase()}
                    </span>
                    <span className="text-xs text-slate-400">{elapsed(t.createdAt)}</span>
                    <StatusBadge status={t.status} />
                  </div>
                  <span className="text-primary font-bold text-sm">฿{t.lockedFare?.toFixed(0) || "—"}</span>
                </div>

                {/* Route */}
                <div className="flex gap-3 mb-3">
                  <div className="flex flex-col items-center gap-0.5 pt-1 flex-shrink-0">
                    <div className="w-2 h-2 rounded-full border-2 border-primary" />
                    <div className="w-px h-5 bg-slate-200" />
                    <div className="w-2 h-2 rounded-full bg-primary" />
                  </div>
                  <div className="flex flex-col gap-1 min-w-0">
                    <p className="text-xs font-medium text-slate-500 truncate">
                      {t.rideRequest?.pickupAddress?.split(",")[0] || "—"}
                    </p>
                    <p className="text-xs font-bold text-slate-800 truncate">
                      {trip.rideRequest?.dropoffAddress?.split(",")[0] || "—"}
                    </p>
                  </div>
                </div>

                {/* Driver + Passenger */}
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className="w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center font-bold text-primary text-xs">
                      {(t.driverProfile?.user?.name || "D")[0].toUpperCase()}
                    </div>
                    <div>
                      <p className="text-[9px] text-slate-400 uppercase font-bold tracking-tight">Driver</p>
                      <p className="text-xs font-bold text-slate-800">{t.driverProfile?.user?.name || "N/A"}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="text-right">
                      <p className="text-[9px] text-slate-400 uppercase font-bold tracking-tight">Passenger</p>
                      <p className="text-xs font-bold text-slate-800">
                        {t.rideRequest?.customerProfile?.user?.name || "N/A"}
                      </p>
                    </div>
                    <div className="w-7 h-7 rounded-full bg-slate-100 flex items-center justify-center font-bold text-slate-500 text-xs">
                      {(t.rideRequest?.customerProfile?.user?.name || "P")[0].toUpperCase()}
                    </div>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Footer: total count */}
        <div className="p-4 border-t border-slate-100 bg-slate-50 flex items-center justify-between">
          <span className="text-xs text-slate-500">{filtered.length} {t.tripsTripsShown}</span>
          <span className={`flex items-center gap-1.5 text-xs font-medium ${isConnected ? "text-emerald-600" : "text-amber-600"}`}>
            <div className={`w-1.5 h-1.5 rounded-full ${isConnected ? "bg-emerald-500 animate-pulse" : "bg-amber-400"}`} />
            {isConnected ? t.liveTracking : t.httpPolling}
          </span>
        </div>
      </aside>

      {/* Trip Detail Modal */}
      {selected && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4" onClick={() => setSelected(null)}>
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-md p-6" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-5">
              <div>
                <h3 className="font-bold text-slate-900">Trip Detail</h3>
                <p className="text-xs text-slate-400 font-mono">{selected.id}</p>
              </div>
              <button onClick={() => setSelected(null)} className="text-slate-400 hover:text-slate-600 p-1">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            <StatusBadge status={selected.status} />

            <div className="mt-4 space-y-3">
              <div className="bg-slate-50 rounded-xl p-4">
                <div className="flex gap-3">
                  <div className="flex flex-col items-center gap-1 pt-1 flex-shrink-0">
                    <div className="w-2 h-2 rounded-full border-2 border-primary" />
                    <div className="w-px flex-1 bg-slate-300" style={{ minHeight: 20 }} />
                    <div className="w-2 h-2 rounded-full bg-primary" />
                  </div>
                  <div className="flex flex-col gap-2 flex-1">
                    <div>
                      <p className="text-[10px] text-slate-400 uppercase font-bold">{t.tripsPickup}</p>
                      <p className="text-sm font-medium text-slate-900">{selected.rideRequest?.pickupAddress || "—"}</p>
                    </div>
                    <div>
                      <p className="text-[10px] text-slate-400 uppercase font-bold">{t.tripsDropoff}</p>
                      <p className="text-sm font-medium text-slate-900">{selected.rideRequest?.dropoffAddress || "—"}</p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-3 gap-3 text-center">
                <div className="bg-slate-50 rounded-xl p-3">
                  <p className="text-xs text-slate-400">{t.tripsFare}</p>
                  <p className="font-bold text-primary">{t.baht}{selected.lockedFare?.toFixed(0) || "—"}</p>
                </div>
                <div className="bg-slate-50 rounded-xl p-3">
                  <p className="text-xs text-slate-400">{t.dashboardVehicle}</p>
                  <p className="font-bold text-slate-900 text-xs">{selected.rideRequest?.vehicleType || "—"}</p>
                </div>
                <div className="bg-slate-50 rounded-xl p-3">
                  <p className="text-xs text-slate-400">{t.tripsTime}</p>
                  <p className="font-bold text-slate-900 text-xs">
                    {new Date(selected.createdAt).toLocaleTimeString("th-TH", { hour: "2-digit", minute: "2-digit" })}
                  </p>
                </div>
              </div>

              <div className="flex gap-3">
                <div className="flex-1 bg-slate-50 rounded-xl p-3">
                  <p className="text-[10px] text-slate-400 uppercase font-bold mb-1">{t.dashboardDriver}</p>
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center font-bold text-primary text-xs">
                      {(selected.driverProfile?.user?.name || "D")[0].toUpperCase()}
                    </div>
                    <div>
                      <p className="text-sm font-semibold text-slate-900">{selected.driverProfile?.user?.name || "N/A"}</p>
                      {selected.driverProfile?.vehicles?.[0] && (
                        <p className="text-xs text-slate-400">{selected.driverProfile.vehicles[0].plateNumber}</p>
                      )}
                    </div>
                  </div>
                </div>
                <div className="flex-1 bg-slate-50 rounded-xl p-3">
                  <p className="text-[10px] text-slate-400 uppercase font-bold mb-1">{t.dashboardPassenger}</p>
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-full bg-slate-200 flex items-center justify-center font-bold text-slate-500 text-xs">
                      {(selected.rideRequest?.customerProfile?.user?.name || "P")[0].toUpperCase()}
                    </div>
                    <p className="text-sm font-semibold text-slate-900">
                      {selected.rideRequest?.customerProfile?.user?.name || "N/A"}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
