import { EstadoEjemplar, Genero, etiquetaEstado, etiquetaGenero } from "../../types";

const CLASE_ESTADO: Record<EstadoEjemplar, string> = {
  DISPONIBLE: "insignia-disponible",
  PRESTADO: "insignia-prestado",
  DANIADO: "insignia-daniado",
  DADO_DE_BAJA: "insignia-baja"
};

/** Color del punto de cada estado (para la barra de distribución del inicio). */
export const COLOR_ESTADO: Record<EstadoEjemplar, string> = {
  DISPONIBLE: "var(--exito-punto)",
  PRESTADO: "var(--info-punto)",
  DANIADO: "var(--aviso-punto)",
  DADO_DE_BAJA: "var(--neutro-punto)"
};

/** Estado de un ejemplar: punto + texto, así no depende solo del color. */
export function InsigniaEstado({ estado, texto }: { estado: EstadoEjemplar; texto?: string }) {
  return <span className={`insignia insignia-estado ${CLASE_ESTADO[estado]}`}>{texto ?? etiquetaEstado(estado)}</span>;
}

/** Género de un libro: categoría neutra, sin punto. */
export function InsigniaGenero({ genero }: { genero: Genero }) {
  return <span className="insignia insignia-categoria">{etiquetaGenero(genero)}</span>;
}
