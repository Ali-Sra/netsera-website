"use client";

import { BinaryFlowCanvas } from "@/components/BinaryFlowCanvas";

export function HeroRobotScene() {
  return (
    <div className="robot-scene" aria-label="Animierte Netsera Datenfluss-Szene">
      <img
        src="/hero/netsera-robot-data-center.png"
        alt="Futuristischer humanoider Operator in einem Rechenzentrum vor einem Computer"
        className="robot-scene__image"
        draggable={false}
      />

      <div className="robot-scene__image-motion" aria-hidden="true" />
      <BinaryFlowCanvas />

      <div className="robot-scene__hud robot-scene__hud--brain" aria-hidden="true">
        <span className="status-dot" />
        NEURAL INPUT
      </div>

      <div className="robot-scene__hud robot-scene__hud--screen" aria-hidden="true">
        <span>SERVER</span><strong>ONLINE</strong>
        <span>FIREWALL</span><strong>ONLINE</strong>
        <span>M365</span><strong>ONLINE</strong>
        <span>BACKUP</span><strong>ONLINE</strong>
      </div>

      <div className="robot-scene__vignette" aria-hidden="true" />
    </div>
  );
}
