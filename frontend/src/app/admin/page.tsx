"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { adminApi } from "@/lib/adminApi";
import { AdminNav } from "@/components/admin/AdminNav";

type Message = {
  id: string;
  name: string;
  email: string;
  subject: string | null;
  message: string;
  status: "New" | "Read" | "Archived";
  createdAtUtc: string;
  updatedAtUtc: string | null;
};

export default function AdminPage() {
  const router = useRouter();
  const [messages, setMessages] = useState<Message[]>([]);
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const meResponse = await adminApi("/admin/auth/me");
      if (meResponse.status === 401) {
        router.replace("/admin/login");
        return;
      }
      if (!meResponse.ok) throw new Error("Session konnte nicht geprüft werden.");

      const me = (await meResponse.json()) as { email: string };
      setEmail(me.email);

      const messagesResponse = await adminApi("/admin/messages");
      if (!messagesResponse.ok) throw new Error("Nachrichten konnten nicht geladen werden.");
      setMessages((await messagesResponse.json()) as Message[]);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unbekannter Fehler.");
    } finally {
      setLoading(false);
    }
  }, [router]);

  useEffect(() => { void loadData(); }, [loadData]);

  async function updateStatus(id: string, status: Message["status"]) {
    const response = await adminApi(`/admin/messages/${id}/status`, {
      method: "PATCH",
      body: JSON.stringify({ status }),
    });
    if (!response.ok) {
      setError("Status konnte nicht geändert werden.");
      return;
    }
    setMessages((current) => current.map((m) => m.id === id ? { ...m, status, updatedAtUtc: new Date().toISOString() } : m));
  }

  async function logout() {
    await adminApi("/admin/auth/logout", { method: "POST" });
    router.replace("/admin/login");
  }

  const newCount = messages.filter((m) => m.status === "New").length;

  return (
    <main className="min-h-screen bg-slate-950 text-white">
      <div className="mx-auto max-w-7xl px-5 py-8">
        <div className="flex flex-col gap-4 border-b border-white/10 pb-6">
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="font-semibold">Netsera Admin</p>
              <p className="text-xs text-slate-500">{email}</p>
            </div>
            <div className="flex items-center gap-3">
              <a href="/" className="text-sm text-slate-400 hover:text-white">Website</a>
              <button onClick={logout} className="rounded-lg border border-white/10 px-3 py-2 text-sm hover:bg-white/5">Abmelden</button>
            </div>
          </div>
          <AdminNav />
        </div>

        <div className="py-8">
          <div className="flex items-end justify-between gap-4">
            <div>
              <p className="text-sm font-semibold text-emerald-300">Dashboard</p>
              <h1 className="mt-2 text-3xl font-semibold">Kontaktanfragen</h1>
              <p className="mt-2 text-slate-400">{messages.length} Nachrichten · {newCount} neu</p>
            </div>
            <button onClick={() => void loadData()} className="rounded-xl border border-white/10 px-4 py-2.5 text-sm hover:bg-white/5">Aktualisieren</button>
          </div>

          {error ? <div className="mt-6 rounded-xl border border-rose-400/20 bg-rose-400/5 p-4 text-sm text-rose-300">{error}</div> : null}
          {loading ? <p className="mt-10 text-slate-400">Wird geladen …</p> : (
            <div className="mt-8 grid gap-4">
              {messages.map((item) => (
                <article key={item.id} className="rounded-2xl border border-white/10 bg-white/[0.035] p-5">
                  <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
                    <div>
                      <div className="flex items-center gap-2">
                        <h2 className="font-semibold">{item.name}</h2>
                        <span className="rounded-full bg-white/5 px-2.5 py-1 text-xs text-slate-300">{item.status}</span>
                      </div>
                      <a href={`mailto:${item.email}`} className="mt-1 block text-sm text-sky-300">{item.email}</a>
                      <p className="mt-4 text-sm font-medium text-slate-200">{item.subject || "Ohne Betreff"}</p>
                      <p className="mt-2 whitespace-pre-wrap text-sm leading-6 text-slate-400">{item.message}</p>
                      <p className="mt-4 text-xs text-slate-600">{new Date(item.createdAtUtc).toLocaleString("de-DE")}</p>
                    </div>
                    <div className="flex gap-2">
                      {(["New", "Read", "Archived"] as const).map((status) => (
                        <button key={status} disabled={item.status === status} onClick={() => void updateStatus(item.id, status)} className="rounded-lg border border-white/10 px-3 py-2 text-xs disabled:bg-white/10">
                          {status}
                        </button>
                      ))}
                    </div>
                  </div>
                </article>
              ))}
            </div>
          )}
        </div>
      </div>
    </main>
  );
}
