"use client";

import { useLang } from "@/lib/lang-context";

interface HeaderProps { title?: string }

export default function Header({ title }: HeaderProps) {
  const { t, lang, toggle } = useLang();
  const now = new Date();
  const dateStr = t.headerDate(now);

  return (
    <header className="sticky top-0 z-10 bg-white/80 backdrop-blur border-b border-gray-100 px-6 py-3">
      <div className="flex items-center justify-between gap-4">
        <p className="text-xs text-gray-400">{dateStr}</p>
        <div className="flex items-center gap-2">
          <div className="relative hidden sm:block">
            <span className="absolute left-3 top-1/2 -translate-y-1/2 material-icons-round text-gray-300 text-base">search</span>
            <input type="text" placeholder={t.headerSearch} className="pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-100 rounded-xl w-56 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition" />
          </div>
          <button
            onClick={toggle}
            className="w-9 h-9 flex items-center justify-center text-gray-500 hover:text-gray-700 hover:bg-gray-50 rounded-xl transition text-xs font-bold border border-gray-100"
            title={t.language}
          >
            {lang === "th" ? "EN" : "TH"}
          </button>
          <button className="relative w-9 h-9 flex items-center justify-center text-gray-400 hover:text-gray-600 hover:bg-gray-50 rounded-xl transition">
            <span className="material-icons-round text-xl">notifications</span>
            <span className="absolute top-2 right-2 w-2 h-2 bg-red-400 rounded-full border border-white" />
          </button>
          <button className="w-9 h-9 flex items-center justify-center text-gray-400 hover:text-gray-600 hover:bg-gray-50 rounded-xl transition">
            <span className="material-icons-round text-xl">help_outline</span>
          </button>
        </div>
      </div>
    </header>
  );
}
