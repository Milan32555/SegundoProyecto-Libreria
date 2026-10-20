import { InputHTMLAttributes, ReactNode, useId } from "react";
import { CircleAlert } from "lucide-react";
import { clases } from "./clases";

interface CampoProps extends Omit<InputHTMLAttributes<HTMLInputElement>, "prefix"> {
  etiqueta: string;
  /** Mensaje de validación en línea (debajo del campo). */
  error?: string | null;
  /** Texto de ayuda permanente debajo del campo. */
  ayuda?: ReactNode;
  /** Texto fijo antes del valor, p. ej. "$". */
  prefijo?: string;
  /** Contenido al final del control, p. ej. un ícono de candado. */
  sufijo?: ReactNode;
  /** Ocupa las dos columnas de la rejilla del formulario. */
  ancho?: boolean;
}

/**
 * Campo de formulario accesible: etiqueta asociada, error en línea (aria-invalid +
 * aria-describedby) y ayuda opcional.
 */
export function Campo({ etiqueta, error, ayuda, prefijo, sufijo, ancho = false, id, className, ...input }: CampoProps) {
  const idGenerado = useId();
  const idCampo = id ?? idGenerado;
  const idError = error ? `${idCampo}-error` : undefined;
  const idAyuda = ayuda ? `${idCampo}-ayuda` : undefined;
  const descripciones = [idError, idAyuda].filter(Boolean).join(" ") || undefined;

  return (
    <div className={clases("campo", ancho && "campo-ancho", className)}>
      <label htmlFor={idCampo}>{etiqueta}</label>
      <div className={clases("control", error && "con-error", input.readOnly && "solo-lectura")}>
        {prefijo && <span className="control-prefijo" aria-hidden="true">{prefijo}</span>}
        <input id={idCampo} aria-invalid={error ? true : undefined} aria-describedby={descripciones} {...input} />
        {sufijo && <span className="control-sufijo">{sufijo}</span>}
      </div>
      {error && (
        <p id={idError} className="campo-error">
          <CircleAlert size={14} aria-hidden="true" />
          {error}
        </p>
      )}
      {ayuda && <p id={idAyuda} className="campo-ayuda">{ayuda}</p>}
    </div>
  );
}
