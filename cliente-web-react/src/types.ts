export type Genero =
  | "FICCION"
  | "NO_FICCION"
  | "CIENCIA"
  | "HISTORIA"
  | "INFANTIL"
  | "POESIA"
  | "OTRO";

export const GENEROS: Genero[] = [
  "FICCION",
  "NO_FICCION",
  "CIENCIA",
  "HISTORIA",
  "INFANTIL",
  "POESIA",
  "OTRO"
];

const ETIQUETAS_GENERO: Record<Genero, string> = {
  FICCION: "Ficción",
  NO_FICCION: "No ficción",
  CIENCIA: "Ciencia",
  HISTORIA: "Historia",
  INFANTIL: "Infantil",
  POESIA: "Poesía",
  OTRO: "Otro"
};

/** Nombre legible del género (al servidor se envía el valor del enum). */
export function etiquetaGenero(genero: Genero): string {
  return ETIQUETAS_GENERO[genero];
}

export type EstadoEjemplar = "DISPONIBLE" | "PRESTADO" | "DANIADO" | "DADO_DE_BAJA";

export const ESTADOS_EJEMPLAR: EstadoEjemplar[] = [
  "DISPONIBLE",
  "PRESTADO",
  "DANIADO",
  "DADO_DE_BAJA"
];

const ETIQUETAS_ESTADO: Record<EstadoEjemplar, string> = {
  DISPONIBLE: "Disponible",
  PRESTADO: "Prestado",
  DANIADO: "Dañado",
  DADO_DE_BAJA: "Dado de baja"
};

/** Nombre legible del estado (al servidor se envía el valor del enum). */
export function etiquetaEstado(estado: EstadoEjemplar): string {
  return ETIQUETAS_ESTADO[estado];
}

export interface Libro {
  isbn: string;
  titulo: string;
  autor: string;
  precio: number;
  numeroPaginas: number;
  fechaPublicacion: string; // ISO-8601, p.ej. 2024-05-10T14:30:00
  genero: Genero;
}

export interface Ejemplar {
  codigo: string;
  estado: EstadoEjemplar;
  ubicacion: string;
  fechaIngreso: string;
  precioReposicion: number;
  numeroPrestamos: number;
  isbnLibro: string;
}

/** Cuántos ejemplares hay en un estado y su porcentaje (0 a 100); lo calcula el servidor. */
export interface ConteoEstado {
  estado: EstadoEjemplar;
  cantidad: number;
  porcentaje: number;
}

/** Resumen del inventario para la ventana principal (query resumenInventario). */
export interface ResumenInventario {
  totalLibros: number;
  totalEjemplares: number;
  ejemplaresPorEstado: ConteoEstado[];
}
