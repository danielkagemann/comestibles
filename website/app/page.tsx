import Link from "next/link";
import Image from "next/image";
import Navbar from "@/components/Navbar";

const features = [
  {
    title: "Standorte",
    desc: "Erstelle beliebig viele Standorte – Zuhause, Ferienwohnung, Büro – und verwalte Lebensmittel je nach Ort getrennt.",
  },
  {
    title: "Barcode-Scanner",
    desc: "Artikel per Barcode hinzufügen. Geschäft, Produktbild und weitere Infos werden automatisch ausgelesen.",
  },
  {
    title: "Filter & Ablaufdaten",
    desc: "Filtere nach Geschäft oder Ablaufdatum und behalte auf einen Blick im Überblick, was bald verbraucht werden sollte.",
  },
];

const steps = [
  {
    num: "01",
    title: "Standort anlegen",
    desc: "Erstelle einen Standort – mit Foto und optionaler Adresse.",
  },
  {
    num: "02",
    title: "Artikel hinzufügen",
    desc: "Scanne den Barcode oder tippe den Namen ein. Ablaufdatum und Menge einstellen.",
  },
  {
    num: "03",
    title: "Überblick behalten",
    desc: "Filtere nach Geschäft oder Datum – kein Lebensmittel mehr wegwerfen.",
  },
];

export default function Home() {
  return (
    <>
      <Navbar />

      {/* Hero section */}
      <section className="pt-36 pb-20 px-6">
        <div className="max-w-5xl mx-auto flex flex-col lg:flex-row items-center gap-14">

          <div className="flex-1">
            <div
              className="mb-5 translate-y-6 opacity-0 animate-[fadeUp_0.7s_ease_forwards]"
              style={{ animationDelay: "0.05s" }}
            >
              <span className="inline-block rounded-full bg-background px-3 py-1 text-xs font-semibold tracking-[0.08em] text-brand uppercase">
                iOS App · bald verfügbar
              </span>
            </div>

            <h1
              className="mb-6 translate-y-6 text-[clamp(2.6rem,6vw,4.5rem)] leading-[1.05] font-extrabold tracking-[-0.03em] opacity-0 animate-[fadeUp_0.7s_ease_forwards]"
              style={{ animationDelay: "0.20s" }}
            >
              Deine Lebens&shy;mittel.<br />
              <span className="text-green-700">Immer frisch.</span>
            </h1>

            <p
              className="mb-10 max-w-md translate-y-6 text-lg leading-relaxed font-light text-gray-500 opacity-0 animate-[fadeUp_0.7s_ease_forwards]"
              style={{ animationDelay: "0.35s" }}
            >
              Überwache das Ablaufdatum Deiner Lebensmittel — geordnet nach
              Standort, Geschäft und Datum. Einfach, übersichtlich, effektiv.
            </p>

            <div
              className="translate-y-6 opacity-0 animate-[fadeUp_0.7s_ease_forwards]"
              style={{ animationDelay: "0.50s" }}
            >
              <Link
                href="#download"
                className="inline-flex items-center"
              >
                <Image src="/comestibles/assets/b-ios.svg" alt="Im App Store laden" width={120} height={40} />
              </Link>
            </div>
          </div>

          <div
            className="translate-y-6 opacity-0 animate-[fadeUp_0.7s_ease_forwards]"
            style={{ animationDelay: "0.35s" }}
          >
            <Image src="/comestibles/assets/screen.webp"
              alt="Screenshot"
              width={600}
              height={734}
              className="h-auto w-full max-w-75 lg:max-w-90" />

          </div>

        </div>
      </section>

      {/* Features section */}
      <section className="py-24 px-6 bg-gray-50">
        <div className="max-w-5xl mx-auto">
          <div className="text-center mb-16">
            <div className="mx-auto mb-4.5 h-0.75 w-9 rounded-xs bg-brand" />
            <h2 className="text-[clamp(2rem,4vw,3.25rem)] leading-[1.1] font-bold tracking-[-0.03em]">
              Was <span className="text-brand">comestibles</span> kann
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {features.map((f) => (
              <div
                key={f.title}
                className="rounded-3xl border-[1.5px] border-[#e5e5e5] bg-white p-9 transition-[border-color,transform] duration-200 hover:-translate-y-1 hover:border-brand"
              >
                <h3 className="font-bold text-lg mb-3 tracking-tight">{f.title}</h3>
                <p className="text-gray-500 text-sm leading-relaxed font-light">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How it works section */}
      <section className="py-24 px-6">
        <div className="max-w-5xl mx-auto">
          <div className="text-center mb-16">
            <div className="mx-auto mb-4.5 h-0.75 w-9 rounded-xs bg-brand" />
            <h2 className="text-[clamp(2rem,4vw,3.25rem)] leading-[1.1] font-bold tracking-[-0.03em]">
              So einfach geht&apos;s
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3">
            {steps.map((s, i) => (
              <div key={s.num} className="text-center px-8 py-6 relative">
                <p className="mb-1 text-[5rem] leading-none font-extrabold text-[#ececec]">{s.num}</p>
                <h3 className="font-bold text-lg mb-2 tracking-tight">{s.title}</h3>
                <p className="text-gray-500 text-sm font-light leading-relaxed">{s.desc}</p>
                {i < steps.length - 1 && (
                  <span className="hidden md:block absolute right-0 top-1/3 text-gray-200 text-3xl">
                    →
                  </span>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA section */}
      <section id="download" className="py-28 px-6 bg-black text-white text-center">
        <div className="max-w-xl mx-auto">
          <p className="text-xs font-semibold tracking-widest uppercase mb-5 text-green-400">
            Jetzt kostenlos
          </p>
          <h2 className="mb-6 text-[clamp(2rem,4vw,3.25rem)] leading-[1.1] font-bold tracking-[-0.03em] text-white">
            Kein Lebens&shy;mittel<br />mehr vergessen.
          </h2>
          <p className="mb-10 text-lg font-light text-gray-400">
            Comestibles ist bald im App Store verfügbar.
          </p>
          <Link
            href="#"
            className="inline-flex items-center"
          >
            <Image src="/comestibles/assets/w-ios.svg" alt="Im App Store laden" width={150} height={50} />
          </Link>
        </div>
      </section>

      {/* Footer section */}
      <footer className="py-8 px-6 border-t border-gray-100 text-center text-gray-400 text-sm">
        <span className="font-semibold text-green-700 mr-2">COMESTIBLES</span>
        © {new Date().getFullYear()} · Lebensmittel im Blick behalten
      </footer>
    </>
  );
}
