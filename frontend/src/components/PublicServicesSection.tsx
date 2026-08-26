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
  { id: "1", title: "Microsoft 365 / Entra ID", slug: "microsoft-365", description: "Identitäten, Gruppen, Lizenzen, MFA und nachvollziehbare Zugriffssteuerung.", icon: "ID", displayOrder: 1 },
  { id: "2", title: "Firewall & Netzwerk", slug: "netzwerk-security", description: "VLAN, Routing, VPN, Segmentierung und klar dokumentierte Firewall-Regeln.", icon: "FW", displayOrder: 2 },
  { id: "3", title: "Virtualisierung", slug: "virtualisierung", description: "VMware, Hyper-V, Serverkonsolidierung und kontrollierte Recovery-Pfade.", icon: "VM", displayOrder: 3 },
  { id: "4", title: "Monitoring & Backup", slug: "monitoring-backup", description: "Verfügbarkeit sichtbar machen, Signale bewerten und Wiederherstellung planbar halten.", icon: "MN", displayOrder: 4 },
  { id: "5", title: "Systemadministration", slug: "systemadministration", description: "Windows Server, Active Directory, Rechte, Clients und strukturierter IT-Betrieb.", icon: "SA", displayOrder: 5 },
  { id: "6", title: "Security", slug: "security", description: "Least Privilege, MFA, Hardening, Segmentierung und nachvollziehbare Schutzmaßnahmen.", icon: "SC", displayOrder: 6 },
];

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:5000/api";

function iconFor(service: Service, index: number) {
  return service.icon || String(index + 1).padStart(2, "0");
}

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
    <section id="leistungen" className="section-shell" data-reveal>
      <div className="container-shell">
        <div className="section-heading section-heading--split">
          <div>
            <p className="eyebrow">CORE MODULES</p>
            <h2>Technische Domänen statt generischer Service-Karten.</h2>
          </div>
          <p>
            Jede Leistung wird als klarer Betriebsbaustein gedacht: mit Zustand,
            Grenzen, Standards und dokumentierbaren Ergebnissen.
          </p>
        </div>

        <div className="service-modules">
          {items.map((service, index) => (
            <article key={service.id} className="service-module" data-reveal>
              <div className="service-module__top">
                <span className="service-module__icon">{iconFor(service, index)}</span>
                <span className="service-module__state">
                  <i className="status-dot" /> READY
                </span>
              </div>
              <div className="service-module__terminal" aria-hidden="true">
                <span>$ inspect {service.slug}</span>
                <i />
                <i />
                <i />
              </div>
              <h3>{service.title}</h3>
              <p>{service.description}</p>
              <div className="service-module__meta">
                <span>DOCUMENTED</span>
                <span>MONITORABLE</span>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
