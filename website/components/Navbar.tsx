"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 40);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <nav
      className={`fixed inset-x-0 top-0 z-50 transition-all duration-300 ${scrolled
        ? "border-b border-[#f0f0f0] bg-white/88 py-3 backdrop-blur-[20px]"
        : "py-5"
        }`}
    >
      <div className="max-w-5xl mx-auto px-6 flex items-center justify-between">
        <span className="font-extrabold text-xl tracking-tight text-green-700">
          COMESTIBLES
        </span>
        <Link
          href="#download"
          className="text-sm font-semibold bg-black text-white px-5 py-2 rounded-full hover:bg-gray-800 transition-colors"
        >
          App holen →
        </Link>
      </div>
    </nav>
  );
}
