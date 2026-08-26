export function SiteFooter() {
  return (
    <footer className="site-footer">
      <div className="container-shell site-footer__inner">
        <div>
          <div className="site-footer__brand">
            <span className="brand-mark brand-mark--small"><i /><b>N</b></span>
            <strong>Netsera</strong>
          </div>
          <p>Systeme. Sicherheit. Klarheit.</p>
        </div>

        <div className="site-footer__meta">
          <span>© {new Date().getFullYear()} Netsera</span>
          <a href="#">Impressum</a>
          <a href="#">Datenschutz</a>
        </div>
      </div>
    </footer>
  );
}
