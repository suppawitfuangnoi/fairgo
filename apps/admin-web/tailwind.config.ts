import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#13c8ec",
          50: "#e8faff",
          100: "#d1f5ff",
          200: "#a3ebff",
          300: "#6ddcf5",
          400: "#2fcee8",
          500: "#13c8ec",
          600: "#0ea5c5",
          700: "#0b86a0",
          800: "#09697d",
          900: "#064e5d",
        },
        fairgo: {
          dark: "#0f172a",
          bg: "#f6f8f8",
          success: "#10b981",
          warning: "#f59e0b",
          danger: "#ef4444",
        },
      },
      fontFamily: {
        sans: ["Plus Jakarta Sans", "IBM Plex Sans Thai", "sans-serif"],
      },
    },
  },
  plugins: [],
};

export default config;
