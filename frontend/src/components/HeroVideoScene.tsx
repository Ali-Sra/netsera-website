export function HeroVideoScene() {
  return (
    <div className="hero-video">
      <div className="hero-video__glow" aria-hidden="true" />
      <div className="hero-video__frame">
        <video
          className="hero-video__media"
          autoPlay
          muted
          loop
          playsInline
          preload="metadata"
          poster="/hero/netsera-robot-poster.png"
          aria-label="Animierte Netsera Infrastruktur-Szene mit humanoidem Operator und Datenfluss"
        >
          <source src="/hero/netsera-binary-flow-v5.webm" type="video/webm" />
        </video>

        <div className="hero-video__status" aria-hidden="true">
          <span className="status-dot" />
          LIVE INFRASTRUCTURE VISUAL
        </div>
      </div>
    </div>
  );
}
