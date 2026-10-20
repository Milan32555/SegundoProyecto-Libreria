import { ESTADOS_EJEMPLAR, EstadoEjemplar, GENEROS, Genero, etiquetaEstado, etiquetaGenero } from "../types";
import { OpcionSelector } from "./ui/Selector";

/** Opciones de los selectores (el texto es la etiqueta legible; el valor es el del enum del servidor). */
export const OPCIONES_GENERO: OpcionSelector<Genero>[] = GENEROS.map((g) => ({ valor: g, texto: etiquetaGenero(g) }));

export const OPCIONES_GENERO_FILTRO: OpcionSelector<Genero>[] = [{ valor: "", texto: "Todos los géneros" }, ...OPCIONES_GENERO];

export const OPCIONES_ESTADO: OpcionSelector<EstadoEjemplar>[] = ESTADOS_EJEMPLAR.map((e) => ({
  valor: e,
  texto: etiquetaEstado(e)
}));
