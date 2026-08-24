"use client";

import { FormEvent, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { adminApi } from "@/lib/adminApi";
import { AdminNav } from "@/components/admin/AdminNav";

type Project = {
  id: string;
  title: string;
  slug: string;
  shortDescription: string;
  description: string | null;
  imageUrl: string | null;
  projectUrl: string | null;
  githubUrl: string | null;
  isPublished: boolean;
  displayOrder: number;
};

const emptyForm = {
  title: "",
  slug: "",
  shortDescription: "",
  description: "",
  imageUrl: "",
  projectUrl: "",
  githubUrl: "",
  isPublished: false,
  displayOrder: 0,
};

export default function AdminProjectsPage() {
  const router = useRouter();
  const [items, setItems] = useState<Project[]>([]);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    const me = await adminApi("/admin/auth/me");
    if (me.status === 401) {
      router.replace("/admin/login");
      return;
    }

    const response = await adminApi("/admin/projects");
    if (!response.ok) {
      setError("Projekte konnten nicht geladen werden.");
      return;
    }

    setItems((await response.json()) as Project[]);
  }

  useEffect(() => {
    void load();
  }, []);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);

    const path = editingId ? `/admin/projects/${editingId}` : "/admin/projects";
    const response = await adminApi(path, {
      method: editingId ? "PUT" : "POST",
      body: JSON.stringify({
        ...form,
        displayOrder: Number(form.displayOrder),
      }),
    });

    if (!response.ok) {
      setError(response.status === 409 ? "Dieser Slug existiert bereits." : "Projekt konnte nicht gespeichert werden.");
      return;
    }

    setForm(emptyForm);
    setEditingId(null);
    await load();
  }

  function edit(item: Project) {
    setEditingId(item.id);
    setForm({
      title: item.title,
      slug: item.slug,
      shortDescription: item.shortDescription,
      description: item.description ?? "",
      imageUrl: item.imageUrl ?? "",
      projectUrl: item.projectUrl ?? "",
      githubUrl: item.githubUrl ?? "",
      isPublished: item.isPublished,
      displayOrder: item.displayOrder,
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  async function remove(id: string) {
    if (!window.confirm("Projekt wirklich löschen?")) return;
    const response = await adminApi(`/admin/projects/${id}`, { method: "DELETE" });
    if (!response.ok) {
      setError("Projekt konnte nicht gelöscht werden.");
      return;
    }
    await load();
  }

  return (
    <main className="min-h-screen bg-slate-950 text-white">
      <div className="mx-auto max-w-7xl px-5 py-8">
        <div className="flex flex-col gap-4 border-b border-white/10 pb-6">
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="font-semibold">Netsera Admin</p>
              <p className="text-xs text-slate-500">Content Management</p>
            </div>
            <a href="/" className="text-sm text-slate-400 hover:text-white">Website</a>
          </div>
          <AdminNav />
        </div>

        <div className="grid gap-8 py-8 lg:grid-cols-[.85fr_1.15fr]">
          <form onSubmit={submit} className="rounded-2xl border border-white/10 bg-white/[.03] p-5">
            <p className="text-sm font-semibold text-emerald-300">{editingId ? "Projekt bearbeiten" : "Neues Projekt"}</p>
            <div className="mt-5 grid gap-3">
              {[
                ["title", "Titel"],
                ["slug", "Slug (optional)"],
                ["shortDescription", "Kurzbeschreibung"],
                ["description", "Beschreibung"],
                ["imageUrl", "Bild-URL"],
                ["projectUrl", "Projekt-URL"],
                ["githubUrl", "GitHub-URL"],
              ].map(([key, label]) => (
                <label key={key} className="text-sm text-slate-300">
                  {label}
                  {key === "description" || key === "shortDescription" ? (
                    <textarea
                      rows={key === "description" ? 4 : 3}
                      value={String(form[key as keyof typeof form])}
                      onChange={(e) => setForm({ ...form, [key]: e.target.value })}
                      className="mt-2 w-full rounded-xl border border-white/10 bg-black/20 px-4 py-3 outline-none"
                    />
                  ) : (
                    <input
                      value={String(form[key as keyof typeof form])}
                      onChange={(e) => setForm({ ...form, [key]: e.target.value })}
                      className="mt-2 w-full rounded-xl border border-white/10 bg-black/20 px-4 py-3 outline-none"
                    />
                  )}
                </label>
              ))}

              <label className="text-sm text-slate-300">
                Reihenfolge
                <input
                  type="number"
                  value={form.displayOrder}
                  onChange={(e) => setForm({ ...form, displayOrder: Number(e.target.value) })}
                  className="mt-2 w-full rounded-xl border border-white/10 bg-black/20 px-4 py-3 outline-none"
                />
              </label>

              <label className="flex items-center gap-3 text-sm text-slate-300">
                <input
                  type="checkbox"
                  checked={form.isPublished}
                  onChange={(e) => setForm({ ...form, isPublished: e.target.checked })}
                />
                Veröffentlicht
              </label>

              <div className="flex gap-2">
                <button className="rounded-xl bg-white px-4 py-3 text-sm font-semibold text-slate-950" type="submit">
                  {editingId ? "Speichern" : "Erstellen"}
                </button>
                {editingId ? (
                  <button type="button" onClick={() => { setEditingId(null); setForm(emptyForm); }} className="rounded-xl border border-white/10 px-4 py-3 text-sm">
                    Abbrechen
                  </button>
                ) : null}
              </div>
              {error ? <p className="text-sm text-rose-300">{error}</p> : null}
            </div>
          </form>

          <div className="grid gap-3">
            <div>
              <p className="text-sm font-semibold text-emerald-300">Projekte</p>
              <h1 className="mt-2 text-3xl font-semibold">{items.length} Einträge</h1>
            </div>
            {items.map((item) => (
              <article key={item.id} className="rounded-2xl border border-white/10 bg-white/[.03] p-5">
                <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                  <div>
                    <div className="flex items-center gap-2">
                      <h2 className="font-semibold">{item.title}</h2>
                      <span className={`rounded-full px-2 py-1 text-xs ${item.isPublished ? "bg-emerald-300/10 text-emerald-300" : "bg-white/5 text-slate-500"}`}>
                        {item.isPublished ? "Published" : "Draft"}
                      </span>
                    </div>
                    <p className="mt-2 text-sm text-slate-400">{item.shortDescription}</p>
                    <p className="mt-3 text-xs text-slate-600">/{item.slug} · Order {item.displayOrder}</p>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => edit(item)} className="rounded-lg border border-white/10 px-3 py-2 text-sm">Bearbeiten</button>
                    <button onClick={() => void remove(item.id)} className="rounded-lg border border-rose-400/20 px-3 py-2 text-sm text-rose-300">Löschen</button>
                  </div>
                </div>
              </article>
            ))}
          </div>
        </div>
      </div>
    </main>
  );
}
