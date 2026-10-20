import { ReactElement } from "react";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter } from "react-router-dom";
import { ProveedorAvisos } from "../componentes/ui/Avisos";
import { ProveedorAyudas } from "../componentes/ui/Ayuda";

/** Renderiza una pantalla con lo que necesita de App: rutas, avisos (toasts) y tooltips. */
export function renderizar(pantalla: ReactElement, { ruta = "/" }: { ruta?: string } = {}) {
  const user = userEvent.setup();
  const resultado = render(
    <MemoryRouter initialEntries={[ruta]}>
      <ProveedorAyudas>
        <ProveedorAvisos>{pantalla}</ProveedorAvisos>
      </ProveedorAyudas>
    </MemoryRouter>
  );
  return { user, ...resultado };
}

type Usuario = ReturnType<typeof userEvent.setup>;

/** Abre una lista desplegable (Radix Select) por su etiqueta y elige una opción. */
export async function elegirOpcion(user: Usuario, etiqueta: string, opcion: string) {
  await user.click(screen.getByRole("combobox", { name: etiqueta }));
  await user.click(await screen.findByRole("option", { name: opcion }));
}
