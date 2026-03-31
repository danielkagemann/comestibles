import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Comestibles – Überwache das Ablaufdatum Deiner Lebensmittel",
  description:
    "Überwache das Ablaufdatum Deiner Lebensmittel – geordnet nach Standort, Geschäft und Datum. Einfach, übersichtlich, effektiv.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="de">
      <body className="bg-white text-black overflow-x-hidden">{children}</body>
    </html>
  );
}
