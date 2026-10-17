import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import App from "./App";
import { listarLibros } from "./graphql/servicioLibro";
import { listarEjemplares } from "./graphql/servicioEjemplar";
import { ErrorGraphQL } from "./graphql/clienteGraphQL";
import { Ejemplar, Libro } from "./types";

vi.mock("./graphql/servicioLibro", () => ({
  listarLibros: vi.fn(),
  consultarRevisionLibros: vi.fn()
}));
vi.mock("./graphql/servicioEjemplar", () => ({
  listarEjemplares: vi.fn(),
  consultarRevisionEjemplares: vi.fn()
}));

const LIBRO: Libro = {
  isbn: "1", titulo: "Delirio", autor: "Laura Restrepo", precio: 55000,
  numeroPaginas: 352, fechaPublicacion: "2004-03-01T00:00:00", genero: "FICCION"
};
const ejemplar = (codigo: string, estado: Ejemplar["estado"]): Ejemplar => ({
  codigo, estado, ubicacion: "Estante", fechaIngreso: "2024-01-01T00:00:00", precioReposicion: 1000, isbnLibro: "1"
});

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
    vi.mocked(listarLibros).mockResolvedValue([LIBRO, { ...LIBRO, isbn: "2" }]);
    vi.mocked(listarEjemplares).mockResolvedValue([
      ejemplar("EJ-1", "DISPONIBLE"), ejemplar("EJ-2", "DISPONIBLE"), ejemplar("EJ-3", "PRESTADO")
    ]);
  });

  it("muestra el resumen del inventario que trae del servidor", async () => {
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
  });

  it("avisa si no hay conexión con el servidor", async () => {
    vi.mocked(listarLibros).mockRejectedValue(new ErrorGraphQL("No se pudo conectar con el servidor."));

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
