import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { beforeEach, describe, expect, it, vi } from "vitest";
import App from "./App";
import { consultarResumenInventario } from "./graphql/servicioResumen";
import { consultarRevisionLibros } from "./graphql/servicioLibro";
import { consultarRevisionEjemplares } from "./graphql/servicioEjemplar";
import { ErrorGraphQL } from "./graphql/clienteGraphQL";
import { ResumenInventario } from "./types";

vi.mock("./graphql/servicioLibro", () => ({ consultarRevisionLibros: vi.fn() }));
vi.mock("./graphql/servicioEjemplar", () => ({ consultarRevisionEjemplares: vi.fn() }));
vi.mock("./graphql/servicioResumen", () => ({ consultarResumenInventario: vi.fn() }));

/** Lo que respondería el servidor: totales y conteo por estado ya calculados. */
const RESUMEN: ResumenInventario = {
  totalLibros: 12,
  totalEjemplares: 20,
  ejemplaresPorEstado: [
    { estado: "DISPONIBLE", cantidad: 10, porcentaje: 50 },
    { estado: "PRESTADO", cantidad: 6, porcentaje: 30 },
    { estado: "DANIADO", cantidad: 3, porcentaje: 15 },
    { estado: "DADO_DE_BAJA", cantidad: 1, porcentaje: 5 }
  ]
};

function renderizarEn(ruta: string) {
  const user = userEvent.setup();
  render(
    <MemoryRouter initialEntries={[ruta]}>
      <App />
    </MemoryRouter>
  );
  return user;
}

const menu = () => screen.getByRole("navigation", { name: "Menú principal" });

describe("Aplicación", () => {
  beforeEach(() => {
    vi.mocked(consultarRevisionLibros).mockReturnValue(new Promise(() => {}));
    vi.mocked(consultarRevisionEjemplares).mockReturnValue(new Promise(() => {}));
    vi.mocked(consultarResumenInventario).mockResolvedValue(RESUMEN);
  });

  it("el Inicio muestra las cifras que calcula el servidor (la pantalla no cuenta nada)", async () => {
    renderizarEn("/");
    const cifras = screen.getByRole("region", { name: "Inventario" });

    expect(await within(cifras).findByText("12")).toBeInTheDocument();
    expect(within(cifras).getByText("20")).toBeInTheDocument();
    expect(within(cifras).getByText("10")).toBeInTheDocument();
    expect(within(cifras).getByText("6")).toBeInTheDocument();

    const estados = screen.getByRole("region", { name: "Estado de los ejemplares" });
    const fila = (nombre: string) => within(estados).getByText(nombre).closest("li");
    expect(fila("Disponibles")).toHaveTextContent("Disponibles1050 %");
    expect(fila("Dañados")).toHaveTextContent("Dañados315 %");
    expect(fila("Dados de baja")).toHaveTextContent("Dados de baja15 %");
    expect(consultarResumenInventario).toHaveBeenCalled();
  });

  it("avisa si no hay conexión y permite reintentar", async () => {
    vi.mocked(consultarResumenInventario).mockRejectedValueOnce(new ErrorGraphQL("No se pudo conectar con el servidor."));
    const user = renderizarEn("/");

    expect(await screen.findByText("No se pudo conectar con el servidor.")).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Reintentar" }));

    expect(await within(screen.getByRole("region", { name: "Inventario" })).findByText("12")).toBeInTheDocument();
    expect(screen.queryByText("No se pudo conectar con el servidor.")).not.toBeInTheDocument();
  });

  it("el menú principal tiene una opción por caso de uso de Libro y de Ejemplar", () => {
    renderizarEn("/");

    for (const opcion of ["Listar", "Consultar", "Adicionar", "Actualizar", "Eliminar"]) {
      expect(within(menu()).getAllByRole("link", { name: opcion })).toHaveLength(2);
    }
    expect(within(menu()).getByRole("list", { name: "Libros" })).toBeInTheDocument();
    expect(within(menu()).getByRole("list", { name: "Ejemplares" })).toBeInTheDocument();
  });

  it("tiene Ayuda > Acerca de... con los integrantes, la versión y el estado del servidor", async () => {
    vi.mocked(consultarRevisionLibros).mockResolvedValue(7);
    const user = renderizarEn("/");

    expect(within(menu()).getByRole("list", { name: "Ayuda" })).toBeInTheDocument();
    await user.click(within(menu()).getByRole("link", { name: "Acerca de..." }));

    expect(screen.getByRole("heading", { level: 1, name: "Acerca de" })).toBeInTheDocument();
    expect(screen.getByText("1.0.0")).toBeInTheDocument();
    for (const integrante of ["Misael Gallo Tangarife", "Sara Zambrano", "Santiago Guimel", "Alejandra González"]) {
      expect(screen.getByText(integrante)).toBeInTheDocument();
    }
    expect(await screen.findByText(/Servidor conectado · \d+ ms/)).toBeInTheDocument();

    vi.mocked(consultarRevisionLibros).mockRejectedValueOnce(new Error("sin red"));
    await user.click(screen.getByRole("button", { name: "Medir de nuevo" }));
    expect(await screen.findByText("Sin conexión con el servidor")).toBeInTheDocument();
  });

  it("cada opción abre una pantalla dedicada a un único caso de uso y marca la opción activa", async () => {
    const user = renderizarEn("/");

    const adicionarEjemplar = within(menu()).getAllByRole("link", { name: "Adicionar" })[1];
    await user.click(adicionarEjemplar);

    expect(screen.getByRole("heading", { level: 1, name: "Adicionar ejemplar" })).toBeInTheDocument();
    expect(adicionarEjemplar).toHaveAttribute("aria-current", "page");
    expect(document.title).toBe("Adicionar ejemplar · Librería");
  });

  it("en pantallas angostas el menú se abre en un cajón", async () => {
    const user = renderizarEn("/");

    await user.click(screen.getByRole("button", { name: "Abrir menú" }));
    const cajon = await screen.findByRole("dialog");
    await user.click(within(cajon).getAllByRole("link", { name: "Listar" })[0]);

    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    expect(screen.getByRole("heading", { level: 1, name: "Listar libros" })).toBeInTheDocument();
  });
});
