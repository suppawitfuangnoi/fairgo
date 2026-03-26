"use client";
import { useState } from "react";

const defaultPolicies = [
  { type: "TAXI", label: "Taxi", icon: "local_taxi", baseMin: 60, baseMax: 500, perKm: 10, surgeMultiplier: 1.0, color: "text-primary bg-primary/10" },
  { type: "MOTORCYCLE", label: "Motorcycle", icon: "two_wheeler", baseMin: 30, baseMax: 250, perKm: 6, surgeMultiplier: 1.0, color: "text-amber-500 bg-amber-50" },
  { type: "TUKTUK", label: "Tuk-tuk", icon: "electric_rickshaw", baseMin: 40, baseMax: 300, perKm: 8, surgeMultiplier: 1.0, color: "text-emerald-500 bg-emerald-50" },
];

const anomalies = [
  { id: 1, time: "14:32", route: "สุขุมวิท → ดอนเมือง", fare: 1850, expected: 420, driver: "วิชัย ขับดี", status: "FLAGGED" },
  { id: 2, time: "13:15", route: "อนุสาวรีย์ → ลาดพร้าว", fare: 580, expected: 120, driver: "สมชาย ใจดี", status: "REVIEWED" },
];

export default function PricingPage() {
  const [policies, setPolicies] = useState(defaultPolicies);
  const [editing, setEditing] = useState<string | null>(null);

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div><h1 className="text-xl font-bold text-fairgo-dark">Pricing Policy</h1><p className="text-sm text-gray-400">Manage fare ranges and surge pricing</p></div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {policies.map(p => (
          <div key={p.type} className="bg-white rounded-2xl p-5 shadow-card">
            <div className="flex items-center gap-3 mb-4">
              <div className={`w-10 h-10 ${p.color} rounded-xl flex items-center justify-center`}>
                <span className="material-icons-round text-xl">{p.icon}</span>
              </div>
              <div>
                <h3 className="font-semibold text-fairgo-dark">{p.label}</h3>
                <p className="text-xs text-gray-400">Fare policy</p>
              </div>
            </div>
            <div className="space-y-3">
              <div>
                <label className="text-xs text-gray-400 font-medium">Base Fare Range (฿)</label>
                <div className="flex gap-2 mt-1">
                  <input type="number" value={p.baseMin} onChange={e => setPolicies(prev => prev.map(x => x.type === p.type ? { ...x, baseMin: +e.target.value } : x))}
                    className="flex-1 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none" placeholder="Min" />
                  <span className="self-center text-gray-400">–</span>
                  <input type="number" value={p.baseMax} onChange={e => setPolicies(prev => prev.map(x => x.type === p.type ? { ...x, baseMax: +e.target.value } : x))}
                    className="flex-1 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none" placeholder="Max" />
                </div>
              </div>
              <div>
                <label className="text-xs text-gray-400 font-medium">Rate per km (฿)</label>
                <input type="number" value={p.perKm} onChange={e => setPolicies(prev => prev.map(x => x.type === p.type ? { ...x, perKm: +e.target.value } : x))}
                  className="w-full mt-1 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none" />
              </div>
              <div>
                <label className="text-xs text-gray-400 font-medium">Surge Multiplier</label>
                <div className="flex items-center gap-2 mt-1">
                  <input type="range" min="1" max="3" step="0.1" value={p.surgeMultiplier}
                    onChange={e => setPolicies(prev => prev.map(x => x.type === p.type ? { ...x, surgeMultiplier: +e.target.value } : x))}
                    className="flex-1 accent-primary" />
                  <span className="text-sm font-semibold text-primary w-8">{p.surgeMultiplier.toFixed(1)}x</span>
                </div>
              </div>
              <button className="w-full bg-primary/10 hover:bg-primary/20 text-primary text-sm font-semibold py-2 rounded-xl transition">Save Policy</button>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-2xl shadow-card overflow-hidden">
        <div className="p-4 border-b border-gray-100 flex items-center justify-between">
          <div><h2 className="font-semibold text-fairgo-dark">Fare Anomaly Flags</h2><p className="text-xs text-gray-400">Suspicious pricing detected by system</p></div>
          <span className="badge-pending">{anomalies.filter(a => a.status === "FLAGGED").length} flagged</span>
        </div>
        <table className="w-full">
          <thead><tr className="bg-gray-50 text-xs font-semibold text-gray-400 uppercase">
            <th className="text-left px-4 py-3">Time</th><th className="text-left px-4 py-3">Route</th>
            <th className="text-left px-4 py-3">Driver</th><th className="text-right px-4 py-3">Fare</th>
            <th className="text-right px-4 py-3">Expected</th><th className="text-left px-4 py-3">Status</th>
          </tr></thead>
          <tbody className="divide-y divide-gray-50">
            {anomalies.map(a => (
              <tr key={a.id} className="hover:bg-gray-50/50 transition">
                <td className="px-4 py-3 text-sm text-gray-500">{a.time}</td>
                <td className="px-4 py-3 text-sm text-fairgo-dark">{a.route}</td>
                <td className="px-4 py-3 text-sm">{a.driver}</td>
                <td className="px-4 py-3 text-sm font-bold text-red-500 text-right">฿{a.fare}</td>
                <td className="px-4 py-3 text-sm text-gray-400 text-right">฿{a.expected}</td>
                <td className="px-4 py-3">
                  {a.status === "FLAGGED"
                    ? <span className="badge-suspended">Flagged</span>
                    : <span className="badge-completed">Reviewed</span>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
