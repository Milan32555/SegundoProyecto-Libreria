// URL del servidor GraphQL. Cambiar aquí si el servidor corre en otra máquina/puerto.
export const URL_GRAPHQL = "http://localhost:8081/graphql";

/** Error con el detalle que devuelve el servidor GraphQL (para mostrarlo amigable al usuario). */
export class ErrorGraphQL extends Error {}

/**
 * Pequeño cliente GraphQL propio (sin librerías externas): envía la consulta/mutación
 * por POST y devuelve `data`, o lanza ErrorGraphQL con el mensaje del servidor.
 */
export async function ejecutarGraphQL<T>(
  query: string,
  variables?: Record<string, unknown>
): Promise<T> {
  const respuesta = await fetch(URL_GRAPHQL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query, variables })
  });

  if (!respuesta.ok) {
    throw new ErrorGraphQL(`El servidor respondió con código HTTP ${respuesta.status}`);
  }

  const cuerpo = await respuesta.json();

  if (cuerpo.errors && cuerpo.errors.length > 0) {
    throw new ErrorGraphQL(cuerpo.errors[0].message ?? "Error desconocido del servidor");
  }

  return cuerpo.data as T;
}
