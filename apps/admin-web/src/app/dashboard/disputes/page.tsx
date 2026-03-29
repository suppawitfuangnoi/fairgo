"use client";
import { useState, useEffect } from "react";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";
import { useLang } from "@/lib/lang-context";

interface SupportTicket {
  id: string;
  subject: string;
  description: string;
  category: string;
  status: string;
  priority: string;
  createdAt: string;
  resolvedAt?: string;
  user: { name: string; phone: string; role: string };
  trip?: { id: string; lockedFare: number; status: string };
}

const STATUS_COLOR: Record<string, string> = {
  OPEN: "badge-pending",
  IN_PROGRESS: "badge-intransit",
  RESOLVED: "badge-completed",
  CLOSED: "badge-active",
};

const PRIORITY_COLOR: Record<string, string> = {
  LOW: "text-gray-500",
  MEDIUM: "text-amber-500",
  HIGH: "text-orange-500",
  URGENT: "text-red-500",
};

export default function DisputesPage() {
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState<SupportTicket | null>(null);
  const [note, setNote] = useState("");
  const [resolving, setResolving] = useState(false);
  const [statusFilter, setStatusFilter] = useState("ALL");
  const { t } = useLang();

  const load = async () => {
    try {
      const token = getToken(); if (!token) return;
      const statusParam = statusFilter !== "ALL" ? `&status=${statusFilter}` : "";
      const res = await apiFetch<{ data: { tickets: SupportTicket[] } }>(
        `/api/v1/admin/disputes?limit=30${statusParam}`,
        { token }
      );
      setTickets(res.data?.tickets || []);
    } catch { setTickets([]); } finally { setLoading(false); }
  };

  useEffect(() => { load(); }, [statusFilter]);

  const resolve = async (id: string) => {
    setResolving(true);
    try {
      const token = getToken(); if (!token) return;
      await apiFetch(`/api/v1/admin/disputes/${id}`, {
        token,
        method: "PATCH",
        body: { status: "RESOLVED", resolution: note || "Resolved by admin" },
      });
      setTickets(prev => prev.map(t => t.id === id ? { ...t, status: "RESOLVED" } : t));
      setSelected(null); setNote("");
    } catch (e) { console.error(e); } finally { setResolving(false); }
  };

  const STATUS_TABS = ["ALL", "OPEN", "IN_PROGRESS", "RESOLVED"];
  const filtered = tickets.filter(t => statusFilter === "ALL" || t.status === statusFilter);

  const openCount = tickets.filter(t => t.status === "OPEN").length;
  const inProgressCount = tickets.filter(t => t.status === "IN_PROGRESS").length;
  const resolvedCount = tickets.filter(t => t.status === "RESOLVED").length;

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-fairgo-dark">{t.disputesSupport}</h1>
          <p className="text-sm text-gray-400 mt-0.5">{t.disputesManageComplaints}</p>
        </div>
        <button onClick={load} className="flex items-center gap-1.5 text-xs text-gray-500 bg-white border border-gray-200 rounded-lg px-3 py-2 hover:bg-gray-50 transition">
          <span className="material-icons-round text-sm">refresh</span>{t.refresh}
        </button>
      </div>

      {/* Summary cards */}
      <div className="grid grid-cols-3 gap-4">
        {[
          { label: t.disputesOpen, count: openCount, color: "text-red-500", bg: "bg-red-50", icon: "report_problem" },
          { label: t.disputesInReview, count: inProgressCount, color: "text-blue-500", bg: "bg-blue-50", icon: "manage_search" },
          { label: t.disputesResolved, count: resolvedCount, color: "text-emerald-500", bg: "bg-emerald-50", icon: "check_circle" },
        ].map(c => (
          <div key={c.label} className="bg-white rounded-2xl p-4 shadow-card flex items-center gap-3">
            <div className={`w-10 h-10 ${c.bg} rounded-xl flex items-center justify-center`}>
              <span className={`material-icons-round ${c.color}`}>{c.icon}</span>
            </div>
            <div>
              <p className="text-xs text-gray-400">{c.label}</p>
              <p className="text-xl font-bold text-fairgo-dark">{loading ? "—" : c.count}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Filter tabs */}
      <div className="flex gap-1.5">
        {STATUS_TABS.map(s => {
          let label = s.replace("_", " ");
          if (s === "OPEN") label = t.disputesOpen;
          if (s === "IN_PROGRESS") label = t.disputesInReview;
          if (s === "RESOLVED") label = t.disputesResolved;
          if (s === "ALL") label = t.tripsAll;
          return (
            <button
              key={s}
              onClick={() => setStatusFilter(s)}
              className={`text-xs px-3 py-1.5 rounded-lg font-medium transition ${
                statusFilter === s ? "bg-primary text-white" : "bg-white text-gray-500 border border-gray-200 hover:bg-gray-50"
              }`}
            >
              {label}
            </button>
          );
        })}
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl shadow-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100">
                <th className="text-left p-4 text-xs font-semibold text-gray-400">{t.disputesTicket}</th>
                <th className="text-left p-4 text-xs font-semibold text-gray-400">{t.disputesSubject}</th>
                <th className="text-left p-4 text-xs font-semibold text-gray-400">{t.disputesUser}</th>
                <th className="text-left p-4 text-xs font-semibold text-gray-400">{t.disputesPriority}</th>
                <th className="text-left p-4 text-xs font-semibold text-gray-400">{t.dashboardStatus}</th>
                <th className="text-left p-4 text-xs font-semibold text-gray-400">{t.disputesDate}</th>
                <th className="text-left p-4 text-xs font-semibold text-gray-400">{t.disputesAction}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading && (
                <tr><td colSpan={7} className="p-8 text-center text-gray-400">{t.loading}</td></tr>
              )}
              {!loading && filtered.length === 0 && (
                <tr><td colSpan={7} className="p-8 text-center text-gray-400">{t.disputesNoDisputesFound}</td></tr>
              )}
              {filtered.map(t => (
                <tr key={t.id} className="hover:bg-gray-50/50 transition">
                  <td className="p-4 text-xs text-gray-400 font-mono">{t.id.slice(0, 8)}</td>
                  <td className="p-4 max-w-[200px]">
                    <p className="text-sm font-medium text-fairgo-dark truncate">{t.subject}</p>
                    <p className="text-xs text-gray-400 truncate">{t.category}</p>
                  </td>
                  <td className="p-4">
                    <p className="text-xs font-medium text-fairgo-dark">{t.user?.name}</p>
                    <p className="text-xs text-gray-400">{t.user?.role}</p>
                  </td>
                  <td className="p-4">
                    <span className={`text-xs font-semibold ${PRIORITY_COLOR[t.priority] || "text-gray-500"}`}>
                      {t.priority}
                    </span>
                  </td>
                  <td className="p-4">
                    <span className={STATUS_COLOR[t.status] || "badge-pending"}>
                      {t.status.replace("_", " ")}
                    </span>
                  </td>
                  <td className="p-4 text-xs text-gray-400">
                    {new Date(t.createdAt).toLocaleDateString("th-TH")}
                  </td>
                  <td className="p-4">
                    {t.status !== "RESOLVED" && t.status !== "CLOSED" && (
                      <button
                        onClick={() => { setSelected(t); setNote(""); }}
                        className="text-xs text-primary font-medium hover:underline"
                      >
                        {t.disputesReview}
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Review modal */}
      {selected && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold text-fairgo-dark">{t.disputesReviewDispute}</h3>
              <button onClick={() => setSelected(null)} className="text-gray-400 hover:text-gray-600">
                <span className="material-icons-round">close</span>
              </button>
            </div>

            <div className="space-y-3 mb-4">
              <div className="bg-gray-50 rounded-xl p-4">
                <p className="text-sm font-medium text-fairgo-dark mb-1">{selected.subject}</p>
                <p className="text-xs text-gray-500">{selected.description}</p>
              </div>
              <div className="grid grid-cols-2 gap-3 text-xs">
                <div><span className="text-gray-400">User: </span><span className="font-medium">{selected.user?.name}</span></div>
                <div><span className="text-gray-400">Priority: </span><span className={`font-medium ${PRIORITY_COLOR[selected.priority]}`}>{selected.priority}</span></div>
                {selected.trip && <div><span className="text-gray-400">Trip fare: </span><span className="font-medium">฿{selected.trip.lockedFare}</span></div>}
              </div>
            </div>

            <div className="mb-4">
              <label className="block text-xs font-semibold text-gray-500 mb-1.5 uppercase tracking-wide">{t.disputesResolutionNote}</label>
              <textarea
                className="w-full border border-gray-200 rounded-xl p-3 text-sm focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none resize-none"
                rows={3}
                placeholder={t.disputesAddAdminNote}
                value={note}
                onChange={e => setNote(e.target.value)}
              />
            </div>

            <div className="flex gap-2">
              <button
                onClick={() => resolve(selected.id)}
                disabled={resolving}
                className="flex-1 bg-primary text-white rounded-xl py-2.5 text-sm font-semibold hover:bg-primary-600 transition disabled:opacity-50"
              >
                {resolving ? "Resolving..." : t.disputesMarkResolved}
              </button>
              <button
                onClick={() => setSelected(null)}
                className="px-4 bg-gray-100 text-gray-600 rounded-xl py-2.5 text-sm font-medium hover:bg-gray-200 transition"
              >
                {t.disputesCancel}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
