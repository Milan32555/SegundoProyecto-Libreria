import { FormEvent, useState } from "react";
import { listarLibrosFiltrados } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { useListadoObservado } from "../../observer/useListadoObservado";
import { formatearFecha, formatearPrecio } from "../../formato";
import { GENEROS, Genero, Libro } from "../../types";

/**
 * Caso de uso: Listar Libros en una grilla, con filtro (del lado del servidor) por autor y/o género.
 *
 * Patrón Observer: esta pantalla se SUSCRIBE a `libroObservable` mientras está abierta.
 * Cuando el sujeto notifica un cambio (una mutación en este cliente o un cambio hecho
 * desde otro cliente), la lista se vuelve a pedir al servidor automáticamente.
 */
export default function ListarLibros() {
  const [libros, setLibros] = useState<Libro[]>([]);
  const [autor, setAutor] = useState("");
  const [genero, setGenero] = useState<Genero | "">("");
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function cargar() {
    setCargando(true);
    setError(null);
    try {
      setLibros(await listarLibrosFiltrados(autor, genero));
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  useListadoObservado(libroObservable, cargar);

  function filtrar(e: FormEvent) {
    e.preventDefault();
    void cargar();
  }

  return (
    <div className="tarjeta">
      <h1>Listar Libros</h1>
      {error && <p className="mensaje-error">{error}</p>}

      <form className="filtros" onSubmit={filtrar}>
        <label>Autor contiene
          <input value={autor} onChange={(e) => setAutor(e.target.value)} placeholder="ej. García" />
        </label>
        <label>Género
          <select value={genero} onChange={(e) => setGenero(e.target.value as Genero | "")}>
            <option value="">(todos)</option>
            {GENEROS.map((g) => <option key={g} value={g}>{g}</option>)}
          </select>
        </label>
        <button type="submit" disabled={cargando}>Filtrar</button>
      </form>

      <p className="conteo">{libros.length} libro(s)</p>
      <table>
        <thead>
          <tr>
            <th>ISBN</th><th>Título</th><th>Autor</th><th>Precio</th>
            <th>Páginas</th><th>Publicación</th><th>Género</th>
          </tr>
        </thead>
        <tbody>
          {libros.map((l) => (
            <tr key={l.isbn}>
              <td>{l.isbn}</td>
              <td>{l.titulo}</td>
              <td>{l.autor}</td>
              <td>{formatearPrecio(l.precio)}</td>
              <td>{l.numeroPaginas}</td>
              <td>{formatearFecha(l.fechaPublicacion)}</td>
              <td>{l.genero}</td>
            </tr>
          ))}
          {libros.length === 0 && !cargando && (
            <tr><td colSpan={7} className="sin-datos">No hay libros para mostrar.</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
