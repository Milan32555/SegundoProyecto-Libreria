import { screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import ConsultarLibro from "./ConsultarLibro";
import { buscarLibroPorIsbn, buscarLibroPorTitulo } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { renderizar } from "../../pruebas/utilidades";
import { Libro } from "../../types";

vi.mock("../../graphql/servicioLibro", () => ({
  buscarLibroPorIsbn: vi.fn(),
  buscarLibroPorTitulo: vi.fn()
}));

const VORAGINE: Libro = {
  isbn: "978-8437609355", titulo: "La vorágine", autor: "José Eustasio Rivera",
  precio: 48000, numeroPaginas: 390, fechaPublicacion: "1924-11-25T00:00:00", genero: "FICCION"
};

describe("ConsultarLibro", () => {
  it("consulta UN SOLO libro por ISBN", async () => {
    vi.mocked(buscarLibroPorIsbn).mockResolvedValue(VORAGINE);
    const { user } = renderizar(<ConsultarLibro />);

    await user.type(screen.getByLabelText("ISBN"), "978-8437609355");
    await user.click(screen.getByRole("button", { name: "Buscar" }));

    expect(await screen.findByRole("heading", { name: "La vorágine" })).toBeInTheDocument();
    expect(buscarLibroPorIsbn).toHaveBeenCalledWith("978-8437609355");
    expect(buscarLibroPorTitulo).not.toHaveBeenCalled();
  });

  it("consulta por título como criterio alternativo", async () => {
    vi.mocked(buscarLibroPorTitulo).mockResolvedValue(VORAGINE);
    const { user } = renderizar(<ConsultarLibro />);

    await user.click(screen.getByRole("radio", { name: "Por título" }));
    await user.type(screen.getByRole("textbox", { name: "Título" }), "la voragine");
    await user.click(screen.getByRole("button", { name: "Buscar" }));

    expect(await screen.findAllByText("José Eustasio Rivera")).not.toHaveLength(0);
    expect(buscarLibroPorTitulo).toHaveBeenCalledWith("la voragine");
  });

  it("informa cuando no encuentra el libro", async () => {
    vi.mocked(buscarLibroPorIsbn).mockResolvedValue(null);
    const { user } = renderizar(<ConsultarLibro />);

    await user.type(screen.getByLabelText("ISBN"), "000");
    await user.click(screen.getByRole("button", { name: "Buscar" }));

    expect(await screen.findByText("No hay ningún libro con el ISBN «000».")).toBeInTheDocument();
  });

  it("informa cuando no encuentra el título y cuando falla la conexión", async () => {
    vi.mocked(buscarLibroPorTitulo).mockResolvedValueOnce(null);
    const { user } = renderizar(<ConsultarLibro />);

    await user.click(screen.getByRole("radio", { name: "Por título" }));
    await user.type(screen.getByRole("textbox", { name: "Título" }), "Inexistente");
    await user.click(screen.getByRole("button", { name: "Buscar" }));
    expect(await screen.findByText("No hay ningún libro titulado «Inexistente».")).toBeInTheDocument();

    vi.mocked(buscarLibroPorTitulo).mockRejectedValueOnce(new ErrorGraphQL("No se pudo conectar con el servidor."));
    await user.click(screen.getByRole("button", { name: "Buscar" }));
    expect(await screen.findByRole("alert")).toHaveTextContent("No se pudo conectar con el servidor.");
  });
});
