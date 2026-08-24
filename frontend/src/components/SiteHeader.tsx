"use client";

import { useState } from "react";

const links = [
  ["Leistungen", "#leistungen"],
  ["Warum Netsera", "#warum"],
  ["Projekte", "#projekte"],
  ["Kontakt", "#kontakt"],
] as const;

export function SiteHeader() {
  const [open, setOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 border-b border-white/10 bg-[#07111f]/80 backdrop-blur-xl">
      <div className="container-shell flex h-18 items-center justify-between">
        <a href="#top" className="flex items-center gap-3 font-semibold tracking-tight" aria-label="Netsera Startseite">
          <span className="grid h-9 w-9 place-items-center rounded-xl border border-emerald-300/30 bg-emerald-300/10 text-emerald-200">N</span>
          <span className="text-lg">Netsera</span>
        </a>

        <nav className="hidden items-center gap-7 text-sm text-slate-300 md:flex" aria-label="Hauptnavigation">
          {links.map(([label, href]) => (
            <a key={href} className="transition hover:text-white" href={href}>{label}</a>
          ))}
        </nav>

        <a href="#kontakt" className="hidden rounded-xl bg-white px-4 py-2.5 text-sm font-semibold text-slate-950 transition hover:bg-emerald-100 md:inline-flex">
          Erstgespräch
        </a>

        <button
          type="button"
          className="rounded-lg border border-white/15 px-3 py-2 text-sm md:hidden"
          aria-expanded={open}
          aria-controls="mobile-menu"
          onClick={() => setOpen((value) => !value)}
        >
          Menü
        </button>
      </div>

      {open && (
        <nav id="mobile-menu" className="container-shell border-t border-white/10 py-4 md:hidden" aria-label="Mobile Navigation">
          <div className="flex flex-col gap-2">
            {links.map(([label, href]) => (
              <a key={href} className="rounded-lg px-3 py-3 text-slate-200 hover:bg-white/5" href={href} onClick={() => setOpen(false)}>{label}</a>
            ))}
          </div>
        </nav>
      )}
    </header>
  );
}
