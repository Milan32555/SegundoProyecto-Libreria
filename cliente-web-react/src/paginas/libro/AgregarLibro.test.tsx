import { fireEvent, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import AgregarLibro from "./AgregarLibro";
import { crearLibro } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { elegirOpcion, renderizar } from "../../pruebas/utilidades";

vi.mock("../../graphql/servicioLibro", () => ({
  crearLibro: vi.fn(),
  consultarRevisionLibros: vi.fn()
}));

async function llenarYEnviar() {
  const { user } = renderizar(<AgregarLibro />);
  await user.type(screen.getByLabelText("ISBN"), "978-9681649500");
  await user.type(screen.getByLabelText("Título"), "Pedro Páramo");
  await user.type(screen.getByLabelText("Autor"), "Juan Rulfo");
  await user.type(screen.getByLabelText("Precio"), "42000.5");
  await user.type(screen.getByLabelText("Número de páginas"), "129");
  fireEvent.change(screen.getByLabelText("Fecha de publicación"), { target: { value: "1955-03-19T10:30" } });
  await elegirOpcion(user, "Género", "No ficción");
  await user.click(screen.getByRole("button", { name: "Adicionar libro" }));
  return user;
}

describe("AgregarLibro", () => {
  it("envía todos los atributos con su tipo, avisa el resultado y notifica al Observer", async () => {
    vi.mocked(crearLibro).mockImplementation(async (libro) => libro);
    const notificar = vi.spyOn(libroObservable, "notificar");

    await llenarYEnviar();

    expect(await screen.findByText("Libro adicionado")).toBeInTheDocument();
    expect(screen.getByText("«Pedro Páramo» quedó registrado con el ISBN 978-9681649500.")).toBeInTheDocument();
    expect(crearLibro).toHaveBeenCalledWith({
      isbn: "978-9681649500", titulo: "Pedro Páramo", autor: "Juan Rulfo", precio: 42000.5,
      numeroPaginas: 129, fechaPublicacion: "1955-03-19T10:30", genero: "NO_FICCION"
    });
    expect(notificar).toHaveBeenCalledTimes(1);
    expect(screen.getByLabelText("ISBN")).toHaveValue("");
  });

  it("valida en línea y no envía un formulario incompleto", async () => {
    const { user } = renderizar(<AgregarLibro />);
    await user.type(screen.getByLabelText("Precio"), "0");

    await user.click(screen.getByRole("button", { name: "Adicionar libro" }));

    expect(screen.getAllByText("Este campo es obligatorio.")).toHaveLength(4); // ISBN, título, autor y páginas
    expect(screen.getByText("Debe ser mayor que cero.")).toBeInTheDocument();
    expect(screen.getByText("Elige la fecha y la hora.")).toBeInTheDocument();
    expect(screen.getByLabelText("ISBN")).toHaveAttribute("aria-invalid", "true");
    expect(crearLibro).not.toHaveBeenCalled();

    // Al corregir un campo, su error desaparece.
    await user.type(screen.getByLabelText("ISBN"), "978-1");
    expect(screen.getByLabelText("ISBN")).not.toHaveAttribute("aria-invalid");
  });

  it("muestra el rechazo del servidor y conserva los datos escritos", async () => {
    vi.mocked(crearLibro).mockRejectedValue(new ErrorGraphQL("Ya existe un libro con el ISBN 978-9681649500."));

    await llenarYEnviar();

    expect(await screen.findByRole("alert")).toHaveTextContent("Ya existe un libro con el ISBN 978-9681649500.");
    expect(screen.getByLabelText("ISBN")).toHaveValue("978-9681649500");
  });
});
