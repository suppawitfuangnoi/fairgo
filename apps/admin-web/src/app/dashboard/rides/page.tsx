"use client";

import { useState, useEffect, useCallback } from "react";
import Header from "@/components/Header";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";
import { MapPin, Clock, RefreshCw } from "lucide-react";

interface RideRequest {
  id: string;
  vehicleType: string;
  pickupAddress: string;
  dropoffAddress: string;
  fareMin: number;
  fareMax: number;
  fareOffer: number;
  recommendedFare: number | null;
  status: string;
  paymentMethod: string;
  estimatedDistance: number | null;
  estimatedDuration: number | null;
  createdAt: string;
  customerProfile: {
    user: { name: string; phone: string; avatarUrl: string | null };
  };
  _count: { offers: number };
  trip: {
    status: string;
    lockedFare: number;
    driverProfile: { user: { name: string } };
    payment: { status: string; amount: number } | null;
  } | null;
}

interface RideListData {
  rides: RideRequest[];
  meta: { page: number; limit: number; total: number; totalPages: number };
}

function StatusBadge({ status }: { status: string }) {
  const colors: Record<string, string> = {
    PENDING: "bg-amber-50 text-amber-600",
    MATCHING: "bg-blue-50 text-blue-600",
    MATCHED: "bg-emerald-50 text-emerald-600",
    CANCELLED: "bg-red-50 text-red-500",
    EXPIRED: "bg-gray-50 text-gray-500",
  };
  return (
    <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${colors[status] || "bg-gray-50 text-gray-600"}`}>
      {status}
    </span>
  );
}

function VehicleBadge({ type }: { type: string }) {
  const icons: Record<string, string> = {
    TAXI: "🚕",
    MOTORCYCLE: "🏍️",
    TUKTUK: "🛺",
  };
  return (
    <span className="text-xs font-medium px-2 py-1 rounded-full bg-primary-50 text-primary-600">
      {icons[type] || ""} {type}
    </span>
  );
}

export default function RidesPage() {
  const [data, setData] = useState<RideListData | null>(null);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState("");
  const [vehicleFilter, setVehicleFilter] = useState("");
  const [page, setPage] = useState(1);

  const fetchRides = useCallback(async () => {
    setLoading(true);
    try {
      const token = getToken();
      if (!token) return;
      const params = new URLSearchParams();
      params.set("page", page.toString());
      params.set("limit", "10");
      if (statusFilter) params.set("status", statusFilter);
      if (vehicleFilter) params.set("vehicleType", vehicleFilter);

      const res = await apiFetch<{ data: RideListData }>(
        `/api/v1/admin/rides?${params}`,
        { token }
      );
      setData(res.data);
    } catch (err) {
      console.error("Fetch rides error:", err);
    } finally {
      setLoading(false);
    }
  }, [page, statusFilter, vehicleFilter]);

  useEffect(() => {
    fetchRides();
  }, [fetchRides]);

  return (
    <div className="flex-1">
      <Header title="Ride Requests" />
      <div className="p-6 space-y-6">
        {/* Filters */}
        <div className="bg-white rounded-xl border border-gray-100 p-4">
          <div className="flex items-center gap-3 flex-wrap">
            <select
              className="px-3 py-2 text-sm border border-gray-200 rounded-lg bg-white"
              value={statusFilter}
              onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}
            >
              <option value="">All Statuses</option>
              <option value="PENDING">Pending</option>
              <option value="MATCHING">Matching</option>
              <option value="MATCHED">Matched</option>
              <option value="CANCELLED">Cancelled</option>
              <option value="EXPIRED">Expired</option>
            </select>
            <select
              className="px-3 py-2 text-sm border border-gray-200 rounded-lg bg-white"
              value={vehicleFilter}
              onChange={(e) => { setVehicleFilter(e.target.value); setPage(1); }}
            >
              <option value="">All Vehicle Types</option>
              <option value="TAXI">Taxi</option>
              <option value="MOTORCYCLE">Motorcycle</option>
              <option value="TUKTUK">Tuk-Tuk</option>
            </select>
            <button
              onClick={fetchRides}
              className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-50 rounded-lg"
            >
              <RefreshCw className="w-4 h-4" />
            </button>
            <span className="text-sm text-gray-500 ml-auto">
              {data?.meta.total || 0} total requests
            </span>
          </div>
        </div>

        {/* Rides list */}
        <div className="space-y-3">
          {loading ? (
            <div className="flex items-center justify-center h-48">
              <div className="w-6 h-6 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" />
            </div>
          ) : (
            (data?.rides || []).map((ride) => (
              <div key={ride.id} className="bg-white rounded-xl border border-gray-100 p-5">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center text-primary-600 text-xs font-bold">
                      {ride.customerProfile?.user?.name?.charAt(0) || "?"}
                    </div>
                    <div>
                      <p className="text-sm font-medium">{ride.customerProfile?.user?.name || "Unknown"}</p>
                      <p className="text-xs text-gray-500">{ride.customerProfile?.user?.phone}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <VehicleBadge type={ride.vehicleType} />
                    <StatusBadge status={ride.status} />
                  </div>
                </div>

                <div className="flex items-start gap-3 mb-3">
                  <div className="flex flex-col items-center mt-1">
                    <div className="w-2.5 h-2.5 rounded-full bg-primary-400" />
                    <div className="w-0.5 h-8 bg-gray-200" />
                    <div className="w-2.5 h-2.5 rounded-full bg-red-400" />
                  </div>
                  <div className="flex-1">
                    <div className="mb-2">
                      <p className="text-xs text-gray-400 flex items-center gap-1">
                        <MapPin className="w-3 h-3" /> PICKUP
                      </p>
                      <p className="text-sm">{ride.pickupAddress}</p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-400 flex items-center gap-1">
                        <MapPin className="w-3 h-3" /> DROP-OFF
                      </p>
                      <p className="text-sm">{ride.dropoffAddress}</p>
                    </div>
                  </div>
                </div>

                <div className="flex items-center justify-between border-t border-gray-50 pt-3">
                  <div className="flex items-center gap-4 text-xs text-gray-500">
                    <span>Offer: <span className="font-bold text-primary-600">฿{ride.fareOffer}</span></span>
                    <span>Range: ฿{ride.fareMin} - ฿{ride.fareMax}</span>
                    {ride.estimatedDistance && (
                      <span>{ride.estimatedDistance.toFixed(1)} km</span>
                    )}
                    {ride.estimatedDuration && (
                      <span className="flex items-center gap-1">
                        <Clock className="w-3 h-3" /> {ride.estimatedDuration} min
                      </span>
                    )}
                  </div>
                  <div className="flex items-center gap-2 text-xs">
                    <span className="text-gray-500">{ride._count.offers} offers</span>
                    {ride.trip && (
                      <span className="text-emerald-600 font-medium">
                        Locked: ฿{ride.trip.lockedFare}
                      </span>
                    )}
                  </div>
                </div>
              </div>
            ))
          )}
          {!loading && (!data?.rides || data.rides.length === 0) && (
            <div className="bg-white rounded-xl border border-gray-100 p-12 text-center text-gray-400">
              No ride requests found
            </div>
          )}
        </div>

        {/* Pagination */}
        {data && data.meta.totalPages > 1 && (
          <div className="flex items-center justify-center gap-2">
            <button
              onClick={() => setPage(Math.max(1, page - 1))}
              disabled={page === 1}
              className="px-4 py-2 text-sm border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-50"
            >
              Previous
            </button>
            <span className="text-sm text-gray-500">
              Page {page} of {data.meta.totalPages}
            </span>
            <button
              onClick={() => setPage(Math.min(data.meta.totalPages, page + 1))}
              disabled={page === data.meta.totalPages}
              className="px-4 py-2 text-sm border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-50"
            >
              Next
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
