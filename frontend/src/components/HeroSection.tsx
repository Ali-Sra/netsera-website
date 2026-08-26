import styles from "./HeroSection.module.css";

const proofItems = [
  ["Sicher.", "Security by Design"],
  ["Stabil.", "24/7 im Blick"],
  ["Dokumentiert.", "Verständlich & klar"],
  ["Skalierbar.", "Für Wachstum bereit"],
] as const;

export function HeroSection() {
  return (
    <section className={styles.hero} aria-labelledby="hero-title">
      <div className={styles.grid} aria-hidden="true" />
      <div className={styles.glowLeft} aria-hidden="true" />
      <div className={styles.glowRight} aria-hidden="true" />

      <div className={styles.inner}>
        <div className={styles.copy}>
          <div className={styles.badge}>
            <span className={styles.dot} aria-hidden="true" />
            IT, die stabil läuft und verständlich bleibt
          </div>

          <p className={styles.kicker}>
            INFRASTRUCTURE / SECURITY / OPERATIONS
          </p>

          <h1 id="hero-title" className={styles.title}>
            Sichere IT-Infrastruktur für{" "}
            <span className={styles.accent}>moderne Unternehmen.</span>
          </h1>

          <p className={styles.lead}>
            Netsera verbindet Systemadministration, Microsoft 365, Netzwerke,
            Virtualisierung und Security zu einer klar dokumentierten IT-Landschaft.
          </p>

          <div className={styles.actions}>
            <a href="#kontakt" className={styles.primaryButton}>
              Projekt besprechen
            </a>
            <a href="#leistungen" className={styles.secondaryButton}>
              Leistungen ansehen
            </a>
          </div>

          <div className={styles.proof} aria-label="Netsera Kernprinzipien">
            {proofItems.map(([title, description]) => (
              <div key={title} className={styles.proofItem}>
                <strong>{title}</strong>
                <span>{description}</span>
              </div>
            ))}
          </div>
        </div>

        <div className={styles.mediaWrap}>
          <div className={styles.mediaGlow} aria-hidden="true" />
          <div className={styles.mediaFrame}>
            <video
              className={styles.video}
              autoPlay
              muted
              loop
              playsInline
              preload="metadata"
              poster="/hero/netsera-robot-poster.png"
              aria-label="Animierte Netsera Infrastruktur-Szene mit humanoidem Operator und Datenfluss"
            >
              <source src="/hero/netsera-binary-flow-v2.webm" type="video/webm" />
            </video>
          </div>
          <div className={styles.mediaMeta} aria-hidden="true">
            <span className={styles.metaDot} />
            LIVE INFRASTRUCTURE VISUAL
          </div>
        </div>
      </div>
    </section>
  );
}
