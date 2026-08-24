export function SiteFooter() {
  return (
    <footer className="border-t border-white/10 py-10 text-sm text-slate-400">
      <div className="container-shell flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between">
        <p>© {new Date().getFullYear()} Netsera. IT-Infrastruktur & Security.</p>
        <div className="flex gap-5">
          <a className="hover:text-white" href="#">Impressum</a>
          <a className="hover:text-white" href="#">Datenschutz</a>
        </div>
      </div>
    </footer>
  );
}
