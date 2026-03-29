"use client";
import { useState, useEffect } from "react";
import { apiFetch } from "@/lib/api";
import { getToken } from "@/lib/auth";
import { useLang } from "@/lib/lang-context";

interface PricingRule {
  id?: string;
  vehicleType: string;
  baseFare: number;
  perKmRate: number;
  perMinuteRate: number;
  minimumFare: number;
  surgeMultiplier: number;
  isActive: boolean;
}

const DEFAULT_RULES: Omit<PricingRule, "id">[] = [
  { vehicleType: "TAXI",       baseFare: 35,  perKmRate: 6.5, perMinuteRate: 1.5, minimumFare: 35,  surgeMultiplier: 1.0, isActive: true },
  { vehicleType: "MOTORCYCLE", baseFare: 20,  perKmRate: 4.5, perMinuteRate: 1.0, minimumFare: 20,  surgeMultiplier: 1.0, isActive: true },
  { vehicleType: "TUKTUK",     baseFare: 40,  perKmRate: 7.0, perMinuteRate: 1.5, minimumFare: 40,  surgeMultiplier: 1.0, isActive: true },
];

const VT_ICON: Record<string, string> = {
  TAXI: "local_taxi",
  MOTORCYCLE: "two_wheeler",
  TUKTUK: "electric_rickshaw",
};

const VT_COLOR: Record<string, string> = {
  TAXI: "bg-primary/10 text-primary",
  MOTORCYCLE: "bg-amber-50 text-amber-500",
  TUKTUK: "bg-emerald-50 text-emerald-500",
};

export default function PricingPage() {
  const [rules, setRules] = useState<PricingRule[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState<string | null>(null);
  const [msg, setMsg] = useState("");
  const { t } = useLang();

  useEffect(() => {
    const load = async () => {
      try {
        const token = getToken(); if (!token) return;
        const res = await apiFetch<{ data: PricingRule[] }>("/api/v1/admin/pricing", { token });
        const fetchedRules = res.data || [];
        // Merge with defaults for any missing vehicle types
        const merged = DEFAULT_RULES.map(def => {
          const found = fetchedRules.find(r => r.vehicleType === def.vehicleType);
          return found || def;
        });
        setRules(merged);
      } catch { setRules(DEFAULT_RULES as PricingRule[]); } finally { setLoading(false); }
    };
    load();
  }, []);

  const updateRule = (vehicleType: string, field: keyof PricingRule, value: number | boolean) => {
    setRules(prev => prev.map(r => r.vehicleType === vehicleType ? { ...r, [field]: value } : r));
  };

  const save = async (rule: PricingRule) => {
    setSaving(rule.vehicleType);
    setMsg("");
    try {
      const token = getToken(); if (!token) return;
      await apiFetch("/api/v1/admin/pricing", {
        token,
        method: "PUT",
        body: rule,
      });
      setMsg(`✓ ${rule.vehicleType} pricing saved successfully`);
      setTimeout(() => setMsg(""), 3000);
    } catch (e) {
      setMsg(`✗ Failed to save ${rule.vehicleType} pricing`);
    } finally { setSaving(null); }
  };

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-fairgo-dark">{t.pricingTitle}</h1>
          <p className="text-sm text-gray-400 mt-0.5">{t.pricingSubtitle}</p>
        </div>
      </div>

      {msg && (
        <div className={`text-sm rounded-xl p-3 ${msg.startsWith("✓") ? "bg-emerald-50 text-emerald-600" : "bg-red-50 text-red-500"}`}>
          {msg}
        </div>
      )}

      {loading ? (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          {[1,2,3].map(i => <div key={i} className="h-64 bg-white rounded-2xl animate-pulse shadow-card" />)}
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          {rules.map(rule => (
            <div key={rule.vehicleType} className="bg-white rounded-2xl p-5 shadow-card">
              <div className="flex items-center gap-3 mb-5">
                <div className={`w-12 h-12 ${VT_COLOR[rule.vehicleType]} rounded-xl flex items-center justify-center`}>
                  <span className="material-icons-round text-2xl">{VT_ICON[rule.vehicleType]}</span>
                </div>
                <div className="flex-1">
                  <h2 className="font-semibold text-fairgo-dark">{rule.vehicleType}</h2>
                  <div className="flex items-center gap-2 mt-0.5">
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input type="checkbox" checked={rule.isActive}
                        onChange={e => updateRule(rule.vehicleType, "isActive", e.target.checked)}
                        className="sr-only peer" />
                      <div className="w-8 h-4 bg-gray-200 peer-focus:ring-2 peer-focus:ring-primary/30 rounded-full peer peer-checked:bg-primary transition-colors" />
                      <div className="absolute left-0.5 top-0.5 w-3 h-3 bg-white rounded-full shadow transition-transform peer-checked:translate-x-4" />
                    </label>
                    <span className="text-xs text-gray-400">{rule.isActive ? "Active" : "Inactive"}</span>
                  </div>
                </div>
              </div>

              <div className="space-y-3">
                {[
                  { label: "Base Fare (฿)", field: "baseFare" as keyof PricingRule, min: 0, step: 5 },
                  { label: "Per KM Rate (฿)", field: "perKmRate" as keyof PricingRule, min: 0, step: 0.5 },
                  { label: "Per Minute (฿)", field: "perMinuteRate" as keyof PricingRule, min: 0, step: 0.5 },
                  { label: "Minimum Fare (฿)", field: "minimumFare" as keyof PricingRule, min: 0, step: 5 },
                ].map(f => (
                  <div key={f.field}>
                    <label className="block text-xs font-medium text-gray-500 mb-1">{f.label.replace("(฿)", `(${t.baht})`)}</label>
                    <input
                      type="number"
                      value={rule[f.field] as number}
                      onChange={e => updateRule(rule.vehicleType, f.field, parseFloat(e.target.value) || 0)}
                      min={f.min}
                      step={f.step}
                      className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:ring-2 focus:ring-primary/30 focus:border-primary outline-none bg-gray-50 focus:bg-white transition"
                    />
                  </div>
                ))}

                <div>
                  <label className="flex items-center justify-between text-xs font-medium text-gray-500 mb-1">
                    <span>Surge Multiplier</span>
                    <span className="font-bold text-primary">{rule.surgeMultiplier.toFixed(1)}×</span>
                  </label>
                  <input
                    type="range" min={1} max={5} step={0.1}
                    value={rule.surgeMultiplier}
                    onChange={e => updateRule(rule.vehicleType, "surgeMultiplier", parseFloat(e.target.value))}
                    className="w-full accent-primary"
                  />
                  <div className="flex justify-between text-[10px] text-gray-300 mt-0.5">
                    <span>1.0×</span><span>5.0×</span>
                  </div>
                </div>
              </div>

              <button
                onClick={() => save(rule)}
                disabled={saving === rule.vehicleType}
                className="w-full mt-4 bg-primary text-white rounded-xl py-2.5 text-sm font-semibold hover:bg-primary-600 transition disabled:opacity-50"
              >
                {saving === rule.vehicleType ? "Saving..." : "Save Changes"}
              </button>
            </div>
          ))}
        </div>
      )}

      {/* Info card */}
      <div className="bg-amber-50 border border-amber-100 rounded-2xl p-4 flex items-start gap-3">
        <span className="material-icons-round text-amber-500 mt-0.5 flex-shrink-0">info</span>
        <div className="text-xs text-amber-700">
          <p className="font-semibold mb-0.5">Pricing Formula</p>
          <p>Fare = Base Fare + (Distance × Per KM Rate) + (Duration × Per Minute Rate)</p>
          <p className="mt-0.5">Final Fare = max(Calculated Fare, Minimum Fare) × Surge Multiplier</p>
          <p className="mt-0.5">Driver negotiation allowed between 80%–150% of calculated fare.</p>
        </div>
      </div>
    </div>
  );
}
