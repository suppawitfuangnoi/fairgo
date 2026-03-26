"use client";
import { useState, useEffect } from "react";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";

interface DriverProfile {
  id: string;
  verificationStatus: string;
  isOnline: boolean;
  isVerified: boolean;
  averageRating: number;
  totalTrips: number;
  user: { id: string; name: string; phone: string; email?: string; status: string; createdAt: string };
  vehicles: { type: string; plateNumber: string; brand: string; model: string }[];
  documents: { type: string; status: string; url: string }[];
  wallet?: { balance: number };
  _count?: { trips: number };
}

const VS_COLOR: Record<string, string> = {
  PENDING: "badge-pending",
  APPROVED: "badge-active",
  REJECTED: "badge-suspended",
  UNDER_REVIEW: "badge-intransit",
};

const VT_ICON: Record<string, string> = { TAXI: "local_taxi", MOTORCYCLE: "two_wheeler", TUKTUK: "electric_rickshaw" };

export default function DriversPage() {
  const [drivers, setDrivers] = useState<DriverProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [tab, setTab] = useState("PENDING");
  const [selected, setSelected] = useState<DriverProfile | null>(null);
  const [processing, setProcessing] = useState(false);
  const [search, setSearch] = useState("");

  const load = async () => {
    setLoading(true);
    try {
      const token = getToken(); if (!token) return;
      const statusParam = tab !== "ALL" ? `&status=${tab}` : "";
      const searchParam = search ? `&search=${encodeURIComponent(search)}` : "";
      const res = await apiFetch<{ data: { drivers: DriverProfile[] } }>(
        `/api/v1/admin/drivers?limit=30${statusParam}${searchParam}`,
        { token }
      );
      setDrivers(res.data?.drivers || []);
    } catch { setDrivers([]); } finally { setLoading(false); }
  };

  useEffect(() => { load(); }, [tab, search]);

  const verifyDriver = async (driverProfileId: string, status: "APPROVED" | "REJECTED") => {
    setProcessing(true);
    try {
      const token = getToken(); if (!token) return;
      await apiFetch(`/api/v1/admin/drivers/${driverProfileId}/verify`, {
        token,
        method: "POST",
        body: { status },
      });
      setDrivers(prev => prev.map(d => d.id === driverProfileId ? { ...d, verificationStatus: status } : d));
      setSelected(null);
    } catch (e) { console.error(e); } finally { setProcessing(false); }
  };

  const TABS = ["PENDING", "APPROVED", "REJECTED", "ALL"];

  const pendingCount = drivers.filter(d => d.verificationStatus === "PENDING").length;

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-xl font-bold text-fairgo-dark">Driver Verification</h1>
          <p className="text-sm text-gray-400 mt-0.5">Review and approve driver applications</p>
        </div>
        <div className="flex items-center gap-2">
          {pendingCount > 0 && (
            <span className="flex items-center gap-1 text-xs font-semibold text-red-500 bg-red-50 px-3 py-1.5 rounded-full">
              <span className="material-icons-round text-sm">warning</span>
              {pendingCount} pending review
            </span>
          )}
          <button onClick={load} className="flex items-center gap-1.5 text-xs text-gray-500 bg-white border border-gray-200 rounded-lg px-3 py-2 hover:bg-gray-50 transition">
            <span className="material-icons-round text-sm">refresh</span>Refresh
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-2 items-center">
        <div className="flex gap-1.5">
          {TABS.map(t => (
            <button key={t} onClick={() => setTab(t)}
              className={`text-xs px-3 py-1.5 rounded-lg font-medium transition ${
                tab === t ? "bg-primary text-white" : "bg-white text-gray-500 border border-gray-200 hover:bg-gray-50"
              }`}>
              {t}
            </button>
          ))}
        </div>
        <div className="relative ml-auto">
          <span className="absolute left-3 top-1/2 -translate-y-1/2 material-icons-round text-gray-300 text-base">search</span>
          <input
            type="text" placeholder="Search drivers..."
            value={search} onChange={e => setSearch(e.target.value)}
            className="pl-9 pr-4 py-2 text-xs bg-white border border-gray-200 rounded-xl w-48 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition"
          />
        </div>
      </div>

      {/* Driver cards */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {[1,2,3,4,5,6].map(i => <div key={i} className="h-40 bg-white rounded-2xl animate-pulse shadow-card" />)}
        </div>
      ) : drivers.length === 0 ? (
        <div className="bg-white rounded-2xl p-12 text-center shadow-card">
          <span className="material-icons-round text-4xl text-gray-200 block mb-2">person_search</span>
          <p className="text-sm text-gray-400">No drivers found</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {drivers.map(d => (
            <div key={d.id} className="bg-white rounded-2xl p-5 shadow-card hover:shadow-lg transition-shadow">
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center">
                    <span className="material-icons-round text-primary">person</span>
                  </div>
                  <div>
                    <p className="font-semibold text-fairgo-dark text-sm">{d.user.name}</p>
                    <p className="text-xs text-gray-400">{d.user.phone}</p>
                  </div>
                </div>
                <span className={VS_COLOR[d.verificationStatus] || "badge-pending"}>
                  {d.verificationStatus}
                </span>
              </div>

              {d.vehicles[0] && (
                <div className="flex items-center gap-2 text-xs text-gray-500 mb-2">
                  <span className="material-icons-round text-sm">{VT_ICON[d.vehicles[0].type] || "directions_car"}</span>
                  {d.vehicles[0].brand} {d.vehicles[0].model} · {d.vehicles[0].plateNumber}
                </div>
              )}

              <div className="flex items-center gap-3 text-xs text-gray-400 mb-3">
                <div className="flex items-center gap-1">
                  <span className="material-icons-round text-amber-400 text-xs">star</span>
                  {d.averageRating?.toFixed(1) || "N/A"}
                </div>
                <div>{d._count?.trips ?? d.totalTrips ?? 0} trips</div>
                {d.wallet && <div>฿{d.wallet.balance.toFixed(0)} wallet</div>}
                <div className={`ml-auto flex items-center gap-1 ${d.isOnline ? "text-emerald-500" : "text-gray-300"}`}>
                  <div className={`w-1.5 h-1.5 rounded-full ${d.isOnline ? "bg-emerald-400" : "bg-gray-300"}`} />
                  {d.isOnline ? "Online" : "Offline"}
                </div>
              </div>

              <div className="flex gap-2">
                <button onClick={() => setSelected(d)}
                  className="flex-1 text-xs bg-gray-50 hover:bg-gray-100 text-gray-600 rounded-xl py-2 font-medium transition">
                  View Details
                </button>
                {d.verificationStatus === "PENDING" && (
                  <>
                    <button
                      onClick={() => verifyDriver(d.id, "APPROVED")}
                      disabled={processing}
                      className="flex-1 text-xs bg-primary text-white rounded-xl py-2 font-medium hover:bg-primary-600 transition disabled:opacity-50"
                    >
                      Approve
                    </button>
                    <button
                      onClick={() => verifyDriver(d.id, "REJECTED")}
                      disabled={processing}
                      className="flex-1 text-xs bg-red-50 text-red-500 rounded-xl py-2 font-medium hover:bg-red-100 transition disabled:opacity-50"
                    >
                      Reject
                    </button>
                  </>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Driver detail modal */}
      {selected && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-lg p-6 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-5">
              <h3 className="font-semibold text-fairgo-dark">Driver Profile</h3>
              <button onClick={() => setSelected(null)} className="text-gray-400 hover:text-gray-600">
                <span className="material-icons-round">close</span>
              </button>
            </div>

            <div className="flex items-center gap-4 mb-5">
              <div className="w-14 h-14 bg-primary/10 rounded-full flex items-center justify-center">
                <span className="material-icons-round text-primary text-2xl">person</span>
              </div>
              <div>
                <p className="font-bold text-fairgo-dark">{selected.user.name}</p>
                <p className="text-sm text-gray-400">{selected.user.phone}</p>
                {selected.user.email && <p className="text-xs text-gray-400">{selected.user.email}</p>}
                <p className="text-xs text-gray-400 mt-0.5">
                  Joined {new Date(selected.user.createdAt).toLocaleDateString("th-TH")}
                </p>
              </div>
            </div>

            {selected.vehicles.length > 0 && (
              <div className="mb-4">
                <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">Vehicle</p>
                {selected.vehicles.map((v, i) => (
                  <div key={i} className="bg-gray-50 rounded-xl p-3 text-sm">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="material-icons-round text-primary text-base">{VT_ICON[v.type] || "directions_car"}</span>
                      <span className="font-medium text-fairgo-dark">{v.type}</span>
                    </div>
                    <p className="text-xs text-gray-500">{v.brand} {v.model} · {v.plateNumber}</p>
                  </div>
                ))}
              </div>
            )}

            {selected.documents.length > 0 && (
              <div className="mb-4">
                <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">Documents</p>
                <div className="space-y-2">
                  {selected.documents.map((doc, i) => (
                    <div key={i} className="flex items-center justify-between bg-gray-50 rounded-xl p-3">
                      <div className="flex items-center gap-2">
                        <span className="material-icons-round text-gray-400 text-sm">description</span>
                        <span className="text-xs text-gray-600">{doc.type.replace(/_/g, " ")}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className={`text-xs font-medium ${doc.status === "APPROVED" ? "text-emerald-500" : doc.status === "PENDING" ? "text-amber-500" : "text-red-500"}`}>
                          {doc.status}
                        </span>
                        {doc.url && (
                          <a href={doc.url} target="_blank" rel="noopener noreferrer"
                            className="text-xs text-primary hover:underline">View</a>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            <div className="grid grid-cols-3 gap-3 mb-5 text-center">
              <div className="bg-gray-50 rounded-xl p-3">
                <p className="text-xs text-gray-400">Rating</p>
                <p className="font-bold text-fairgo-dark">{selected.averageRating?.toFixed(1) || "—"}</p>
              </div>
              <div className="bg-gray-50 rounded-xl p-3">
                <p className="text-xs text-gray-400">Trips</p>
                <p className="font-bold text-fairgo-dark">{selected._count?.trips ?? selected.totalTrips ?? 0}</p>
              </div>
              <div className="bg-gray-50 rounded-xl p-3">
                <p className="text-xs text-gray-400">Wallet</p>
                <p className="font-bold text-fairgo-dark">฿{selected.wallet?.balance.toFixed(0) || "0"}</p>
              </div>
            </div>

            {selected.verificationStatus === "PENDING" && (
              <div className="flex gap-3">
                <button
                  onClick={() => verifyDriver(selected.id, "APPROVED")}
                  disabled={processing}
                  className="flex-1 bg-primary text-white rounded-xl py-3 font-semibold hover:bg-primary-600 transition disabled:opacity-50"
                >
                  {processing ? "Processing..." : "✓ Approve Driver"}
                </button>
                <button
                  onClick={() => verifyDriver(selected.id, "REJECTED")}
                  disabled={processing}
                  className="flex-1 bg-red-50 text-red-500 rounded-xl py-3 font-semibold hover:bg-red-100 transition disabled:opacity-50"
                >
                  {processing ? "Processing..." : "✕ Reject"}
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
