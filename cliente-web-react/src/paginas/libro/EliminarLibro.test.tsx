import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import EliminarLibro from "./EliminarLibro";
import { buscarLibroPorIsbn, eliminarLibro } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { Libro } from "../../types";

vi.mock("../../graphql/servicioLibro", () => ({
  buscarLibroPorIsbn: vi.fn(),
  eliminarLibro: vi.fn(),
  consultarRevisionLibros: vi.fn()
}));

const DELIRIO: Libro = {
  isbn: "978-9584276193", titulo: "Delirio", autor: "Laura Restrepo",
  precio: 55000, numeroPaginas: 352, fechaPublicacion: "2004-03-01T00:00:00", genero: "FICCION"
};

async function buscar(isbn: string) {
  const user = userEvent.setup();
  render(<EliminarLibro />);
  await user.type(screen.getByLabelText("ISBN del libro a eliminar"), isbn);
  await user.click(screen.getByRole("button", { name: "Buscar" }));
  return user;
}

describe("EliminarLibro", () => {
  beforeEach(() => {
    vi.mocked(buscarLibroPorIsbn).mockResolvedValue(DELIRIO);
    vi.mocked(eliminarLibro).mockResolvedValue(DELIRIO);
  });

  it("muestra TODA la información del libro antes de eliminar", async () => {
    await buscar("978-9584276193");

    expect(await screen.findByText("Delirio")).toBeInTheDocument();
    expect(screen.getByText("Laura Restrepo")).toBeInTheDocument();
    expect(screen.getByText("352")).toBeInTheDocument();
    expect(screen.getAllByText("Ficción")).toHaveLength(2); // pastilla + dato "Género"
    expect(screen.getByText("por Laura Restrepo")).toBeInTheDocument();
    expect(screen.getByText(/55\.000/)).toBeInTheDocument();
    expect(screen.getByText(/2004/)).toBeInTheDocument();
    expect(eliminarLibro).not.toHaveBeenCalled();
  });

  it("elimina solo después de confirmar y notifica al Observer", async () => {
    const notificar = vi.spyOn(libroObservable, "notificar");
    const user = await buscar("978-9584276193");

    await user.click(await screen.findByRole("button", { name: "Confirmar eliminación" }));

    expect(eliminarLibro).toHaveBeenCalledWith("978-9584276193");
    expect(await screen.findByText(/eliminado correctamente/)).toBeInTheDocument();
    expect(notificar).toHaveBeenCalledTimes(1);
  });

  it("cancelar no elimina nada", async () => {
    const user = await buscar("978-9584276193");

    await user.click(await screen.findByRole("button", { name: "Cancelar" }));

    expect(screen.queryByText("Delirio")).not.toBeInTheDocument();
    expect(eliminarLibro).not.toHaveBeenCalled();
  });

  it("informa si el libro no existe", async () => {
    vi.mocked(buscarLibroPorIsbn).mockResolvedValue(null);

    await buscar("000");

    expect(await screen.findByText('No se encontró ningún libro con el ISBN "000".')).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Confirmar eliminación" })).not.toBeInTheDocument();
  });

  it("muestra el motivo cuando el servidor rechaza la eliminación", async () => {
    vi.mocked(eliminarLibro).mockRejectedValue(
      new ErrorGraphQL("No se puede eliminar el libro 978-9584276193 porque tiene 2 ejemplar(es) registrado(s).")
    );
    const user = await buscar("978-9584276193");

    await user.click(await screen.findByRole("button", { name: "Confirmar eliminación" }));

    expect(await screen.findByText(/tiene 2 ejemplar\(es\) registrado\(s\)/)).toBeInTheDocument();
  });
});
