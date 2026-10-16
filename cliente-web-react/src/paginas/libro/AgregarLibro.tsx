import { FormEvent, useState } from "react";
import { crearLibro } from "../../graphql/servicioLibro";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { GENEROS, Genero } from "../../types";

/** Caso de uso: Adicionar Libro (único propósito de esta pantalla). */
export default function AgregarLibro() {
  const [isbn, setIsbn] = useState("");
  const [titulo, setTitulo] = useState("");
  const [autor, setAutor] = useState("");
  const [precio, setPrecio] = useState("");
  const [numeroPaginas, setNumeroPaginas] = useState("");
  const [fechaPublicacion, setFechaPublicacion] = useState("");
  const [genero, setGenero] = useState<Genero>("FICCION");

  const [error, setError] = useState<string | null>(null);
  const [exito, setExito] = useState<string | null>(null);
  const [enviando, setEnviando] = useState(false);

  async function manejarEnvio(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setExito(null);
    setEnviando(true);
    try {
      const libro = await crearLibro({
        isbn,
        titulo,
        autor,
        precio: Number(precio),
        numeroPaginas: Number(numeroPaginas),
        fechaPublicacion,
        genero
      });
      setExito(`Libro "${libro.titulo}" creado correctamente.`);
      libroObservable.notificar(); // Observer: avisa a la pantalla Listar que debe refrescar
      setIsbn(""); setTitulo(""); setAutor(""); setPrecio("");
      setNumeroPaginas(""); setFechaPublicacion("");
    } catch (err) {
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
    } finally {
      setEnviando(false);
    }
  }

  return (
    <div className="tarjeta">
      <h1>Adicionar Libro</h1>
      {error && <p className="mensaje-error">{error}</p>}
      {exito && <p className="mensaje-exito">{exito}</p>}
      <form onSubmit={manejarEnvio}>
        <label>ISBN
          <input value={isbn} onChange={(e) => setIsbn(e.target.value)} required />
        </label>
        <label>Título
          <input value={titulo} onChange={(e) => setTitulo(e.target.value)} required />
        </label>
        <label>Autor
          <input value={autor} onChange={(e) => setAutor(e.target.value)} required />
        </label>
        <label>Precio
          <input type="number" min="0" step="0.01" value={precio}
                 onChange={(e) => setPrecio(e.target.value)} required />
        </label>
        <label>Número de páginas
          <input type="number" min="1" value={numeroPaginas}
                 onChange={(e) => setNumeroPaginas(e.target.value)} required />
        </label>
        <label>Fecha de publicación
          <input type="datetime-local" value={fechaPublicacion}
                 onChange={(e) => setFechaPublicacion(e.target.value)} required />
        </label>
        <label>Género
          <select value={genero} onChange={(e) => setGenero(e.target.value as Genero)}>
            {GENEROS.map((g) => <option key={g} value={g}>{g}</option>)}
          </select>
        </label>
        <button type="submit" disabled={enviando}>{enviando ? "Guardando..." : "Adicionar"}</button>
      </form>
    </div>
  );
}
