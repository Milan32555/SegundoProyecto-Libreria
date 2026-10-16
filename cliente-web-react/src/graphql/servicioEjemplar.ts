import { ejecutarGraphQL } from "./clienteGraphQL";
import { EstadoEjemplar, Ejemplar } from "../types";

const CAMPOS_EJEMPLAR = `codigo estado ubicacion fechaIngreso precioReposicion isbnLibro`;

export async function listarEjemplares(): Promise<Ejemplar[]> {
  const data = await ejecutarGraphQL<{ ejemplares: Ejemplar[] }>(
    `query { ejemplares { ${CAMPOS_EJEMPLAR} } }`
  );
  return data.ejemplares;
}

export async function listarEjemplaresFiltrados(
  estado: EstadoEjemplar | "",
  isbnLibro: string
): Promise<Ejemplar[]> {
  const data = await ejecutarGraphQL<{ ejemplaresFiltrados: Ejemplar[] }>(
    `query ($estado: EstadoEjemplar, $isbnLibro: String) {
       ejemplaresFiltrados(estado: $estado, isbnLibro: $isbnLibro) { ${CAMPOS_EJEMPLAR} }
     }`,
    { estado: estado || null, isbnLibro: isbnLibro || null }
  );
  return data.ejemplaresFiltrados;
}

export async function buscarEjemplarPorCodigo(codigo: string): Promise<Ejemplar | null> {
  const data = await ejecutarGraphQL<{ ejemplarPorCodigo: Ejemplar | null }>(
    `query ($codigo: ID!) { ejemplarPorCodigo(codigo: $codigo) { ${CAMPOS_EJEMPLAR} } }`,
    { codigo }
  );
  return data.ejemplarPorCodigo;
}

export async function crearEjemplar(input: Ejemplar): Promise<Ejemplar> {
  const data = await ejecutarGraphQL<{ crearEjemplar: Ejemplar }>(
    `mutation ($input: EjemplarInput!) { crearEjemplar(input: $input) { ${CAMPOS_EJEMPLAR} } }`,
    { input }
  );
  return data.crearEjemplar;
}

export async function actualizarEjemplar(
  codigo: string,
  input: Omit<Ejemplar, "codigo" | "isbnLibro">
): Promise<Ejemplar> {
  const data = await ejecutarGraphQL<{ actualizarEjemplar: Ejemplar }>(
    `mutation ($codigo: ID!, $input: EjemplarUpdateInput!) {
       actualizarEjemplar(codigo: $codigo, input: $input) { ${CAMPOS_EJEMPLAR} }
     }`,
    { codigo, input }
  );
  return data.actualizarEjemplar;
}

export async function eliminarEjemplar(codigo: string): Promise<Ejemplar> {
  const data = await ejecutarGraphQL<{ eliminarEjemplar: Ejemplar }>(
    `mutation ($codigo: ID!) { eliminarEjemplar(codigo: $codigo) { ${CAMPOS_EJEMPLAR} } }`,
    { codigo }
  );
  return data.eliminarEjemplar;
}
