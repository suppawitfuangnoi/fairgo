"use client";
import { useState } from "react";

const DISPUTES = [
  { id: "D001", tripId: "T1234", category: "overcharge", passenger: "สมหญิง ดีใจ", driver: "วิชัย ขับดี", amount: 350, status: "OPEN", createdAt: "2025-03-26T10:32:00Z", desc: "คนขับเรียกเก็บเงินเกินกว่าที่ตกลงไว้ ตกลง 80 บาท แต่เรียก 350 บาท" },
  { id: "D002", tripId: "T1189", category: "unsafe", passenger: "อนุชา มีชัย", driver: "สุรชัย เร็วแรง", amount: 0, status: "UNDER_REVIEW", createdAt: "2025-03-25T14:15:00Z", desc: "ขับรถเร็วเกินกำหนด ฝ่าไฟแดงหลายครั้ง ผู้โดยสารรู้สึกไม่ปลอดภัย" },
  { id: "D003", tripId: "T1045", category: "lost_item", passenger: "กมลา สวยงาม", driver: "ประเสริฐ ดีมาก", amount: 0, status: "RESOLVED", createdAt: "2025-03-24T09:00:00Z", desc: "ลืมกระเป๋าไว้ในรถ คนขับนำส่งคืนเรียบร้อยแล้ว" },
];

const CAT: Record<string, string> = { overcharge: "ค่าโดยสารเกิน", unsafe: "ขับรถไม่ปลอดภัย", lost_item: "ของหาย", other: "อื่นๆ" };

export default function DisputesPage() {
  const [disputes, setDisputes] = useState(DISPUTES);
  const [selected, setSelected] = useState<string | null>(null);
  const [note, setNote] = useState("");

  const resolve = (id: string) => {
    setDisputes(prev => prev.map(d => d.id === id ? { ...d, status: "RESOLVED" } : d));
    setSelected(null); setNote("");
  };

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div className="flex items-center justify-between">
        <div><h1 className="text-xl font-bold text-fairgo-dark">Disputes & Complaints</h1><p className="text-sm text-gray-400">Review and resolve passenger/driver disputes</p></div>
        <div className="flex gap-2">
          {[{ l: "All", v: DISPUTES.length }, { l: "Open", v: DISPUTES.filter(d => d.status === "OPEN").length }, { l: "Review", v: DISPUTES.filter(d => d.status === "UNDER_REVIEW").length }].map(t => (
            <span key={t.l} className="text-xs bg-white border border-gray-200 rounded-xl px-3 py-1.5 font-medium text-gray-500 shadow-card">{t.l} <strong>{t.v}</strong></span>
          ))}
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-card overflow-hidden">
        <table className="w-full">
          <thead><tr className="bg-gray-50 text-xs font-semibold text-gray-400 uppercase">
            <th className="text-left px-4 py-3">ID</th><th className="text-left px-4 py-3">Category</th>
            <th className="text-left px-4 py-3">Passenger</th><th className="text-left px-4 py-3">Driver</th>
            <th className="text-left px-4 py-3">Status</th><th className="text-left px-4 py-3">Date</th>
            <th className="text-left px-4 py-3">Action</th>
          </tr></thead>
          <tbody className="divide-y divide-gray-50">
            {disputes.map(d => (
              <tr key={d.id} className="hover:bg-gray-50/50 transition">
                <td className="px-4 py-3 text-sm font-mono text-gray-500">{d.id}</td>
                <td className="px-4 py-3 text-sm text-fairgo-dark">{CAT[d.category] || d.category}</td>
                <td className="px-4 py-3 text-sm">{d.passenger}</td>
                <td className="px-4 py-3 text-sm text-gray-500">{d.driver}</td>
                <td className="px-4 py-3">
                  {d.status === "OPEN" && <span className="badge-suspended">Open</span>}
                  {d.status === "UNDER_REVIEW" && <span className="badge-pending">Under Review</span>}
                  {d.status === "RESOLVED" && <span className="badge-completed">Resolved</span>}
                </td>
                <td className="px-4 py-3 text-xs text-gray-400">{new Date(d.createdAt).toLocaleDateString("th-TH")}</td>
                <td className="px-4 py-3">
                  {d.status !== "RESOLVED" && (
                    <button onClick={() => setSelected(d.id)} className="text-xs text-primary font-medium hover:underline">Review</button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {selected && (() => {
        const d = disputes.find(x => x.id === selected)!;
        return (
          <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4" onClick={() => setSelected(null)}>
            <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl" onClick={e => e.stopPropagation()}>
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-bold text-fairgo-dark">Review Dispute {d.id}</h3>
                <button onClick={() => setSelected(null)} className="text-gray-400 hover:text-gray-600"><span className="material-icons-round text-xl">close</span></button>
              </div>
              <div className="bg-gray-50 rounded-xl p-3 mb-4 text-sm text-gray-600">{d.desc}</div>
              <div className="space-y-2 text-sm mb-4">
                <div className="flex justify-between"><span className="text-gray-400">Category</span><span className="font-medium">{CAT[d.category]}</span></div>
                <div className="flex justify-between"><span className="text-gray-400">Passenger</span><span className="font-medium">{d.passenger}</span></div>
                <div className="flex justify-between"><span className="text-gray-400">Driver</span><span className="font-medium">{d.driver}</span></div>
              </div>
              <textarea value={note} onChange={e => setNote(e.target.value)} placeholder="Admin note..." rows={3}
                className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none mb-3 resize-none" />
              <div className="flex gap-2">
                <button onClick={() => setSelected(null)} className="flex-1 border border-gray-200 text-gray-500 text-sm font-medium py-2.5 rounded-xl hover:bg-gray-50 transition">Close</button>
                <button onClick={() => resolve(d.id)} className="flex-1 bg-primary text-white text-sm font-semibold py-2.5 rounded-xl hover:bg-primary-600 transition">Mark Resolved</button>
              </div>
            </div>
          </div>
        );
      })()}
    </div>
  );
}
