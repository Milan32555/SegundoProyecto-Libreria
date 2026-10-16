import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import ConsultarLibro from "./ConsultarLibro";
import { buscarLibroPorIsbn, buscarLibroPorTitulo } from "../../graphql/servicioLibro";
import { Libro } from "../../types";

vi.mock("../../graphql/servicioLibro", () => ({
  buscarLibroPorIsbn: vi.fn(),
  buscarLibroPorTitulo: vi.fn()
}));

const VORAGINE: Libro = {
  isbn: "978-8420471839", titulo: "La vorágine", autor: "José Eustasio Rivera",
  precio: 48000, numeroPaginas: 384, fechaPublicacion: "1924-11-25T00:00:00", genero: "FICCION"
};

describe("ConsultarLibro", () => {
  it("consulta UN SOLO libro por ISBN", async () => {
    vi.mocked(buscarLibroPorIsbn).mockResolvedValue(VORAGINE);
    const user = userEvent.setup();
    render(<ConsultarLibro />);

    await user.type(screen.getByLabelText("ISBN"), "978-8420471839");
    await user.click(screen.getByRole("button", { name: "Buscar" }));

    expect(await screen.findByText("La vorágine")).toBeInTheDocument();
    expect(buscarLibroPorIsbn).toHaveBeenCalledWith("978-8420471839");
    expect(buscarLibroPorTitulo).not.toHaveBeenCalled();
  });

  it("consulta por título como criterio alternativo", async () => {
    vi.mocked(buscarLibroPorTitulo).mockResolvedValue(VORAGINE);
    const user = userEvent.setup();
    render(<ConsultarLibro />);

    await user.click(screen.getByRole("radio", { name: "Por título" }));
    await user.type(screen.getByLabelText("Título"), "la voragine");
    await user.click(screen.getByRole("button", { name: "Buscar" }));

    expect(await screen.findByText("José Eustasio Rivera")).toBeInTheDocument();
    expect(buscarLibroPorTitulo).toHaveBeenCalledWith("la voragine");
  });

  it("informa cuando no encuentra el libro", async () => {
    vi.mocked(buscarLibroPorIsbn).mockResolvedValue(null);
    const user = userEvent.setup();
    render(<ConsultarLibro />);

    await user.type(screen.getByLabelText("ISBN"), "000");
    await user.click(screen.getByRole("button", { name: "Buscar" }));

    expect(await screen.findByText('No se encontró ningún libro con el ISBN "000".')).toBeInTheDocument();
  });
});
