import { FormEvent, useState } from "react";
import { BookOpen, FilterX, Plus, Search } from "lucide-react";
import { listarLibrosFiltrados } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { useListadoObservado } from "../../observer/useListadoObservado";
import { formatearFechaCorta, formatearPrecio } from "../../formato";
import { OPCIONES_GENERO_FILTRO } from "../../componentes/opciones";
import { Banner } from "../../componentes/ui/Banner";
import { Boton, BotonEnlace } from "../../componentes/ui/Boton";
import { Campo } from "../../componentes/ui/Campo";
import { Encabezado } from "../../componentes/ui/Encabezado";
import { InsigniaGenero } from "../../componentes/ui/Insignias";
import { Selector } from "../../componentes/ui/Selector";
import { Columna, TablaDatos } from "../../componentes/ui/TablaDatos";
import { Genero, Libro } from "../../types";

const COLUMNAS: Columna<Libro>[] = [
  {
    titulo: "Título",
    celda: (l) => (
      <span className="celda-titulo">
        <strong className="titulo-libro">{l.titulo}</strong>
        <small>{l.autor}</small>
      </span>
    )
  },
  { titulo: "Género", celda: (l) => <InsigniaGenero genero={l.genero} /> },
  { titulo: "ISBN", celda: (l) => l.isbn, apagada: true },
  { titulo: "Publicación", celda: (l) => formatearFechaCorta(l.fechaPublicacion), apagada: true },
  { titulo: "Páginas", celda: (l) => l.numeroPaginas, numerica: true },
  { titulo: "Precio", celda: (l) => formatearPrecio(l.precio), numerica: true }
];

/**
 * Caso de uso: Listar Libros en una grilla con filtro por autor y/o género. El filtro y el
 * total los resuelve el servidor (librosFiltrados + totalLibrosFiltrados).
 *
 * Patrón Observer: mientras la pantalla está abierta se SUSCRIBE a `libroObservable`; cuando
 * el sujeto notifica un cambio (en este cliente o en otro), la lista se vuelve a pedir sola.
 */
export default function ListarLibros() {
  const [libros, setLibros] = useState<Libro[]>([]);
  const [total, setTotal] = useState(0);
  const [autor, setAutor] = useState("");
  const [genero, setGenero] = useState<Genero | "">("");
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(true);
  const [cargado, setCargado] = useState(false);

  async function cargar(filtroAutor: string = autor, filtroGenero: Genero | "" = genero) {
    setCargando(true);
    setError(null);
    try {
      const listado = await listarLibrosFiltrados(filtroAutor, filtroGenero);
      setLibros(listado.libros);
      setTotal(listado.total);
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
      setCargado(true);
    }
  }

  useListadoObservado(libroObservable, cargar);

  function filtrar(e: FormEvent) {
    e.preventDefault();
    void cargar();
  }

  function cambiarGenero(nuevo: Genero | "") {
    setGenero(nuevo);
    void cargar(autor, nuevo);
  }

  function limpiar() {
    setAutor("");
    setGenero("");
    void cargar("", "");
  }

  const hayFiltros = autor.trim() !== "" || genero !== "";

  return (
    <>
      <Encabezado
        seccion="Libros"
        titulo="Listar libros"
        descripcion="Todos los títulos del inventario. El filtro lo aplica el servidor."
        acciones={<BotonEnlace to="/libros/agregar" variante="primario" icono={Plus}>Adicionar libro</BotonEnlace>}
      />

      {error && libros.length > 0 && <Banner titulo="No se pudo actualizar la lista" className="espacio-abajo">{error}</Banner>}

      <section className="panel" aria-label="Libros">
        <form className="barra-filtros" role="search" onSubmit={filtrar}>
          <Campo
            className="campo-busqueda"
            etiqueta="Autor"
            value={autor}
            onChange={(e) => setAutor(e.target.value)}
            placeholder="Contiene… (p. ej. García)"
            autoComplete="off"
          />
          <Selector etiqueta="Género" valor={genero} opciones={OPCIONES_GENERO_FILTRO} alCambiar={cambiarGenero} />
          <Boton type="submit" icono={Search} disabled={cargando && !cargado}>Filtrar</Boton>
          {hayFiltros && <Boton variante="fantasma" icono={FilterX} onClick={limpiar}>Limpiar filtros</Boton>}
        </form>

        <div className="barra-tabla" aria-live="polite">
          <span className="conteo">{total === 1 ? "1 libro" : `${total} libros`}</span>
          <span>Total calculado por el servidor</span>
        </div>

        <TablaDatos
          etiqueta="Libros del inventario"
          columnas={COLUMNAS}
          filas={libros}
          claveFila={(l) => l.isbn}
          cargandoInicial={!cargado}
          ocupada={cargando}
          error={error}
          alReintentar={() => void cargar()}
          vacio={hayFiltros
            ? {
                icono: FilterX,
                titulo: "Ningún libro coincide con el filtro",
                descripcion: "Prueba con otro autor o con otro género.",
                accion: <Boton icono={FilterX} onClick={limpiar}>Limpiar filtros</Boton>
              }
            : {
                icono: BookOpen,
                titulo: "Todavía no hay libros",
                descripcion: "Los libros que adiciones aparecerán aquí.",
                accion: <BotonEnlace to="/libros/agregar" icono={Plus}>Adicionar libro</BotonEnlace>
              }}
        />
      </section>
    </>
  );
}
