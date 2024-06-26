import PageSeparator from "@/components/elements/PageSeparator/PageSeparator";
import Link from "next/link";

export default function Theater() {
  return (
    <>
      <h1 className="capitalize text-center text-xl mt-28 mb-12 font-extrabold text-3xl underline underline-offset-8 text-custom-green">
        Upcoming Theater
      </h1>
      <div className="py-5 px-32 flex flex-col gap-y-12">
        <div className="flex gap-x-8 items-center">
          <img className="w-1/3 rounded-3xl" src="/setlistPoster/renai_kinshi_jourei.jpg" alt="" />
          <div className="flex flex-col">
            <h5 className="w-fit py-1 text-2xl rounded-3xl mb-5 font-bold text-black text-custom-green">
              Aturan Anti Cinta
            </h5>
            <h4 className="font-light text-xs">
              Kamis, 20 Juni 2024<span className="ml-12">19.00 WIB</span>
            </h4>
            <h2 className="text-lg font-semibold mb-10">
              Christy, Cathy, Chelsea, Cynthia, Daisy, Olla, Feni, Fiony, Flora,
              Gendis, Gracie, Greesel, Indah, Jessi, Lyn, Raisha
            </h2>
            <h1 className="text-sm italic">Read More</h1>
          </div>
        </div>
        <div className="flex gap-x-8 items-center">
          <img className="w-1/3 rounded-3xl" src="/setlistPoster/aitakatta.jpg" alt="" />
          <div className="flex flex-col">
            <h5 className="w-fit py-1 text-2xl rounded-3xl mb-5 font-bold text-black text-custom-green">
              Aitakatta
            </h5>
            <h4 className="font-light text-xs">
              Jum'at, 21 Juni 2024<span className="ml-12">19.00 WIB</span>
            </h4>
            <h2 className="text-lg font-semibold mb-10">
              Lana, Erine, Fritzy, Lily, Moreen, Nayla, Nachia, Oline, Regie,
              Ribka, Nala, Kimmy
            </h2>
            <h1 className="text-sm italic">Read More</h1>
          </div>
        </div>
        <div className="flex gap-x-8 items-center">
          <img className="w-1/3 rounded-3xl" src="/setlistPoster/pajama_drive.jpg" alt="" />
          <div className="flex flex-col">
            <h5 className="w-fit py-1 text-2xl rounded-3xl mb-5 font-bold text-black text-custom-green">
              Pajama Drive
            </h5>
            <h4 className="font-light text-xs">
              Minggu, 22 Juni 2024<span className="ml-12">14.00 WIB</span>
            </h4>
            <h2 className="text-lg font-semibold mb-10">
              Aralie, Alya, Anindya, Chelsea, Cynthia, Danella, Trisha, Michie,
              Levi, Nayla, Nachia, Regie
            </h2>
            <h1 className="text-sm italic">Read More</h1>
          </div>
        </div>
      </div>
      <Link
        href={"/theater"}
        className="block capitalize text-center text-slate-700 italic mt-8 hover:text-white hover:cursor-pointer"
      >
        see full theater schedule
      </Link>
      <PageSeparator />
    </>
  );
}
