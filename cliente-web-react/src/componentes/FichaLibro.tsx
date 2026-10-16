import { formatearFecha, formatearPrecio } from "../formato";
import { Libro } from "../types";

/** Muestra TODA la información de un Libro (se usa al consultar y antes de eliminar). */
export default function FichaLibro({ libro }: { libro: Libro }) {
  return (
    <div className="ficha-objeto">
      <p><strong>ISBN:</strong> {libro.isbn}</p>
      <p><strong>Título:</strong> {libro.titulo}</p>
      <p><strong>Autor:</strong> {libro.autor}</p>
      <p><strong>Precio:</strong> {formatearPrecio(libro.precio)}</p>
      <p><strong>Páginas:</strong> {libro.numeroPaginas}</p>
      <p><strong>Fecha de publicación:</strong> {formatearFecha(libro.fechaPublicacion)}</p>
      <p><strong>Género:</strong> {libro.genero}</p>
    </div>
  );
}
