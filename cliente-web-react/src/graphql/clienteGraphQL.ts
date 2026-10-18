// URL del servidor GraphQL. Para usar otra máquina/puerto, crear un archivo .env con
// VITE_URL_GRAPHQL=http://<ip-del-servidor>:8081/graphql (no hace falta tocar el código).
export const URL_GRAPHQL = import.meta.env.VITE_URL_GRAPHQL ?? "http://localhost:8081/graphql";

/** Con este encabezado el servidor sabe qué cliente hizo cada operación (lo muestra en consola). */
export const ENCABEZADO_CLIENTE = { "X-Cliente": "web" } as const;

/** Error con un mensaje listo para mostrarle al usuario (del servidor o de conexión). */
export class ErrorGraphQL extends Error {
  constructor(mensaje: string) {
    super(mensaje);
    this.name = "ErrorGraphQL";
  }
}

interface RespuestaGraphQL<T> {
  data?: T | null;
  errors?: { message?: string }[];
}

/**
 * Patrón Singleton: única instancia del cliente que se comunica con el servidor GraphQL.
 * Todas las peticiones de la aplicación pasan por aquí: envía la consulta/mutación por
 * POST y devuelve `data`, o lanza ErrorGraphQL con un mensaje entendible.
 * (Cliente propio, sin librerías externas de GraphQL.)
 */
export class ClienteGraphQL {
  private static instancia: ClienteGraphQL | null = null;

  private constructor(private readonly url: string) {}

  static getInstancia(): ClienteGraphQL {
    if (ClienteGraphQL.instancia === null) {
      ClienteGraphQL.instancia = new ClienteGraphQL(URL_GRAPHQL);
    }
    return ClienteGraphQL.instancia;
  }

  async ejecutar<T>(query: string, variables?: Record<string, unknown>): Promise<T> {
    let respuesta: Response;
    try {
      respuesta = await fetch(this.url, {
        method: "POST",
        headers: { "Content-Type": "application/json", Accept: "application/json", ...ENCABEZADO_CLIENTE },
        body: JSON.stringify({ query, variables })
      });
    } catch {
      throw new ErrorGraphQL(
        `No se pudo conectar con el servidor (${this.url}). Verifique que esté en ejecución.`
      );
    }

    // Se lee el cuerpo aunque el código HTTP sea de error: ahí viene el mensaje del servidor.
    const cuerpo = (await respuesta.json().catch(() => null)) as RespuestaGraphQL<T> | null;

    if (cuerpo?.errors && cuerpo.errors.length > 0) {
      throw new ErrorGraphQL(cuerpo.errors[0].message ?? "Error desconocido del servidor.");
    }
    if (!respuesta.ok || !cuerpo?.data) {
      throw new ErrorGraphQL(`El servidor respondió con código HTTP ${respuesta.status}.`);
    }
    return cuerpo.data;
  }
}

/** Texto para mostrarle al usuario a partir de cualquier error capturado en una pantalla. */
export function mensajeDeError(error: unknown): string {
  return error instanceof ErrorGraphQL ? error.message : "Ocurrió un error inesperado.";
}
