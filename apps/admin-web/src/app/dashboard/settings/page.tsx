"use client";
import { useState } from "react";
import { useLang } from "@/lib/lang-context";

export default function SettingsPage() {
  const [notifications, setNotifications] = useState({ newDriver: true, tripComplete: true, dispute: true, revenue: false });
  const [commission, setCommission] = useState(15);
  const [matchTimeout, setMatchTimeout] = useState(5);
  const { t } = useLang();

  return (
    <div className="p-6 space-y-5 max-w-3xl mx-auto">
      <div><h1 className="text-xl font-bold text-fairgo-dark">{t.settingsSystemSettings}</h1><p className="text-sm text-gray-400">{t.settingsPlatformConfig}</p></div>

      {/* Platform Config */}
      <div className="bg-white rounded-2xl p-5 shadow-card">
        <h2 className="font-semibold text-fairgo-dark mb-4 flex items-center gap-2">
          <span className="material-icons-round text-primary">tune</span>{t.settingsPlatformConfiguration}
        </h2>
        <div className="space-y-4">
          <div>
            <label className="text-sm font-medium text-gray-700 flex justify-between"><span>{t.settingsCommission}</span><span className="text-primary font-bold">{commission}%</span></label>
            <input type="range" min={5} max={30} step={1} value={commission} onChange={e => setCommission(+e.target.value)} className="w-full mt-2 accent-primary" />
            <div className="flex justify-between text-xs text-gray-400 mt-1"><span>5%</span><span>30%</span></div>
          </div>
          <div>
            <label className="text-sm font-medium text-gray-700 flex justify-between"><span>{t.settingsMatchTimeout}</span><span className="text-primary font-bold">{matchTimeout} {t.settingsMin}</span></label>
            <input type="range" min={1} max={15} step={1} value={matchTimeout} onChange={e => setMatchTimeout(+e.target.value)} className="w-full mt-2 accent-primary" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            {[{ l: t.settingsMaxOffers, v: "10" }, { l: t.settingsMaxCancellations, v: "3" }, { l: t.settingsFareAnomaly, v: "3x" }, { l: t.settingsOTPExpiry, v: "5" }].map(f => (
              <div key={f.l}>
                <label className="text-xs text-gray-400 font-medium">{f.l}</label>
                <input defaultValue={f.v} className="w-full mt-1 border border-gray-200 rounded-xl px-3 py-2 text-sm focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none" />
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Notifications */}
      <div className="bg-white rounded-2xl p-5 shadow-card">
        <h2 className="font-semibold text-fairgo-dark mb-4 flex items-center gap-2">
          <span className="material-icons-round text-primary">notifications</span>{t.settingsAdminNotifications}
        </h2>
        <div className="space-y-3">
          {[
            { k: "newDriver" as const, l: t.settingsNewDriver, d: t.settingsNewDriverDesc },
            { k: "tripComplete" as const, l: t.settingsTripCompletion, d: t.settingsTripCompletionDesc },
            { k: "dispute" as const, l: t.settingsNewDispute, d: t.settingsNewDisputeDesc },
            { k: "revenue" as const, l: t.settingsRevenueThreshold, d: t.settingsRevenueDesc },
          ].map(n => (
            <div key={n.k} className="flex items-start justify-between gap-4">
              <div>
                <p className="text-sm font-medium text-fairgo-dark">{n.l}</p>
                <p className="text-xs text-gray-400">{n.d}</p>
              </div>
              <button onClick={() => setNotifications(prev => ({ ...prev, [n.k]: !prev[n.k] }))}
                className={`relative flex-shrink-0 w-11 h-6 rounded-full transition-colors ${notifications[n.k] ? "bg-primary" : "bg-gray-200"}`}>
                <span className={`absolute top-1 w-4 h-4 rounded-full bg-white shadow transition-transform ${notifications[n.k] ? "translate-x-6" : "translate-x-1"}`} />
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Save */}
      <div className="flex justify-end">
        <button className="flex items-center gap-2 bg-primary text-white font-semibold px-6 py-2.5 rounded-xl hover:bg-primary-600 transition shadow-sm">
          <span className="material-icons-round text-base">save</span>{t.settingsSaveSettings}
        </button>
      </div>
    </div>
  );
}
