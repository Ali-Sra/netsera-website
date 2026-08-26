const disorder = ["Shadow IT", "Legacy", "Unklare Rechte", "Manuelle Backups"];
const order = ["Identitäten", "Netzwerk", "Security", "Monitoring"];

export function ComplexityDiagram() {
  return (
    <div className="complexity-map" aria-label="Von unstrukturierter IT zu klarer Infrastruktur">
      <div className="complexity-map__side">
        <span className="eyebrow">VORHER</span>
        <div className="complexity-map__chaos">
          {disorder.map((item, index) => (
            <span key={item} className={`chaos-node chaos-node--${index + 1}`}>
              {item}
            </span>
          ))}
          <svg viewBox="0 0 320 190" aria-hidden="true">
            <path d="M25 39C93 117 168 18 286 144M42 153C113 90 179 171 295 58M85 31C116 77 185 90 265 92" />
          </svg>
        </div>
      </div>

      <div className="complexity-map__core">
        <span className="complexity-map__pulse" />
        <div className="brand-node">
          <span>N</span>
          <strong>NETSERA</strong>
          <small>STANDARDIZE / SECURE</small>
        </div>
      </div>

      <div className="complexity-map__side">
        <span className="eyebrow">NACHHER</span>
        <div className="complexity-map__ordered">
          {order.map((item, index) => (
            <div key={item} className="ordered-row">
              <span>{String(index + 1).padStart(2, "0")}</span>
              <strong>{item}</strong>
              <i>OK</i>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
