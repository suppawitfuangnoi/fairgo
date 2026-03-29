"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { Lang, translations, Translations } from "./i18n";

interface LangContextType {
  lang: Lang;
  t: Translations;
  setLang: (l: Lang) => void;
  toggle: () => void;
}

const LangContext = createContext<LangContextType>({
  lang: "th",
  t: translations.th,
  setLang: () => {},
  toggle: () => {},
});

export function LangProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLangState] = useState<Lang>("th");

  useEffect(() => {
    const saved = localStorage.getItem("admin_lang") as Lang | null;
    if (saved === "en" || saved === "th") setLangState(saved);
  }, []);

  const setLang = (l: Lang) => {
    setLangState(l);
    localStorage.setItem("admin_lang", l);
  };

  const toggle = () => setLang(lang === "th" ? "en" : "th");

  return (
    <LangContext.Provider value={{ lang, t: translations[lang], setLang, toggle }}>
      {children}
    </LangContext.Provider>
  );
}

export const useLang = () => useContext(LangContext);
