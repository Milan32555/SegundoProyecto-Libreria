import { useEffect, useState } from "react";
import { listarLibrosFiltrados } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { GENEROS, Genero, Libro } from "../../types";

/**
 * Caso de uso: Listar Libros, con filtro por autor y/o género.
 *
 * Patrón Observer: esta pantalla se SUSCRIBE a `libroObservable`. Cada vez que otra
 * pantalla (Agregar/Actualizar/Eliminar) notifica un cambio, el useEffect de abajo
 * vuelve a pedir el listado al servidor automáticamente, sin que el usuario tenga
 * que navegar de nuevo a esta pantalla ni pulsar un botón de "refrescar".
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
      const resultado = await listarLibrosFiltrados(autor, genero);
      setLibros(resultado);
    } catch (err) {
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
    } finally {
      setCargando(false);
    }
  }

  useEffect(() => {
    cargar();
    // Suscripción Observer: al desmontar la pantalla nos desuscribimos (evita fugas de memoria).
    const desuscribir = libroObservable.suscribir(cargar);
    return desuscribir;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="tarjeta">
      <h1>Listar Libros</h1>
      {error && <p className="mensaje-error">{error}</p>}

      <div className="filtros">
        <label>Autor contiene
          <input value={autor} onChange={(e) => setAutor(e.target.value)} placeholder="ej. García" />
        </label>
        <label>Género
          <select value={genero} onChange={(e) => setGenero(e.target.value as Genero | "")}>
            <option value="">(todos)</option>
            {GENEROS.map((g) => <option key={g} value={g}>{g}</option>)}
          </select>
        </label>
        <button onClick={cargar} disabled={cargando}>Filtrar</button>
      </div>

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
              <td>${l.precio.toLocaleString()}</td>
              <td>{l.numeroPaginas}</td>
              <td>{l.fechaPublicacion}</td>
              <td>{l.genero}</td>
            </tr>
          ))}
          {libros.length === 0 && !cargando && (
            <tr><td colSpan={7} style={{ color: "#8a91a3" }}>No hay libros para mostrar.</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
