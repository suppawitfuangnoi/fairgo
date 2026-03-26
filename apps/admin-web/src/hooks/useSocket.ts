"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import { io, Socket } from "socket.io-client";
import { getToken } from "@/lib/auth";

const SOCKET_URL = process.env.NEXT_PUBLIC_SOCKET_URL || "http://localhost:4000";

export interface DriverLocation {
  driverId: string;
  userId: string;
  lat: number;
  lng: number;
  heading?: number;
  speed?: number;
  vehicleType?: string;
  updatedAt: number;
}

export interface DriverStatus {
  userId: string;
  isOnline: boolean;
  vehicleType?: string;
}

export function useAdminSocket() {
  const socketRef = useRef<Socket | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const [drivers, setDrivers] = useState<Map<string, DriverLocation>>(new Map());
  const [driverStatuses, setDriverStatuses] = useState<Map<string, DriverStatus>>(new Map());
  const [activeTrips, setActiveTrips] = useState(0);

  useEffect(() => {
    const token = getToken();
    if (!token) return;

    const socket = io(SOCKET_URL, {
      auth: { token },
      transports: ["websocket", "polling"],
      reconnection: true,
      reconnectionDelay: 2000,
      reconnectionAttempts: 5,
    });

    socketRef.current = socket;

    socket.on("connect", () => {
      console.log("[Socket.IO Admin] Connected");
      setIsConnected(true);
    });

    socket.on("disconnect", () => {
      console.log("[Socket.IO Admin] Disconnected");
      setIsConnected(false);
    });

    // Receive full snapshot of online drivers on connect
    socket.on("drivers:snapshot", (snapshot: DriverLocation[]) => {
      const map = new Map<string, DriverLocation>();
      snapshot.forEach((d) => map.set(d.userId, d));
      setDrivers(map);
    });

    // Live driver location updates
    socket.on("driver:location:update", (location: DriverLocation) => {
      setDrivers((prev) => {
        const next = new Map(prev);
        next.set(location.userId, location);
        return next;
      });
    });

    // Driver online/offline status changes
    socket.on("driver:status:change", (status: DriverStatus) => {
      setDriverStatuses((prev) => {
        const next = new Map(prev);
        next.set(status.userId, status);
        return next;
      });
      if (!status.isOnline) {
        setDrivers((prev) => {
          const next = new Map(prev);
          next.delete(status.userId);
          return next;
        });
      }
    });

    // New ride request notification
    socket.on("ride:new_request", (data: { rideRequestId: string }) => {
      console.log("[Socket.IO Admin] New ride request:", data.rideRequestId);
    });

    return () => {
      socket.disconnect();
      socketRef.current = null;
    };
  }, []);

  const emit = useCallback((event: string, data?: unknown) => {
    socketRef.current?.emit(event, data);
  }, []);

  return {
    isConnected,
    drivers: Array.from(drivers.values()),
    driverStatuses,
    activeTrips,
    emit,
  };
}
