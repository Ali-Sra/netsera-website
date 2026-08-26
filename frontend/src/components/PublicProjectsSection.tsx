"use client";

import { useEffect, useState } from "react";

type Project = {
  id: string;
  title: string;
  slug: string;
  shortDescription: string;
  projectUrl: string | null;
  githubUrl: string | null;
  displayOrder: number;
};

const fallback: Project[] = [
  { id: "1", title: "Enterprise Firewall Security Lab", slug: "enterprise-firewall-security-lab", shortDescription: "LAN/WAN/DMZ, NAT, VLAN, VPN, IPS und dokumentierte Security-Flows.", projectUrl: null, githubUrl: "https://github.com/Ali-Sra/Enterprise-Firewall-Security-Lab", displayOrder: 1 },
  { id: "2", title: "FacilityFlow", slug: "facilityflow", shortDescription: ".NET/Blazor Anwendung mit EF Core, REST API, Docker Compose und Tests.", projectUrl: null, githubUrl: "https://github.com/Ali-Sra/FacilityFlow", displayOrder: 2 },
  { id: "3", title: "Virtual Infrastructure Lab", slug: "virtual-infrastructure-lab", shortDescription: "Nested ESXi/vCenter, Netzwerkdesign, Troubleshooting und Active-Directory-Integration.", projectUrl: null, githubUrl: null, displayOrder: 3 },
];

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:5000/api";

function projectTech(slug: string) {
  if (slug.includes("firewall")) return ["SOPHOS", "VLAN", "VPN", "IPS"];
  if (slug.includes("facility")) return [".NET", "BLAZOR", "EF CORE", "DOCKER"];
  return ["VMWARE", "VCENTER", "AD", "NETWORK"];
}

export function PublicProjectsSection() {
  const [items, setItems] = useState<Project[]>(fallback);

  useEffect(() => {
    fetch(`${API_BASE_URL}/content/projects`, { cache: "no-store" })
      .then(async (response) => {
        if (!response.ok) return;
        const data = (await response.json()) as Project[];
        if (data.length > 0) setItems(data);
      })
      .catch(() => undefined);
  }, []);

  return (
    <section id="projekte" className="section-shell section-shell--tinted" data-reveal>
      <div className="container-shell">
        <div className="section-heading section-heading--split">
          <div>
            <p className="eyebrow">ENGINEERING CASES</p>
            <h2>Projekte mit Architektur, Betrieb und Ergebnis.</h2>
          </div>
          <a
            href="https://github.com/Ali-Sra"
            target="_blank"
            rel="noreferrer"
            className="text-link"
          >
            GitHub ansehen ↗
          </a>
        </div>

        <div className="project-cases">
          {items.map((project, index) => (
            <article key={project.id} className="project-case" data-reveal>
              <div className="project-case__visual" aria-hidden="true">
                <div className="topology-grid" />
                <div className="topology-node topology-node--wan">WAN</div>
                <div className="topology-node topology-node--core">CORE</div>
                <div className="topology-node topology-node--dmz">DMZ</div>
                <div className="topology-node topology-node--lan">LAN</div>
                <svg viewBox="0 0 400 180">
                  <path d="M62 50H190M214 90H334M202 62V128M202 128H97" />
                </svg>
                <span className="project-case__number">
                  CASE / {String(index + 1).padStart(2, "0")}
                </span>
              </div>

              <div className="project-case__body">
                <div className="project-case__tech">
                  {projectTech(project.slug).map((tech) => <span key={tech}>{tech}</span>)}
                </div>
                <h3>{project.title}</h3>
                <p>{project.shortDescription}</p>
                <div className="project-case__links">
                  {project.projectUrl ? (
                    <a href={project.projectUrl} target="_blank" rel="noreferrer">Projekt ↗</a>
                  ) : null}
                  {project.githubUrl ? (
                    <a href={project.githubUrl} target="_blank" rel="noreferrer">Repository ↗</a>
                  ) : null}
                  {!project.projectUrl && !project.githubUrl ? (
                    <span>TECHNICAL CASE STUDY</span>
                  ) : null}
                </div>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
