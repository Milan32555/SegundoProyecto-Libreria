import { ReactNode, useEffect } from "react";

/**
 * Encabezado de cada pantalla: sección (Libros / Ejemplares), título, descripción y, a la
 * derecha, la acción principal. También pone el título de la pestaña del navegador.
 */
export function Encabezado({ seccion, titulo, descripcion, acciones }: {
  seccion?: string;
  titulo: string;
  descripcion?: ReactNode;
  acciones?: ReactNode;
}) {
  useEffect(() => {
    document.title = `${titulo} · Librería`;
  }, [titulo]);

  return (
    <header className="encabezado">
      <div>
        {seccion && <p className="encabezado-seccion">{seccion}</p>}
        <h1>{titulo}</h1>
        {descripcion && <p className="encabezado-descripcion">{descripcion}</p>}
      </div>
      {acciones && <div className="encabezado-acciones">{acciones}</div>}
    </header>
  );
}
