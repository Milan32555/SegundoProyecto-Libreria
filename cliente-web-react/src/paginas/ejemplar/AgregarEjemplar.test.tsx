import { fireEvent, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import AgregarEjemplar from "./AgregarEjemplar";
import { crearEjemplar } from "../../graphql/servicioEjemplar";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { elegirOpcion, renderizar } from "../../pruebas/utilidades";

vi.mock("../../graphql/servicioEjemplar", () => ({
  crearEjemplar: vi.fn(),
  consultarRevisionEjemplares: vi.fn()
}));

async function llenarFormulario(prestamos: string) {
  const resultado = renderizar(<AgregarEjemplar />);
  const { user } = resultado;
  await user.type(screen.getByLabelText("Código del ejemplar"), "EJ-100");
  await user.type(screen.getByLabelText("ISBN del libro"), "978-0307474728");
  await user.type(screen.getByLabelText("Ubicación"), "Estante C3");
  fireEvent.change(screen.getByLabelText("Fecha de ingreso"), { target: { value: "2024-05-10T14:30" } });
  await user.type(screen.getByLabelText("Precio de reposición"), "45000");
  await user.clear(screen.getByLabelText("Número de préstamos"));
  await user.type(screen.getByLabelText("Número de préstamos"), prestamos);
  await elegirOpcion(user, "Estado", "Prestado");
  await user.click(screen.getByRole("button", { name: "Adicionar ejemplar" }));
  return user;
}

describe("AgregarEjemplar", () => {
  it("envía todos los atributos (incluido el número de préstamos) y notifica al Observer", async () => {
    vi.mocked(crearEjemplar).mockImplementation(async (ejemplar) => ejemplar);
    const notificar = vi.spyOn(ejemplarObservable, "notificar");

    await llenarFormulario("3");

    expect(await screen.findByText("Ejemplar adicionado")).toBeInTheDocument();
    expect(crearEjemplar).toHaveBeenCalledWith({
      codigo: "EJ-100", estado: "PRESTADO", ubicacion: "Estante C3", fechaIngreso: "2024-05-10T14:30",
      precioReposicion: 45000, numeroPrestamos: 3, isbnLibro: "978-0307474728"
    });
    expect(notificar).toHaveBeenCalledTimes(1);
    expect(screen.getByLabelText("Número de préstamos")).toHaveValue(0);
    expect(screen.getByRole("combobox", { name: "Estado" })).toHaveTextContent("Disponible");
  });

  it("valida el formato antes de enviar (préstamos negativos, campos vacíos)", async () => {
    await llenarFormulario("-2");

    expect(screen.getByText("No puede ser negativo.")).toBeInTheDocument();
    expect(crearEjemplar).not.toHaveBeenCalled();
  });

  it("muestra el rechazo del servidor y conserva los datos", async () => {
    vi.mocked(crearEjemplar).mockRejectedValue(new ErrorGraphQL("No existe un libro con el ISBN 978-0307474728."));

    await llenarFormulario("2");

    expect(await screen.findByRole("alert")).toHaveTextContent("No existe un libro con el ISBN 978-0307474728.");
    expect(screen.getByLabelText("Código del ejemplar")).toHaveValue("EJ-100");
  });
});
