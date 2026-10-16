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

export type EstadoEjemplar = "DISPONIBLE" | "PRESTADO" | "DANIADO" | "DADO_DE_BAJA";

export const ESTADOS_EJEMPLAR: EstadoEjemplar[] = [
  "DISPONIBLE",
  "PRESTADO",
  "DANIADO",
  "DADO_DE_BAJA"
];

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
  isbnLibro: string;
}
