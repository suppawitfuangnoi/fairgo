"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useState } from "react";
import { clearAuth, getUser } from "@/lib/auth";

const navItems = [
  { href: "/dashboard",           label: "Dashboard",      icon: "dashboard" },
  { href: "/dashboard/trips",     label: "Trip Monitor",   icon: "map" },
  { href: "/dashboard/users",     label: "Users & Drivers",icon: "people" },
  { href: "/dashboard/pricing",   label: "Pricing Policy", icon: "sell" },
  { href: "/dashboard/disputes",  label: "Disputes",       icon: "gavel" },
  { href: "/dashboard/promos",    label: "Promotions",     icon: "local_offer" },
  { href: "/dashboard/analytics", label: "Reports",        icon: "bar_chart" },
  { href: "/dashboard/settings",  label: "Settings",       icon: "settings" },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const user = getUser();
  const [collapsed, setCollapsed] = useState(false);

  const handleLogout = () => {
    clearAuth();
    router.push("/login");
  };

  return (
    <aside
      className={`${collapsed ? "w-16" : "w-60"} bg-white border-r border-gray-100 min-h-screen flex flex-col transition-all duration-200 shadow-sm flex-shrink-0`}
    >
      {/* Logo */}
      <div className="p-4 border-b border-gray-100 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 bg-primary rounded-xl flex items-center justify-center shadow-sm flex-shrink-0">
            <span className="material-icons-round text-white text-lg">directions_car</span>
          </div>
          {!collapsed && (
            <div>
              <h1 className="font-extrabold text-fairgo-dark text-base tracking-tight leading-none">FAIRGO</h1>
              <p className="text-[10px] text-primary font-semibold mt-0.5 tracking-widest uppercase">Admin Portal</p>
            </div>
          )}
        </div>
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="text-gray-400 hover:text-gray-600 transition"
        >
          <span className="material-icons-round text-sm">
            {collapsed ? "chevron_right" : "chevron_left"}
          </span>
        </button>
      </div>

      {/* Nav */}
      <nav className="flex-1 py-3 px-2 space-y-0.5 overflow-y-auto">
        {navItems.map((item) => {
          const isActive =
            item.href === "/dashboard"
              ? pathname === "/dashboard"
              : pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-150 group ${
                isActive
                  ? "bg-primary/10 text-primary font-semibold"
                  : "text-gray-500 hover:bg-gray-50 hover:text-gray-800"
              }`}
              title={collapsed ? item.label : ""}
            >
              <span
                className={`material-icons-round text-[20px] flex-shrink-0 ${
                  isActive ? "text-primary" : "text-gray-400 group-hover:text-gray-600"
                }`}
              >
                {item.icon}
              </span>
              {!collapsed && <span className="truncate">{item.label}</span>}
              {!collapsed && isActive && (
                <div className="ml-auto w-1.5 h-1.5 rounded-full bg-primary" />
              )}
            </Link>
          );
        })}
      </nav>

      {/* User */}
      <div className="p-3 border-t border-gray-100">
        <div className={`flex items-center gap-3 ${collapsed ? "justify-center" : ""}`}>
          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-primary text-xs font-bold flex-shrink-0">
            {((user?.name as string) || "A").charAt(0).toUpperCase()}
          </div>
          {!collapsed && (
            <div className="flex-1 min-w-0">
              <p className="text-xs font-semibold text-fairgo-dark truncate">
                {(user?.name as string) || "Admin"}
              </p>
              <p className="text-[10px] text-gray-400">System Manager</p>
            </div>
          )}
          {!collapsed && (
            <button
              onClick={handleLogout}
              className="text-gray-300 hover:text-red-400 transition"
              title="Logout"
            >
              <span className="material-icons-round text-[18px]">logout</span>
            </button>
          )}
        </div>
      </div>
    </aside>
  );
}
