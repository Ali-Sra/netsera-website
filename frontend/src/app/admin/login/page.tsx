"use client";

import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { adminApi } from "@/lib/adminApi";

export default function AdminLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const response = await adminApi("/admin/auth/login", {
        method: "POST",
        body: JSON.stringify({ email, password }),
      });

      if (response.status === 429) {
        setError("Zu viele Anmeldeversuche. Bitte kurz warten.");
        return;
      }

      if (!response.ok) {
        setError("E-Mail oder Passwort ist falsch.");
        return;
      }

      router.replace("/admin");
    } catch {
      setError("Die API ist nicht erreichbar.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="min-h-screen bg-slate-950 px-5 py-16 text-white">
      <div className="mx-auto max-w-md">
        <a href="/" className="text-sm text-slate-400 hover:text-white">
          ← Zur Website
        </a>

        <div className="mt-8 rounded-3xl border border-white/10 bg-white/[0.04] p-7 shadow-2xl">
          <p className="text-sm font-semibold text-emerald-300">Netsera Admin</p>
          <h1 className="mt-3 text-3xl font-semibold">Anmelden</h1>
          <p className="mt-3 text-sm leading-6 text-slate-400">
            Geschützter Bereich für Kontaktanfragen und Administration.
          </p>

          <form onSubmit={handleSubmit} className="mt-7 grid gap-4">
            <label className="text-sm text-slate-300">
              E-Mail
              <input
                required
                type="email"
                autoComplete="username"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                className="mt-2 w-full rounded-xl border border-white/10 bg-black/20 px-4 py-3 outline-none focus:border-emerald-300/50"
              />
            </label>

            <label className="text-sm text-slate-300">
              Passwort
              <input
                required
                minLength={12}
                type="password"
                autoComplete="current-password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                className="mt-2 w-full rounded-xl border border-white/10 bg-black/20 px-4 py-3 outline-none focus:border-emerald-300/50"
              />
            </label>

            <button
              disabled={loading}
              className="mt-2 rounded-xl bg-white px-5 py-3 text-sm font-semibold text-slate-950 disabled:opacity-60"
              type="submit"
            >
              {loading ? "Anmeldung …" : "Anmelden"}
            </button>

            <div aria-live="polite" className="min-h-6 text-sm text-rose-300">
              {error}
            </div>
          </form>
        </div>
      </div>
    </main>
  );
}
