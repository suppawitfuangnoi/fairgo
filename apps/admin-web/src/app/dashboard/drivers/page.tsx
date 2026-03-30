"use client";
import { useState, useEffect } from "react";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";
import { useLang } from "@/lib/lang-context";

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

const VT_ICON: Record<string, string> = { TAXI: "local_taxi", MOTORCYCLE: "two_wheeler", TUKTUK: "electric_rickshaw" };

function StatusChip({ status }: { status: string }) {
  const map: Record<string, { cls: string; dot: string; label: string }> = {
    APPROVED:  { cls: "text-emerald-700 bg-emerald-100", dot: "bg-emerald-500", label: "Active" },
    PENDING:   { cls: "text-primary bg-primary/15", dot: "bg-primary animate-pulse", label: "Pending Verification" },
    REJECTED:  { cls: "text-red-600 bg-red-100", dot: "bg-red-500", label: "Rejected" },
    UNDER_REVIEW: { cls: "text-amber-700 bg-amber-100", dot: "bg-amber-400", label: "Under Review" },
  };
  const s = map[status] || { cls: "bg-slate-100 text-slate-500", dot: "bg-slate-400", label: status };
  return (
    <span className={`inline-flex items-center gap-1.5 px-3 py-1 text-xs font-bold rounded-full ${s.cls}`}>
      <span className={`w-1.5 h-1.5 rounded-full ${s.dot}`} />
      {s.label}
    </span>
  );
}

function initials(name: string): string {
  return name.split(" ").slice(0, 2).map(w => w[0]).join("").toUpperCase();
}

const TABS = ["PENDING", "APPROVED", "REJECTED", "ALL"];

export default function DriversPage() {
  const [drivers, setDrivers] = useState<DriverProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [tab, setTab] = useState("PENDING");
  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState<DriverProfile | null>(null);
  const [processing, setProcessing] = useState(false);
  const { t } = useLang();

  const load = async () => {
    setLoading(true);
    try {
      const token = getToken(); if (!token) return;
      const statusParam = tab !== "ALL" ? `&status=${tab}` : "";
      const searchParam = search ? `&search=${encodeURIComponent(search)}` : "";
      const res = await apiFetch<{ data: { drivers: DriverProfile[] } }>(
        `/api/v1/admin/drivers?limit=50${statusParam}${searchParam}`,
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
        token, method: "POST", body: { status },
      });
      setDrivers(prev => prev.map(d => d.id === driverProfileId ? { ...d, verificationStatus: status } : d));
      setSelected(null);
    } catch (e) { console.error(e); } finally { setProcessing(false); }
  };

  const blockDriver = async (driver: DriverProfile) => {
    const isSuspended = driver.user.status === "SUSPENDED";
    const action = isSuspended ? "Reactivate" : "Block";
    const newStatus = isSuspended ? "ACTIVE" : "SUSPENDED";
    if (!confirm(`${action} ${driver.user.name}?`)) return;
    setProcessing(true);
    try {
      const token = getToken(); if (!token) return;
      await apiFetch(`/api/v1/admin/users/${driver.user.id}`, { token, method: "PATCH", body: { status: newStatus } });
      setDrivers(prev => prev.map(d => d.id === driver.id ? { ...d, user: { ...d.user, status: newStatus } } : d));
      if (selected?.id === driver.id) setSelected(prev => prev ? { ...prev, user: { ...prev.user, status: newStatus } } : null);
    } catch (e) { console.error(e); } finally { setProcessing(false); }
  };

  const pendingCount = drivers.filter(d => d.verificationStatus === "PENDING").length;

  return (
    <div className="p-8 space-y-6 max-w-screen-xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-extrabold tracking-tight text-slate-900">{t.driversManagement}</h2>
          <p className="text-slate-500 mt-1">{t.driversReviewApprove}</p>
        </div>
        <div className="flex gap-3">
          {pendingCount > 0 && (
            <span className="flex items-center gap-1.5 text-xs font-semibold text-amber-700 bg-amber-100 px-3 py-2 rounded-lg">
              <span className="material-symbols-outlined text-sm">warning</span>
              {pendingCount} {t.driversPendingReview}
            </span>
          )}
          <button
            onClick={load}
            className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 text-slate-700 rounded-lg font-bold text-sm shadow-sm hover:bg-slate-50 transition"
          >
            <span className="material-symbols-outlined text-xl">refresh</span>
            {t.refresh}
          </button>
        </div>
      </div>

      {/* Search + Filters */}
      <div className="flex flex-wrap items-center gap-4 bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
        <div className="flex-1 min-w-[280px]">
          <div className="relative">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-lg">search</span>
            <input
              type="text"
              value={search}
              onChange={e => setSearch(e.target.value)}
              placeholder={t.driversSearch}
              className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border-none rounded-lg text-sm focus:ring-2 focus:ring-primary/30 outline-none"
            />
          </div>
        </div>
        <div className="flex gap-2">
          {TABS.map(t => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`px-4 py-2 rounded-lg text-sm font-bold transition ${
                tab === t ? "bg-primary text-white shadow-sm" : "bg-slate-100 text-slate-600 hover:bg-slate-200"
              }`}
            >
              {t === "ALL" ? "All" : t.charAt(0) + t.slice(1).toLowerCase()}
              <span className={`ml-1.5 text-xs ${tab === t ? "text-white/80" : "text-slate-400"}`}>
                ({t === "ALL" ? drivers.length : drivers.filter(d => d.verificationStatus === t).length})
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Table */}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200">
                {[t.driversName, t.dashboardVehicle, t.driversRating, t.driversTotalTrips, t.driversWallet, t.driversOnline, t.dashboardStatus, t.usersActions].map(h => (
                  <th key={h} className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i}>
                    {Array.from({ length: 8 }).map((_, j) => (
                      <td key={j} className="px-6 py-4">
                        <div className="h-4 bg-slate-100 rounded animate-pulse" />
                      </td>
                    ))}
                  </tr>
                ))
              ) : drivers.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-6 py-12 text-center">
                    <span className="material-symbols-outlined text-4xl text-slate-300 block mb-2">person_search</span>
                    <p className="text-sm text-slate-400">{t.driversNoDrivers}</p>
                  </td>
                </tr>
              ) : (
                drivers.map(d => {
                  const isPending = d.verificationStatus === "PENDING";
                  return (
                    <tr
                      key={d.id}
                      className={`transition-colors ${
                        isPending
                          ? "bg-primary/5 border-l-4 border-l-primary hover:bg-primary/10"
                          : "hover:bg-slate-50/50"
                      }`}
                    >
                      {/* Driver name */}
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div className={`w-9 h-9 rounded-full flex items-center justify-center font-bold text-sm ${
                            isPending ? "bg-primary text-white" : "bg-primary/20 text-primary"
                          }`}>
                            {initials(d.user.name)}
                          </div>
                          <div>
                            <p className="text-sm font-bold text-slate-900">{d.user.name}</p>
                            <p className="text-xs text-slate-500">{d.user.email || d.user.phone}</p>
                          </div>
                        </div>
                      </td>

                      {/* Vehicle */}
                      <td className="px-6 py-4">
                        {d.vehicles[0] ? (
                          <div className="flex items-center gap-1.5 text-sm text-slate-600">
                            <span className="material-symbols-outlined text-slate-400 text-base">
                              {VT_ICON[d.vehicles[0].type] || "directions_car"}
                            </span>
                            <div>
                              <p className="text-xs font-semibold">{d.vehicles[0].brand} {d.vehicles[0].model}</p>
                              <p className="text-xs text-slate-400">{d.vehicles[0].plateNumber}</p>
                            </div>
                          </div>
                        ) : <span className="text-slate-400 text-xs">—</span>}
                      </td>

                      {/* Rating */}
                      <td className="px-6 py-4">
                        {d.averageRating ? (
                          <div className="flex items-center gap-1">
                            <span className="text-sm font-bold text-slate-900">{d.averageRating.toFixed(1)}</span>
                            <span className="material-symbols-outlined text-amber-400 text-base" style={{ fontVariationSettings: "'FILL' 1" }}>star</span>
                          </div>
                        ) : <span className="text-slate-400 text-sm">—</span>}
                      </td>

                      {/* Total trips */}
                      <td className="px-6 py-4 font-semibold text-sm text-slate-900">
                        {(d._count?.trips ?? d.totalTrips ?? 0).toLocaleString()}
                      </td>

                      {/* Wallet */}
                      <td className="px-6 py-4 text-sm font-semibold text-slate-700">
                        {d.wallet ? `฿${d.wallet.balance.toFixed(0)}` : "—"}
                      </td>

                      {/* Online status */}
                      <td className="px-6 py-4">
                        <div className={`flex items-center gap-1.5 text-xs font-semibold ${d.isOnline ? "text-emerald-600" : "text-slate-400"}`}>
                          <div className={`w-2 h-2 rounded-full ${d.isOnline ? "bg-emerald-500" : "bg-slate-300"}`} />
                          {d.isOnline ? t.driversOnline : t.driversOffline}
                        </div>
                      </td>

                      {/* Status */}
                      <td className="px-6 py-4">
                        <StatusChip status={d.verificationStatus} />
                      </td>

                      {/* Actions */}
                      <td className="px-6 py-4">
                        {isPending ? (
                          <button
                            onClick={() => setSelected(d)}
                            className="px-4 py-1.5 bg-primary text-white rounded-lg text-xs font-bold shadow-sm hover:opacity-90 transition"
                          >
                            {t.driversVerifyDriver}
                          </button>
                        ) : (
                          <div className="flex gap-1">
                            <button onClick={() => setSelected(d)} className="p-1.5 text-slate-400 hover:text-primary transition" title="View">
                              <span className="material-symbols-outlined text-xl">visibility</span>
                            </button>
                            <button onClick={() => setSelected(d)} className="p-1.5 text-slate-400 hover:text-primary transition" title="Edit">
                              <span className="material-symbols-outlined text-xl">edit</span>
                            </button>
                            <button
                              onClick={() => blockDriver(d)}
                              disabled={processing}
                              className={`p-1.5 transition disabled:opacity-50 ${d.user.status === "SUSPENDED" ? "text-emerald-400 hover:text-emerald-600" : "text-slate-400 hover:text-red-500"}`}
                              title={d.user.status === "SUSPENDED" ? "Reactivate" : "Block"}
                            >
                              <span className="material-symbols-outlined text-xl">{d.user.status === "SUSPENDED" ? "check_circle" : "block"}</span>
                            </button>
                          </div>
                        )}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Table footer */}
        {!loading && drivers.length > 0 && (
          <div className="px-6 py-3 border-t border-slate-100 bg-slate-50 flex items-center justify-between">
            <p className="text-xs text-slate-500">{drivers.length} {t.driversNoDrivers.toLowerCase()}</p>
            <p className="text-xs text-slate-400">{t.usersJoined}: sorted by newest</p>
          </div>
        )}
      </div>

      {/* Driver detail / verify modal */}
      {selected && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4" onClick={() => setSelected(null)}>
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-lg p-6 max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-5">
              <h3 className="font-bold text-slate-900 text-lg">{t.driversProfile}</h3>
              <button onClick={() => setSelected(null)} className="text-slate-400 hover:text-slate-600">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            {/* Avatar + info */}
            <div className="flex items-center gap-4 mb-5">
              <div className="w-14 h-14 bg-primary/10 rounded-full flex items-center justify-center font-bold text-primary text-xl">
                {initials(selected.user.name)}
              </div>
              <div>
                <p className="font-bold text-slate-900 text-lg">{selected.user.name}</p>
                <p className="text-sm text-slate-500">{selected.user.phone}</p>
                {selected.user.email && <p className="text-xs text-slate-400">{selected.user.email}</p>}
                <p className="text-xs text-slate-400 mt-0.5">
                  Joined {new Date(selected.user.createdAt).toLocaleDateString("th-TH")}
                </p>
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-3 mb-5 text-center">
              <div className="bg-slate-50 rounded-xl p-3">
                <p className="text-xs text-slate-400 mb-1">{t.driversRating}</p>
                <p className="font-bold text-slate-900">{selected.averageRating?.toFixed(1) || "—"}</p>
              </div>
              <div className="bg-slate-50 rounded-xl p-3">
                <p className="text-xs text-slate-400 mb-1">{t.usersTrips}</p>
                <p className="font-bold text-slate-900">{selected._count?.trips ?? selected.totalTrips ?? 0}</p>
              </div>
              <div className="bg-slate-50 rounded-xl p-3">
                <p className="text-xs text-slate-400 mb-1">{t.driversWallet}</p>
                <p className="font-bold text-slate-900">{t.baht}{selected.wallet?.balance.toFixed(0) || "0"}</p>
              </div>
            </div>

            {/* Vehicle */}
            {selected.vehicles.length > 0 && (
              <div className="mb-4">
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wide mb-2">{t.dashboardVehicle}</p>
                {selected.vehicles.map((v, i) => (
                  <div key={i} className="bg-slate-50 rounded-xl p-3 flex items-center gap-3">
                    <span className="material-symbols-outlined text-primary">{VT_ICON[v.type] || "directions_car"}</span>
                    <div>
                      <p className="text-sm font-semibold text-slate-900">{v.type} · {v.plateNumber}</p>
                      <p className="text-xs text-slate-500">{v.brand} {v.model}</p>
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Documents */}
            {selected.documents.length > 0 && (
              <div className="mb-5">
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wide mb-2">{t.driversDocuments}</p>
                <div className="space-y-2">
                  {selected.documents.map((doc, i) => (
                    <div key={i} className="flex items-center justify-between bg-slate-50 rounded-xl p-3">
                      <div className="flex items-center gap-2">
                        <span className="material-symbols-outlined text-slate-400 text-base">description</span>
                        <span className="text-xs text-slate-600 font-medium">{doc.type.replace(/_/g, " ")}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className={`text-xs font-semibold ${
                          doc.status === "APPROVED" ? "text-emerald-600"
                          : doc.status === "PENDING" ? "text-amber-600"
                          : "text-red-500"
                        }`}>{doc.status}</span>
                        {doc.url && (
                          <a href={doc.url} target="_blank" rel="noopener noreferrer"
                            className="text-xs text-primary hover:underline font-medium">View</a>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Action buttons */}
            {selected.verificationStatus === "PENDING" ? (
              <div className="flex gap-3">
                <button
                  onClick={() => verifyDriver(selected.id, "APPROVED")}
                  disabled={processing}
                  className="flex-1 bg-primary text-white rounded-xl py-3 font-bold text-sm hover:opacity-90 transition disabled:opacity-50"
                >
                  {processing ? "Processing..." : `✓ ${t.driversApprove}`}
                </button>
                <button
                  onClick={() => verifyDriver(selected.id, "REJECTED")}
                  disabled={processing}
                  className="flex-1 bg-red-50 text-red-500 border border-red-200 rounded-xl py-3 font-bold text-sm hover:bg-red-100 transition disabled:opacity-50"
                >
                  {processing ? "..." : `✕ ${t.driversReject}`}
                </button>
              </div>
            ) : (
              <div className="flex gap-3 mt-2">
                {selected.user.status === "SUSPENDED" ? (
                  <button
                    onClick={() => blockDriver(selected)}
                    disabled={processing}
                    className="flex-1 bg-emerald-600 text-white rounded-xl py-2.5 font-bold text-sm hover:bg-emerald-700 transition disabled:opacity-50"
                  >
                    {processing ? "Processing…" : "Reactivate Driver"}
                  </button>
                ) : (
                  <button
                    onClick={() => blockDriver(selected)}
                    disabled={processing}
                    className="flex-1 bg-red-50 text-red-500 border border-red-200 rounded-xl py-2.5 font-bold text-sm hover:bg-red-100 transition disabled:opacity-50"
                  >
                    {processing ? "Processing…" : "Block Driver"}
                  </button>
                )}
                <button onClick={() => setSelected(null)} className="px-5 border border-slate-200 text-slate-500 rounded-xl py-2.5 text-sm font-medium hover:bg-slate-50 transition">
                  Close
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
