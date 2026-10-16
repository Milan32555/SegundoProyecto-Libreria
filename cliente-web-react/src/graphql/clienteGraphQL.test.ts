import { describe, expect, it, vi } from "vitest";
import { ClienteGraphQL, ErrorGraphQL, URL_GRAPHQL, mensajeDeError } from "./clienteGraphQL";

function respuestaJson(cuerpo: unknown, status = 200): Response {
  return new Response(JSON.stringify(cuerpo), {
    status,
    headers: { "Content-Type": "application/json" }
  });
}

describe("ClienteGraphQL", () => {
  it("es un Singleton", () => {
    expect(ClienteGraphQL.getInstancia()).toBe(ClienteGraphQL.getInstancia());
  });

  it("envía la consulta por POST y devuelve `data`", async () => {
    const fetchFalso = vi.fn().mockResolvedValue(respuestaJson({ data: { libros: [] } }));
    vi.stubGlobal("fetch", fetchFalso);

    const data = await ClienteGraphQL.getInstancia().ejecutar("query { libros { isbn } }", { a: 1 });

    expect(data).toEqual({ libros: [] });
    const [url, opciones] = fetchFalso.mock.calls[0];
    expect(url).toBe(URL_GRAPHQL);
    expect(opciones.method).toBe("POST");
    expect(JSON.parse(opciones.body)).toEqual({ query: "query { libros { isbn } }", variables: { a: 1 } });
  });

  it("convierte los errores de GraphQL en ErrorGraphQL con el mensaje del servidor", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(
      respuestaJson({ errors: [{ message: "Ya existe un libro con el ISBN 1." }], data: { crearLibro: null } })
    ));

    await expect(ClienteGraphQL.getInstancia().ejecutar("mutation")).rejects.toThrow(
      new ErrorGraphQL("Ya existe un libro con el ISBN 1.")
    );
  });

  it("muestra el mensaje del servidor aunque el código HTTP sea de error", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(
      respuestaJson({ errors: [{ message: "Fecha inválida: 30/02/2020" }] }, 400)
    ));

    await expect(ClienteGraphQL.getInstancia().ejecutar("mutation")).rejects.toThrow("Fecha inválida");
  });

  it("informa el código HTTP cuando la respuesta no es GraphQL", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(new Response("Internal error", { status: 500 })));

    await expect(ClienteGraphQL.getInstancia().ejecutar("query")).rejects.toThrow("código HTTP 500");
  });

  it("da un mensaje claro si el servidor no está disponible", async () => {
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new TypeError("Failed to fetch")));

    await expect(ClienteGraphQL.getInstancia().ejecutar("query")).rejects.toThrow(
      "No se pudo conectar con el servidor"
    );
  });
});

describe("mensajeDeError", () => {
  it("usa el mensaje de ErrorGraphQL y uno genérico para lo demás", () => {
    expect(mensajeDeError(new ErrorGraphQL("detalle"))).toBe("detalle");
    expect(mensajeDeError(new Error("interno"))).toBe("Ocurrió un error inesperado.");
  });
});
