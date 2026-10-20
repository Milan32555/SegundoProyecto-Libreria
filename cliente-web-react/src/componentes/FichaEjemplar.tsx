import { Lock } from "lucide-react";
import { formatearFecha, formatearPrecio } from "../formato";
import { Ejemplar } from "../types";
import { Dato } from "./FichaLibro";
import { InsigniaEstado } from "./ui/Insignias";

/**
 * Muestra TODA la información de un Ejemplar (la fecha de ingreso con hora). Se usa al
 * consultar, antes de eliminar y antes de editar.
 */
export default function FichaEjemplar({ ejemplar, titulo = "Ejemplar" }: { ejemplar: Ejemplar; titulo?: string }) {
  return (
    <article className="panel" aria-label={`Ejemplar ${ejemplar.codigo}`}>
      <header className="ficha-cabecera">
        <div>
          <p className="ficha-tipo">{titulo}</p>
          <h2 className="ficha-titulo">{ejemplar.codigo}</h2>
          <p className="ficha-subtitulo">Libro {ejemplar.isbnLibro}</p>
        </div>
        <InsigniaEstado estado={ejemplar.estado} />
      </header>
      <dl className="ficha-datos">
        <Dato termino="Código" valor={ejemplar.codigo} />
        <Dato termino="Estado" valor={<InsigniaEstado estado={ejemplar.estado} />} />
        <Dato termino="Libro (ISBN)" valor={ejemplar.isbnLibro} />
        <Dato termino="Ubicación" valor={ejemplar.ubicacion} />
        <Dato termino="Fecha de ingreso" valor={formatearFecha(ejemplar.fechaIngreso)} />
        <Dato termino="Precio de reposición" valor={formatearPrecio(ejemplar.precioReposicion)} />
        <Dato
          termino="Número de préstamos"
          valor={ejemplar.numeroPrestamos}
          nota={<><Lock size={12} aria-hidden="true" /> Lo calcula el servidor</>}
        />
      </dl>
    </article>
  );
}
