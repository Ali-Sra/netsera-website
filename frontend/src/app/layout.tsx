import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Netsera | IT-Infrastruktur & Security",
    template: "%s | Netsera",
  },
  description:
    "Moderne IT-Infrastruktur, Microsoft 365, Netzwerke, Virtualisierung und Security für kleine und mittelständische Unternehmen.",
  metadataBase: new URL("https://netsera.de"),
  openGraph: {
    title: "Netsera | IT-Infrastruktur & Security",
    description:
      "Zuverlässige IT-Systeme, sichere Netzwerke und moderne Cloud-Lösungen.",
    url: "https://netsera.de",
    siteName: "Netsera",
    type: "website",
    locale: "de_DE",
  },
  robots: { index: true, follow: true },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="de">
      <body>{children}</body>
    </html>
  );
}
