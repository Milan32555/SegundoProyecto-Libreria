import { FormEvent, useState } from "react";
import { FilterX, Library, Plus, Search } from "lucide-react";
import { listarEjemplaresFiltrados } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { useListadoObservado } from "../../observer/useListadoObservado";
import { formatearFechaCorta, formatearPrecio } from "../../formato";
import { Banner } from "../../componentes/ui/Banner";
import { Boton, BotonEnlace } from "../../componentes/ui/Boton";
import { Campo } from "../../componentes/ui/Campo";
import { Encabezado } from "../../componentes/ui/Encabezado";
import { InsigniaEstado } from "../../componentes/ui/Insignias";
import { Segmentado } from "../../componentes/ui/Segmentado";
import { Columna, TablaDatos } from "../../componentes/ui/TablaDatos";
import { ESTADOS_EJEMPLAR, EstadoEjemplar, Ejemplar, etiquetaEstado } from "../../types";

type FiltroEstado = EstadoEjemplar | "TODOS";

const OPCIONES_FILTRO_ESTADO = [
  { valor: "TODOS" as FiltroEstado, texto: "Todos" },
  ...ESTADOS_EJEMPLAR.map((e) => ({ valor: e as FiltroEstado, texto: etiquetaEstado(e) }))
];

const COLUMNAS: Columna<Ejemplar>[] = [
  {
    titulo: "Código",
    celda: (e) => (
      <span className="celda-titulo">
        <strong>{e.codigo}</strong>
        <small>{e.ubicacion}</small>
      </span>
    )
  },
  { titulo: "Estado", celda: (e) => <InsigniaEstado estado={e.estado} /> },
  { titulo: "Libro (ISBN)", celda: (e) => e.isbnLibro, apagada: true },
  { titulo: "Ingreso", celda: (e) => formatearFechaCorta(e.fechaIngreso), apagada: true },
  { titulo: "Préstamos", celda: (e) => e.numeroPrestamos, numerica: true },
  { titulo: "Reposición", celda: (e) => formatearPrecio(e.precioReposicion), numerica: true }
];

/**
 * Caso de uso: Listar Ejemplares en una grilla con filtro por estado y/o ISBN del libro. El
 * filtro y el total los resuelve el servidor. Observer igual que en Listar Libros.
 */
export default function ListarEjemplares() {
  const [ejemplares, setEjemplares] = useState<Ejemplar[]>([]);
  const [total, setTotal] = useState(0);
  const [estado, setEstado] = useState<FiltroEstado>("TODOS");
  const [isbnLibro, setIsbnLibro] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(true);
  const [cargado, setCargado] = useState(false);

  async function cargar(filtroEstado: FiltroEstado = estado, filtroIsbn: string = isbnLibro) {
    setCargando(true);
    setError(null);
    try {
      const listado = await listarEjemplaresFiltrados(filtroEstado === "TODOS" ? "" : filtroEstado, filtroIsbn);
      setEjemplares(listado.ejemplares);
      setTotal(listado.total);
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
      setCargado(true);
    }
  }

  useListadoObservado(ejemplarObservable, cargar);

  function filtrar(e: FormEvent) {
    e.preventDefault();
    void cargar();
  }

  function cambiarEstado(nuevo: FiltroEstado) {
    setEstado(nuevo);
    void cargar(nuevo);
  }

  function limpiar() {
    setEstado("TODOS");
    setIsbnLibro("");
    void cargar("TODOS", "");
  }

  const hayFiltros = estado !== "TODOS" || isbnLibro.trim() !== "";

  return (
    <>
      <Encabezado
        seccion="Ejemplares"
        titulo="Listar ejemplares"
        descripcion="Todas las copias físicas del inventario. El filtro lo aplica el servidor."
        acciones={<BotonEnlace to="/ejemplares/agregar" variante="primario" icono={Plus}>Adicionar ejemplar</BotonEnlace>}
      />

      {error && ejemplares.length > 0 && <Banner titulo="No se pudo actualizar la lista" className="espacio-abajo">{error}</Banner>}

      <section className="panel" aria-label="Ejemplares">
        <form className="barra-filtros" role="search" onSubmit={filtrar}>
          <Segmentado etiqueta="Estado" nombre="estado" valor={estado} opciones={OPCIONES_FILTRO_ESTADO} alCambiar={cambiarEstado} />
          <Campo
            className="campo-busqueda"
            etiqueta="ISBN del libro"
            value={isbnLibro}
            onChange={(e) => setIsbnLibro(e.target.value)}
            placeholder="Opcional"
            autoComplete="off"
          />
          <Boton type="submit" icono={Search} disabled={cargando && !cargado}>Filtrar</Boton>
          {hayFiltros && <Boton variante="fantasma" icono={FilterX} onClick={limpiar}>Limpiar filtros</Boton>}
        </form>

        <div className="barra-tabla" aria-live="polite">
          <span className="conteo">{total === 1 ? "1 ejemplar" : `${total} ejemplares`}</span>
          <span>Total calculado por el servidor</span>
        </div>

        <TablaDatos
          etiqueta="Ejemplares del inventario"
          columnas={COLUMNAS}
          filas={ejemplares}
          claveFila={(e) => e.codigo}
          cargandoInicial={!cargado}
          ocupada={cargando}
          error={error}
          alReintentar={() => void cargar()}
          vacio={hayFiltros
            ? {
                icono: FilterX,
                titulo: "Ningún ejemplar coincide con el filtro",
                descripcion: "Prueba con otro estado o revisa el ISBN.",
                accion: <Boton icono={FilterX} onClick={limpiar}>Limpiar filtros</Boton>
              }
            : {
                icono: Library,
                titulo: "Todavía no hay ejemplares",
                descripcion: "Las copias que registres aparecerán aquí.",
                accion: <BotonEnlace to="/ejemplares/agregar" icono={Plus}>Adicionar ejemplar</BotonEnlace>
              }}
        />
      </section>
    </>
  );
}
