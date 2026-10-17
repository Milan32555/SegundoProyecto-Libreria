import { CSSProperties, ReactNode } from "react";
import Icono, { NombreIcono } from "./Icono";
import { EstadoEjemplar } from "../types";

/** Encabezado de cada pantalla: etiqueta, título en serif y una línea de ayuda. */
export function Encabezado({ etiqueta, titulo, children }: { etiqueta: string; titulo: string; children?: ReactNode }) {
  return (
    <header className="encabezado">
      <span className="etiqueta etiqueta-acento">{etiqueta}</span>
      <h1>{titulo}</h1>
      {children && <p className="descripcion">{children}</p>}
    </header>
  );
}

type TipoAviso = "error" | "exito" | "advertencia";

/** Mensaje destacado (errores del servidor, confirmaciones, advertencias). */
export function Aviso({ tipo = "error", children }: { tipo?: TipoAviso; children: ReactNode }) {
  return (
    <p className={`aviso aviso-${tipo}`} role={tipo === "error" ? "alert" : "status"}>
      <Icono nombre={tipo} />
      <span>{children}</span>
    </p>
  );
}

const COLOR_ESTADO: Record<EstadoEjemplar, string> = {
  DISPONIBLE: "var(--verde)",
  PRESTADO: "var(--azul)",
  DANIADO: "var(--naranja)",
  DADO_DE_BAJA: "var(--rojo)"
};

export function colorEstado(estado: EstadoEjemplar): string {
  return COLOR_ESTADO[estado];
}

/** Pastilla de color para estados y categorías (Disponible, Ficción…). */
export function Pastilla({ children, color }: { children: ReactNode; color?: string }) {
  return (
    <span className="pastilla" style={color ? ({ "--color": color } as CSSProperties) : undefined}>
      {children}
    </span>
  );
}

/** Título de una sección (serif) con un ícono y, opcionalmente, un detalle a la derecha. */
export function TituloSeccion({ icono, titulo, detalle }: { icono: NombreIcono; titulo: string; detalle?: string }) {
  return (
    <div className="titulo-seccion">
      <Icono nombre={icono} tamano={22} />
      <h2>{titulo}</h2>
      {detalle && <span className="titulo-seccion-detalle">{detalle}</span>}
    </div>
  );
}

/** Ícono dentro de un cuadro redondeado con color tenue. */
export function IconoAcento({ nombre, color }: { nombre: Parameters<typeof Icono>[0]["nombre"]; color?: string }) {
  return (
    <span className="icono-acento" style={color ? ({ "--color": color } as CSSProperties) : undefined}>
      <Icono nombre={nombre} tamano={22} />
    </span>
  );
}

interface SelectorChipsProps<T extends string> {
  etiqueta: string;
  nombre: string;
  opciones: readonly T[];
  valor: T | "";
  etiquetaDe: (opcion: T) => string;
  alCambiar: (valor: T | "") => void;
  /** Agrega la opción "todos" (valor vacío), útil para filtros. */
  textoTodos?: string;
}

/** Selección única con chips (radio buttons accesibles con forma de pastilla). */
export function SelectorChips<T extends string>({
  etiqueta, nombre, opciones, valor, etiquetaDe, alCambiar, textoTodos
}: SelectorChipsProps<T>) {
  const chip = (valorChip: T | "", texto: string) => (
    <label className="chip" key={valorChip || "todos"}>
      <input
        type="radio"
        name={nombre}
        value={valorChip}
        checked={valor === valorChip}
        onChange={() => alCambiar(valorChip)}
      />
      <span>{texto}</span>
    </label>
  );
  return (
    <fieldset>
      <legend className="etiqueta">{etiqueta}</legend>
      <div className="chips">
        {textoTodos !== undefined && chip("", textoTodos)}
        {opciones.map((opcion) => chip(opcion, etiquetaDe(opcion)))}
      </div>
    </fieldset>
  );
}
