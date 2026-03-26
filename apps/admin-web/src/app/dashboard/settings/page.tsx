"use client";

import Header from "@/components/Header";
import { Settings } from "lucide-react";

export default function SettingsPage() {
  return (
    <div className="flex-1">
      <Header title="Settings" />
      <div className="p-6">
        <div className="bg-white rounded-xl border border-gray-100 p-12 text-center">
          <Settings className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h2 className="text-lg font-semibold text-gray-600 mb-2">
            System Settings
          </h2>
          <p className="text-sm text-gray-400">
            System configuration, pricing rules, and content management
            <br />
            will be available in Phase 2.
          </p>
        </div>
      </div>
    </div>
  );
}
