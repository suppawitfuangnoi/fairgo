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
    <html lang="th">
      <head>
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Round" rel="stylesheet" />
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=IBM+Plex+Sans+Thai:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
      </head>
      <body className="bg-fairgo-bg">{children}</body>
    </html>
  );
}
