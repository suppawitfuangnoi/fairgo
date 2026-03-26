"use client";

import { useState, useEffect, useCallback } from "react";
import Header from "@/components/Header";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";
import { RefreshCw } from "lucide-react";

interface Trip {
  id: string;
  lockedFare: number;
  status: string;
  pickupAddress: string;
  dropoffAddress: string;
  actualDistance: number | null;
  actualDuration: number | null;
  createdAt: string;
  completedAt: string | null;
  rideRequest: {
    vehicleType: string;
    customerProfile: { user: { name: string; avatarUrl: string | null } };
  };
  driverProfile: {
    user: { name: string; avatarUrl: string | null };
  };
  payment: { amount: number; status: string; commission: number } | null;
}

interface TripListData {
  trips: Trip[];
  meta: { page: number; limit: number; total: number; totalPages: number };
}

function StatusBadge({ status }: { status: string }) {
  const colors: Record<string, string> = {
    COMPLETED: "bg-emerald-50 text-emerald-600",
    IN_PROGRESS: "bg-blue-50 text-blue-600",
    DRIVER_ASSIGNED: "bg-amber-50 text-amber-600",
    DRIVER_EN_ROUTE: "bg-cyan-50 text-cyan-600",
    DRIVER_ARRIVED: "bg-indigo-50 text-indigo-600",
    PICKUP_CONFIRMED: "bg-violet-50 text-violet-600",
    CANCELLED: "bg-red-50 text-red-500",
  };
  return (
    <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${colors[status] || "bg-gray-50 text-gray-600"}`}>
      {status.replace(/_/g, " ")}
    </span>
  );
}

export default function TripsPage() {
  const [data, setData] = useState<TripListData | null>(null);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState("");
  const [page, setPage] = useState(1);

  const fetchTrips = useCallback(async () => {
    setLoading(true);
    try {
      const token = getToken();
      if (!token) return;
      const params = new URLSearchParams();
      params.set("page", page.toString());
      params.set("limit", "10");
      if (statusFilter) params.set("status", statusFilter);

      const res = await apiFetch<{ data: TripListData }>(
        `/api/v1/admin/trips?${params}`,
        { token }
      );
      setData(res.data);
    } catch (err) {
      console.error("Fetch trips error:", err);
    } finally {
      setLoading(false);
    }
  }, [page, statusFilter]);

  useEffect(() => {
    fetchTrips();
  }, [fetchTrips]);

  return (
    <div className="flex-1">
      <Header title="Trip Management" />
      <div className="p-6 space-y-6">
        <div className="bg-white rounded-xl border border-gray-100 p-4">
          <div className="flex items-center gap-3">
            <select
              className="px-3 py-2 text-sm border border-gray-200 rounded-lg bg-white"
              value={statusFilter}
              onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}
            >
              <option value="">All Statuses</option>
              <option value="DRIVER_ASSIGNED">Driver Assigned</option>
              <option value="DRIVER_EN_ROUTE">Driver En Route</option>
              <option value="IN_PROGRESS">In Progress</option>
              <option value="COMPLETED">Completed</option>
              <option value="CANCELLED">Cancelled</option>
            </select>
            <button
              onClick={fetchTrips}
              className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-50 rounded-lg"
            >
              <RefreshCw className="w-4 h-4" />
            </button>
            <span className="text-sm text-gray-500 ml-auto">
              {data?.meta.total || 0} trips
            </span>
          </div>
        </div>

        <div className="bg-white rounded-xl border border-gray-100">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="text-left border-b border-gray-100">
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">ID</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Passenger</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Driver</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Route</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Fare</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Status</th>
                  <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase">Date</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={7} className="py-12 text-center">
                      <div className="w-6 h-6 border-2 border-primary-500 border-t-transparent rounded-full animate-spin mx-auto" />
                    </td>
                  </tr>
                ) : (
                  (data?.trips || []).map((trip) => (
                    <tr key={trip.id} className="border-b border-gray-50 hover:bg-gray-50/50">
                      <td className="px-5 py-3 text-xs text-gray-500 font-mono">
                        {trip.id.substring(0, 8)}
                      </td>
                      <td className="px-5 py-3">
                        <div className="flex items-center gap-2">
                          <div className="w-7 h-7 bg-primary-100 rounded-full flex items-center justify-center text-primary-600 text-xs font-bold">
                            {trip.rideRequest?.customerProfile?.user?.name?.charAt(0) || "?"}
                          </div>
                          <span className="text-sm">{trip.rideRequest?.customerProfile?.user?.name || "Unknown"}</span>
                        </div>
                      </td>
                      <td className="px-5 py-3">
                        <div className="flex items-center gap-2">
                          <div className="w-7 h-7 bg-gray-100 rounded-full flex items-center justify-center text-gray-600 text-xs font-bold">
                            {trip.driverProfile?.user?.name?.charAt(0) || "?"}
                          </div>
                          <span className="text-sm">{trip.driverProfile?.user?.name || "Unknown"}</span>
                        </div>
                      </td>
                      <td className="px-5 py-3">
                        <p className="text-xs text-gray-500 truncate max-w-40">
                          {trip.pickupAddress}
                        </p>
                        <p className="text-xs text-primary-500 truncate max-w-40">
                          → {trip.dropoffAddress}
                        </p>
                      </td>
                      <td className="px-5 py-3 text-sm font-semibold text-primary-600">
                        ฿{trip.lockedFare.toFixed(2)}
                      </td>
                      <td className="px-5 py-3">
                        <StatusBadge status={trip.status} />
                      </td>
                      <td className="px-5 py-3 text-xs text-gray-500">
                        {new Date(trip.createdAt).toLocaleDateString()}
                      </td>
                    </tr>
                  ))
                )}
                {!loading && (!data?.trips || data.trips.length === 0) && (
                  <tr>
                    <td colSpan={7} className="py-12 text-center text-gray-400 text-sm">
                      No trips found
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {data && data.meta.totalPages > 1 && (
            <div className="flex items-center justify-between px-5 py-3 border-t border-gray-100">
              <p className="text-xs text-gray-500">
                Page {page} of {data.meta.totalPages}
              </p>
              <div className="flex gap-1">
                <button
                  onClick={() => setPage(Math.max(1, page - 1))}
                  disabled={page === 1}
                  className="px-3 py-1.5 text-xs border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-50"
                >
                  Prev
                </button>
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
      </div>
    </div>
  );
}
