import { ReactNode } from "react";
import { CircleAlert, LucideIcon, RotateCw } from "lucide-react";
import { Boton } from "./Boton";
import { clases } from "./clases";

export interface Columna<T> {
  titulo: string;
  celda: (fila: T) => ReactNode;
  /** Números: alineados a la derecha y con cifras tabulares. */
  numerica?: boolean;
  /** Dato secundario en gris (ISBN, fechas). */
  apagada?: boolean;
}

interface EstadoVacio {
  icono: LucideIcon;
  titulo: string;
  descripcion?: string;
  accion?: ReactNode;
}

interface TablaDatosProps<T> {
  /** Nombre de la tabla para lectores de pantalla. */
  etiqueta: string;
  columnas: Columna<T>[];
  filas: T[];
  claveFila: (fila: T) => string;
  /** true mientras llega la primera respuesta (muestra filas de carga). */
  cargandoInicial: boolean;
  /** true mientras se refresca (la tabla se marca como ocupada, sin parpadear). */
  ocupada?: boolean;
  error?: string | null;
  alReintentar?: () => void;
  vacio: EstadoVacio;
}

const FILAS_CARGA = 6;

/**
 * Grilla de datos con encabezado fijo y los cuatro estados: cargando (skeleton), error con
 * reintento, vacía con una acción útil y con datos.
 */
export function TablaDatos<T>({
  etiqueta, columnas, filas, claveFila, cargandoInicial, ocupada = false, error, alReintentar, vacio
}: TablaDatosProps<T>) {
  const claseColumna = (c: Columna<T>) => clases(c.numerica && "numero", c.apagada && "apagado") || undefined;

  let cuerpo: ReactNode;
  if (error && filas.length === 0) {
    cuerpo = (
      <FilaEstado columnas={columnas.length}>
        <CircleAlert size={24} aria-hidden="true" />
        <strong>No se pudo cargar la lista</strong>
        <p>{error}</p>
        {alReintentar && <Boton icono={RotateCw} onClick={alReintentar}>Reintentar</Boton>}
      </FilaEstado>
    );
  } else if (cargandoInicial && filas.length === 0) {
    cuerpo = Array.from({ length: FILAS_CARGA }, (_, i) => (
      <tr key={i} aria-hidden="true">
        {columnas.map((c, j) => (
          <td key={j} className={claseColumna(c)}>
            <span className="esqueleto" style={{ width: j === 0 ? "70%" : "50%", marginLeft: c.numerica ? "auto" : undefined }} />
          </td>
        ))}
      </tr>
    ));
  } else if (filas.length === 0) {
    const Icono = vacio.icono;
    cuerpo = (
      <FilaEstado columnas={columnas.length}>
        <Icono size={24} aria-hidden="true" />
        <strong>{vacio.titulo}</strong>
        {vacio.descripcion && <p>{vacio.descripcion}</p>}
        {vacio.accion}
      </FilaEstado>
    );
  } else {
    cuerpo = filas.map((fila) => (
      <tr key={claveFila(fila)}>
        {columnas.map((c) => (
          <td key={c.titulo} className={claseColumna(c)}>{c.celda(fila)}</td>
        ))}
      </tr>
    ));
  }

  return (
    <div className="tabla-contenedor">
      <table className="tabla" aria-busy={cargandoInicial || ocupada || undefined}>
        <caption className="visualmente-oculto">{etiqueta}</caption>
        <thead>
          <tr>
            {columnas.map((c) => (
              <th key={c.titulo} scope="col" className={c.numerica ? "numero" : undefined}>{c.titulo}</th>
            ))}
          </tr>
        </thead>
        <tbody>{cuerpo}</tbody>
      </table>
    </div>
  );
}

function FilaEstado({ columnas, children }: { columnas: number; children: ReactNode }) {
  return (
    <tr>
      <td colSpan={columnas}>
        <div className="tabla-estado">{children}</div>
      </td>
    </tr>
  );
}
