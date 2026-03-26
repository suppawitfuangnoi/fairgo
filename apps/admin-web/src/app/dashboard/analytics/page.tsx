"use client";
import { useState } from "react";

const WEEKS = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
const REV = [38400, 42100, 35800, 51200, 48600, 62300, 55900];
const TRIPS = [128, 142, 116, 178, 164, 214, 192];

const ZONES = [
  { name: "สุขุมวิท", trips: 892 }, { name: "สีลม", trips: 634 }, { name: "อโศก", trips: 521 },
  { name: "ลาดพร้าว", trips: 384 }, { name: "รัชดา", trips: 298 },
];
const RATINGS = [{ s: 5, pct: 62, n: 2580 }, { s: 4, pct: 24, n: 998 }, { s: 3, pct: 8, n: 332 }, { s: 2, pct: 4, n: 166 }, { s: 1, pct: 2, n: 83 }];
const PAY_METHODS = [{ l: "Cash", v: 54, color: "bg-primary" }, { l: "Card", v: 30, color: "bg-amber-400" }, { l: "Wallet", v: 16, color: "bg-emerald-400" }];

const maxRev = Math.max(...REV);
const maxZone = Math.max(...ZONES.map(z => z.trips));

export default function AnalyticsPage() {
  const [period, setPeriod] = useState("week");

  const totalRev = REV.reduce((a, b) => a + b, 0);
  const totalTrips = TRIPS.reduce((a, b) => a + b, 0);

  return (
    <div className="p-6 space-y-5 max-w-7xl mx-auto">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div><h1 className="text-xl font-bold text-fairgo-dark">Analytics & Reports</h1><p className="text-sm text-gray-400">Platform performance metrics</p></div>
        <div className="flex gap-1.5 bg-white p-1 rounded-xl shadow-card">
          {["week","month","year"].map(p => (
            <button key={p} onClick={() => setPeriod(p)}
              className={`px-4 py-1.5 text-xs font-semibold rounded-lg capitalize transition ${period === p ? "bg-primary text-white" : "text-gray-400 hover:text-gray-600"}`}>
              {p === "week" ? "7 Days" : p === "month" ? "30 Days" : "Year"}
            </button>
          ))}
        </div>
      </div>

      {/* Summary KPIs */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { l: "Total Revenue", v: `฿${totalRev.toLocaleString()}`, icon: "payments", color: "text-primary bg-primary/10" },
          { l: "Total Trips", v: totalTrips.toLocaleString(), icon: "route", color: "text-emerald-500 bg-emerald-50" },
          { l: "Avg Revenue/Trip", v: `฿${Math.round(totalRev/totalTrips).toLocaleString()}`, icon: "trending_up", color: "text-amber-500 bg-amber-50" },
          { l: "Driver Earnings", v: `฿${Math.round(totalRev * 0.85).toLocaleString()}`, icon: "account_balance_wallet", color: "text-purple-500 bg-purple-50" },
        ].map(s => (
          <div key={s.l} className="bg-white rounded-2xl p-4 shadow-card flex items-center gap-3">
            <div className={`w-10 h-10 ${s.color} rounded-xl flex items-center justify-center flex-shrink-0`}><span className="material-icons-round">{s.icon}</span></div>
            <div><p className="text-xs text-gray-400">{s.l}</p><p className="text-lg font-bold text-fairgo-dark">{s.v}</p></div>
          </div>
        ))}
      </div>

      {/* Revenue Chart */}
      <div className="bg-white rounded-2xl p-5 shadow-card">
        <div className="flex items-center justify-between mb-4">
          <div><h2 className="font-semibold text-fairgo-dark">Weekly GMV</h2><p className="text-xs text-gray-400">Gross merchandise value by day</p></div>
          <span className="text-sm font-bold text-primary">฿{totalRev.toLocaleString()}</span>
        </div>
        <div className="flex items-end gap-2 h-40">
          {REV.map((r, i) => (
            <div key={i} className="flex-1 flex flex-col items-center gap-1.5 group">
              <span className="text-[10px] text-gray-400 opacity-0 group-hover:opacity-100 transition">฿{(r/1000).toFixed(0)}k</span>
              <div className="w-full bg-primary/15 rounded-t-lg hover:bg-primary/25 transition-colors relative" style={{ height: `${(r/maxRev)*100}%` }}>
                <div className="absolute bottom-0 left-0 right-0 bg-primary rounded-t-lg opacity-80" style={{ height: "55%" }} />
              </div>
              <span className="text-[10px] text-gray-400">{WEEKS[i]}</span>
            </div>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Top Zones */}
        <div className="lg:col-span-2 bg-white rounded-2xl p-5 shadow-card">
          <h2 className="font-semibold text-fairgo-dark mb-4">Top Pickup Zones</h2>
          <div className="space-y-3">
            {ZONES.map((z, i) => (
              <div key={z.name} className="flex items-center gap-3">
                <span className="text-xs font-bold text-gray-300 w-4">{i + 1}</span>
                <span className="text-sm text-fairgo-dark flex-1">{z.name}</span>
                <div className="w-32 bg-gray-100 rounded-full h-2"><div className="bg-primary rounded-full h-2 transition-all" style={{ width: `${(z.trips/maxZone)*100}%` }} /></div>
                <span className="text-xs font-semibold text-gray-500 w-12 text-right">{z.trips.toLocaleString()}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Payment methods */}
        <div className="bg-white rounded-2xl p-5 shadow-card">
          <h2 className="font-semibold text-fairgo-dark mb-4">Payment Methods</h2>
          <div className="h-4 rounded-full overflow-hidden flex mb-4">
            {PAY_METHODS.map(p => <div key={p.l} className={`${p.color} transition-all`} style={{ width: `${p.v}%` }} />)}
          </div>
          {PAY_METHODS.map(p => (
            <div key={p.l} className="flex items-center justify-between mb-2">
              <div className="flex items-center gap-2"><div className={`w-2.5 h-2.5 rounded-full ${p.color}`} /><span className="text-sm text-gray-600">{p.l}</span></div>
              <span className="text-sm font-bold text-fairgo-dark">{p.v}%</span>
            </div>
          ))}

          <div className="mt-4 pt-4 border-t border-gray-100">
            <h3 className="font-semibold text-fairgo-dark mb-3 text-sm">Rating Distribution</h3>
            {RATINGS.map(r => (
              <div key={r.s} className="flex items-center gap-2 mb-1.5">
                <span className="text-xs text-gray-400 w-4">{r.s}★</span>
                <div className="flex-1 bg-gray-100 rounded-full h-1.5"><div className="bg-amber-400 rounded-full h-1.5" style={{ width: `${r.pct}%` }} /></div>
                <span className="text-xs text-gray-400 w-8 text-right">{r.pct}%</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
