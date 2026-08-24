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
  { id: "1", title: "Enterprise Firewall Security Lab", slug: "enterprise-firewall-security-lab", shortDescription: "LAN/WAN/DMZ, NAT, VLAN, VPN, IPS und dokumentierte Security-Flows.", projectUrl: null, githubUrl: null, displayOrder: 1 },
  { id: "2", title: "FacilityFlow", slug: "facilityflow", shortDescription: ".NET/Blazor Anwendung mit EF Core, REST API, Docker Compose und Tests.", projectUrl: null, githubUrl: null, displayOrder: 2 },
  { id: "3", title: "Virtual Infrastructure Lab", slug: "virtual-infrastructure-lab", shortDescription: "Nested ESXi/vCenter, Netzwerkdesign, Troubleshooting und Active-Directory-Integration.", projectUrl: null, githubUrl: null, displayOrder: 3 },
];

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:5000/api";

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
    <section id="projekte" className="container-shell py-24">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-sm font-semibold text-emerald-300">Projekte</p>
          <h2 className="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">Praxis statt Buzzwords.</h2>
        </div>
        <a href="https://github.com/Ali-Sra" target="_blank" rel="noreferrer" className="text-sm text-slate-300 hover:text-white">
          GitHub ansehen ↗
        </a>
      </div>

      <div className="mt-10 grid gap-4 lg:grid-cols-3">
        {items.map((project, index) => (
          <article key={project.id} className="glass flex min-h-64 flex-col justify-between rounded-2xl p-6">
            <span className="text-xs text-slate-500">
              PROJECT / {String(index + 1).padStart(2, "0")}
            </span>
            <div>
              <h3 className="text-xl font-semibold">{project.title}</h3>
              <p className="mt-3 text-sm leading-6 text-slate-400">{project.shortDescription}</p>
              <div className="mt-5 flex flex-wrap gap-3 text-sm">
                {project.projectUrl ? (
                  <a href={project.projectUrl} target="_blank" rel="noreferrer" className="text-emerald-300 hover:underline">Projekt ↗</a>
                ) : null}
                {project.githubUrl ? (
                  <a href={project.githubUrl} target="_blank" rel="noreferrer" className="text-sky-300 hover:underline">GitHub ↗</a>
                ) : null}
              </div>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
