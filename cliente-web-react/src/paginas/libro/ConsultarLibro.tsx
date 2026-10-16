import { FormEvent, useState } from "react";
import { buscarLibroPorIsbn } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { Libro } from "../../types";

/** Caso de uso: Buscar/Consultar UN SOLO Libro a partir de un criterio (el ISBN). */
export default function ConsultarLibro() {
  const [isbn, setIsbn] = useState("");
  const [libro, setLibro] = useState<Libro | null>(null);
  const [buscado, setBuscado] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function buscar(e: FormEvent) {
    e.preventDefault();
    setError(null); setLibro(null); setBuscado(false);
    setCargando(true);
    try {
      const resultado = await buscarLibroPorIsbn(isbn);
      setLibro(resultado);
      setBuscado(true);
    } catch (err) {
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
    } finally {
      setCargando(false);
    }
  }

  return (
    <div className="tarjeta">
      <h1>Consultar Libro</h1>
      {error && <p className="mensaje-error">{error}</p>}
      <form onSubmit={buscar}>
        <label>ISBN
          <input value={isbn} onChange={(e) => setIsbn(e.target.value)} required />
        </label>
        <button type="submit" disabled={cargando}>Buscar</button>
      </form>

      {buscado && !libro && (
        <p style={{ marginTop: "1rem" }}>No se encontró ningún libro con el ISBN "{isbn}".</p>
      )}

      {libro && (
        <div className="ficha-objeto">
          <p><strong>ISBN:</strong> {libro.isbn}</p>
          <p><strong>Título:</strong> {libro.titulo}</p>
          <p><strong>Autor:</strong> {libro.autor}</p>
          <p><strong>Precio:</strong> ${libro.precio.toLocaleString()}</p>
          <p><strong>Páginas:</strong> {libro.numeroPaginas}</p>
          <p><strong>Fecha de publicación:</strong> {libro.fechaPublicacion}</p>
          <p><strong>Género:</strong> {libro.genero}</p>
        </div>
      )}
    </div>
  );
}
