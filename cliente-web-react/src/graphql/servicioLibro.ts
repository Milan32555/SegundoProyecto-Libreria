import { ejecutarGraphQL } from "./clienteGraphQL";
import { Genero, Libro } from "../types";

const CAMPOS_LIBRO = `isbn titulo autor precio numeroPaginas fechaPublicacion genero`;

export async function listarLibros(): Promise<Libro[]> {
  const data = await ejecutarGraphQL<{ libros: Libro[] }>(
    `query { libros { ${CAMPOS_LIBRO} } }`
  );
  return data.libros;
}

export async function listarLibrosFiltrados(autor: string, genero: Genero | ""): Promise<Libro[]> {
  const data = await ejecutarGraphQL<{ librosFiltrados: Libro[] }>(
    `query ($autor: String, $genero: Genero) {
       librosFiltrados(autor: $autor, genero: $genero) { ${CAMPOS_LIBRO} }
     }`,
    { autor: autor || null, genero: genero || null }
  );
  return data.librosFiltrados;
}

export async function buscarLibroPorIsbn(isbn: string): Promise<Libro | null> {
  const data = await ejecutarGraphQL<{ libroPorIsbn: Libro | null }>(
    `query ($isbn: ID!) { libroPorIsbn(isbn: $isbn) { ${CAMPOS_LIBRO} } }`,
    { isbn }
  );
  return data.libroPorIsbn;
}

export async function crearLibro(input: Libro): Promise<Libro> {
  const data = await ejecutarGraphQL<{ crearLibro: Libro }>(
    `mutation ($input: LibroInput!) { crearLibro(input: $input) { ${CAMPOS_LIBRO} } }`,
    { input }
  );
  return data.crearLibro;
}

export async function actualizarLibro(
  isbn: string,
  input: Omit<Libro, "isbn">
): Promise<Libro> {
  const data = await ejecutarGraphQL<{ actualizarLibro: Libro }>(
    `mutation ($isbn: ID!, $input: LibroUpdateInput!) {
       actualizarLibro(isbn: $isbn, input: $input) { ${CAMPOS_LIBRO} }
     }`,
    { isbn, input }
  );
  return data.actualizarLibro;
}

export async function eliminarLibro(isbn: string): Promise<Libro> {
  const data = await ejecutarGraphQL<{ eliminarLibro: Libro }>(
    `mutation ($isbn: ID!) { eliminarLibro(isbn: $isbn) { ${CAMPOS_LIBRO} } }`,
    { isbn }
  );
  return data.eliminarLibro;
}
