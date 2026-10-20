import { screen, within } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import ActualizarEjemplar from "./ActualizarEjemplar";
import { actualizarEjemplar, buscarEjemplarPorCodigo } from "../../graphql/servicioEjemplar";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { elegirOpcion, renderizar } from "../../pruebas/utilidades";
import { Ejemplar } from "../../types";

vi.mock("../../graphql/servicioEjemplar", () => ({
  buscarEjemplarPorCodigo: vi.fn(),
  actualizarEjemplar: vi.fn(),
  consultarRevisionEjemplares: vi.fn()
}));

const EJ_001: Ejemplar = {
  codigo: "EJ-001", estado: "DISPONIBLE", ubicacion: "Estante A1",
  fechaIngreso: "2024-02-10T09:00:00", precioReposicion: 65000, numeroPrestamos: 4, isbnLibro: "978-0307474728"
};

async function buscar() {
  const { user } = renderizar(<ActualizarEjemplar />);
  await user.type(screen.getByLabelText("Código del ejemplar"), "EJ-001");
  await user.click(screen.getByRole("button", { name: "Buscar" }));
  await screen.findByText("Datos actuales");
  return user;
}

describe("ActualizarEjemplar", () => {
  it("busca primero y muestra TODA la información actual; préstamos se ve pero no se edita", async () => {
    vi.mocked(buscarEjemplarPorCodigo).mockResolvedValue(EJ_001);

    await buscar();

    const ficha = screen.getByRole("article", { name: "Ejemplar EJ-001" });
    expect(within(ficha).getByText("Estante A1")).toBeInTheDocument();
    expect(within(ficha).getByText(/10\/02\/2024.*09:00/)).toBeInTheDocument();
    expect(within(ficha).getAllByText("978-0307474728").length).toBeGreaterThan(0);
    expect(screen.getByRole("combobox", { name: "Estado" })).toHaveTextContent("Disponible");
    expect(screen.getByLabelText("Ubicación")).toHaveValue("Estante A1");
    expect(screen.getByLabelText("Fecha de ingreso")).toHaveValue("2024-02-10T09:00");
    expect(screen.getByLabelText("Precio de reposición")).toHaveValue(65000);
    const prestamos = screen.getByLabelText("Número de préstamos");
    expect(prestamos).toHaveValue("4");
    expect(prestamos).toHaveAttribute("readonly");
    expect(screen.getByText("Lo calcula el servidor: suma 1 cada vez que el ejemplar pasa a Prestado.")).toBeInTheDocument();
  });

  it("guarda sin enviar préstamos y muestra el valor que calculó el servidor", async () => {
    vi.mocked(buscarEjemplarPorCodigo).mockResolvedValue(EJ_001);
    vi.mocked(actualizarEjemplar).mockResolvedValue({ ...EJ_001, estado: "PRESTADO", ubicacion: "Mostrador", numeroPrestamos: 5 });
    const notificar = vi.spyOn(ejemplarObservable, "notificar");
    const user = await buscar();

    await elegirOpcion(user, "Estado", "Prestado");
    await user.clear(screen.getByLabelText("Ubicación"));
    await user.type(screen.getByLabelText("Ubicación"), "Mostrador");
    await user.click(screen.getByRole("button", { name: "Guardar cambios" }));

    expect(await screen.findByText("Cambios guardados")).toBeInTheDocument();
    expect(screen.getByText("EJ-001 quedó prestado con 5 préstamos.")).toBeInTheDocument();
    expect(actualizarEjemplar).toHaveBeenCalledWith("EJ-001", {
      estado: "PRESTADO", ubicacion: "Mostrador", fechaIngreso: "2024-02-10T09:00", precioReposicion: 65000
    });
    expect(notificar).toHaveBeenCalledTimes(1);
    const guardado = screen.getByRole("article", { name: "Ejemplar EJ-001" });
    expect(within(guardado).getByText("Datos guardados")).toBeInTheDocument();
    expect(within(guardado).getByText("5")).toBeInTheDocument();
  });

  it("valida en línea y muestra el rechazo del servidor", async () => {
    vi.mocked(buscarEjemplarPorCodigo).mockResolvedValue(EJ_001);
    vi.mocked(actualizarEjemplar).mockRejectedValue(new ErrorGraphQL("La fecha de ingreso no puede ser futura."));
    const user = await buscar();

    await user.clear(screen.getByLabelText("Precio de reposición"));
    await user.click(screen.getByRole("button", { name: "Guardar cambios" }));
    expect(screen.getByText("Este campo es obligatorio.")).toBeInTheDocument();
    expect(actualizarEjemplar).not.toHaveBeenCalled();

    await user.type(screen.getByLabelText("Precio de reposición"), "70000");
    await user.click(screen.getByRole("button", { name: "Guardar cambios" }));
    expect(await screen.findByRole("alert")).toHaveTextContent("La fecha de ingreso no puede ser futura.");
  });

  it("informa si el ejemplar no existe", async () => {
    vi.mocked(buscarEjemplarPorCodigo).mockResolvedValue(null);
    const { user } = renderizar(<ActualizarEjemplar />);

    await user.type(screen.getByLabelText("Código del ejemplar"), "EJ-999");
    await user.click(screen.getByRole("button", { name: "Buscar" }));

    expect(await screen.findByText("No hay ningún ejemplar con el código «EJ-999».")).toBeInTheDocument();
  });
});
