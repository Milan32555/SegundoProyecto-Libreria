import { ReactNode } from "react";
import { SearchX } from "lucide-react";

/** Resultado vacío de una búsqueda por clave (no es un error: el objeto no existe). */
export function SinResultados({ titulo, children }: { titulo: string; children?: ReactNode }) {
  return (
    <div className="panel" role="status">
      <div className="tabla-estado">
        <SearchX size={24} aria-hidden="true" />
        <strong>{titulo}</strong>
        {children && <p>{children}</p>}
      </div>
    </div>
  );
}
