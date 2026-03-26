"use client";

import { useState, useEffect } from "react";
import Header from "@/components/Header";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";
import {
  Car,
  Users,
  UserPlus,
  DollarSign,
  TrendingUp,
  TrendingDown,
} from "lucide-react";

interface DashboardData {
  stats: {
    totalUsers: number;
    totalDrivers: number;
    activeDrivers: number;
    pendingVerifications: number;
    totalTrips: number;
    activeTrips: number;
    completedTrips: number;
    cancelledTrips: number;
    recentUsers: number;
    totalRevenue: number;
  };
  dailyTrips: Array<{ day: string; date: string; trips: number }>;
  recentActivity: Array<{
    id: string;
    status: string;
    lockedFare: number;
    createdAt: string;
    rideRequest: {
      pickupAddress: string;
      customerProfile: { user: { name: string } };
    };
    driverProfile: { user: { name: string } };
  }>;
}

function StatCard({
  label,
  value,
  change,
  icon: Icon,
  trend,
}: {
  label: string;
  value: string;
  change: string;
  icon: React.ElementType;
  trend: "up" | "down";
}) {
  return (
    <div className="bg-white rounded-xl border border-gray-100 p-5">
      <div className="flex items-start justify-between">
        <div className="w-10 h-10 bg-primary-50 rounded-lg flex items-center justify-center">
          <Icon className="w-5 h-5 text-primary-500" />
        </div>
        <span
          className={`flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full ${
            trend === "up"
              ? "text-emerald-600 bg-emerald-50"
              : "text-red-500 bg-red-50"
          }`}
        >
          {trend === "up" ? (
            <TrendingUp className="w-3 h-3" />
          ) : (
            <TrendingDown className="w-3 h-3" />
          )}
          {change}
        </span>
      </div>
      <p className="mt-3 text-sm text-gray-500">{label}</p>
      <p className="text-2xl font-bold text-fairgo-dark">{value}</p>
    </div>
  );
}

function StatusBadge({ status }: { status: string }) {
  const colors: Record<string, string> = {
    COMPLETED: "bg-emerald-50 text-emerald-600",
    IN_PROGRESS: "bg-amber-50 text-amber-600",
    CANCELLED: "bg-red-50 text-red-500",
    DRIVER_ASSIGNED: "bg-blue-50 text-blue-600",
    DRIVER_EN_ROUTE: "bg-blue-50 text-blue-600",
  };
  return (
    <span
      className={`text-xs font-medium px-2.5 py-1 rounded-full ${
        colors[status] || "bg-gray-50 text-gray-600"
      }`}
    >
      {status.replace(/_/g, " ")}
    </span>
  );
}

export default function DashboardPage() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = getToken();
        if (!token) return;
        const res = await apiFetch<{ data: DashboardData }>(
          "/api/v1/admin/dashboard",
          { token }
        );
        setData(res.data);
      } catch (err) {
        console.error("Dashboard fetch error:", err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="flex-1">
        <Header title="Overview Dashboard" />
        <div className="p-6 flex items-center justify-center h-96">
          <div className="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin" />
        </div>
      </div>
    );
  }

  const stats = data?.stats;

  return (
    <div className="flex-1">
      <Header title="Overview Dashboard" />
      <div className="p-6 space-y-6">
        {/* KPI Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard
            label="Active Trips"
            value={stats?.activeTrips?.toLocaleString() || "0"}
            change="+12.5%"
            icon={Car}
            trend="up"
          />
          <StatCard
            label="Total Revenue"
            value={`฿${(stats?.totalRevenue || 0).toLocaleString()}`}
            change="+8.2%"
            icon={DollarSign}
            trend="up"
          />
          <StatCard
            label="New Users"
            value={stats?.recentUsers?.toLocaleString() || "0"}
            change="-3.1%"
            icon={UserPlus}
            trend="down"
          />
          <StatCard
            label="Active Drivers"
            value={stats?.activeDrivers?.toLocaleString() || "0"}
            change="+5.4%"
            icon={Users}
            trend="up"
          />
        </div>

        {/* Charts Section */}
        <div className="bg-white rounded-xl border border-gray-100 p-5">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2 className="text-lg font-semibold text-fairgo-dark">
                Trips vs Revenue
              </h2>
              <p className="text-sm text-gray-500">
                Performance insights over the last 7 days
              </p>
            </div>
            <div className="flex gap-2">
              <button className="px-3 py-1.5 text-xs border border-gray-200 rounded-lg hover:bg-gray-50">
                Export CSV
              </button>
              <button className="px-3 py-1.5 text-xs bg-primary-500 text-white rounded-lg">
                Daily
              </button>
            </div>
          </div>

          {/* Simple bar chart visualization */}
          <div className="h-48 flex items-end gap-2 pt-4">
            {(data?.dailyTrips || []).map((day, i) => {
              const maxTrips = Math.max(
                ...(data?.dailyTrips || []).map((d) => d.trips || 1)
              );
              const height = maxTrips > 0 ? (day.trips / maxTrips) * 100 : 10;
              return (
                <div key={i} className="flex-1 flex flex-col items-center gap-2">
                  <span className="text-xs text-gray-500">{day.trips}</span>
                  <div
                    className="w-full bg-primary-100 rounded-t-md hover:bg-primary-200 transition-colors relative group"
                    style={{ height: `${Math.max(height, 5)}%` }}
                  >
                    <div
                      className="absolute bottom-0 left-0 right-0 bg-primary-400 rounded-t-md"
                      style={{ height: `${Math.max(height * 0.7, 3)}%` }}
                    />
                  </div>
                  <span className="text-xs text-gray-500">{day.day}</span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Recent Activity */}
        <div className="bg-white rounded-xl border border-gray-100 p-5">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-fairgo-dark">
              Recent Activity
            </h2>
            <a
              href="/dashboard/trips"
              className="text-sm text-primary-500 hover:text-primary-600 font-medium"
            >
              View All Trips
            </a>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="text-left border-b border-gray-100">
                  <th className="pb-3 text-xs font-semibold text-gray-500 uppercase">
                    User
                  </th>
                  <th className="pb-3 text-xs font-semibold text-gray-500 uppercase">
                    Driver
                  </th>
                  <th className="pb-3 text-xs font-semibold text-gray-500 uppercase">
                    Route
                  </th>
                  <th className="pb-3 text-xs font-semibold text-gray-500 uppercase">
                    Fare
                  </th>
                  <th className="pb-3 text-xs font-semibold text-gray-500 uppercase">
                    Status
                  </th>
                  <th className="pb-3 text-xs font-semibold text-gray-500 uppercase">
                    Time
                  </th>
                </tr>
              </thead>
              <tbody>
                {(data?.recentActivity || []).map((trip) => (
                  <tr
                    key={trip.id}
                    className="border-b border-gray-50 hover:bg-gray-50/50"
                  >
                    <td className="py-3">
                      <div className="flex items-center gap-2">
                        <div className="w-7 h-7 bg-primary-100 rounded-full flex items-center justify-center text-primary-600 text-xs font-bold">
                          {trip.rideRequest?.customerProfile?.user?.name?.charAt(0) || "?"}
                        </div>
                        <span className="text-sm">
                          {trip.rideRequest?.customerProfile?.user?.name || "Unknown"}
                        </span>
                      </div>
                    </td>
                    <td className="py-3">
                      <div className="flex items-center gap-2">
                        <div className="w-7 h-7 bg-gray-100 rounded-full flex items-center justify-center text-gray-600 text-xs font-bold">
                          {trip.driverProfile?.user?.name?.charAt(0) || "?"}
                        </div>
                        <span className="text-sm">
                          {trip.driverProfile?.user?.name || "Unknown"}
                        </span>
                      </div>
                    </td>
                    <td className="py-3">
                      <div>
                        <p className="text-xs text-gray-400">From</p>
                        <p className="text-sm">
                          {trip.rideRequest?.pickupAddress?.substring(0, 20) || "N/A"}
                        </p>
                      </div>
                    </td>
                    <td className="py-3 text-sm font-medium">
                      ฿{trip.lockedFare?.toFixed(2)}
                    </td>
                    <td className="py-3">
                      <StatusBadge status={trip.status} />
                    </td>
                    <td className="py-3 text-xs text-gray-500">
                      {new Date(trip.createdAt).toLocaleDateString()}
                    </td>
                  </tr>
                ))}
                {(!data?.recentActivity || data.recentActivity.length === 0) && (
                  <tr>
                    <td colSpan={6} className="py-8 text-center text-gray-400 text-sm">
                      No recent activity
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
