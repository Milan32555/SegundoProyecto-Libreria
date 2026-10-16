import { FormEvent, useState } from "react";
import { listarEjemplaresFiltrados } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { useListadoObservado } from "../../observer/useListadoObservado";
import { formatearFecha, formatearPrecio } from "../../formato";
import { ESTADOS_EJEMPLAR, EstadoEjemplar, Ejemplar } from "../../types";

/**
 * Caso de uso: Listar Ejemplares en una grilla, con filtro (del lado del servidor) por estado
 * y/o ISBN del libro. Observer igual que en ListarLibros.
 */
export default function ListarEjemplares() {
  const [ejemplares, setEjemplares] = useState<Ejemplar[]>([]);
  const [estado, setEstado] = useState<EstadoEjemplar | "">("");
  const [isbnLibro, setIsbnLibro] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function cargar() {
    setCargando(true);
    setError(null);
    try {
      setEjemplares(await listarEjemplaresFiltrados(estado, isbnLibro));
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  useListadoObservado(ejemplarObservable, cargar);

  function filtrar(e: FormEvent) {
    e.preventDefault();
    void cargar();
  }

  return (
    <div className="tarjeta">
      <h1>Listar Ejemplares</h1>
      {error && <p className="mensaje-error">{error}</p>}

      <form className="filtros" onSubmit={filtrar}>
        <label>Estado
          <select value={estado} onChange={(e) => setEstado(e.target.value as EstadoEjemplar | "")}>
            <option value="">(todos)</option>
            {ESTADOS_EJEMPLAR.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </label>
        <label>ISBN del libro
          <input value={isbnLibro} onChange={(e) => setIsbnLibro(e.target.value)} placeholder="opcional" />
        </label>
        <button type="submit" disabled={cargando}>Filtrar</button>
      </form>

      <p className="conteo">{ejemplares.length} ejemplar(es)</p>
      <table>
        <thead>
          <tr>
            <th>Código</th><th>Estado</th><th>Ubicación</th>
            <th>Ingreso</th><th>Reposición</th><th>Libro (ISBN)</th>
          </tr>
        </thead>
        <tbody>
          {ejemplares.map((e) => (
            <tr key={e.codigo}>
              <td>{e.codigo}</td>
              <td>{e.estado}</td>
              <td>{e.ubicacion}</td>
              <td>{formatearFecha(e.fechaIngreso)}</td>
              <td>{formatearPrecio(e.precioReposicion)}</td>
              <td>{e.isbnLibro}</td>
            </tr>
          ))}
          {ejemplares.length === 0 && !cargando && (
            <tr><td colSpan={6} className="sin-datos">No hay ejemplares para mostrar.</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
