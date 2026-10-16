import { fireEvent, render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import AgregarLibro from "./AgregarLibro";
import { crearLibro } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";

vi.mock("../../graphql/servicioLibro", () => ({
  crearLibro: vi.fn(),
  consultarRevisionLibros: vi.fn()
}));

async function llenarFormulario() {
  const user = userEvent.setup();
  render(<AgregarLibro />);
  await user.type(screen.getByLabelText("ISBN"), "978-1");
  await user.type(screen.getByLabelText("Título"), "Pedro Páramo");
  await user.type(screen.getByLabelText("Autor"), "Juan Rulfo");
  await user.type(screen.getByLabelText("Precio"), "39000.5");
  await user.type(screen.getByLabelText("Número de páginas"), "124");
  fireEvent.change(screen.getByLabelText("Fecha de publicación"), { target: { value: "1955-03-19T10:30" } });
  await user.selectOptions(screen.getByLabelText(/^Género/), "NO_FICCION");
  await user.click(screen.getByRole("button", { name: "Adicionar" }));
}

describe("AgregarLibro", () => {
  it("envía todos los atributos con su tipo y notifica al Observer", async () => {
    vi.mocked(crearLibro).mockImplementation(async (libro) => libro);
    const notificar = vi.spyOn(libroObservable, "notificar");

    await llenarFormulario();

    expect(await screen.findByText('Libro "Pedro Páramo" creado correctamente.')).toBeInTheDocument();
    expect(crearLibro).toHaveBeenCalledWith({
      isbn: "978-1", titulo: "Pedro Páramo", autor: "Juan Rulfo", precio: 39000.5,
      numeroPaginas: 124, fechaPublicacion: "1955-03-19T10:30", genero: "NO_FICCION"
    });
    expect(notificar).toHaveBeenCalledTimes(1);
    expect(screen.getByLabelText("ISBN")).toHaveValue("");
  });

  it("muestra el error de validación del servidor y conserva los datos", async () => {
    vi.mocked(crearLibro).mockRejectedValue(new ErrorGraphQL("Ya existe un libro con el ISBN 978-1."));

    await llenarFormulario();

    expect(await screen.findByText("Ya existe un libro con el ISBN 978-1.")).toBeInTheDocument();
    expect(screen.getByLabelText("ISBN")).toHaveValue("978-1");
  });
});
