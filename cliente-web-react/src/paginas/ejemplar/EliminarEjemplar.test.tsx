import { screen, within } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import EliminarEjemplar from "./EliminarEjemplar";
import { buscarEjemplarPorCodigo, eliminarEjemplar } from "../../graphql/servicioEjemplar";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { renderizar } from "../../pruebas/utilidades";
import { Ejemplar } from "../../types";

vi.mock("../../graphql/servicioEjemplar", () => ({
  buscarEjemplarPorCodigo: vi.fn(),
  eliminarEjemplar: vi.fn(),
  consultarRevisionEjemplares: vi.fn()
}));

const EJ_020: Ejemplar = {
  codigo: "EJ-020", estado: "DADO_DE_BAJA", ubicacion: "Bodega", fechaIngreso: "2021-09-08T09:30:00",
  precioReposicion: 79000, numeroPrestamos: 14, isbnLibro: "978-8432311451"
};

async function buscar() {
  const { user } = renderizar(<EliminarEjemplar />);
  await user.type(screen.getByLabelText("Código del ejemplar"), "EJ-020");
  await user.click(screen.getByRole("button", { name: "Buscar" }));
  await screen.findByText("Ejemplar a eliminar");
  return user;
}

describe("EliminarEjemplar", () => {
  beforeEach(() => {
    vi.mocked(buscarEjemplarPorCodigo).mockResolvedValue(EJ_020);
    vi.mocked(eliminarEjemplar).mockResolvedValue(EJ_020);
  });

  it("muestra TODA la información y elimina solo al confirmar", async () => {
    const notificar = vi.spyOn(ejemplarObservable, "notificar");
    const user = await buscar();

    const ficha = screen.getByRole("article", { name: "Ejemplar EJ-020" });
    expect(within(ficha).getAllByText("Dado de baja")).toHaveLength(2);
    expect(within(ficha).getByText(/08\/09\/2021.*09:30/)).toBeInTheDocument();
    expect(within(ficha).getByText("14")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Eliminar ejemplar" }));
    await user.click(within(await screen.findByRole("alertdialog")).getByRole("button", { name: "Eliminar" }));

    expect(eliminarEjemplar).toHaveBeenCalledWith("EJ-020");
    expect(await screen.findByText("Ejemplar eliminado")).toBeInTheDocument();
    expect(notificar).toHaveBeenCalledTimes(1);
  });

  it("cancelar no elimina", async () => {
    const user = await buscar();

    await user.click(screen.getByRole("button", { name: "Eliminar ejemplar" }));
    await user.click(within(await screen.findByRole("alertdialog")).getByRole("button", { name: "Cancelar" }));
    await user.click(screen.getByRole("button", { name: "Cancelar" }));

    expect(screen.queryByText("Ejemplar a eliminar")).not.toBeInTheDocument();
    expect(eliminarEjemplar).not.toHaveBeenCalled();
  });

  it("muestra el motivo si el servidor rechaza la eliminación", async () => {
    vi.mocked(eliminarEjemplar).mockRejectedValue(new ErrorGraphQL("No se pudo conectar con el servidor."));
    const user = await buscar();

    await user.click(screen.getByRole("button", { name: "Eliminar ejemplar" }));
    await user.click(within(await screen.findByRole("alertdialog")).getByRole("button", { name: "Eliminar" }));

    expect(await screen.findByRole("alert")).toHaveTextContent("El servidor no permitió eliminar el ejemplar");
  });

  it("informa si el ejemplar no existe", async () => {
    vi.mocked(buscarEjemplarPorCodigo).mockResolvedValue(null);
    const { user } = renderizar(<EliminarEjemplar />);

    await user.type(screen.getByLabelText("Código del ejemplar"), "EJ-999");
    await user.click(screen.getByRole("button", { name: "Buscar" }));

    expect(await screen.findByText("No hay ningún ejemplar con el código «EJ-999».")).toBeInTheDocument();
  });
});
