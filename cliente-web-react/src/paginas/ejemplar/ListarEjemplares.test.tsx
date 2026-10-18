import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import ListarEjemplares from "./ListarEjemplares";
import { consultarRevisionEjemplares, listarEjemplaresFiltrados } from "../../graphql/servicioEjemplar";
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

  it("muestra los ejemplares en una grilla con el número de préstamos y el total del servidor", async () => {
    render(<ListarEjemplares />);

    expect(await screen.findByText("EJ-002")).toBeInTheDocument();
    expect(screen.getByRole("columnheader", { name: "Préstamos" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "9" })).toBeInTheDocument();
    expect(screen.getByText("1 ejemplar")).toBeInTheDocument();
    expect(listarEjemplaresFiltrados).toHaveBeenCalledWith("", "");
  });

  it("filtra en el servidor por estado e ISBN", async () => {
    const user = userEvent.setup();
    render(<ListarEjemplares />);
    await screen.findByText("EJ-002");

    await user.type(screen.getByLabelText("ISBN del libro"), "978-0307474728");
    await user.click(screen.getByRole("radio", { name: "Prestado" }));

    await waitFor(() => expect(listarEjemplaresFiltrados).toHaveBeenLastCalledWith("PRESTADO", "978-0307474728"));
  });
});
