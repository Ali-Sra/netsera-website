import { ContactForm } from "@/components/ContactForm";
import { SiteFooter } from "@/components/SiteFooter";
import { SiteHeader } from "@/components/SiteHeader";

const services = [
  { title: "Systemadministration", text: "Windows Server, Active Directory, Benutzer, Berechtigungen und zuverlässiger IT-Betrieb.", icon: "01" },
  { title: "Microsoft 365", text: "Entra ID, Benutzer, Gruppen, Lizenzen, MFA und strukturierte Cloud-Administration.", icon: "02" },
  { title: "Netzwerk & Security", text: "VLANs, Routing, Firewalls, sichere Segmentierung, VPN und nachvollziehbare Regeln.", icon: "03" },
  { title: "Virtualisierung", text: "VMware, Hyper-V, Serverkonsolidierung, Backup-Konzepte und dokumentierte Wiederherstellung.", icon: "04" },
];

const projects = [
  ["Enterprise Firewall Security Lab", "LAN/WAN/DMZ, NAT, VLAN, VPN, IPS und dokumentierte Security-Flows."],
  ["FacilityFlow", ".NET/Blazor Anwendung mit EF Core, REST API, Docker Compose und Tests."],
  ["Virtual Infrastructure Lab", "Nested ESXi/vCenter, Netzwerkdesign, Troubleshooting und Active-Directory-Integration."],
] as const;

export default function Home() {
  return (
    <main id="top">
      <SiteHeader />

      <section className="relative overflow-hidden border-b border-white/10">
        <div className="grid-noise absolute inset-0 opacity-50" aria-hidden="true" />
        <div className="container-shell relative grid min-h-[680px] items-center gap-14 py-20 lg:grid-cols-[1.15fr_.85fr] lg:py-28">
          <div>
            <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-emerald-300/20 bg-emerald-300/5 px-3 py-1.5 text-xs font-medium text-emerald-100">
              <span className="h-2 w-2 rounded-full bg-emerald-300" />
              IT, die stabil läuft und verständlich bleibt
            </div>
            <h1 className="max-w-4xl text-5xl font-semibold leading-[1.03] tracking-[-0.045em] sm:text-6xl lg:text-7xl">
              Sichere IT-Infrastruktur für <span className="text-gradient">moderne Unternehmen.</span>
            </h1>
            <p className="mt-7 max-w-2xl text-lg leading-8 text-slate-300">
              Netsera verbindet Systemadministration, Microsoft 365, Netzwerke, Virtualisierung und Security zu einer klar dokumentierten IT-Landschaft.
            </p>
            <div className="mt-9 flex flex-col gap-3 sm:flex-row">
              <a href="#kontakt" className="rounded-xl bg-white px-5 py-3.5 text-center text-sm font-semibold text-slate-950 transition hover:bg-emerald-100">Projekt besprechen</a>
              <a href="#leistungen" className="rounded-xl border border-white/15 bg-white/5 px-5 py-3.5 text-center text-sm font-semibold transition hover:bg-white/10">Leistungen ansehen</a>
            </div>
          </div>

          <div className="glass rounded-3xl p-5 sm:p-7">
            <div className="mb-6 flex items-center justify-between border-b border-white/10 pb-5">
              <div>
                <p className="text-xs uppercase tracking-[.18em] text-slate-500">Systemübersicht</p>
                <p className="mt-1 font-semibold">Netsera Infrastructure</p>
              </div>
              <span className="rounded-full bg-emerald-300/10 px-3 py-1 text-xs text-emerald-200">Operational</span>
            </div>
            <div className="space-y-3">
              {["Microsoft 365 / Entra ID", "Firewall & Netzwerk", "Virtualisierung", "Monitoring & Backup"].map((item, index) => (
                <div key={item} className="flex items-center justify-between rounded-2xl border border-white/10 bg-black/10 p-4">
                  <div className="flex items-center gap-3">
                    <span className="grid h-9 w-9 place-items-center rounded-xl bg-white/5 text-xs text-slate-400">0{index + 1}</span>
                    <span className="text-sm text-slate-200">{item}</span>
                  </div>
                  <span className="text-xs text-emerald-300">● Online</span>
                </div>
              ))}
            </div>
            <div className="mt-5 grid grid-cols-3 gap-3 text-center">
              {[["99.9%", "Ziel Verfügbarkeit"], ["24/7", "Monitoring-ready"], ["4", "Kernbereiche"]].map(([value, label]) => (
                <div key={label} className="rounded-2xl border border-white/10 p-4">
                  <div className="text-lg font-semibold">{value}</div>
                  <div className="mt-1 text-[11px] leading-4 text-slate-500">{label}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      <section id="leistungen" className="container-shell py-24">
        <div className="max-w-2xl">
          <p className="text-sm font-semibold text-emerald-300">Leistungen</p>
          <h2 className="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">Von Arbeitsplatz bis Firewall.</h2>
          <p className="mt-4 leading-7 text-slate-400">Technik soll Probleme lösen, nicht neue schaffen. Deshalb setzen wir auf klare Standards, nachvollziehbare Konfiguration und saubere Dokumentation.</p>
        </div>
        <div className="mt-10 grid gap-4 md:grid-cols-2">
          {services.map((service) => (
            <article key={service.title} className="glass rounded-2xl p-6 transition hover:-translate-y-1">
              <div className="mb-8 text-xs font-semibold tracking-[.2em] text-slate-500">{service.icon}</div>
              <h3 className="text-xl font-semibold">{service.title}</h3>
              <p className="mt-3 max-w-xl leading-7 text-slate-400">{service.text}</p>
            </article>
          ))}
        </div>
      </section>

      <section id="warum" className="border-y border-white/10 bg-white/[.025] py-24">
        <div className="container-shell grid gap-12 lg:grid-cols-2 lg:items-center">
          <div>
            <p className="text-sm font-semibold text-sky-300">Arbeitsweise</p>
            <h2 className="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">Weniger Blackbox. Mehr Kontrolle.</h2>
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            {[["01", "Analyse", "Ist-Zustand verstehen, Risiken sichtbar machen."], ["02", "Planung", "Zielbild, Prioritäten und saubere Umsetzung."], ["03", "Absicherung", "Least Privilege, MFA, Segmentierung und Backups."], ["04", "Dokumentation", "Konfigurationen und Entscheidungen nachvollziehbar halten."]].map(([n,t,d]) => (
              <div key={n} className="rounded-2xl border border-white/10 p-5">
                <span className="text-xs text-slate-500">{n}</span>
                <h3 className="mt-5 font-semibold">{t}</h3>
                <p className="mt-2 text-sm leading-6 text-slate-400">{d}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section id="projekte" className="container-shell py-24">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p className="text-sm font-semibold text-emerald-300">Projekte</p>
            <h2 className="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">Praxis statt Buzzwords.</h2>
          </div>
          <a href="https://github.com/Ali-Sra" target="_blank" rel="noreferrer" className="text-sm text-slate-300 hover:text-white">GitHub ansehen ↗</a>
        </div>
        <div className="mt-10 grid gap-4 lg:grid-cols-3">
          {projects.map(([title, text], index) => (
            <article key={title} className="glass flex min-h-64 flex-col justify-between rounded-2xl p-6">
              <span className="text-xs text-slate-500">PROJECT / 0{index + 1}</span>
              <div>
                <h3 className="text-xl font-semibold">{title}</h3>
                <p className="mt-3 text-sm leading-6 text-slate-400">{text}</p>
              </div>
            </article>
          ))}
        </div>
      </section>

      <section id="kontakt" className="container-shell pb-24">
        <div className="glass overflow-hidden rounded-3xl p-7 sm:p-10 lg:p-14">
          <div className="grid gap-10 lg:grid-cols-[1fr_.8fr] lg:items-start">
            <div>
              <p className="text-sm font-semibold text-emerald-300">Kontakt</p>
              <h2 className="mt-3 max-w-2xl text-3xl font-semibold tracking-tight sm:text-5xl">Ihre IT soll sicherer, übersichtlicher oder moderner werden?</h2>
              <p className="mt-5 max-w-xl leading-7 text-slate-400">
                Beschreiben Sie kurz Ihr Vorhaben. Ihre Nachricht wird über die Netsera API validiert und in PostgreSQL gespeichert.
              </p>
              <div className="mt-7 rounded-2xl border border-white/10 bg-black/10 p-5 text-sm leading-6 text-slate-400">
                <p className="font-medium text-slate-200">Technischer Ablauf</p>
                <p className="mt-2">Next.js → ASP.NET Core API → EF Core → PostgreSQL</p>
              </div>
            </div>
            <ContactForm />
          </div>
        </div>
      </section>

      <SiteFooter />
    </main>
  );
}
