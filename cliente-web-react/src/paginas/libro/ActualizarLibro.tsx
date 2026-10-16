import { FormEvent, useState } from "react";
import { actualizarLibro, buscarLibroPorIsbn } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { aValorDeInputFecha } from "../../formato";
import { GENEROS, Genero, Libro } from "../../types";

/**
 * Caso de uso: Actualizar Libro. Primero se busca el objeto y se muestra TODA su
 * información actual; luego el usuario la modifica y confirma.
 */
export default function ActualizarLibro() {
  const [isbn, setIsbn] = useState("");
  const [libro, setLibro] = useState<Libro | null>(null);

  const [titulo, setTitulo] = useState("");
  const [autor, setAutor] = useState("");
  const [precio, setPrecio] = useState("");
  const [numeroPaginas, setNumeroPaginas] = useState("");
  const [fechaPublicacion, setFechaPublicacion] = useState("");
  const [genero, setGenero] = useState<Genero>("FICCION");

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
        setTitulo(resultado.titulo);
        setAutor(resultado.autor);
        setPrecio(String(resultado.precio));
        setNumeroPaginas(String(resultado.numeroPaginas));
        setFechaPublicacion(aValorDeInputFecha(resultado.fechaPublicacion));
        setGenero(resultado.genero);
      }
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  async function guardarCambios(e: FormEvent) {
    e.preventDefault();
    if (!libro) return;
    setCargando(true); setError(null);
    try {
      await actualizarLibro(libro.isbn, {
        titulo, autor,
        precio: Number(precio),
        numeroPaginas: Number(numeroPaginas),
        fechaPublicacion,
        genero
      });
      setExito(`Libro "${titulo}" actualizado correctamente.`);
      libroObservable.notificar();
      setLibro(null);
      setIsbn("");
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  return (
    <div className="tarjeta">
      <h1>Actualizar Libro</h1>
      {error && <p className="mensaje-error">{error}</p>}
      {exito && <p className="mensaje-exito">{exito}</p>}

      {!libro && (
        <form onSubmit={buscar}>
          <label>ISBN del libro a actualizar
            <input value={isbn} onChange={(e) => setIsbn(e.target.value)} required />
          </label>
          <button type="submit" disabled={cargando}>Buscar</button>
        </form>
      )}

      {libro && (
        <form onSubmit={guardarCambios}>
          <p className="dato-fijo">ISBN (no editable): <strong>{libro.isbn}</strong></p>
          <label>Título
            <input value={titulo} onChange={(e) => setTitulo(e.target.value)} required />
          </label>
          <label>Autor
            <input value={autor} onChange={(e) => setAutor(e.target.value)} required />
          </label>
          <label>Precio
            <input type="number" min="0.01" step="0.01" value={precio}
                   onChange={(e) => setPrecio(e.target.value)} required />
          </label>
          <label>Número de páginas
            <input type="number" min="1" step="1" value={numeroPaginas}
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
          <div className="acciones">
            <button type="submit" disabled={cargando}>Guardar cambios</button>
            <button type="button" className="secundario" onClick={() => setLibro(null)}>Cancelar</button>
          </div>
        </form>
      )}
    </div>
  );
}
