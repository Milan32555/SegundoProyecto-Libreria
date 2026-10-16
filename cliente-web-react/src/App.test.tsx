import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { describe, expect, it } from "vitest";
import App from "./App";

function renderizarEn(ruta: string) {
  return render(
    <MemoryRouter initialEntries={[ruta]}>
      <App />
    </MemoryRouter>
  );
}

describe("Menú principal", () => {
  it("tiene una opción por cada caso de uso de Libro y de Ejemplar", () => {
    renderizarEn("/");
    const menu = screen.getByRole("navigation");

    for (const opcion of ["Adicionar", "Eliminar", "Actualizar", "Listar", "Buscar por criterios"]) {
      expect(within(menu).getAllByRole("link", { name: opcion })).toHaveLength(2);
    }
  });

  it("tiene el menú Ayuda con 'Acerca de...' (integrantes y versión)", async () => {
    const user = userEvent.setup();
    renderizarEn("/");

    expect(screen.getByText("Ayuda ▾")).toBeInTheDocument();
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

    expect(screen.getByRole("heading", { name: "Adicionar Ejemplar" })).toBeInTheDocument();
  });
});
