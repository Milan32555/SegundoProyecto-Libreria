import { ClienteGraphQL } from "./clienteGraphQL";
import { Genero, Libro } from "../types";

const CAMPOS_LIBRO = `isbn titulo autor precio numeroPaginas fechaPublicacion genero`;

const graphql = () => ClienteGraphQL.getInstancia();

export interface ListadoLibros {
  libros: Libro[];
  total: number;
}

/**
 * Listar con filtro: el servidor filtra y también cuenta cuántos libros cumplen el filtro
 * (las dos cosas en una sola petición GraphQL).
 */
export async function listarLibrosFiltrados(autor: string, genero: Genero | ""): Promise<ListadoLibros> {
  const data = await graphql().ejecutar<{ librosFiltrados: Libro[]; totalLibrosFiltrados: number }>(
    `query ($autor: String, $genero: Genero) {
       librosFiltrados(autor: $autor, genero: $genero) { ${CAMPOS_LIBRO} }
       totalLibrosFiltrados(autor: $autor, genero: $genero)
     }`,
    { autor: autor.trim() || null, genero: genero || null }
  );
  return { libros: data.librosFiltrados, total: data.totalLibrosFiltrados };
}

export async function buscarLibroPorIsbn(isbn: string): Promise<Libro | null> {
  const data = await graphql().ejecutar<{ libroPorIsbn: Libro | null }>(
    `query ($isbn: ID!) { libroPorIsbn(isbn: $isbn) { ${CAMPOS_LIBRO} } }`,
    { isbn: isbn.trim() }
  );
  return data.libroPorIsbn;
}

export async function buscarLibroPorTitulo(titulo: string): Promise<Libro | null> {
  const data = await graphql().ejecutar<{ libroPorTitulo: Libro | null }>(
    `query ($titulo: String!) { libroPorTitulo(titulo: $titulo) { ${CAMPOS_LIBRO} } }`,
    { titulo: titulo.trim() }
  );
  return data.libroPorTitulo;
}

/** Número de revisión de la colección en el servidor (lo usa el Observer de Listar). */
export async function consultarRevisionLibros(): Promise<number> {
  const data = await graphql().ejecutar<{ revisionLibros: number }>(`query { revisionLibros }`);
  return data.revisionLibros;
}

export async function crearLibro(input: Libro): Promise<Libro> {
  const data = await graphql().ejecutar<{ crearLibro: Libro }>(
    `mutation ($input: LibroInput!) { crearLibro(input: $input) { ${CAMPOS_LIBRO} } }`,
    { input }
  );
  return data.crearLibro;
}

export async function actualizarLibro(isbn: string, input: Omit<Libro, "isbn">): Promise<Libro> {
  const data = await graphql().ejecutar<{ actualizarLibro: Libro }>(
    `mutation ($isbn: ID!, $input: LibroUpdateInput!) {
       actualizarLibro(isbn: $isbn, input: $input) { ${CAMPOS_LIBRO} }
     }`,
    { isbn, input }
  );
  return data.actualizarLibro;
}

export async function eliminarLibro(isbn: string): Promise<Libro> {
  const data = await graphql().ejecutar<{ eliminarLibro: Libro }>(
    `mutation ($isbn: ID!) { eliminarLibro(isbn: $isbn) { ${CAMPOS_LIBRO} } }`,
    { isbn }
  );
  return data.eliminarLibro;
}
