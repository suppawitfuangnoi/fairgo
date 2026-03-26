"use client";
import { useState, useEffect } from "react";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";

interface User {
  id: string; name: string; phone: string; role: string; status: string; createdAt: string;
  driverProfile?: { verificationStatus: string; averageRating: number; totalTrips: number; vehicles: { type: string }[] };
}

const ROLE_TAB = ["ALL", "CUSTOMER", "DRIVER"];
const STATUS_COLOR: Record<string, string> = {
  ACTIVE: "badge-active", INACTIVE: "badge-completed",
  SUSPENDED: "badge-suspended", PENDING_VERIFICATION: "badge-pending",
};
const VT_ICON: Record<string, string> = { TAXI: "local_taxi", MOTORCYCLE: "two_wheeler", TUKTUK: "electric_rickshaw" };

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [tab, setTab] = useState("ALL");
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetch = async () => {
      try {
        const token = getToken(); if (!token) return;
        const res = await apiFetch<{ data: { users: User[] } }>("/api/v1/admin/users?limit=50", { token });
        setUsers(res.data?.users || res.data as any || []);
      } catch { setUsers([]); } finally { setLoading(false); }
    };
    fetch();
  }, []);

  const filtered = users.filter(u => {
    const roleOk = tab === "ALL" || u.role === tab;
    const searchOk = !search || u.name?.toLowerCase().includes(search.toLowerCase()) || u.phone?.includes(search);
    return roleOk && searchOk;
  });

  return (
    <div className="p-6 space-y-5 max-w-7xl mx-auto">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div><h1 className="text-xl font-bold text-fairgo-dark">Users & Drivers</h1><p className="text-sm text-gray-400">{users.length} total users</p></div>
        <div className="relative">
          <span className="absolute left-3 top-1/2 -translate-y-1/2 material-icons-round text-gray-300 text-lg">search</span>
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by name or phone..."
            className="pl-9 pr-4 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none bg-white w-64" />
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 bg-white p-1 rounded-xl shadow-card w-fit">
        {ROLE_TAB.map(t => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-4 py-2 text-sm font-medium rounded-lg transition ${tab === t ? "bg-primary text-white" : "text-gray-500 hover:text-gray-700"}`}>
            {t === "ALL" ? "All" : t === "CUSTOMER" ? "Passengers" : "Drivers"}
            <span className={`ml-1.5 text-xs px-1.5 py-0.5 rounded-full ${tab === t ? "bg-white/20 text-white" : "bg-gray-100 text-gray-400"}`}>
              {t === "ALL" ? users.length : users.filter(u => u.role === t).length}
            </span>
          </button>
        ))}
      </div>

      <div className="bg-white rounded-2xl shadow-card overflow-hidden">
        {loading ? (
          <div className="flex justify-center py-12"><div className="w-8 h-8 border-4 border-primary/30 border-t-primary rounded-full animate-spin" /></div>
        ) : (
          <table className="w-full">
            <thead><tr className="bg-gray-50 text-xs font-semibold text-gray-400 uppercase">
              <th className="text-left px-4 py-3">User</th><th className="text-left px-4 py-3">Phone</th>
              <th className="text-left px-4 py-3">Role</th><th className="text-left px-4 py-3">Status</th>
              {tab !== "CUSTOMER" && <><th className="text-left px-4 py-3">Vehicle</th><th className="text-center px-4 py-3">Rating</th><th className="text-center px-4 py-3">Trips</th></>}
              <th className="text-left px-4 py-3">Joined</th><th className="text-left px-4 py-3">Action</th>
            </tr></thead>
            <tbody className="divide-y divide-gray-50">
              {filtered.length === 0 && <tr><td colSpan={9} className="py-10 text-center text-sm text-gray-400">No users found</td></tr>}
              {filtered.map(u => (
                <tr key={u.id} className="hover:bg-gray-50/50 transition">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2.5">
                      <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-primary text-xs font-bold flex-shrink-0">
                        {(u.name || "?").charAt(0)}
                      </div>
                      <span className="text-sm font-medium text-fairgo-dark">{u.name || "ไม่ระบุ"}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-500 font-mono">{u.phone}</td>
                  <td className="px-4 py-3">
                    <span className={`text-xs font-semibold px-2 py-1 rounded-lg ${u.role === "DRIVER" ? "bg-amber-50 text-amber-600" : u.role === "ADMIN" ? "bg-purple-50 text-purple-600" : "bg-primary/10 text-primary"}`}>
                      {u.role === "CUSTOMER" ? "Passenger" : u.role}
                    </span>
                  </td>
                  <td className="px-4 py-3"><span className={STATUS_COLOR[u.status] || "badge-pending"}>{u.status?.replace(/_/g, " ")}</span></td>
                  {tab !== "CUSTOMER" && (
                    <>
                      <td className="px-4 py-3">
                        {u.driverProfile?.vehicles?.[0] && (
                          <span className="flex items-center gap-1 text-xs text-gray-500">
                            <span className="material-icons-round text-base text-gray-400">{VT_ICON[u.driverProfile.vehicles[0].type] || "directions_car"}</span>
                            {u.driverProfile.vehicles[0].type}
                          </span>
                        )}
                      </td>
                      <td className="px-4 py-3 text-center">
                        {u.driverProfile ? (
                          <span className="flex items-center justify-center gap-1 text-sm font-medium">
                            <span className="material-icons-round text-amber-400 text-sm">star</span>
                            {u.driverProfile.averageRating?.toFixed(1) || "—"}
                          </span>
                        ) : "—"}
                      </td>
                      <td className="px-4 py-3 text-center text-sm font-medium text-fairgo-dark">{u.driverProfile?.totalTrips ?? "—"}</td>
                    </>
                  )}
                  <td className="px-4 py-3 text-xs text-gray-400">{new Date(u.createdAt).toLocaleDateString("th-TH")}</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-1.5">
                      {u.driverProfile?.verificationStatus === "PENDING" && (
                        <button className="text-xs bg-emerald-50 text-emerald-600 font-medium px-2 py-1 rounded-lg hover:bg-emerald-100 transition">Approve</button>
                      )}
                      {u.status === "ACTIVE" && (
                        <button className="text-xs bg-red-50 text-red-500 font-medium px-2 py-1 rounded-lg hover:bg-red-100 transition">Suspend</button>
                      )}
                      {u.status === "SUSPENDED" && (
                        <button className="text-xs bg-gray-50 text-gray-500 font-medium px-2 py-1 rounded-lg hover:bg-gray-100 transition">Restore</button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
