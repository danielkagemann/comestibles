import Image from "next/image";

export default function PhoneMockup() {
  return (
    <div className="shrink-0 filter-[drop-shadow(0_40px_80px_rgba(0,0,0,0.2))_drop-shadow(0_10px_24px_rgba(0,0,0,0.1))]">
      <div className="w-63 rounded-[44px] border-10 border-[#1a1a1a] bg-[#f2f2f7]">
        <Image src="/assets/3.webp"
          width={252}
          height={504}
          className="min-h-100 rounded-[44px]" alt="Screenshot" />
      </div>
    </div>
  );
}
