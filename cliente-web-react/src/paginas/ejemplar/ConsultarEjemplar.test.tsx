import { screen, within } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import ConsultarEjemplar from "./ConsultarEjemplar";
import { buscarEjemplarPorCodigo } from "../../graphql/servicioEjemplar";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { renderizar } from "../../pruebas/utilidades";
import { Ejemplar } from "../../types";

vi.mock("../../graphql/servicioEjemplar", () => ({
  buscarEjemplarPorCodigo: vi.fn()
}));

const EJ_007: Ejemplar = {
  codigo: "EJ-007", estado: "DANIADO", ubicacion: "Bodega", fechaIngreso: "2023-11-14T15:10:00",
  precioReposicion: 39000, numeroPrestamos: 11, isbnLibro: "978-9589012338"
};

async function buscar(codigo: string) {
  const { user } = renderizar(<ConsultarEjemplar />);
  await user.type(screen.getByLabelText("Código del ejemplar"), codigo);
  await user.click(screen.getByRole("button", { name: "Buscar" }));
}

describe("ConsultarEjemplar", () => {
  it("consulta UN SOLO ejemplar por código y muestra todos sus atributos", async () => {
    vi.mocked(buscarEjemplarPorCodigo).mockResolvedValue(EJ_007);

    await buscar("ej-007");

    const ficha = await screen.findByRole("article", { name: "Ejemplar EJ-007" });
    expect(within(ficha).getAllByText("Dañado")).toHaveLength(2); // cabecera + dato "Estado"
    expect(within(ficha).getByText("Bodega")).toBeInTheDocument();
    expect(within(ficha).getByText("11")).toBeInTheDocument();
    expect(within(ficha).getByText(/14\/11\/2023.*15:10/)).toBeInTheDocument();
    expect(buscarEjemplarPorCodigo).toHaveBeenCalledWith("ej-007");
  });

  it("informa cuando no existe o cuando falla la conexión", async () => {
    vi.mocked(buscarEjemplarPorCodigo).mockResolvedValueOnce(null);
    await buscar("EJ-999");
    expect(await screen.findByText("No hay ningún ejemplar con el código «EJ-999».")).toBeInTheDocument();
  });

  it("muestra el error del servidor", async () => {
    vi.mocked(buscarEjemplarPorCodigo).mockRejectedValue(new ErrorGraphQL("No se pudo conectar con el servidor."));
    await buscar("EJ-001");
    expect(await screen.findByRole("alert")).toHaveTextContent("No se pudo conectar con el servidor.");
  });
});
