import { formatearFecha, formatearPrecio } from "../formato";
import { Ejemplar, etiquetaEstado } from "../types";
import { Pastilla, colorEstado } from "./Basicos";

/** Muestra TODA la información de un Ejemplar (se usa al consultar y antes de eliminar). */
export default function FichaEjemplar({ ejemplar }: { ejemplar: Ejemplar }) {
  const color = colorEstado(ejemplar.estado);
  return (
    <article className="ficha" aria-label={`Ejemplar ${ejemplar.codigo}`}>
      <div className="ficha-cabecera">
        <span className="etiqueta etiqueta-acento">Ejemplar</span>
        <Pastilla color={color}>{etiquetaEstado(ejemplar.estado)}</Pastilla>
      </div>
      <h2 className="ficha-titulo">{ejemplar.codigo}</h2>
      <p className="ficha-subtitulo">Ubicación: {ejemplar.ubicacion}</p>
      <p className="ficha-precio">{formatearPrecio(ejemplar.precioReposicion)}</p>
      <span className="leyenda">Precio de reposición</span>
      <dl className="ficha-datos">
        <div><dt className="etiqueta">Estado</dt><dd>{etiquetaEstado(ejemplar.estado)}</dd></div>
        <div><dt className="etiqueta">Ingreso</dt><dd>{formatearFecha(ejemplar.fechaIngreso)}</dd></div>
        <div><dt className="etiqueta">Préstamos</dt><dd>{ejemplar.numeroPrestamos}</dd></div>
        <div><dt className="etiqueta">Libro (ISBN)</dt><dd>{ejemplar.isbnLibro}</dd></div>
      </dl>
    </article>
  );
}
