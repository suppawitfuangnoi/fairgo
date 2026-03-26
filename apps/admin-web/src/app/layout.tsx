import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "FAIRGO Admin Portal",
  description: "FAIRGO Admin - Management Portal for Thailand's Fair-Pricing Ride-Hailing Platform",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
