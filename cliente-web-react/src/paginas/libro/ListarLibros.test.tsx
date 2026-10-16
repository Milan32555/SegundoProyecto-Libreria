import { act, render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import ListarLibros from "./ListarLibros";
import { listarLibrosFiltrados } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
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
  isbn: "978-6070701", titulo: "Pedro Páramo", autor: "Juan Rulfo",
  precio: 39000, numeroPaginas: 124, fechaPublicacion: "1955-03-19T00:00:00", genero: "FICCION"
};

describe("ListarLibros", () => {
  beforeEach(async () => {
    const { consultarRevisionLibros } = await import("../../graphql/servicioLibro");
    vi.mocked(consultarRevisionLibros).mockReturnValue(new Promise(() => {}));
    vi.mocked(listarLibrosFiltrados).mockResolvedValue([CIEN_ANOS]);
  });

  it("muestra todos los libros en una grilla al abrir la pantalla", async () => {
    render(<ListarLibros />);

    expect(await screen.findByRole("cell", { name: "Cien años de soledad" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "Gabriel García Márquez" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "496" })).toBeInTheDocument();
    expect(screen.getByText("1 libro(s)")).toBeInTheDocument();
    expect(listarLibrosFiltrados).toHaveBeenCalledWith("", "");
  });

  it("filtra en el servidor por autor y género", async () => {
    const user = userEvent.setup();
    render(<ListarLibros />);
    await screen.findByRole("cell", { name: "Cien años de soledad" });

    await user.type(screen.getByLabelText("Autor contiene"), "garcia");
    await user.selectOptions(screen.getByLabelText(/^Género/), "FICCION");
    await user.click(screen.getByRole("button", { name: "Filtrar" }));

    await waitFor(() => expect(listarLibrosFiltrados).toHaveBeenLastCalledWith("garcia", "FICCION"));
  });

  it("Observer: se refresca sola, con los filtros actuales, cuando el sujeto notifica", async () => {
    const user = userEvent.setup();
    render(<ListarLibros />);
    await screen.findByRole("cell", { name: "Cien años de soledad" });
    await user.type(screen.getByLabelText("Autor contiene"), "rulfo");
    vi.mocked(listarLibrosFiltrados).mockResolvedValue([PEDRO_PARAMO]);

    act(() => libroObservable.notificar());

    expect(await screen.findByRole("cell", { name: "Pedro Páramo" })).toBeInTheDocument();
    expect(listarLibrosFiltrados).toHaveBeenLastCalledWith("rulfo", "");
    expect(screen.queryByRole("cell", { name: "Cien años de soledad" })).not.toBeInTheDocument();
  });

  it("muestra un mensaje cuando no hay datos o hay un error", async () => {
    vi.mocked(listarLibrosFiltrados).mockRejectedValue(new ErrorGraphQL("No se pudo conectar con el servidor"));

    render(<ListarLibros />);

    expect(await screen.findByText("No se pudo conectar con el servidor")).toBeInTheDocument();
    expect(screen.getByText("No hay libros para mostrar.")).toBeInTheDocument();
  });
});
