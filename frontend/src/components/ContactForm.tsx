"use client";

import { FormEvent, useState } from "react";

type FormState = {
  name: string;
  email: string;
  subject: string;
  message: string;
};

type ContactResponse = {
  id: string;
  status: string;
  createdAtUtc: string;
};

const initialState: FormState = {
  name: "",
  email: "",
  subject: "",
  message: "",
};

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:5000/api";

export function ContactForm() {
  const [form, setForm] = useState<FormState>(initialState);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [success, setSuccess] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const updateField = (field: keyof FormState, value: string) => {
    setForm((current) => ({ ...current, [field]: value }));
  };

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);

    if (
      form.name.trim().length < 2 ||
      !form.email.trim() ||
      form.message.trim().length < 10
    ) {
      setError("Bitte Name, gültige E-Mail und eine Nachricht mit mindestens 10 Zeichen angeben.");
      return;
    }

    setIsSubmitting(true);

    try {
      const response = await fetch(`${API_BASE_URL}/contact`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name: form.name.trim(),
          email: form.email.trim(),
          subject: form.subject.trim() || null,
          message: form.message.trim(),
        }),
      });

      if (!response.ok) {
        if (response.status === 400) {
          throw new Error("Bitte prüfen Sie Ihre Eingaben.");
        }
        throw new Error("Die Nachricht konnte nicht gesendet werden.");
      }

      const data = (await response.json()) as ContactResponse;
      setSuccess(`Nachricht gesendet. Referenz: ${data.id.slice(0, 8)}`);
      setForm(initialState);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "Die Nachricht konnte nicht gesendet werden."
      );
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form className="grid gap-4" onSubmit={handleSubmit} noValidate>
      <div className="grid gap-4 sm:grid-cols-2">
        <label className="text-sm text-slate-300">
          Name
          <input
            required
            minLength={2}
            maxLength={120}
            autoComplete="name"
            value={form.name}
            onChange={(event) => updateField("name", event.target.value)}
            placeholder="Ihr Name"
            className="mt-2 w-full rounded-xl border border-white/10 bg-black/20 px-4 py-3 text-white outline-none placeholder:text-slate-600 transition focus:border-emerald-300/50 focus:ring-2 focus:ring-emerald-300/10"
          />
        </label>

        <label className="text-sm text-slate-300">
          E-Mail
          <input
            required
            type="email"
            maxLength={254}
            autoComplete="email"
            value={form.email}
            onChange={(event) => updateField("email", event.target.value)}
            placeholder="name@unternehmen.de"
            className="mt-2 w-full rounded-xl border border-white/10 bg-black/20 px-4 py-3 text-white outline-none placeholder:text-slate-600 transition focus:border-emerald-300/50 focus:ring-2 focus:ring-emerald-300/10"
          />
        </label>
      </div>

      <label className="text-sm text-slate-300">
        Betreff <span className="text-slate-500">(optional)</span>
        <input
          maxLength={160}
          value={form.subject}
          onChange={(event) => updateField("subject", event.target.value)}
          placeholder="z. B. Microsoft 365, Netzwerk oder Server"
          className="mt-2 w-full rounded-xl border border-white/10 bg-black/20 px-4 py-3 text-white outline-none placeholder:text-slate-600 transition focus:border-emerald-300/50 focus:ring-2 focus:ring-emerald-300/10"
        />
      </label>

      <label className="text-sm text-slate-300">
        Nachricht
        <textarea
          required
          minLength={10}
          maxLength={5000}
          rows={5}
          value={form.message}
          onChange={(event) => updateField("message", event.target.value)}
          placeholder="Beschreiben Sie kurz Ihr Vorhaben oder Problem."
          className="mt-2 w-full resize-y rounded-xl border border-white/10 bg-black/20 px-4 py-3 text-white outline-none placeholder:text-slate-600 transition focus:border-emerald-300/50 focus:ring-2 focus:ring-emerald-300/10"
        />
      </label>

      <button
        disabled={isSubmitting}
        type="submit"
        className="rounded-xl bg-white px-5 py-3.5 text-sm font-semibold text-slate-950 transition hover:bg-emerald-100 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {isSubmitting ? "Wird gesendet …" : "Nachricht senden"}
      </button>

      <div aria-live="polite" className="min-h-6 text-sm">
        {success ? <p className="text-emerald-300">{success}</p> : null}
        {error ? <p className="text-rose-300">{error}</p> : null}
      </div>

      <p className="text-xs leading-5 text-slate-500">
        Ihre Angaben werden ausschließlich zur Bearbeitung Ihrer Anfrage verwendet.
      </p>
    </form>
  );
}
