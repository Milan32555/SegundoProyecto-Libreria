import { formatearFecha, formatearPrecio } from "../formato";
import { Libro, etiquetaGenero } from "../types";
import { Pastilla } from "./Basicos";

/** Muestra TODA la información de un Libro (se usa al consultar y antes de eliminar). */
export default function FichaLibro({ libro }: { libro: Libro }) {
  return (
    <article className="ficha" aria-label={`Libro ${libro.titulo}`}>
      <div className="ficha-cabecera">
        <span className="etiqueta etiqueta-acento">Libro</span>
        <Pastilla>{etiquetaGenero(libro.genero)}</Pastilla>
      </div>
      <h2 className="ficha-titulo">{libro.titulo}</h2>
      <p className="ficha-subtitulo">por {libro.autor}</p>
      <p className="ficha-precio">{formatearPrecio(libro.precio)}</p>
      <span className="leyenda">Precio de venta</span>
      <dl className="ficha-datos">
        <div><dt className="etiqueta">ISBN</dt><dd>{libro.isbn}</dd></div>
        <div><dt className="etiqueta">Autor</dt><dd>{libro.autor}</dd></div>
        <div><dt className="etiqueta">Páginas</dt><dd>{libro.numeroPaginas}</dd></div>
        <div><dt className="etiqueta">Publicación</dt><dd>{formatearFecha(libro.fechaPublicacion)}</dd></div>
        <div><dt className="etiqueta">Género</dt><dd>{etiquetaGenero(libro.genero)}</dd></div>
      </dl>
    </article>
  );
}
