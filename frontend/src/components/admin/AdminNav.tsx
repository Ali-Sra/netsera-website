"use client";

import { usePathname } from "next/navigation";

const links = [
  ["/admin", "Nachrichten"],
  ["/admin/projects", "Projekte"],
  ["/admin/services", "Leistungen"],
] as const;

export function AdminNav() {
  const pathname = usePathname();

  return (
    <nav className="flex flex-wrap gap-2">
      {links.map(([href, label]) => {
        const active = pathname === href;
        return (
          <a
            key={href}
            href={href}
            className={`rounded-lg border px-3 py-2 text-sm transition ${
              active
                ? "border-emerald-300/30 bg-emerald-300/10 text-emerald-200"
                : "border-white/10 text-slate-400 hover:bg-white/5 hover:text-white"
            }`}
          >
            {label}
          </a>
        );
      })}
    </nav>
  );
}
