import { ClienteGraphQL } from "./clienteGraphQL";
import { EstadoEjemplar, Ejemplar } from "../types";

const CAMPOS_EJEMPLAR = `codigo estado ubicacion fechaIngreso precioReposicion isbnLibro`;

const graphql = () => ClienteGraphQL.getInstancia();

export async function listarEjemplares(): Promise<Ejemplar[]> {
  const data = await graphql().ejecutar<{ ejemplares: Ejemplar[] }>(
    `query { ejemplares { ${CAMPOS_EJEMPLAR} } }`
  );
  return data.ejemplares;
}

/** Listar con filtro: el filtrado se hace del lado del servidor. */
export async function listarEjemplaresFiltrados(
  estado: EstadoEjemplar | "",
  isbnLibro: string
): Promise<Ejemplar[]> {
  const data = await graphql().ejecutar<{ ejemplaresFiltrados: Ejemplar[] }>(
    `query ($estado: EstadoEjemplar, $isbnLibro: String) {
       ejemplaresFiltrados(estado: $estado, isbnLibro: $isbnLibro) { ${CAMPOS_EJEMPLAR} }
     }`,
    { estado: estado || null, isbnLibro: isbnLibro.trim() || null }
  );
  return data.ejemplaresFiltrados;
}

export async function buscarEjemplarPorCodigo(codigo: string): Promise<Ejemplar | null> {
  const data = await graphql().ejecutar<{ ejemplarPorCodigo: Ejemplar | null }>(
    `query ($codigo: ID!) { ejemplarPorCodigo(codigo: $codigo) { ${CAMPOS_EJEMPLAR} } }`,
    { codigo: codigo.trim() }
  );
  return data.ejemplarPorCodigo;
}

/** Número de revisión de la colección en el servidor (lo usa el Observer de Listar). */
export async function consultarRevisionEjemplares(): Promise<number> {
  const data = await graphql().ejecutar<{ revisionEjemplares: number }>(
    `query { revisionEjemplares }`
  );
  return data.revisionEjemplares;
}

export async function crearEjemplar(input: Ejemplar): Promise<Ejemplar> {
  const data = await graphql().ejecutar<{ crearEjemplar: Ejemplar }>(
    `mutation ($input: EjemplarInput!) { crearEjemplar(input: $input) { ${CAMPOS_EJEMPLAR} } }`,
    { input }
  );
  return data.crearEjemplar;
}

export async function actualizarEjemplar(
  codigo: string,
  input: Omit<Ejemplar, "codigo" | "isbnLibro">
): Promise<Ejemplar> {
  const data = await graphql().ejecutar<{ actualizarEjemplar: Ejemplar }>(
    `mutation ($codigo: ID!, $input: EjemplarUpdateInput!) {
       actualizarEjemplar(codigo: $codigo, input: $input) { ${CAMPOS_EJEMPLAR} }
     }`,
    { codigo, input }
  );
  return data.actualizarEjemplar;
}

export async function eliminarEjemplar(codigo: string): Promise<Ejemplar> {
  const data = await graphql().ejecutar<{ eliminarEjemplar: Ejemplar }>(
    `mutation ($codigo: ID!) { eliminarEjemplar(codigo: $codigo) { ${CAMPOS_EJEMPLAR} } }`,
    { codigo }
  );
  return data.eliminarEjemplar;
}
