"use client";

import { useState, useEffect, useCallback } from "react";
import Header from "@/components/Header";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";
import { Search, RefreshCw, Eye, Edit, Ban, Star, CheckCircle } from "lucide-react";

interface User {
  id: string;
  name: string | null;
  email: string | null;
  phone: string;
  role: string;
  status: string;
  avatarUrl: string | null;
  createdAt: string;
  customerProfile?: { totalTrips: number; averageRating: number } | null;
  driverProfile?: {
    totalTrips: number;
    averageRating: number;
    isVerified: boolean;
    verificationStatus: string;
    isOnline: boolean;
  } | null;
}

interface UserListData {
  users: User[];
  meta: { page: number; limit: number; total: number; totalPages: number };
}

function StatusBadge({ status }: { status: string }) {
  const colors: Record<string, string> = {
    ACTIVE: "bg-emerald-50 text-emerald-600",
    INACTIVE: "bg-gray-50 text-gray-600",
    SUSPENDED: "bg-red-50 text-red-500",
    PENDING_VERIFICATION: "bg-amber-50 text-amber-600",
  };
  return (
    <span className={`text-xs font-medium px-2.5 py-1 rounded-full flex items-center gap-1.5 w-fit ${colors[status] || "bg-gray-50 text-gray-600"}`}>
      <span className={`w-1.5 h-1.5 rounded-full ${
        status === "ACTIVE" ? "bg-emerald-500" :
        status === "SUSPENDED" ? "bg-red-500" :
        status === "PENDING_VERIFICATION" ? "bg-amber-500" : "bg-gray-400"
      }`} />
      {status === "PENDING_VERIFICATION" ? "Pending Verification" : status.charAt(0) + status.slice(1).toLowerCase()}
    </span>
  );
}

export default function UsersPage() {
  const [data, setData] = useState<UserListData | null>(null);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [page, setPage] = useState(1);

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    try {
      const token = getToken();
      if (!token) return;
      const params = new URLSearchParams();
      params.set("page", page.toString());
      params.set("limit", "10");
      if (search) params.set("search", search);
      if (roleFilter) params.set("role", roleFilter);
      if (statusFilter) params.set("status", statusFilter);

      const res = await apiFetch<{ data: UserListData }>(
        `/api/v1/admin/users?${params}`,
        { token }
      );
      setData(res.data);
    } catch (err) {
      console.error("Fetch users error:", err);
    } finally {
      setLoading(false);
    }
  }, [page, search, roleFilter, statusFilter]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  const handleVerifyDriver = async (driverProfileId: string) => {
    try {
      const token = getToken();
      if (!token) return;
      await apiFetch(`/api/v1/admin/drivers/${driverProfileId}/verify`, {
        method: "POST",
        body: { status: "APPROVED" },
        token,
      });
      fetchUsers();
    } catch (err) {
      console.error("Verify error:", err);
    }
  };

  return (
    <div className="flex-1">
      <Header title="User & Driver Management" />
      <div className="p-6 space-y-6">
        <p className="text-sm text-gray-500">
          Monitor, verify and manage platform participants in real-time.
        </p>

        {/* Filters */}
        <div className="bg-white rounded-xl border border-gray-100 p-4">
          <div className="flex items-center gap-3 flex-wrap">
            <div className="relative flex-1 min-w-64">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                type="text"
                placeholder="Search by name, email, or ID..."
                className="w-full pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                value={search}
                onChange={(e) => { setSearch(e.target.value); setPage(1); }}
              />
            </div>
            <select
              className="px-3 py-2 text-sm border border-gray-200 rounded-lg bg-white"
              value={statusFilter}
              onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}
            >
              <option value="">All Statuses</option>
              <option value="ACTIVE">Active</option>
              <option value="INACTIVE">Inactive</option>
              <option value="SUSPENDED">Suspended</option>
              <option value="PENDING_VERIFICATION">Pending Verification</option>
            </select>
            <select
              className="px-3 py-2 text-sm border border-gray-200 rounded-lg bg-white"
              value={roleFilter}
              onChange={(e) => { setRoleFilter(e.target.value); setPage(1); }}
            >
              <option value="">All Types</option>
              <option value="CUSTOMER">Passenger</option>
              <option value="DRIVER">Driver</option>
            </select>
            <button
              onClick={fetchUsers}
              className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-50 rounded-lg"
            >
              <RefreshCw className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Users Table */}
        <div className="bg-white rounded-xl border border-gray-100">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="text-left border-b border-gray-100">
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Name</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Type</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Rating</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Total Trips</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Status</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={6} className="py-12 text-center">
                      <div className="w-6 h-6 border-2 border-primary-500 border-t-transparent rounded-full animate-spin mx-auto" />
                    </td>
                  </tr>
                ) : (
                  (data?.users || []).map((user) => {
                    const profile = user.driverProfile || user.customerProfile;
                    const rating = profile?.averageRating || 0;
                    const trips = profile?.totalTrips || 0;
                    return (
                      <tr key={user.id} className="border-b border-gray-50 hover:bg-gray-50/50">
                        <td className="px-5 py-4">
                          <div className="flex items-center gap-3">
                            <div className="w-9 h-9 bg-primary-100 rounded-full flex items-center justify-center text-primary-600 text-sm font-bold">
                              {(user.name || "?").charAt(0).toUpperCase()}
                            </div>
                            <div>
                              <p className="text-sm font-medium text-gray-900">{user.name || "Unnamed"}</p>
                              <p className="text-xs text-gray-500">{user.email || user.phone}</p>
                            </div>
                          </div>
                        </td>
                        <td className="px-5 py-4">
                          <span className="text-xs font-medium px-2.5 py-1 rounded-full bg-gray-100 text-gray-700">
                            {user.role === "CUSTOMER" ? "Passenger" : "Driver"}
                          </span>
                        </td>
                        <td className="px-5 py-4">
                          {rating > 0 ? (
                            <span className="flex items-center gap-1 text-sm">
                              {rating.toFixed(1)} <Star className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
                            </span>
                          ) : (
                            <span className="text-gray-400">--</span>
                          )}
                        </td>
                        <td className="px-5 py-4 text-sm text-gray-700">{trips.toLocaleString()}</td>
                        <td className="px-5 py-4">
                          <StatusBadge status={user.status} />
                        </td>
                        <td className="px-5 py-4">
                          <div className="flex items-center gap-2">
                            {user.driverProfile?.verificationStatus === "PENDING" ? (
                              <button
                                onClick={() => user.driverProfile && handleVerifyDriver(user.driverProfile.isVerified ? "" : user.id)}
                                className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition"
                              >
                                <CheckCircle className="w-3.5 h-3.5" />
                                Verify Driver
                              </button>
                            ) : (
                              <>
                                <button className="p-1.5 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition">
                                  <Eye className="w-4 h-4" />
                                </button>
                                <button className="p-1.5 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition">
                                  <Edit className="w-4 h-4" />
                                </button>
                                <button className="p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition">
                                  <Ban className="w-4 h-4" />
                                </button>
                              </>
                            )}
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
                {!loading && (!data?.users || data.users.length === 0) && (
                  <tr>
                    <td colSpan={6} className="py-12 text-center text-gray-400 text-sm">
                      No users found
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {data && data.meta.totalPages > 1 && (
            <div className="flex items-center justify-between px-5 py-3 border-t border-gray-100">
              <p className="text-xs text-gray-500">
                Showing {(data.meta.page - 1) * data.meta.limit + 1} to{" "}
                {Math.min(data.meta.page * data.meta.limit, data.meta.total)} of{" "}
                {data.meta.total} results
              </p>
              <div className="flex gap-1">
                <button
                  onClick={() => setPage(Math.max(1, page - 1))}
                  disabled={page === 1}
                  className="px-3 py-1.5 text-xs border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-50"
                >
                  Previous
                </button>
                {Array.from({ length: Math.min(data.meta.totalPages, 5) }, (_, i) => i + 1).map((p) => (
                  <button
                    key={p}
                    onClick={() => setPage(p)}
                    className={`px-3 py-1.5 text-xs rounded-lg ${
                      p === page
                        ? "bg-primary-500 text-white"
                        : "border border-gray-200 hover:bg-gray-50"
                    }`}
                  >
                    {p}
                  </button>
                ))}
                <button
                  onClick={() => setPage(Math.min(data.meta.totalPages, page + 1))}
                  disabled={page === data.meta.totalPages}
                  className="px-3 py-1.5 text-xs border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-50"
                >
                  Next
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Stats footer */}
        <div className="grid grid-cols-4 gap-4">
          <div className="bg-white rounded-xl border border-gray-100 p-4 text-center">
            <p className="text-xs text-gray-500 uppercase font-semibold">Total Users</p>
            <p className="text-2xl font-bold text-fairgo-dark">{data?.meta.total || 0}</p>
          </div>
          <div className="bg-white rounded-xl border border-gray-100 p-4 text-center">
            <p className="text-xs text-gray-500 uppercase font-semibold">Active Drivers</p>
            <p className="text-2xl font-bold text-fairgo-dark">
              {data?.users.filter(u => u.driverProfile?.isOnline).length || 0}
            </p>
          </div>
          <div className="bg-white rounded-xl border border-primary-200 p-4 text-center">
            <p className="text-xs text-red-500 uppercase font-semibold">Pending Verifications</p>
            <p className="text-2xl font-bold text-fairgo-dark">
              {data?.users.filter(u => u.driverProfile?.verificationStatus === "PENDING").length || 0}
            </p>
          </div>
          <div className="bg-white rounded-xl border border-gray-100 p-4 text-center">
            <p className="text-xs text-gray-500 uppercase font-semibold">Avg. Platform Rating</p>
            <p className="text-2xl font-bold text-fairgo-dark">
              {(() => {
                const rated = data?.users.filter(u => (u.driverProfile?.averageRating || u.customerProfile?.averageRating || 0) > 0) || [];
                if (rated.length === 0) return "N/A";
                const avg = rated.reduce((s, u) => s + (u.driverProfile?.averageRating || u.customerProfile?.averageRating || 0), 0) / rated.length;
                return avg.toFixed(2);
              })()}
              {" "}<Star className="w-4 h-4 text-amber-400 fill-amber-400 inline" />
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
