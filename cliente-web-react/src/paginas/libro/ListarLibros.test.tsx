import { act, screen, waitFor, within } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import ListarLibros from "./ListarLibros";
import { consultarRevisionLibros, listarLibrosFiltrados } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { elegirOpcion, renderizar } from "../../pruebas/utilidades";
import { Libro } from "../../types";

vi.mock("../../graphql/servicioLibro", () => ({
  listarLibrosFiltrados: vi.fn(),
  consultarRevisionLibros: vi.fn()
}));

const CIEN_ANOS: Libro = {
  isbn: "978-0307474728", titulo: "Cien años de soledad", autor: "Gabriel García Márquez",
  precio: 65000, numeroPaginas: 496, fechaPublicacion: "1967-05-30T00:00:00", genero: "FICCION"
};
const PEDRO_PARAMO: Libro = {
  isbn: "978-9681649500", titulo: "Pedro Páramo", autor: "Juan Rulfo",
  precio: 42000, numeroPaginas: 129, fechaPublicacion: "1955-03-19T00:00:00", genero: "FICCION"
};

describe("ListarLibros", () => {
  beforeEach(() => {
    vi.mocked(consultarRevisionLibros).mockReturnValue(new Promise(() => {}));
    vi.mocked(listarLibrosFiltrados).mockResolvedValue({ libros: [CIEN_ANOS], total: 1 });
  });

  it("muestra todos los libros en una grilla al abrir la pantalla", async () => {
    renderizar(<ListarLibros />);

    expect(await screen.findByText("Cien años de soledad")).toBeInTheDocument();
    const tabla = screen.getByRole("table", { name: "Libros del inventario" });
    expect(within(tabla).getByRole("columnheader", { name: "Páginas" })).toBeInTheDocument();
    expect(within(tabla).getByRole("cell", { name: "496" })).toHaveClass("numero");
    expect(within(tabla).getByRole("cell", { name: "Ficción" })).toBeInTheDocument();
    expect(within(tabla).getByText("Gabriel García Márquez")).toBeInTheDocument();
    expect(screen.getByText("1 libro")).toBeInTheDocument();
    expect(listarLibrosFiltrados).toHaveBeenCalledWith("", "");
  });

  it("filtra en el servidor por autor y por género", async () => {
    const { user } = renderizar(<ListarLibros />);
    await screen.findByText("Cien años de soledad");

    await user.type(screen.getByLabelText("Autor"), "garcia");
    await user.click(screen.getByRole("button", { name: "Filtrar" }));
    await waitFor(() => expect(listarLibrosFiltrados).toHaveBeenLastCalledWith("garcia", ""));

    // Elegir un género filtra de inmediato, sin perder el autor escrito.
    await elegirOpcion(user, "Género", "Poesía");
    await waitFor(() => expect(listarLibrosFiltrados).toHaveBeenLastCalledWith("garcia", "POESIA"));
  });

  it("limpiar filtros vuelve a pedir la lista completa", async () => {
    const { user } = renderizar(<ListarLibros />);
    await screen.findByText("Cien años de soledad");
    expect(screen.queryByRole("button", { name: "Limpiar filtros" })).not.toBeInTheDocument();

    await user.type(screen.getByLabelText("Autor"), "rulfo");
    await user.click(screen.getByRole("button", { name: "Limpiar filtros" }));

    await waitFor(() => expect(listarLibrosFiltrados).toHaveBeenLastCalledWith("", ""));
    expect(screen.getByLabelText("Autor")).toHaveValue("");
  });

  it("Observer: se refresca sola, con los filtros actuales, cuando el sujeto notifica", async () => {
    const { user } = renderizar(<ListarLibros />);
    await screen.findByText("Cien años de soledad");
    await user.type(screen.getByLabelText("Autor"), "rulfo");
    vi.mocked(listarLibrosFiltrados).mockResolvedValue({ libros: [PEDRO_PARAMO], total: 1 });

    act(() => libroObservable.notificar());

    expect(await screen.findByText("Pedro Páramo")).toBeInTheDocument();
    expect(listarLibrosFiltrados).toHaveBeenLastCalledWith("rulfo", "");
    expect(screen.queryByText("Cien años de soledad")).not.toBeInTheDocument();
  });

  it("muestra el total que calcula el servidor", async () => {
    vi.mocked(listarLibrosFiltrados).mockResolvedValue({ libros: [CIEN_ANOS, PEDRO_PARAMO], total: 2 });

    renderizar(<ListarLibros />);

    expect(await screen.findByText("2 libros")).toBeInTheDocument();
  });

  it("si falla la carga muestra el error y permite reintentar", async () => {
    vi.mocked(listarLibrosFiltrados).mockRejectedValueOnce(new ErrorGraphQL("No se pudo conectar con el servidor."));
    const { user } = renderizar(<ListarLibros />);

    expect(await screen.findByText("No se pudo cargar la lista")).toBeInTheDocument();
    expect(screen.getByText("No se pudo conectar con el servidor.")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Reintentar" }));

    expect(await screen.findByText("Cien años de soledad")).toBeInTheDocument();
  });

  it("estado vacío: sin libros invita a adicionar; con filtro invita a limpiarlo", async () => {
    vi.mocked(listarLibrosFiltrados).mockResolvedValue({ libros: [], total: 0 });
    const { user } = renderizar(<ListarLibros />);

    expect(await screen.findByText("Todavía no hay libros")).toBeInTheDocument();

    await user.type(screen.getByLabelText("Autor"), "nadie");
    await user.click(screen.getByRole("button", { name: "Filtrar" }));

    expect(await screen.findByText("Ningún libro coincide con el filtro")).toBeInTheDocument();
  });
});
