import { screen, within } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import EliminarLibro from "./EliminarLibro";
import { buscarLibroPorIsbn, eliminarLibro } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { renderizar } from "../../pruebas/utilidades";
import { Libro } from "../../types";

vi.mock("../../graphql/servicioLibro", () => ({
  buscarLibroPorIsbn: vi.fn(),
  eliminarLibro: vi.fn(),
  consultarRevisionLibros: vi.fn()
}));

const DELIRIO: Libro = {
  isbn: "978-8420401751", titulo: "Delirio", autor: "Laura Restrepo",
  precio: 55000, numeroPaginas: 352, fechaPublicacion: "2004-03-01T10:30:00", genero: "FICCION"
};

async function buscar(isbn: string) {
  const { user } = renderizar(<EliminarLibro />);
  await user.type(screen.getByLabelText("ISBN del libro"), isbn);
  await user.click(screen.getByRole("button", { name: "Buscar" }));
  return user;
}

describe("EliminarLibro", () => {
  beforeEach(() => {
    vi.mocked(buscarLibroPorIsbn).mockResolvedValue(DELIRIO);
    vi.mocked(eliminarLibro).mockResolvedValue(DELIRIO);
  });

  it("muestra TODA la información del libro (fecha con hora) antes de eliminar", async () => {
    await buscar("978-8420401751");

    const ficha = await screen.findByRole("article", { name: "Libro Delirio" });
    expect(within(ficha).getByRole("heading", { name: "Delirio" })).toBeInTheDocument();
    expect(within(ficha).getAllByText("Laura Restrepo")).toHaveLength(2); // cabecera + dato "Autor"
    expect(within(ficha).getByText("978-8420401751")).toBeInTheDocument();
    expect(within(ficha).getByText("352")).toBeInTheDocument();
    expect(within(ficha).getByText("Ficción")).toBeInTheDocument();
    expect(within(ficha).getByText(/55\.000/)).toBeInTheDocument();
    expect(within(ficha).getByText(/01\/03\/2004.*10:30/)).toBeInTheDocument();
    expect(buscarLibroPorIsbn).toHaveBeenCalledWith("978-8420401751");
    expect(eliminarLibro).not.toHaveBeenCalled();
  });

  it("elimina solo después de confirmar en el diálogo y notifica al Observer", async () => {
    const notificar = vi.spyOn(libroObservable, "notificar");
    const user = await buscar("978-8420401751");

    await user.click(await screen.findByRole("button", { name: "Eliminar libro" }));
    const dialogo = await screen.findByRole("alertdialog", { name: "¿Eliminar «Delirio»?" });
    expect(eliminarLibro).not.toHaveBeenCalled();
    await user.click(within(dialogo).getByRole("button", { name: "Eliminar" }));

    expect(eliminarLibro).toHaveBeenCalledWith("978-8420401751");
    expect(await screen.findByText("Libro eliminado")).toBeInTheDocument();
    expect(notificar).toHaveBeenCalledTimes(1);
    expect(screen.queryByRole("article")).not.toBeInTheDocument();
    expect(screen.getByLabelText("ISBN del libro")).toHaveValue("");
  });

  it("cancelar en el diálogo no elimina nada", async () => {
    const user = await buscar("978-8420401751");

    await user.click(await screen.findByRole("button", { name: "Eliminar libro" }));
    await user.click(within(await screen.findByRole("alertdialog")).getByRole("button", { name: "Cancelar" }));

    expect(screen.queryByRole("alertdialog")).not.toBeInTheDocument();
    expect(screen.getByRole("article", { name: "Libro Delirio" })).toBeInTheDocument();
    expect(eliminarLibro).not.toHaveBeenCalled();
  });

  it("cancelar en la pantalla descarta el libro encontrado", async () => {
    const user = await buscar("978-8420401751");

    await user.click(await screen.findByRole("button", { name: "Cancelar" }));

    expect(screen.queryByRole("article")).not.toBeInTheDocument();
    expect(eliminarLibro).not.toHaveBeenCalled();
  });

  it("informa si el libro no existe", async () => {
    vi.mocked(buscarLibroPorIsbn).mockResolvedValue(null);

    await buscar("000");

    expect(await screen.findByText("No hay ningún libro con el ISBN «000».")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Eliminar libro" })).not.toBeInTheDocument();
  });

  it("muestra el motivo cuando el servidor rechaza la eliminación (libro con ejemplares)", async () => {
    vi.mocked(eliminarLibro).mockRejectedValue(
      new ErrorGraphQL("No se puede eliminar el libro 978-8420401751 porque tiene 2 ejemplar(es) registrado(s).")
    );
    const user = await buscar("978-8420401751");

    await user.click(await screen.findByRole("button", { name: "Eliminar libro" }));
    await user.click(within(await screen.findByRole("alertdialog")).getByRole("button", { name: "Eliminar" }));

    const alerta = await screen.findByRole("alert");
    expect(alerta).toHaveTextContent("El servidor no permitió eliminar el libro");
    expect(alerta).toHaveTextContent("tiene 2 ejemplar(es) registrado(s)");
    expect(screen.getByRole("article", { name: "Libro Delirio" })).toBeInTheDocument();
  });

  it("muestra un error si no hay conexión al buscar", async () => {
    vi.mocked(buscarLibroPorIsbn).mockRejectedValue(new ErrorGraphQL("No se pudo conectar con el servidor."));

    await buscar("978-8420401751");

    expect(await screen.findByRole("alert")).toHaveTextContent("No se pudo buscar el libro");
  });

  it("no busca con el campo vacío", async () => {
    const { user } = renderizar(<EliminarLibro />);

    await user.click(screen.getByRole("button", { name: "Buscar" }));

    expect(screen.getByText("Este campo es obligatorio.")).toBeInTheDocument();
    expect(buscarLibroPorIsbn).not.toHaveBeenCalled();
  });
});
