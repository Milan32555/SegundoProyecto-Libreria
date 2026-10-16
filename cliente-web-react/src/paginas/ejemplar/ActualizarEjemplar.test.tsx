import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import ActualizarEjemplar from "./ActualizarEjemplar";
import { actualizarEjemplar, buscarEjemplarPorCodigo } from "../../graphql/servicioEjemplar";
import { ejemplarObservable } from "../../observer/Observable";
import { Ejemplar } from "../../types";

vi.mock("../../graphql/servicioEjemplar", () => ({
  buscarEjemplarPorCodigo: vi.fn(),
  actualizarEjemplar: vi.fn(),
  consultarRevisionEjemplares: vi.fn()
}));

const EJ_001: Ejemplar = {
  codigo: "EJ-001", estado: "DISPONIBLE", ubicacion: "Estante A1",
  fechaIngreso: "2024-02-10T09:00:00", precioReposicion: 65000, isbnLibro: "978-0307474728"
};

describe("ActualizarEjemplar", () => {
  it("busca primero, muestra los datos actuales y luego guarda los cambios", async () => {
    vi.mocked(buscarEjemplarPorCodigo).mockResolvedValue(EJ_001);
    vi.mocked(actualizarEjemplar).mockResolvedValue({ ...EJ_001, estado: "PRESTADO" });
    const notificar = vi.spyOn(ejemplarObservable, "notificar");
    const user = userEvent.setup();
    render(<ActualizarEjemplar />);

    await user.type(screen.getByLabelText("Código del ejemplar a actualizar"), "EJ-001");
    await user.click(screen.getByRole("button", { name: "Buscar" }));

    // Datos actuales visibles antes de modificar.
    expect(await screen.findByRole("radio", { name: "Disponible" })).toBeChecked();
    expect(screen.getByLabelText("Ubicación")).toHaveValue("Estante A1");
    expect(screen.getByLabelText("Fecha de ingreso")).toHaveValue("2024-02-10T09:00");
    expect(screen.getByLabelText("Precio de reposición")).toHaveValue(65000);
    expect(screen.getByText("978-0307474728")).toBeInTheDocument();

    await user.click(screen.getByRole("radio", { name: "Prestado" }));
    await user.clear(screen.getByLabelText("Ubicación"));
    await user.type(screen.getByLabelText("Ubicación"), "Mostrador");
    await user.click(screen.getByRole("button", { name: "Guardar cambios" }));

    expect(await screen.findByText('Ejemplar "EJ-001" actualizado correctamente.')).toBeInTheDocument();
    expect(actualizarEjemplar).toHaveBeenCalledWith("EJ-001", {
      estado: "PRESTADO", ubicacion: "Mostrador", fechaIngreso: "2024-02-10T09:00", precioReposicion: 65000
    });
    expect(notificar).toHaveBeenCalledTimes(1);
  });
});
