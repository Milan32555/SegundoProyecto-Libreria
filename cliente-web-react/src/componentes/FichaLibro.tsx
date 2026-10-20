import { ReactNode } from "react";
import { formatearFecha, formatearPrecio } from "../formato";
import { Libro } from "../types";
import { InsigniaGenero } from "./ui/Insignias";

/**
 * Muestra TODA la información de un Libro: título y autor en la cabecera y el resto de
 * atributos debajo (la fecha con hora). Se usa al consultar, antes de eliminar y antes de editar.
 */
export default function FichaLibro({ libro, titulo = "Libro" }: { libro: Libro; titulo?: string }) {
  return (
    <article className="panel" aria-label={`Libro ${libro.titulo}`}>
      <header className="ficha-cabecera">
        <div>
          <p className="ficha-tipo">{titulo}</p>
          <h2 className="ficha-titulo titulo-libro">{libro.titulo}</h2>
          <p className="ficha-subtitulo">{libro.autor}</p>
        </div>
      </header>
      <dl className="ficha-datos">
        <Dato termino="ISBN" valor={libro.isbn} />
        <Dato termino="Autor" valor={libro.autor} />
        <Dato termino="Género" valor={<InsigniaGenero genero={libro.genero} />} />
        <Dato termino="Precio de venta" valor={formatearPrecio(libro.precio)} />
        <Dato termino="Número de páginas" valor={libro.numeroPaginas} />
        <Dato termino="Fecha de publicación" valor={formatearFecha(libro.fechaPublicacion)} />
      </dl>
    </article>
  );
}

export function Dato({ termino, valor, nota }: { termino: string; valor: ReactNode; nota?: ReactNode }) {
  return (
    <div>
      <dt>{termino}</dt>
      <dd>{valor}</dd>
      {nota && <dd className="ficha-nota">{nota}</dd>}
    </div>
  );
}
