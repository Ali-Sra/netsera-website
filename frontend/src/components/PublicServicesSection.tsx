"use client";

import { useEffect, useState } from "react";

type Service = {
  id: string;
  title: string;
  slug: string;
  description: string;
  icon: string | null;
  displayOrder: number;
};

const fallback: Service[] = [
  { id: "1", title: "Systemadministration", slug: "systemadministration", description: "Windows Server, Active Directory, Benutzer, Berechtigungen und zuverlässiger IT-Betrieb.", icon: "01", displayOrder: 1 },
  { id: "2", title: "Microsoft 365", slug: "microsoft-365", description: "Entra ID, Benutzer, Gruppen, Lizenzen, MFA und strukturierte Cloud-Administration.", icon: "02", displayOrder: 2 },
  { id: "3", title: "Netzwerk & Security", slug: "netzwerk-security", description: "VLANs, Routing, Firewalls, sichere Segmentierung, VPN und nachvollziehbare Regeln.", icon: "03", displayOrder: 3 },
  { id: "4", title: "Virtualisierung", slug: "virtualisierung", description: "VMware, Hyper-V, Serverkonsolidierung, Backup-Konzepte und dokumentierte Wiederherstellung.", icon: "04", displayOrder: 4 },
];

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:5000/api";

export function PublicServicesSection() {
  const [items, setItems] = useState<Service[]>(fallback);

  useEffect(() => {
    fetch(`${API_BASE_URL}/content/services`, { cache: "no-store" })
      .then(async (response) => {
        if (!response.ok) return;
        const data = (await response.json()) as Service[];
        if (data.length > 0) setItems(data);
      })
      .catch(() => undefined);
  }, []);

  return (
    <section id="leistungen" className="container-shell py-24">
      <div className="max-w-2xl">
        <p className="text-sm font-semibold text-emerald-300">Leistungen</p>
        <h2 className="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">Von Arbeitsplatz bis Firewall.</h2>
        <p className="mt-4 leading-7 text-slate-400">
          Technik soll Probleme lösen, nicht neue schaffen. Deshalb setzen wir auf klare Standards, nachvollziehbare Konfiguration und saubere Dokumentation.
        </p>
      </div>

      <div className="mt-10 grid gap-4 md:grid-cols-2">
        {items.map((service, index) => (
          <article key={service.id} className="glass rounded-2xl p-6 transition hover:-translate-y-1">
            <div className="mb-8 text-xs font-semibold tracking-[.2em] text-slate-500">
              {service.icon || String(index + 1).padStart(2, "0")}
            </div>
            <h3 className="text-xl font-semibold">{service.title}</h3>
            <p className="mt-3 max-w-xl leading-7 text-slate-400">{service.description}</p>
          </article>
        ))}
      </div>
    </section>
  );
}
