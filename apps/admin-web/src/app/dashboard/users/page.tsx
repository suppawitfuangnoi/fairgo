"use client";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";
import { useLang } from "@/lib/lang-context";

interface User {
  id: string; name: string; phone: string; email?: string; role: string; status: string; createdAt: string;
  driverProfile?: {
    verificationStatus: string; averageRating: number; totalTrips: number;
    vehicles: { type: string; plateNumber: string }[];
  };
}

const VT_ICON: Record<string, string> = { TAXI: "local_taxi", MOTORCYCLE: "two_wheeler", TUKTUK: "electric_rickshaw" };
const PAGE_SIZE = 20;

function TypeBadge({ role }: { role: string }) {
  const map: Record<string, string> = {
    DRIVER: "bg-slate-100 text-slate-700",
    CUSTOMER: "bg-slate-100 text-slate-700",
    ADMIN: "bg-purple-100 text-purple-700",
  };
  const label = role === "CUSTOMER" ? "Passenger" : role.charAt(0) + role.slice(1).toLowerCase();
  return <span className={`px-2.5 py-1 text-xs font-bold rounded-full ${map[role] || "bg-slate-100 text-slate-600"}`}>{label}</span>;
}

function StatusChip({ status, role, driverStatus }: { status: string; role: string; driverStatus?: string }) {
  if (role === "DRIVER" && driverStatus) {
    const map: Record<string, { cls: string; dot: string; label: string }> = {
      APPROVED:  { cls: "text-emerald-700 bg-emerald-100", dot: "bg-emerald-500", label: "Active" },
      PENDING:   { cls: "text-primary bg-primary/15", dot: "bg-primary animate-pulse", label: "Pending Verification" },
      REJECTED:  { cls: "text-red-600 bg-red-100", dot: "bg-red-500", label: "Rejected" },
    };
    const s = map[driverStatus] || { cls: "bg-slate-100 text-slate-500", dot: "bg-slate-400", label: driverStatus };
    return (
      <span className={`inline-flex items-center gap-1.5 px-3 py-1 text-xs font-bold rounded-full ${s.cls}`}>
        <span className={`w-1.5 h-1.5 rounded-full ${s.dot}`} />
        {s.label}
      </span>
    );
  }
  const map: Record<string, { cls: string; dot: string; label: string }> = {
    ACTIVE:    { cls: "text-emerald-700 bg-emerald-100", dot: "bg-emerald-500", label: "Active" },
    INACTIVE:  { cls: "text-slate-500 bg-slate-100", dot: "bg-slate-400", label: "Inactive" },
    SUSPENDED: { cls: "text-red-600 bg-red-100", dot: "bg-red-500", label: "Suspended" },
    PENDING_VERIFICATION: { cls: "text-primary bg-primary/15", dot: "bg-primary animate-pulse", label: "Pending" },
  };
  const s = map[status] || { cls: "bg-slate-100 text-slate-500", dot: "bg-slate-400", label: status.replace(/_/g, " ") };
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

// ── Toast ────────────────────────────────────────────────────
function Toast({ msg, type }: { msg: string; type: "success" | "error" | "info" }) {
  const colors = { success: "bg-emerald-600", error: "bg-red-500", info: "bg-primary" };
  return (
    <div className={`fixed bottom-6 right-6 z-[100] flex items-center gap-3 px-5 py-3 rounded-xl text-white shadow-xl text-sm font-semibold ${colors[type]}`}>
      <span className="material-symbols-outlined text-xl">
        {type === "success" ? "check_circle" : type === "error" ? "error" : "info"}
      </span>
      {msg}
    </div>
  );
}

type RoleTab = "ALL" | "DRIVER" | "CUSTOMER";
type StatusFilter = "All Statuses" | "Active" | "Pending Verification" | "Suspended";
type RatingFilter = "Rating: Any" | "4.5+" | "4.0+" | "3.0+";

export default function UsersPage() {
  const router = useRouter();
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [roleTab, setRoleTab] = useState<RoleTab>("ALL");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("All Statuses");
  const [ratingFilter, setRatingFilter] = useState<RatingFilter>("Rating: Any");
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [actionProcessing, setActionProcessing] = useState(false);
  const [toast, setToast] = useState<{ msg: string; type: "success" | "error" | "info" } | null>(null);
  const { t } = useLang();

  const showToast = (msg: string, type: "success" | "error" | "info" = "success") => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const load = async () => {
    setLoading(true);
    try {
      const token = getToken(); if (!token) return;
      const res = await apiFetch<{ data: { users: User[] } }>("/api/v1/admin/users?limit=100", { token });
      setUsers(res.data?.users || (res.data as unknown as User[]) || []);
    } catch { setUsers([]); } finally { setLoading(false); }
  };

  useEffect(() => { load(); }, []);

  // ── Update user status via API ──
  const updateStatus = async (userId: string, status: string, successMsg: string) => {
    setActionProcessing(true);
    try {
      const token = getToken(); if (!token) return;
      await apiFetch(`/api/v1/admin/users/${userId}`, { token, method: "PATCH", body: { status } });
      setUsers(prev => prev.map(u => u.id === userId ? { ...u, status } : u));
      if (selectedUser?.id === userId) setSelectedUser(prev => prev ? { ...prev, status } : null);
      showToast(successMsg, "success");
    } catch (e) {
      showToast("Action failed. Please try again.", "error");
      console.error(e);
    } finally { setActionProcessing(false); }
  };

  // ── CSV export ──
  const exportCSV = () => {
    const rows = [
      ["ID", "Name", "Phone", "Email", "Role", "Status", "Driver Status", "Rating", "Trips", "Joined"],
      ...filtered.map(u => [
        u.id.substring(0, 8),
        u.name || "",
        u.phone || "",
        u.email || "",
        u.role,
        u.status,
        u.driverProfile?.verificationStatus || "",
        u.driverProfile?.averageRating?.toFixed(1) || "",
        u.driverProfile?.totalTrips?.toString() || "",
        u.createdAt ? new Date(u.createdAt).toLocaleDateString("th-TH") : "",
      ]),
    ];
    const csv = rows.map(r => r.map(v => `"${String(v).replace(/"/g, '""')}"`).join(",")).join("\n");
    const blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `fairgo-users-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const filtered = users.filter(u => {
    if (roleTab !== "ALL" && u.role !== roleTab) return false;
    if (search) {
      const q = search.toLowerCase();
      const hit = u.name?.toLowerCase().includes(q) || u.phone?.includes(q) || u.email?.toLowerCase().includes(q) || u.id.includes(q);
      if (!hit) return false;
    }
    if (statusFilter === "Active" && u.status !== "ACTIVE") return false;
    if (statusFilter === "Pending Verification" && u.status !== "PENDING_VERIFICATION" && u.driverProfile?.verificationStatus !== "PENDING") return false;
    if (statusFilter === "Suspended" && u.status !== "SUSPENDED") return false;
    if (ratingFilter !== "Rating: Any" && u.driverProfile) {
      const min = parseFloat(ratingFilter);
      if (u.driverProfile.averageRating < min) return false;
    }
    return true;
  });

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  return (
    <div className="bg-fairgo-bg min-h-screen">
      {toast && <Toast msg={toast.msg} type={toast.type} />}

      {/* Header */}
      <header className="p-8 pb-0 bg-fairgo-bg">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
          <div>
            <h2 className="text-3xl font-extrabold tracking-tight text-slate-900">{t.usersDriverManagement}</h2>
            <p className="text-slate-500 mt-1">{t.usersMonitorManage}</p>
          </div>
          <div className="flex gap-3">
            <button
              onClick={exportCSV}
              className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 text-slate-700 rounded-lg font-bold text-sm shadow-sm hover:bg-slate-50 transition"
            >
              <span className="material-symbols-outlined text-xl">file_download</span>
              {t.usersExportData}
            </button>
            <button
              onClick={() => showToast("ผู้ใช้ลงทะเบียนผ่านแอปด้วย OTP เท่านั้น", "info")}
              className="flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-lg font-bold text-sm shadow-md hover:opacity-90 transition"
            >
              <span className="material-symbols-outlined text-xl">add</span>
              {t.usersAddNewUser}
            </button>
          </div>
        </div>

        {/* Search + Filters */}
        <div className="flex flex-wrap items-center gap-4 bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex-1 min-w-[300px]">
            <div className="relative">
              <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-lg">search</span>
              <input
                type="text"
                value={search}
                onChange={e => { setSearch(e.target.value); setPage(1); }}
                placeholder={t.usersSearchByName}
                className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border-none rounded-lg focus:ring-2 focus:ring-primary/30 text-sm outline-none"
              />
            </div>
          </div>
          <div className="flex gap-3 flex-wrap">
            <div className="relative">
              <select
                value={statusFilter}
                onChange={e => { setStatusFilter(e.target.value as StatusFilter); setPage(1); }}
                className="appearance-none pl-4 pr-10 py-2.5 bg-slate-50 border-none rounded-lg text-sm font-semibold focus:ring-2 focus:ring-primary/30 outline-none cursor-pointer"
              >
                {[t.usersAllStatuses, t.usersActive, t.usersPendingVerification, t.usersSuspended].map((s, i) => (
                  <option key={i}>{s}</option>
                ))}
              </select>
              <span className="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-lg">expand_more</span>
            </div>
            <div className="relative">
              <select
                value={roleTab}
                onChange={e => { setRoleTab(e.target.value as RoleTab); setPage(1); }}
                className="appearance-none pl-4 pr-10 py-2.5 bg-slate-50 border-none rounded-lg text-sm font-semibold focus:ring-2 focus:ring-primary/30 outline-none cursor-pointer"
              >
                <option value="ALL">{t.usersAllTypes}</option>
                <option value="DRIVER">{t.usersName}</option>
                <option value="CUSTOMER">{t.usersPassenger}</option>
              </select>
              <span className="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-lg">expand_more</span>
            </div>
            <div className="relative">
              <select
                value={ratingFilter}
                onChange={e => { setRatingFilter(e.target.value as RatingFilter); setPage(1); }}
                className="appearance-none pl-4 pr-10 py-2.5 bg-slate-50 border-none rounded-lg text-sm font-semibold focus:ring-2 focus:ring-primary/30 outline-none cursor-pointer"
              >
                {["Rating: Any", "4.5+", "4.0+", "3.0+"].map(r => <option key={r}>{r}</option>)}
              </select>
              <span className="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-lg">star</span>
            </div>
            <button onClick={load} className="p-2.5 text-slate-500 hover:text-primary transition">
              <span className="material-symbols-outlined">refresh</span>
            </button>
          </div>
        </div>
      </header>

      {/* Table */}
      <section className="p-8">
        <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200">
                  {[t.usersName, t.usersType, t.usersRating, t.usersTrips, t.usersStatus, t.usersActions].map(h => (
                    <th key={h} className={`px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider ${h === t.usersRating || h === t.usersTrips ? "text-center" : ""}`}>
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {loading ? (
                  Array.from({ length: 6 }).map((_, i) => (
                    <tr key={i}>
                      {Array.from({ length: 6 }).map((_, j) => (
                        <td key={j} className="px-6 py-4">
                          <div className="h-4 bg-slate-100 rounded animate-pulse" />
                        </td>
                      ))}
                    </tr>
                  ))
                ) : paginated.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-6 py-12 text-center">
                      <span className="material-symbols-outlined text-4xl text-slate-300 block mb-2">group</span>
                      <p className="text-sm text-slate-400">{t.usersNoUsers}</p>
                    </td>
                  </tr>
                ) : (
                  paginated.map(u => {
                    const isPendingDriver = u.role === "DRIVER" && u.driverProfile?.verificationStatus === "PENDING";
                    return (
                      <tr
                        key={u.id}
                        className={`transition-colors ${
                          isPendingDriver
                            ? "bg-primary/5 border-l-4 border-l-primary hover:bg-primary/10"
                            : "hover:bg-slate-50/50"
                        }`}
                      >
                        {/* Name */}
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-3">
                            <div className={`w-9 h-9 rounded-full flex items-center justify-center font-bold text-sm ${
                              isPendingDriver
                                ? "bg-primary text-white"
                                : u.role === "DRIVER"
                                  ? "bg-primary/20 text-primary"
                                  : u.status === "SUSPENDED"
                                    ? "bg-red-100 text-red-500"
                                    : "bg-slate-100 text-slate-500"
                            }`}>
                              {initials(u.name || "?")}
                            </div>
                            <div>
                              <p className="text-sm font-bold text-slate-900">{u.name || "—"}</p>
                              <p className="text-xs text-slate-500">{u.email || u.phone}</p>
                            </div>
                          </div>
                        </td>

                        {/* Type */}
                        <td className="px-6 py-4"><TypeBadge role={u.role} /></td>

                        {/* Rating */}
                        <td className="px-6 py-4 text-center">
                          {u.driverProfile?.averageRating ? (
                            <div className="flex items-center justify-center gap-1">
                              <span className="text-sm font-bold text-slate-900">{u.driverProfile.averageRating.toFixed(1)}</span>
                              <span className="material-symbols-outlined text-amber-400 text-base" style={{ fontVariationSettings: "'FILL' 1" }}>star</span>
                            </div>
                          ) : <span className="text-slate-400 text-sm">—</span>}
                        </td>

                        {/* Total Trips */}
                        <td className="px-6 py-4 text-center font-semibold text-sm text-slate-900">
                          {u.driverProfile?.totalTrips?.toLocaleString() ?? "—"}
                        </td>

                        {/* Status */}
                        <td className="px-6 py-4">
                          <StatusChip status={u.status} role={u.role} driverStatus={u.driverProfile?.verificationStatus} />
                        </td>

                        {/* Actions */}
                        <td className="px-6 py-4">
                          {isPendingDriver ? (
                            <button
                              onClick={() => router.push("/dashboard/drivers")}
                              className="px-4 py-1.5 bg-primary text-white rounded-lg text-xs font-bold shadow-sm hover:opacity-90 transition"
                            >
                              Verify Driver
                            </button>
                          ) : u.status === "SUSPENDED" ? (
                            <div className="flex justify-end gap-2">
                              <button
                                onClick={() => updateStatus(u.id, "ACTIVE", `${u.name} reactivated`)}
                                disabled={actionProcessing}
                                className="px-3 py-1 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 rounded-lg text-xs font-bold transition disabled:opacity-50"
                              >
                                Reactivate
                              </button>
                              <button
                                onClick={() => setSelectedUser(u)}
                                className="p-1.5 text-slate-400 hover:text-primary transition"
                              >
                                <span className="material-symbols-outlined text-xl">edit</span>
                              </button>
                            </div>
                          ) : (
                            <div className="flex gap-1">
                              <button
                                onClick={() => setSelectedUser(u)}
                                className="p-1.5 text-slate-400 hover:text-primary transition"
                                title="View"
                              >
                                <span className="material-symbols-outlined text-xl">visibility</span>
                              </button>
                              <button
                                onClick={() => setSelectedUser(u)}
                                className="p-1.5 text-slate-400 hover:text-primary transition"
                                title="Edit"
                              >
                                <span className="material-symbols-outlined text-xl">edit</span>
                              </button>
                              <button
                                onClick={() => {
                                  if (confirm(`Block ${u.name}? They will be suspended immediately.`)) {
                                    updateStatus(u.id, "SUSPENDED", `${u.name} has been blocked`);
                                  }
                                }}
                                disabled={actionProcessing}
                                className="p-1.5 text-slate-400 hover:text-red-500 transition disabled:opacity-50"
                                title="Block"
                              >
                                <span className="material-symbols-outlined text-xl">block</span>
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

          {/* Pagination footer */}
          {!loading && filtered.length > 0 && (
            <div className="px-6 py-4 border-t border-slate-100 bg-slate-50 flex items-center justify-between">
              <p className="text-xs text-slate-500">
                {t.usersShowing} <span className="font-semibold">{Math.min(filtered.length, (page - 1) * PAGE_SIZE + paginated.length)}</span> {t.usersOf} <span className="font-semibold">{filtered.length}</span> users
              </p>
              <div className="flex items-center gap-1">
                <button
                  onClick={() => setPage(p => Math.max(1, p - 1))}
                  disabled={page === 1}
                  className="px-3 py-1.5 text-xs font-bold text-slate-500 bg-white border border-slate-200 rounded-lg hover:bg-slate-50 transition disabled:opacity-40 disabled:cursor-not-allowed"
                >
                  Previous
                </button>
                {Array.from({ length: totalPages }, (_, i) => i + 1).filter(p => p === 1 || p === totalPages || Math.abs(p - page) <= 1).map((p, idx, arr) => (
                  <span key={p}>
                    {idx > 0 && arr[idx - 1] !== p - 1 && <span className="px-1 text-slate-400">…</span>}
                    <button
                      onClick={() => setPage(p)}
                      className={`px-3 py-1.5 text-xs font-bold rounded-lg transition ${p === page ? "text-white bg-primary" : "text-slate-500 bg-white border border-slate-200 hover:bg-slate-50"}`}
                    >
                      {p}
                    </button>
                  </span>
                ))}
                <button
                  onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                  disabled={page === totalPages}
                  className="px-3 py-1.5 text-xs font-bold text-slate-500 bg-white border border-slate-200 rounded-lg hover:bg-slate-50 transition disabled:opacity-40 disabled:cursor-not-allowed"
                >
                  Next
                </button>
              </div>
            </div>
          )}
        </div>
      </section>

      {/* User Detail Modal */}
      {selectedUser && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4" onClick={() => setSelectedUser(null)}>
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-md p-6 max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-5">
              <h3 className="font-bold text-slate-900 text-lg">User Details</h3>
              <button onClick={() => setSelectedUser(null)} className="text-slate-400 hover:text-slate-600">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            {/* Avatar + info */}
            <div className="flex items-center gap-4 mb-5">
              <div className={`w-14 h-14 rounded-full flex items-center justify-center font-bold text-xl ${
                selectedUser.status === "SUSPENDED" ? "bg-red-100 text-red-500" : "bg-primary/10 text-primary"
              }`}>
                {initials(selectedUser.name || "?")}
              </div>
              <div>
                <p className="font-bold text-slate-900 text-lg">{selectedUser.name || "—"}</p>
                <p className="text-sm text-slate-500">{selectedUser.phone}</p>
                {selectedUser.email && <p className="text-xs text-slate-400">{selectedUser.email}</p>}
                <p className="text-xs text-slate-400 mt-0.5">Joined {new Date(selectedUser.createdAt).toLocaleDateString("th-TH")}</p>
              </div>
            </div>

            {/* Status + role badges */}
            <div className="flex gap-2 mb-4">
              <TypeBadge role={selectedUser.role} />
              <StatusChip status={selectedUser.status} role={selectedUser.role} driverStatus={selectedUser.driverProfile?.verificationStatus} />
            </div>

            {/* Driver-specific info */}
            {selectedUser.driverProfile && (
              <div className="grid grid-cols-3 gap-3 mb-4 text-center">
                <div className="bg-slate-50 rounded-xl p-3">
                  <p className="text-xs text-slate-400 mb-1">Rating</p>
                  <p className="font-bold text-slate-900">{selectedUser.driverProfile.averageRating?.toFixed(1) || "—"}</p>
                </div>
                <div className="bg-slate-50 rounded-xl p-3">
                  <p className="text-xs text-slate-400 mb-1">Trips</p>
                  <p className="font-bold text-slate-900">{selectedUser.driverProfile.totalTrips ?? 0}</p>
                </div>
                <div className="bg-slate-50 rounded-xl p-3">
                  <p className="text-xs text-slate-400 mb-1">Vehicles</p>
                  <p className="font-bold text-slate-900">{selectedUser.driverProfile.vehicles?.length || 0}</p>
                </div>
              </div>
            )}

            {/* Vehicles */}
            {selectedUser.driverProfile?.vehicles?.length > 0 && (
              <div className="mb-4">
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wide mb-2">Vehicles</p>
                {selectedUser.driverProfile.vehicles.map((v, i) => (
                  <div key={i} className="bg-slate-50 rounded-xl p-3 flex items-center gap-2">
                    <span className="material-symbols-outlined text-primary">{VT_ICON[v.type] || "directions_car"}</span>
                    <span className="text-sm font-semibold text-slate-700">{v.type} · {v.plateNumber}</span>
                  </div>
                ))}
              </div>
            )}

            {/* Action buttons */}
            <div className="flex gap-3 mt-5">
              {selectedUser.status === "ACTIVE" ? (
                <button
                  onClick={() => {
                    if (confirm(`Block ${selectedUser.name}?`)) {
                      updateStatus(selectedUser.id, "SUSPENDED", `${selectedUser.name} has been blocked`);
                      setSelectedUser(null);
                    }
                  }}
                  disabled={actionProcessing}
                  className="flex-1 bg-red-50 text-red-500 border border-red-200 rounded-xl py-2.5 font-bold text-sm hover:bg-red-100 transition disabled:opacity-50"
                >
                  {actionProcessing ? "Processing…" : "Block User"}
                </button>
              ) : selectedUser.status === "SUSPENDED" ? (
                <button
                  onClick={() => {
                    updateStatus(selectedUser.id, "ACTIVE", `${selectedUser.name} reactivated`);
                    setSelectedUser(null);
                  }}
                  disabled={actionProcessing}
                  className="flex-1 bg-emerald-600 text-white rounded-xl py-2.5 font-bold text-sm hover:bg-emerald-700 transition disabled:opacity-50"
                >
                  {actionProcessing ? "Processing…" : "Reactivate User"}
                </button>
              ) : null}
              {selectedUser.role === "DRIVER" && selectedUser.driverProfile?.verificationStatus === "PENDING" && (
                <button
                  onClick={() => { router.push("/dashboard/drivers"); setSelectedUser(null); }}
                  className="flex-1 bg-primary text-white rounded-xl py-2.5 font-bold text-sm hover:opacity-90 transition"
                >
                  Go to Driver Verification
                </button>
              )}
              <button
                onClick={() => setSelectedUser(null)}
                className="px-5 border border-slate-200 text-slate-500 rounded-xl py-2.5 text-sm font-medium hover:bg-slate-50 transition"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
