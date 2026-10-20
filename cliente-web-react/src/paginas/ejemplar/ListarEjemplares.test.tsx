import { act, screen, waitFor, within } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import ListarEjemplares from "./ListarEjemplares";
import { consultarRevisionEjemplares, listarEjemplaresFiltrados } from "../../graphql/servicioEjemplar";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { renderizar } from "../../pruebas/utilidades";
import { Ejemplar } from "../../types";

vi.mock("../../graphql/servicioEjemplar", () => ({
  listarEjemplaresFiltrados: vi.fn(),
  consultarRevisionEjemplares: vi.fn()
}));

const EJ_002: Ejemplar = {
  codigo: "EJ-002", estado: "PRESTADO", ubicacion: "Estante A1", fechaIngreso: "2024-02-10T09:05:00",
  precioReposicion: 65000, numeroPrestamos: 9, isbnLibro: "978-0307474728"
};

describe("ListarEjemplares", () => {
  beforeEach(() => {
    vi.mocked(consultarRevisionEjemplares).mockReturnValue(new Promise(() => {}));
    vi.mocked(listarEjemplaresFiltrados).mockResolvedValue({ ejemplares: [EJ_002], total: 1 });
  });

  it("muestra los ejemplares en una grilla con su estado, préstamos y el total del servidor", async () => {
    renderizar(<ListarEjemplares />);

    expect(await screen.findByText("EJ-002")).toBeInTheDocument();
    const tabla = screen.getByRole("table", { name: "Ejemplares del inventario" });
    expect(within(tabla).getByRole("columnheader", { name: "Préstamos" })).toBeInTheDocument();
    expect(within(tabla).getByRole("cell", { name: "9" })).toBeInTheDocument();
    expect(within(tabla).getByText("Prestado")).toHaveClass("insignia-estado");
    expect(screen.getByText("1 ejemplar")).toBeInTheDocument();
    expect(listarEjemplaresFiltrados).toHaveBeenCalledWith("", "");
  });

  it("filtra en el servidor por estado e ISBN, y limpia los filtros", async () => {
    const { user } = renderizar(<ListarEjemplares />);
    await screen.findByText("EJ-002");

    await user.type(screen.getByLabelText("ISBN del libro"), "978-0307474728");
    await user.click(screen.getByRole("radio", { name: "Prestado" }));
    await waitFor(() => expect(listarEjemplaresFiltrados).toHaveBeenLastCalledWith("PRESTADO", "978-0307474728"));

    await user.click(screen.getByRole("button", { name: "Limpiar filtros" }));
    await waitFor(() => expect(listarEjemplaresFiltrados).toHaveBeenLastCalledWith("", ""));
    expect(screen.getByRole("radio", { name: "Todos" })).toBeChecked();
  });

  it("Observer: se refresca sola cuando el sujeto notifica", async () => {
    renderizar(<ListarEjemplares />);
    await screen.findByText("EJ-002");
    vi.mocked(listarEjemplaresFiltrados).mockResolvedValue({ ejemplares: [EJ_002, { ...EJ_002, codigo: "EJ-021" }], total: 2 });

    act(() => ejemplarObservable.notificar());

    expect(await screen.findByText("EJ-021")).toBeInTheDocument();
    expect(screen.getByText("2 ejemplares")).toBeInTheDocument();
  });

  it("muestra el error de carga y el estado vacío con filtro", async () => {
    vi.mocked(listarEjemplaresFiltrados).mockRejectedValueOnce(new ErrorGraphQL("No se pudo conectar con el servidor."));
    const { user } = renderizar(<ListarEjemplares />);
    expect(await screen.findByText("No se pudo cargar la lista")).toBeInTheDocument();

    vi.mocked(listarEjemplaresFiltrados).mockResolvedValue({ ejemplares: [], total: 0 });
    await user.click(screen.getByRole("radio", { name: "Dañado" }));

    expect(await screen.findByText("Ningún ejemplar coincide con el filtro")).toBeInTheDocument();
  });
});
