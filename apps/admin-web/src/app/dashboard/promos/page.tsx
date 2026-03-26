"use client";
import { useState } from "react";

const PROMOS = [
  { id: "P001", code: "FAIRGO20", desc: "ส่วนลด 20% สำหรับผู้ใช้ใหม่", type: "PERCENT", value: 20, maxDisc: 50, used: 128, limit: 500, active: true, expires: "2025-06-30" },
  { id: "P002", code: "SAVE50", desc: "ลด 50 บาท สำหรับการเดินทางกลางคืน", type: "FIXED", value: 50, maxDisc: 50, used: 47, limit: 200, active: true, expires: "2025-04-30" },
  { id: "P003", code: "TUK50", desc: "ลด 50% สำหรับตุ๊กตุ๊กทุกเส้นทาง", type: "PERCENT", value: 50, maxDisc: 80, used: 200, limit: 200, active: false, expires: "2025-03-31" },
];

export default function PromosPage() {
  const [promos, setPromos] = useState(PROMOS);
  const [showNew, setShowNew] = useState(false);
  const [form, setForm] = useState({ code: "", desc: "", type: "PERCENT", value: 10, maxDisc: 50, limit: 100, expires: "" });

  const toggle = (id: string) => setPromos(prev => prev.map(p => p.id === id ? { ...p, active: !p.active } : p));

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div className="flex items-center justify-between">
        <div><h1 className="text-xl font-bold text-fairgo-dark">Promotions & Coupons</h1><p className="text-sm text-gray-400">Manage discount codes and campaigns</p></div>
        <button onClick={() => setShowNew(true)} className="flex items-center gap-2 bg-primary text-white text-sm font-semibold px-4 py-2.5 rounded-xl hover:bg-primary-600 transition shadow-sm">
          <span className="material-icons-round text-base">add</span>New Promotion
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-2">
        {[{ l: "Active Promos", v: promos.filter(p => p.active).length, icon: "local_offer", color: "text-primary bg-primary/10" },
          { l: "Total Redemptions", v: promos.reduce((a, p) => a + p.used, 0), icon: "redeem", color: "text-emerald-500 bg-emerald-50" },
          { l: "Expired", v: promos.filter(p => !p.active).length, icon: "timer_off", color: "text-gray-400 bg-gray-100" }].map(s => (
          <div key={s.l} className="bg-white rounded-2xl p-4 shadow-card flex items-center gap-3">
            <div className={`w-10 h-10 ${s.color} rounded-xl flex items-center justify-center`}>
              <span className="material-icons-round">{s.icon}</span>
            </div>
            <div><p className="text-xs text-gray-400">{s.l}</p><p className="text-xl font-bold text-fairgo-dark">{s.v}</p></div>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-2xl shadow-card overflow-hidden">
        <div className="p-4 border-b border-gray-100"><h2 className="font-semibold text-fairgo-dark">All Promotions</h2></div>
        <table className="w-full">
          <thead><tr className="bg-gray-50 text-xs font-semibold text-gray-400 uppercase">
            <th className="text-left px-4 py-3">Code</th><th className="text-left px-4 py-3">Description</th>
            <th className="text-center px-4 py-3">Discount</th><th className="text-center px-4 py-3">Usage</th>
            <th className="text-left px-4 py-3">Expires</th><th className="text-center px-4 py-3">Status</th>
            <th className="text-center px-4 py-3">Toggle</th>
          </tr></thead>
          <tbody className="divide-y divide-gray-50">
            {promos.map(p => (
              <tr key={p.id} className="hover:bg-gray-50/50 transition">
                <td className="px-4 py-3"><span className="font-mono font-bold text-primary text-sm bg-primary/5 px-2 py-0.5 rounded-lg">{p.code}</span></td>
                <td className="px-4 py-3 text-sm text-gray-600 max-w-[200px] truncate">{p.desc}</td>
                <td className="px-4 py-3 text-center">
                  <span className="text-sm font-bold text-fairgo-dark">{p.type === "PERCENT" ? `${p.value}%` : `฿${p.value}`}</span>
                  {p.type === "PERCENT" && <span className="text-xs text-gray-400 ml-1">(max ฿{p.maxDisc})</span>}
                </td>
                <td className="px-4 py-3 text-center">
                  <div className="text-xs text-gray-500">{p.used} / {p.limit}</div>
                  <div className="w-full bg-gray-100 rounded-full h-1.5 mt-1"><div className="bg-primary rounded-full h-1.5" style={{ width: `${(p.used / p.limit) * 100}%` }} /></div>
                </td>
                <td className="px-4 py-3 text-sm text-gray-400">{p.expires}</td>
                <td className="px-4 py-3 text-center">
                  {p.active ? <span className="badge-active">Active</span> : <span className="badge-completed">Expired</span>}
                </td>
                <td className="px-4 py-3 text-center">
                  <button onClick={() => toggle(p.id)} className={`relative w-10 h-5 rounded-full transition-colors ${p.active ? "bg-primary" : "bg-gray-200"}`}>
                    <span className={`absolute top-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform ${p.active ? "translate-x-5" : "translate-x-0.5"}`} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showNew && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4" onClick={() => setShowNew(false)}>
          <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl" onClick={e => e.stopPropagation()}>
            <h3 className="font-bold text-fairgo-dark mb-4">New Promotion</h3>
            <div className="space-y-3">
              {[{ l: "Coupon Code", k: "code", t: "text", ph: "FAIRGO20" }, { l: "Description", k: "desc", t: "text", ph: "ลดราคา..." }].map(f => (
                <div key={f.k}>
                  <label className="text-xs text-gray-500 font-medium">{f.l}</label>
                  <input type={f.t} value={(form as any)[f.k]} onChange={e => setForm(prev => ({ ...prev, [f.k]: e.target.value }))} placeholder={f.ph}
                    className="w-full mt-1 border border-gray-200 rounded-xl px-3 py-2 text-sm focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none" />
                </div>
              ))}
              <div className="grid grid-cols-2 gap-3">
                <div><label className="text-xs text-gray-500 font-medium">Type</label>
                  <select value={form.type} onChange={e => setForm(prev => ({ ...prev, type: e.target.value }))} className="w-full mt-1 border border-gray-200 rounded-xl px-3 py-2 text-sm focus:ring-2 focus:ring-primary/30 outline-none">
                    <option value="PERCENT">Percent (%)</option><option value="FIXED">Fixed (฿)</option>
                  </select></div>
                <div><label className="text-xs text-gray-500 font-medium">Value</label>
                  <input type="number" value={form.value} onChange={e => setForm(prev => ({ ...prev, value: +e.target.value }))}
                    className="w-full mt-1 border border-gray-200 rounded-xl px-3 py-2 text-sm focus:ring-2 focus:ring-primary/30 outline-none" /></div>
              </div>
              <div><label className="text-xs text-gray-500 font-medium">Expires</label>
                <input type="date" value={form.expires} onChange={e => setForm(prev => ({ ...prev, expires: e.target.value }))}
                  className="w-full mt-1 border border-gray-200 rounded-xl px-3 py-2 text-sm focus:ring-2 focus:ring-primary/30 outline-none" /></div>
            </div>
            <div className="flex gap-2 mt-4">
              <button onClick={() => setShowNew(false)} className="flex-1 border border-gray-200 text-gray-500 text-sm font-medium py-2.5 rounded-xl hover:bg-gray-50 transition">Cancel</button>
              <button onClick={() => { setPromos(prev => [...prev, { ...form, id: `P${Date.now()}`, used: 0, active: true, maxDisc: form.maxDisc }]); setShowNew(false); }}
                className="flex-1 bg-primary text-white text-sm font-semibold py-2.5 rounded-xl hover:bg-primary-600 transition">Create</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
