"use client";

import { useEffect, useRef } from "react";
import { GoogleMap, Marker, useJsApiLoader } from "@react-google-maps/api";

const GOOGLE_MAPS_API_KEY = "AIzaSyDkmyeCIfQZ9an61Fq1L9WLa6nNzJ9hKwA";

const BANGKOK_CENTER = { lat: 13.7563, lng: 100.5018 };

const VI: Record<string, string> = {
  TAXI: "🚕",
  MOTORCYCLE: "🏍️",
  TUKTUK: "🛺",
};

interface DriverLocation {
  userId: string;
  driverId: string;
  lat: number;
  lng: number;
  heading?: number;
  speed?: number;
  vehicleType?: string;
}

interface LiveMapProps {
  drivers: DriverLocation[];
  height?: string;
}

const mapContainerStyle = { width: "100%", height: "100%" };

const mapOptions: google.maps.MapOptions = {
  disableDefaultUI: false,
  zoomControl: true,
  streetViewControl: false,
  mapTypeControl: false,
  fullscreenControl: false,
  styles: [
    { elementType: "geometry", stylers: [{ color: "#f5f5f5" }] },
    { elementType: "labels.icon", stylers: [{ visibility: "off" }] },
    { elementType: "labels.text.fill", stylers: [{ color: "#616161" }] },
    { elementType: "labels.text.stroke", stylers: [{ color: "#f5f5f5" }] },
    { featureType: "road", elementType: "geometry", stylers: [{ color: "#ffffff" }] },
    { featureType: "road.arterial", elementType: "labels.text.fill", stylers: [{ color: "#757575" }] },
    { featureType: "road.highway", elementType: "geometry", stylers: [{ color: "#dadada" }] },
    { featureType: "water", elementType: "geometry", stylers: [{ color: "#c9c9c9" }] },
    { featureType: "water", elementType: "labels.text.fill", stylers: [{ color: "#9e9e9e" }] },
  ],
};

// Fallback static dot positions for demo mode when no real drivers
const FALLBACK_POSITIONS = [
  { lat: 13.7460, lng: 100.5351 }, // Sukhumvit
  { lat: 13.7330, lng: 100.5290 }, // Asok
  { lat: 13.7525, lng: 100.4935 }, // Ratchadamri
  { lat: 13.7284, lng: 100.5180 }, // Silom
];

export default function LiveMap({ drivers, height = "224px" }: LiveMapProps) {
  const { isLoaded, loadError } = useJsApiLoader({
    googleMapsApiKey: GOOGLE_MAPS_API_KEY,
  });

  if (loadError) {
    return (
      <div className="flex items-center justify-center h-full text-sm text-gray-400">
        Failed to load map
      </div>
    );
  }

  if (!isLoaded) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  const displayDrivers = drivers.length > 0 ? drivers : FALLBACK_POSITIONS.map((pos, i) => ({
    userId: `demo-${i}`,
    driverId: `demo-${i}`,
    lat: pos.lat,
    lng: pos.lng,
    vehicleType: ["TAXI", "MOTORCYCLE", "TAXI", "TUKTUK"][i],
  }));

  return (
    <div style={{ height }}>
      <GoogleMap
        mapContainerStyle={mapContainerStyle}
        center={BANGKOK_CENTER}
        zoom={12}
        options={mapOptions}
      >
        {displayDrivers.map((driver) => (
          <Marker
            key={driver.userId}
            position={{ lat: driver.lat, lng: driver.lng }}
            title={`Driver ${driver.driverId} — ${driver.vehicleType || "TAXI"}`}
            label={{
              text: VI[driver.vehicleType || "TAXI"] || "🚕",
              fontSize: "18px",
            }}
          />
        ))}
      </GoogleMap>
    </div>
  );
}
