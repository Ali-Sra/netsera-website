const rows = [
  ["Microsoft 365 / Entra ID", "IDENTITY", "99.99%"],
  ["Firewall & Netzwerk", "EDGE", "12 ms"],
  ["Virtualisierung", "COMPUTE", "4 Nodes"],
  ["Monitoring & Backup", "RESILIENCE", "24/7"],
];

export function InfrastructureDashboard() {
  return (
    <div className="infra-console">
      <div className="infra-console__topbar">
        <div>
          <span className="eyebrow">LIVE OPERATIONS</span>
          <h3>Infrastructure Control Plane</h3>
        </div>
        <div className="infra-console__live">
          <span className="status-dot" /> Operational
        </div>
      </div>

      <div className="infra-console__metrics">
        <div><strong>99.9%</strong><span>Availability target</span></div>
        <div><strong>04</strong><span>Core domains</span></div>
        <div><strong>24/7</strong><span>Monitoring ready</span></div>
      </div>

      <div className="infra-console__rows">
        {rows.map(([name, domain, metric], index) => (
          <div className="infra-row" key={name}>
            <span className="infra-row__index">{String(index + 1).padStart(2, "0")}</span>
            <div>
              <strong>{name}</strong>
              <small>{domain}</small>
            </div>
            <div className="infra-row__spark" aria-hidden="true">
              <i />
              <i />
              <i />
              <i />
              <i />
            </div>
            <span className="infra-row__metric">{metric}</span>
            <span className="infra-row__state"><i className="status-dot" /> Online</span>
          </div>
        ))}
      </div>
    </div>
  );
}
