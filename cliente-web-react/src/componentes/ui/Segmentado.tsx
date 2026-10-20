import { ReactNode } from "react";
import { clases } from "./clases";

export interface OpcionSegmento<T extends string> {
  valor: T;
  texto: string;
  adorno?: ReactNode;
}

interface SegmentadoProps<T extends string> {
  etiqueta: string;
  nombre: string;
  valor: T;
  opciones: readonly OpcionSegmento<T>[];
  alCambiar: (valor: T) => void;
}

/** Control segmentado: un grupo de radios accesibles con aspecto de pestañas. */
export function Segmentado<T extends string>({ etiqueta, nombre, valor, opciones, alCambiar }: SegmentadoProps<T>) {
  return (
    <fieldset className="segmentado-grupo">
      <legend className="campo-etiqueta">{etiqueta}</legend>
      <div className="segmentado">
        {opciones.map((opcion) => (
          <label key={opcion.valor} className={clases("segmento", valor === opcion.valor && "activo")}>
            <input
              type="radio"
              name={nombre}
              value={opcion.valor}
              checked={valor === opcion.valor}
              onChange={() => alCambiar(opcion.valor)}
            />
            {opcion.adorno}
            {opcion.texto}
          </label>
        ))}
      </div>
    </fieldset>
  );
}
