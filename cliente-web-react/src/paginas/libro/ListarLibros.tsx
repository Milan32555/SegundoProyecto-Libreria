import { FormEvent, useState } from "react";
import { listarLibrosFiltrados } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { useListadoObservado } from "../../observer/useListadoObservado";
import { formatearFechaCorta, formatearPrecio } from "../../formato";
import { Aviso, Encabezado, Pastilla, SelectorChips } from "../../componentes/Basicos";
import Icono from "../../componentes/Icono";
import { GENEROS, Genero, Libro, etiquetaGenero } from "../../types";

/**
 * Caso de uso: Listar Libros en una grilla, con filtro (del lado del servidor) por autor y/o género.
 * El total de libros encontrados también lo calcula el servidor.
 *
 * Patrón Observer: esta pantalla se SUSCRIBE a `libroObservable` mientras está abierta.
 * Cuando el sujeto notifica un cambio (una mutación en este cliente o un cambio hecho
 * desde otro cliente), la lista se vuelve a pedir al servidor automáticamente.
 */
export default function ListarLibros() {
  const [libros, setLibros] = useState<Libro[]>([]);
  const [total, setTotal] = useState(0);
  const [autor, setAutor] = useState("");
  const [genero, setGenero] = useState<Genero | "">("");
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function cargar(filtroGenero: Genero | "" = genero) {
    setCargando(true);
    setError(null);
    try {
      const listado = await listarLibrosFiltrados(autor, filtroGenero);
      setLibros(listado.libros);
      setTotal(listado.total);
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

  function cambiarGenero(nuevo: Genero | "") {
    setGenero(nuevo);
    void cargar(nuevo);
  }

  return (
    <>
      <Encabezado etiqueta="Libros" titulo="Listar libros">
        Todos los libros registrados. El filtro se aplica en el servidor.
      </Encabezado>

      <section className="tarjeta filtros">
        <form className="filtros-fila" role="search" onSubmit={filtrar}>
          <label>Autor contiene
            <input value={autor} onChange={(e) => setAutor(e.target.value)} placeholder="ej. García" />
          </label>
          <button type="submit" disabled={cargando}><Icono nombre="buscar" /> Filtrar</button>
        </form>
        <SelectorChips etiqueta="Género" nombre="genero" opciones={GENEROS} valor={genero}
                       etiquetaDe={etiquetaGenero} alCambiar={cambiarGenero} textoTodos="Todos" />
      </section>

      {error && <Aviso>{error}</Aviso>}

      <div className="resumen-lista">
        <span className="conteo">{total === 1 ? "1 libro" : `${total} libros`}</span>
      </div>
      <div className="tabla-contenedor">
        <table>
          <thead>
            <tr>
              <th>Libro</th><th>Género</th><th className="numero">Precio</th>
              <th className="numero">Páginas</th><th>Publicación</th><th>ISBN</th>
            </tr>
          </thead>
          <tbody>
            {libros.map((l) => (
              <tr key={l.isbn}>
                <td className="celda-doble"><strong>{l.titulo}</strong><small>{l.autor}</small></td>
                <td><Pastilla>{etiquetaGenero(l.genero)}</Pastilla></td>
                <td className="numero precio">{formatearPrecio(l.precio)}</td>
                <td className="numero">{l.numeroPaginas}</td>
                <td>{formatearFechaCorta(l.fechaPublicacion)}</td>
                <td className="apagado">{l.isbn}</td>
              </tr>
            ))}
            {libros.length === 0 && !cargando && (
              <tr><td colSpan={6} className="sin-datos">No hay libros para mostrar.</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </>
  );
}
