"use client";

import Header from "@/components/Header";
import { BarChart3 } from "lucide-react";

export default function AnalyticsPage() {
  return (
    <div className="flex-1">
      <Header title="Analytics" />
      <div className="p-6">
        <div className="bg-white rounded-xl border border-gray-100 p-12 text-center">
          <BarChart3 className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h2 className="text-lg font-semibold text-gray-600 mb-2">
            Analytics Dashboard
          </h2>
          <p className="text-sm text-gray-400">
            Advanced analytics will be available in Phase 3.
            <br />
            This includes pricing intelligence, revenue forecasting, and driver performance metrics.
          </p>
        </div>
      </div>
    </div>
  );
}
