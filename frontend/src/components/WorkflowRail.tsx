const steps = [
  ["01", "Analyse", "Ist-Zustand, Risiken und Abhängigkeiten sichtbar machen."],
  ["02", "Architektur", "Zielbild, Standards und klare technische Grenzen definieren."],
  ["03", "Umsetzung", "Kontrolliert implementieren, testen und dokumentieren."],
  ["04", "Monitoring", "Zustand messen, Signale bewerten und Betrieb absichern."],
];

export function WorkflowRail() {
  return (
    <div className="workflow-rail">
      <div className="workflow-rail__line" aria-hidden="true">
        <span />
      </div>
      {steps.map(([number, title, description]) => (
        <article className="workflow-step" data-reveal key={number}>
          <div className="workflow-step__marker">
            <span>{number}</span>
          </div>
          <p className="eyebrow">PHASE {number}</p>
          <h3>{title}</h3>
          <p>{description}</p>
        </article>
      ))}
    </div>
  );
}
