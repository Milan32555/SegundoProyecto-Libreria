import { formatearFecha, formatearPrecio } from "../formato";
import { Ejemplar } from "../types";

/** Muestra TODA la información de un Ejemplar (se usa al consultar y antes de eliminar). */
export default function FichaEjemplar({ ejemplar }: { ejemplar: Ejemplar }) {
  return (
    <div className="ficha-objeto">
      <p><strong>Código:</strong> {ejemplar.codigo}</p>
      <p><strong>Estado:</strong> {ejemplar.estado}</p>
      <p><strong>Ubicación:</strong> {ejemplar.ubicacion}</p>
      <p><strong>Fecha de ingreso:</strong> {formatearFecha(ejemplar.fechaIngreso)}</p>
      <p><strong>Precio de reposición:</strong> {formatearPrecio(ejemplar.precioReposicion)}</p>
      <p><strong>ISBN del libro:</strong> {ejemplar.isbnLibro}</p>
    </div>
  );
}
