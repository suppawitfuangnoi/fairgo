"use client";
import { useState, useEffect } from "react";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";

interface User {
  id: string; name: string; phone: string; email?: string; role: string; status: string; createdAt: string;
  driverProfile?: {
    verificationStatus: string; averageRating: number; totalTrips: number;
    vehicles: { type: string; plateNumber: string }[];
  };
}

const VT_ICON: Record<string, string> = { TAXI: "local_taxi", MOTORCYCLE: "two_wheeler", TUKTUK: "electric_rickshaw" };

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
  // For drivers, show their verification status
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

type RoleTab = "ALL" | "DRIVER" | "CUSTOMER";
type StatusFilter = "All Statuses" | "Active" | "Pending Verification" | "Suspended";
type RatingFilter = "Rating: Any" | "4.5+" | "4.0+" | "3.0+";

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [roleTab, setRoleTab] = useState<RoleTab>("ALL");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("All Statuses");
  const [ratingFilter, setRatingFilter] = useState<RatingFilter>("Rating: Any");
  const [search, setSearch] = useState("");

  const load = async () => {
    setLoading(true);
    try {
      const token = getToken(); if (!token) return;
      const res = await apiFetch<{ data: { users: User[] } }>("/api/v1/admin/users?limit=100", { token });
      setUsers(res.data?.users || (res.data as unknown as User[]) || []);
    } catch { setUsers([]); } finally { setLoading(false); }
  };

  useEffect(() => { load(); }, []);

  const filtered = users.filter(u => {
    // Role filter
    if (roleTab !== "ALL" && u.role !== roleTab) return false;
    // Search
    if (search) {
      const q = search.toLowerCase();
      const hit = u.name?.toLowerCase().includes(q) || u.phone?.includes(q) || u.email?.toLowerCase().includes(q) || u.id.includes(q);
      if (!hit) return false;
    }
    // Status filter
    if (statusFilter === "Active" && u.status !== "ACTIVE") return false;
    if (statusFilter === "Pending Verification" && u.status !== "PENDING_VERIFICATION" && u.driverProfile?.verificationStatus !== "PENDING") return false;
    if (statusFilter === "Suspended" && u.status !== "SUSPENDED") return false;
    // Rating filter (drivers only)
    if (ratingFilter !== "Rating: Any" && u.driverProfile) {
      const min = parseFloat(ratingFilter);
      if (u.driverProfile.averageRating < min) return false;
    }
    return true;
  });

  return (
    <div className="bg-fairgo-bg min-h-screen">
      {/* Header */}
      <header className="p-8 pb-0 bg-fairgo-bg">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
          <div>
            <h2 className="text-3xl font-extrabold tracking-tight text-slate-900">User &amp; Driver Management</h2>
            <p className="text-slate-500 mt-1">Monitor, verify and manage platform participants in real-time.</p>
          </div>
          <div className="flex gap-3">
            <button
              onClick={load}
              className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 text-slate-700 rounded-lg font-bold text-sm shadow-sm hover:bg-slate-50 transition"
            >
              <span className="material-symbols-outlined text-xl">file_download</span>
              Export Data
            </button>
            <button className="flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-lg font-bold text-sm shadow-md hover:opacity-90 transition">
              <span className="material-symbols-outlined text-xl">add</span>
              Add New User
            </button>
          </div>
        </div>

        {/* Search + Filters row */}
        <div className="flex flex-wrap items-center gap-4 bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex-1 min-w-[300px]">
            <div className="relative">
              <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-lg">search</span>
              <input
                type="text"
                value={search}
                onChange={e => setSearch(e.target.value)}
                placeholder="Search by name, email, or ID..."
                className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border-none rounded-lg focus:ring-2 focus:ring-primary/30 text-sm outline-none"
              />
            </div>
          </div>
          <div className="flex gap-3 flex-wrap">
            {/* Status select */}
            <div className="relative">
              <select
                value={statusFilter}
                onChange={e => setStatusFilter(e.target.value as StatusFilter)}
                className="appearance-none pl-4 pr-10 py-2.5 bg-slate-50 border-none rounded-lg text-sm font-semibold focus:ring-2 focus:ring-primary/30 outline-none cursor-pointer"
              >
                {["All Statuses", "Active", "Pending Verification", "Suspended"].map(s => (
                  <option key={s}>{s}</option>
                ))}
              </select>
              <span className="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-lg">expand_more</span>
            </div>
            {/* Type select */}
            <div className="relative">
              <select
                value={roleTab}
                onChange={e => setRoleTab(e.target.value as RoleTab)}
                className="appearance-none pl-4 pr-10 py-2.5 bg-slate-50 border-none rounded-lg text-sm font-semibold focus:ring-2 focus:ring-primary/30 outline-none cursor-pointer"
              >
                <option value="ALL">All Types</option>
                <option value="DRIVER">Driver</option>
                <option value="CUSTOMER">Passenger</option>
              </select>
              <span className="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-lg">expand_more</span>
            </div>
            {/* Rating select */}
            <div className="relative">
              <select
                value={ratingFilter}
                onChange={e => setRatingFilter(e.target.value as RatingFilter)}
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
                  {["Name", "Type", "Rating", "Total Trips", "Status", "Actions"].map(h => (
                    <th key={h} className={`px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider ${h === "Rating" || h === "Total Trips" ? "text-center" : ""}`}>
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
                ) : filtered.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-6 py-12 text-center">
                      <span className="material-symbols-outlined text-4xl text-slate-300 block mb-2">group</span>
                      <p className="text-sm text-slate-400">No users found</p>
                    </td>
                  </tr>
                ) : (
                  filtered.map(u => {
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
                        <td className="px-6 py-4">
                          <TypeBadge role={u.role} />
                        </td>

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
                          <StatusChip
                            status={u.status}
                            role={u.role}
                            driverStatus={u.driverProfile?.verificationStatus}
                          />
                        </td>

                        {/* Actions */}
                        <td className="px-6 py-4">
                          {isPendingDriver ? (
                            <button className="px-4 py-1.5 bg-primary text-white rounded-lg text-xs font-bold shadow-sm hover:opacity-90 transition">
                              Verify Driver
                            </button>
                          ) : u.status === "SUSPENDED" ? (
                            <div className="flex justify-end gap-2">
                              <button className="px-3 py-1 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-bold transition">
                                Reactivate
                              </button>
                              <button className="p-1.5 text-slate-400 hover:text-primary transition">
                                <span className="material-symbols-outlined text-xl">edit</span>
                              </button>
                            </div>
                          ) : (
                            <div className="flex gap-1">
                              <button className="p-1.5 text-slate-400 hover:text-primary transition" title="View">
                                <span className="material-symbols-outlined text-xl">visibility</span>
                              </button>
                              <button className="p-1.5 text-slate-400 hover:text-primary transition" title="Edit">
                                <span className="material-symbols-outlined text-xl">edit</span>
                              </button>
                              <button className="p-1.5 text-slate-400 hover:text-red-500 transition" title="Block">
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
                Showing <span className="font-semibold">{filtered.length}</span> of <span className="font-semibold">{users.length}</span> users
              </p>
              <div className="flex items-center gap-1">
                <button className="px-3 py-1.5 text-xs font-bold text-slate-500 bg-white border border-slate-200 rounded-lg hover:bg-slate-50 transition">
                  Previous
                </button>
                <button className="px-3 py-1.5 text-xs font-bold text-white bg-primary rounded-lg">1</button>
                <button className="px-3 py-1.5 text-xs font-bold text-slate-500 bg-white border border-slate-200 rounded-lg hover:bg-slate-50 transition">
                  Next
                </button>
              </div>
            </div>
          )}
        </div>
      </section>
    </div>
  );
}
