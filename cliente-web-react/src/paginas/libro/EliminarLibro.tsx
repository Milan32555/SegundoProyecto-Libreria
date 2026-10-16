import { FormEvent, useState } from "react";
import { buscarLibroPorIsbn, eliminarLibro } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { Libro } from "../../types";

/**
 * Caso de uso: Eliminar Libro. Primero se busca el objeto y se muestra TODA su información;
 * solo después de confirmar se ejecuta la eliminación (como exige el enunciado).
 */
export default function EliminarLibro() {
  const [isbn, setIsbn] = useState("");
  const [libro, setLibro] = useState<Libro | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [exito, setExito] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function buscar(e: FormEvent) {
    e.preventDefault();
    setError(null); setExito(null); setLibro(null);
    setCargando(true);
    try {
      const resultado = await buscarLibroPorIsbn(isbn);
      if (!resultado) {
        setError(`No se encontró ningún libro con el ISBN "${isbn}".`);
      } else {
        setLibro(resultado);
      }
    } catch (err) {
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
    } finally {
      setCargando(false);
    }
  }

  async function confirmarEliminacion() {
    if (!libro) return;
    setCargando(true);
    setError(null);
    try {
      await eliminarLibro(libro.isbn);
      setExito(`Libro "${libro.titulo}" (ISBN ${libro.isbn}) eliminado correctamente.`);
      libroObservable.notificar();
      setLibro(null);
      setIsbn("");
    } catch (err) {
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
    } finally {
      setCargando(false);
    }
  }

  return (
    <div className="tarjeta">
      <h1>Eliminar Libro</h1>
      {error && <p className="mensaje-error">{error}</p>}
      {exito && <p className="mensaje-exito">{exito}</p>}

      <form onSubmit={buscar}>
        <label>ISBN del libro a eliminar
          <input value={isbn} onChange={(e) => setIsbn(e.target.value)} required />
        </label>
        <button type="submit" disabled={cargando}>Buscar</button>
      </form>

      {libro && (
        <>
          <div className="ficha-objeto">
            <p><strong>ISBN:</strong> {libro.isbn}</p>
            <p><strong>Título:</strong> {libro.titulo}</p>
            <p><strong>Autor:</strong> {libro.autor}</p>
            <p><strong>Precio:</strong> ${libro.precio.toLocaleString()}</p>
            <p><strong>Páginas:</strong> {libro.numeroPaginas}</p>
            <p><strong>Fecha de publicación:</strong> {libro.fechaPublicacion}</p>
            <p><strong>Género:</strong> {libro.genero}</p>
          </div>
          <div className="acciones">
            <button className="peligro" onClick={confirmarEliminacion} disabled={cargando}>
              Confirmar eliminación
            </button>
            <button className="secundario" onClick={() => setLibro(null)}>Cancelar</button>
          </div>
        </>
      )}
    </div>
  );
}
