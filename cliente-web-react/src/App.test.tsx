import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import App from "./App";
import { consultarResumenInventario } from "./graphql/servicioResumen";
import { ErrorGraphQL } from "./graphql/clienteGraphQL";
import { ResumenInventario } from "./types";

vi.mock("./graphql/servicioLibro", () => ({
  consultarRevisionLibros: vi.fn()
}));
vi.mock("./graphql/servicioEjemplar", () => ({
  consultarRevisionEjemplares: vi.fn()
}));
vi.mock("./graphql/servicioResumen", () => ({
  consultarResumenInventario: vi.fn()
}));

/** Lo que respondería el servidor: totales y conteo por estado ya calculados. */
const RESUMEN: ResumenInventario = {
  totalLibros: 2,
  totalEjemplares: 3,
  ejemplaresPorEstado: [
    { estado: "DISPONIBLE", cantidad: 2, porcentaje: 66.67 },
    { estado: "PRESTADO", cantidad: 1, porcentaje: 33.33 },
    { estado: "DANIADO", cantidad: 0, porcentaje: 0 },
    { estado: "DADO_DE_BAJA", cantidad: 0, porcentaje: 0 }
  ]
};

function renderizarEn(ruta: string) {
  return render(
    <MemoryRouter initialEntries={[ruta]}>
      <App />
    </MemoryRouter>
  );
}

describe("Ventana principal", () => {
  beforeEach(async () => {
    const libro = await import("./graphql/servicioLibro");
    const ejemplarServicio = await import("./graphql/servicioEjemplar");
    vi.mocked(libro.consultarRevisionLibros).mockReturnValue(new Promise(() => {}));
    vi.mocked(ejemplarServicio.consultarRevisionEjemplares).mockReturnValue(new Promise(() => {}));
    vi.mocked(consultarResumenInventario).mockResolvedValue(RESUMEN);
  });

  it("muestra el resumen del inventario que calcula el servidor (no cuenta en la pantalla)", async () => {
    renderizarEn("/");
    const inventario = screen.getByRole("region", { name: "Inventario" });

    expect(await within(inventario).findByText("2")).toBeInTheDocument(); // títulos
    expect(within(inventario).getByText("3")).toBeInTheDocument(); // ejemplares

    const estados = screen.getByRole("region", { name: "Estado de los ejemplares" });
    const cantidad = (estado: string) => within(estados).getByText(estado).closest("li");
    expect(cantidad("Disponibles")).toHaveTextContent("Disponibles2");
    expect(cantidad("Prestados")).toHaveTextContent("Prestados1");
    expect(cantidad("Dañados")).toHaveTextContent("Dañados0");
    expect(cantidad("Dados de baja")).toHaveTextContent("Dados de baja0");
    expect(consultarResumenInventario).toHaveBeenCalled();
  });

  it("avisa si no hay conexión con el servidor", async () => {
    vi.mocked(consultarResumenInventario).mockRejectedValue(new ErrorGraphQL("No se pudo conectar con el servidor."));

    renderizarEn("/");

    expect(await screen.findByText("No se pudo conectar con el servidor.")).toBeInTheDocument();
  });

  it("el menú tiene una opción por cada caso de uso de Libro y de Ejemplar", () => {
    renderizarEn("/");
    const menu = screen.getByRole("navigation");

    for (const opcion of ["Adicionar", "Eliminar", "Actualizar", "Listar", "Buscar por criterios"]) {
      expect(within(menu).getAllByRole("link", { name: opcion })).toHaveLength(2);
    }
  });

  it("tiene el menú Ayuda con 'Acerca de...' (integrantes y versión)", async () => {
    const user = userEvent.setup();
    renderizarEn("/");

    expect(within(screen.getByRole("navigation")).getByRole("button", { name: "Ayuda" })).toBeInTheDocument();
    await user.click(screen.getByRole("link", { name: "Acerca de..." }));

    expect(screen.getByRole("heading", { name: "Acerca de..." })).toBeInTheDocument();
    expect(screen.getByText(/1\.0\.0/)).toBeInTheDocument();
    for (const integrante of ["Misael Gallo Tangarife", "Sara Zambrano", "Santiago Guimel", "Alejandra González"]) {
      expect(screen.getByText(integrante)).toBeInTheDocument();
    }
  });

  it("cada opción abre una pantalla dedicada a un único caso de uso", async () => {
    const user = userEvent.setup();
    renderizarEn("/");

    await user.click(within(screen.getByRole("navigation")).getAllByRole("link", { name: "Adicionar" })[1]);

    expect(screen.getByRole("heading", { name: "Nuevo ejemplar" })).toBeInTheDocument();
  });
});
