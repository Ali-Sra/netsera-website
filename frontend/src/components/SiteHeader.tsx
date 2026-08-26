"use client";

import { useState } from "react";

const links = [
  ["Leistungen", "#leistungen"],
  ["Arbeitsweise", "#warum"],
  ["Projekte", "#projekte"],
  ["Kontakt", "#kontakt"],
] as const;

export function SiteHeader() {
  const [open, setOpen] = useState(false);

  return (
    <header className="site-header">
      <div className="container-shell site-header__inner">
        <a href="#top" className="brand-lockup" aria-label="Netsera Startseite">
          <span className="brand-mark" aria-hidden="true">
            <i />
            <b>N</b>
          </span>
          <span>
            <strong>Netsera</strong>
            <small>INFRASTRUCTURE SYSTEMS</small>
          </span>
        </a>

        <nav className="site-nav" aria-label="Hauptnavigation">
          {links.map(([label, href]) => (
            <a key={href} href={href}>{label}</a>
          ))}
        </nav>

        <a href="#kontakt" className="header-cta">Erstgespräch</a>

        <button
          type="button"
          className="menu-button"
          aria-expanded={open}
          aria-controls="mobile-menu"
          onClick={() => setOpen((value) => !value)}
        >
          {open ? "Schließen" : "Menü"}
        </button>
      </div>

      {open ? (
        <nav id="mobile-menu" className="mobile-nav container-shell" aria-label="Mobile Navigation">
          {links.map(([label, href]) => (
            <a key={href} href={href} onClick={() => setOpen(false)}>{label}</a>
          ))}
        </nav>
      ) : null}
    </header>
  );
}
