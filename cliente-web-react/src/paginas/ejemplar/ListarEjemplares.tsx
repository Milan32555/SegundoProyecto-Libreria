import { useEffect, useState } from "react";
import { listarEjemplaresFiltrados } from "../../graphql/servicioEjemplar";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { ESTADOS_EJEMPLAR, EstadoEjemplar, Ejemplar } from "../../types";

/** Caso de uso: Listar Ejemplares, con filtro por estado y/o isbn del libro. Observer igual que en Libros. */
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
      const resultado = await listarEjemplaresFiltrados(estado, isbnLibro);
      setEjemplares(resultado);
    } catch (err) {
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
    } finally {
      setCargando(false);
    }
  }

  useEffect(() => {
    cargar();
    const desuscribir = ejemplarObservable.suscribir(cargar);
    return desuscribir;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="tarjeta">
      <h1>Listar Ejemplares</h1>
      {error && <p className="mensaje-error">{error}</p>}

      <div className="filtros">
        <label>Estado
          <select value={estado} onChange={(e) => setEstado(e.target.value as EstadoEjemplar | "")}>
            <option value="">(todos)</option>
            {ESTADOS_EJEMPLAR.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </label>
        <label>ISBN del libro
          <input value={isbnLibro} onChange={(e) => setIsbnLibro(e.target.value)} placeholder="opcional" />
        </label>
        <button onClick={cargar} disabled={cargando}>Filtrar</button>
      </div>

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
              <td>{e.fechaIngreso}</td>
              <td>${e.precioReposicion.toLocaleString()}</td>
              <td>{e.isbnLibro}</td>
            </tr>
          ))}
          {ejemplares.length === 0 && !cargando && (
            <tr><td colSpan={6} style={{ color: "#8a91a3" }}>No hay ejemplares para mostrar.</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
