import Image from "next/image";
import React from "react";

export default function FrontSide(props: { nama: string; baseColor: string }) {
  const { nama, baseColor } = props;
  return (
    <div
      className={`front backface-hidden w-full h-full md:h-full md:w-full border-${baseColor} border rounded-2xl absolute top-0 bottom-0 left-0 right-0 overflow-hidden bg-zinc-950 hover:cursor-pointer shadow-xl shadow-${baseColor} duration-700`}
    >
      <Image
        width={256}
        height={361}
        className={`w-4/5 h-fit border-r md:h-full border-${baseColor}`}
        src={"/member/" + nama.toLowerCase().replace(/ /g, "_") + ".png"}
        alt={nama}
      />
      <div className="absolute top-1/2 left-[.47rem] md:left-[5.9rem] transform -translate-y-1/2 bg-transparent w-60 h-60 flex items-center justify-center rotate-90">
        <h1
          className={`md:text-xl text-xs font-bold text-${baseColor} uppercase text-nowrap font-poppins`}
        >
          {nama}
        </h1>
      </div>
    </div>
  );
}
