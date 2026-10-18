import { FormEvent, useState } from "react";
import { listarEjemplaresFiltrados } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { useListadoObservado } from "../../observer/useListadoObservado";
import { formatearFechaCorta, formatearPrecio } from "../../formato";
import { Aviso, Encabezado, Pastilla, SelectorChips, colorEstado } from "../../componentes/Basicos";
import Icono from "../../componentes/Icono";
import { ESTADOS_EJEMPLAR, EstadoEjemplar, Ejemplar, etiquetaEstado } from "../../types";

/**
 * Caso de uso: Listar Ejemplares en una grilla, con filtro (del lado del servidor) por estado
 * y/o ISBN del libro. El total encontrado también lo calcula el servidor. Observer igual que
 * en ListarLibros.
 */
export default function ListarEjemplares() {
  const [ejemplares, setEjemplares] = useState<Ejemplar[]>([]);
  const [total, setTotal] = useState(0);
  const [estado, setEstado] = useState<EstadoEjemplar | "">("");
  const [isbnLibro, setIsbnLibro] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function cargar(filtroEstado: EstadoEjemplar | "" = estado) {
    setCargando(true);
    setError(null);
    try {
      const listado = await listarEjemplaresFiltrados(filtroEstado, isbnLibro);
      setEjemplares(listado.ejemplares);
      setTotal(listado.total);
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

  function cambiarEstado(nuevo: EstadoEjemplar | "") {
    setEstado(nuevo);
    void cargar(nuevo);
  }

  return (
    <>
      <Encabezado etiqueta="Ejemplares" titulo="Listar ejemplares">
        Todas las copias físicas en inventario. El filtro se aplica en el servidor.
      </Encabezado>

      <section className="tarjeta filtros">
        <form className="filtros-fila" role="search" onSubmit={filtrar}>
          <label>ISBN del libro
            <input value={isbnLibro} onChange={(e) => setIsbnLibro(e.target.value)} placeholder="opcional" />
          </label>
          <button type="submit" disabled={cargando}><Icono nombre="buscar" /> Filtrar</button>
        </form>
        <SelectorChips etiqueta="Estado" nombre="estado" opciones={ESTADOS_EJEMPLAR} valor={estado}
                       etiquetaDe={etiquetaEstado} alCambiar={cambiarEstado} textoTodos="Todos" />
      </section>

      {error && <Aviso>{error}</Aviso>}

      <div className="resumen-lista">
        <span className="conteo">{total === 1 ? "1 ejemplar" : `${total} ejemplares`}</span>
      </div>
      <div className="tabla-contenedor">
        <table>
          <thead>
            <tr>
              <th>Ejemplar</th><th>Estado</th><th className="numero">Reposición</th>
              <th className="numero">Préstamos</th><th>Ingreso</th><th>Libro (ISBN)</th>
            </tr>
          </thead>
          <tbody>
            {ejemplares.map((e) => (
              <tr key={e.codigo}>
                <td className="celda-doble"><strong>{e.codigo}</strong><small>{e.ubicacion}</small></td>
                <td><Pastilla color={colorEstado(e.estado)}>{etiquetaEstado(e.estado)}</Pastilla></td>
                <td className="numero precio">{formatearPrecio(e.precioReposicion)}</td>
                <td className="numero">{e.numeroPrestamos}</td>
                <td>{formatearFechaCorta(e.fechaIngreso)}</td>
                <td className="apagado">{e.isbnLibro}</td>
              </tr>
            ))}
            {ejemplares.length === 0 && !cargando && (
              <tr><td colSpan={6} className="sin-datos">No hay ejemplares para mostrar.</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </>
  );
}
