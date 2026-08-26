import { ComplexityDiagram } from "@/components/ComplexityDiagram";
import { ContactForm } from "@/components/ContactForm";
import { ExperienceMotion } from "@/components/ExperienceMotion";
import { HeroVideoScene } from "@/components/HeroVideoScene";
import { InfrastructureDashboard } from "@/components/InfrastructureDashboard";
import { PublicProjectsSection } from "@/components/PublicProjectsSection";
import { PublicServicesSection } from "@/components/PublicServicesSection";
import { SiteFooter } from "@/components/SiteFooter";
import { SiteHeader } from "@/components/SiteHeader";
import { WorkflowRail } from "@/components/WorkflowRail";

export default function Home() {
  return (
    <main id="top" className="site-shell">
      <ExperienceMotion />
      <SiteHeader />

      <section className="hero-stage">
        <div className="hero-stage__grid" aria-hidden="true" />
        <div className="hero-stage__orb hero-stage__orb--green" aria-hidden="true" />
        <div className="hero-stage__orb hero-stage__orb--blue" aria-hidden="true" />

        <div className="container-shell hero-stage__inner hero-stage__inner--video">
          <div className="hero-copy hero-copy--balanced">
            <div className="signal-badge">
              <span className="status-dot" />
              IT, die stabil läuft und verständlich bleibt
            </div>

            <p className="hero-kicker">INFRASTRUCTURE / SECURITY / OPERATIONS</p>

            <h1>
              Sichere IT-Infrastruktur für{" "}
              <span className="text-gradient">moderne Unternehmen.</span>
            </h1>

            <p className="hero-copy__lead">
              Netsera verbindet Systemadministration, Microsoft 365, Netzwerke,
              Virtualisierung und Security zu einer klar dokumentierten IT-Landschaft.
            </p>

            <div className="hero-actions">
              <a href="#kontakt" className="button-primary">Projekt besprechen</a>
              <a href="#leistungen" className="button-secondary">Leistungen ansehen</a>
            </div>

            <div className="hero-principles" aria-label="Netsera Kernprinzipien">
              <div><strong>Sicher.</strong><span>Security by Design</span></div>
              <div><strong>Stabil.</strong><span>24/7 im Blick</span></div>
              <div><strong>Dokumentiert.</strong><span>Verständlich & klar</span></div>
              <div><strong>Skalierbar.</strong><span>Für Wachstum bereit</span></div>
            </div>
          </div>

          <HeroVideoScene />
        </div>
      </section>

      <section className="section-shell section-shell--bordered" data-reveal>
        <div className="container-shell">
          <div className="section-heading section-heading--split">
            <div>
              <p className="eyebrow">VON KOMPLEXITÄT ZU KLARHEIT</p>
              <h2>IT wird beherrschbar, wenn Struktur sichtbar wird.</h2>
            </div>
            <p>
              Nicht mehr Tools, sondern klare Zuständigkeiten, nachvollziehbare Flows
              und messbare Zustände schaffen einen stabilen Betrieb.
            </p>
          </div>
          <ComplexityDiagram />
        </div>
      </section>

      <PublicServicesSection />

      <section id="warum" className="section-shell section-shell--tinted" data-reveal>
        <div className="container-shell">
          <div className="section-heading">
            <p className="eyebrow">WIE NETSERA ARBEITET</p>
            <h2>Vom ersten Signal bis zum stabilen Betrieb.</h2>
            <p>
              Jede Änderung folgt einem nachvollziehbaren technischen Ablauf statt
              spontanen Einzelmaßnahmen.
            </p>
          </div>
          <WorkflowRail />
        </div>
      </section>

      <PublicProjectsSection />

      <section className="section-shell section-shell--bordered" data-reveal>
        <div className="container-shell">
          <div className="section-heading section-heading--split">
            <div>
              <p className="eyebrow">SYSTEM STATUS</p>
              <h2>Infrastruktur, die ihren Zustand zeigt.</h2>
            </div>
            <p>
              Identität, Netzwerk, Compute und Resilienz werden nicht als Blackbox
              betrieben, sondern als messbare technische Domänen.
            </p>
          </div>
          <InfrastructureDashboard />
        </div>
      </section>

      <section id="kontakt" className="section-shell" data-reveal>
        <div className="container-shell">
          <div className="contact-console glass">
            <div className="contact-console__intro">
              <p className="eyebrow">TECHNICAL SERVICE REQUEST</p>
              <h2>Was soll Ihre IT besser können?</h2>
              <p>
                Beschreiben Sie kurz Ziel, Problem oder Umgebung. Die Anfrage wird über
                die bestehende Netsera API validiert und in PostgreSQL gespeichert.
              </p>

              <div className="request-flow" aria-label="Technischer Nachrichtenfluss">
                <div><span>01</span><strong>Browser</strong></div>
                <i>→</i>
                <div><span>02</span><strong>Netsera API</strong></div>
                <i>→</i>
                <div><span>03</span><strong>PostgreSQL</strong></div>
              </div>
            </div>

            <div className="contact-console__form">
              <div className="terminal-label">
                <span>request.json</span>
                <span>HTTPS / POST</span>
              </div>
              <ContactForm />
            </div>
          </div>
        </div>
      </section>

      <SiteFooter />
    </main>
  );
}
