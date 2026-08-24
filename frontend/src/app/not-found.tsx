export default function NotFound() {
  return (
    <main className="container-shell grid min-h-screen place-items-center py-20 text-center">
      <div>
        <p className="text-sm text-emerald-300">404</p>
        <h1 className="mt-4 text-4xl font-semibold">Seite nicht gefunden</h1>
        <p className="mt-4 text-slate-400">Die angeforderte Seite existiert nicht.</p>
        <a href="/" className="mt-8 inline-flex rounded-xl bg-white px-5 py-3 text-sm font-semibold text-slate-950">Zur Startseite</a>
      </div>
    </main>
  );
}
