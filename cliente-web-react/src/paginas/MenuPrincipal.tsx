import { useState } from "react";
import { Link } from "react-router-dom";
import { List, LucideIcon, Pencil, Plus, RotateCw, Search, Trash2 } from "lucide-react";
import { consultarResumenInventario } from "../graphql/servicioResumen";
import { mensajeDeError } from "../graphql/clienteGraphQL";
import { ejemplarObservable, libroObservable } from "../observer/Observable";
import { useListadoObservado } from "../observer/useListadoObservado";
import { Banner } from "../componentes/ui/Banner";
import { Boton } from "../componentes/ui/Boton";
import { Encabezado } from "../componentes/ui/Encabezado";
import { COLOR_ESTADO, InsigniaEstado } from "../componentes/ui/Insignias";
import { formatearFechaLarga } from "../formato";
import { ConteoEstado, ESTADOS_EJEMPLAR, EstadoEjemplar, ResumenInventario } from "../types";

const NOMBRE_ESTADO: Record<EstadoEjemplar, string> = {
  DISPONIBLE: "Disponibles",
  PRESTADO: "Prestados",
  DANIADO: "Dañados",
  DADO_DE_BAJA: "Dados de baja"
};

const formatoPorcentaje = new Intl.NumberFormat("es-CO", { maximumFractionDigits: 1 });

/**
 * Ventana principal: el resumen del inventario y accesos a cada caso de uso (el menú lateral
 * tiene las mismas opciones y "Ayuda").
 *
 * Todas las cifras las calcula el servidor (query resumenInventario): esta pantalla no cuenta
 * nada, solo muestra lo que recibe. Se suscribe a los dos sujetos del Observer, así que se
 * actualiza sola cuando cambian los libros o los ejemplares.
 */
export default function MenuPrincipal() {
  const [resumen, setResumen] = useState<ResumenInventario | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function cargar() {
    try {
      setResumen(await consultarResumenInventario());
      setError(null);
    } catch (err) {
      setError(mensajeDeError(err));
    }
  }

  useListadoObservado(libroObservable, cargar);
  useListadoObservado(ejemplarObservable, cargar, { cargarAlInicio: false });

  const cantidad = (estado: EstadoEjemplar) =>
    resumen?.ejemplaresPorEstado.find((c) => c.estado === estado)?.cantidad ?? null;

  return (
    <>
      <Encabezado titulo="Inicio" descripcion={formatearFechaLarga(new Date())} />

      {error && (
        <Banner
          titulo="No se pudo cargar el resumen del inventario"
          className="espacio-abajo"
          accion={<Boton icono={RotateCw} onClick={() => void cargar()}>Reintentar</Boton>}
        >
          {error}
        </Banner>
      )}

      <section aria-label="Inventario" className="cifras">
        <Cifra etiqueta="Títulos" valor={resumen?.totalLibros ?? null} detalle="Libros distintos en el catálogo" />
        <Cifra etiqueta="Ejemplares" valor={resumen?.totalEjemplares ?? null} detalle="Copias físicas registradas" />
        <Cifra etiqueta="Disponibles" valor={cantidad("DISPONIBLE")} detalle="Listas para prestar o vender" />
        <Cifra etiqueta="Prestados" valor={cantidad("PRESTADO")} detalle="Fuera de la librería" />
      </section>

      <div className="inicio-rejilla">
        <EstadoEjemplares conteos={resumen?.ejemplaresPorEstado ?? null} total={resumen?.totalEjemplares ?? null} />
        <section className="panel" aria-labelledby="titulo-accesos">
          <header className="panel-cabecera">
            <h2 className="panel-titulo" id="titulo-accesos">Accesos directos</h2>
          </header>
          <div className="panel-cuerpo accesos">
            <Accesos titulo="Libros" base="/libros" />
            <Accesos titulo="Ejemplares" base="/ejemplares" />
          </div>
        </section>
      </div>
    </>
  );
}

function Cifra({ etiqueta, valor, detalle }: { etiqueta: string; valor: number | null; detalle: string }) {
  return (
    <div className="panel cifra-panel">
      <p className="cifra-etiqueta">{etiqueta}</p>
      <strong className="cifra">{valor ?? "—"}</strong>
      <p className="cifra-detalle">{detalle}</p>
    </div>
  );
}

/** Distribución de los ejemplares por estado; cantidades y porcentajes vienen del servidor. */
function EstadoEjemplares({ conteos, total }: { conteos: ConteoEstado[] | null; total: number | null }) {
  const filas = ESTADOS_EJEMPLAR.map(
    (estado) => conteos?.find((c) => c.estado === estado) ?? { estado, cantidad: null, porcentaje: null }
  );
  return (
    <section className="panel" aria-label="Estado de los ejemplares">
      <header className="panel-cabecera">
        <h2 className="panel-titulo">Estado de los ejemplares</h2>
        <span className="panel-subtitulo">{total === null ? "Cargando…" : `${total} copias · calculado por el servidor`}</span>
      </header>
      <div className="panel-cuerpo">
        <div className="barra-estados" aria-hidden="true">
          {filas.map(({ estado, porcentaje }) => (
            <span key={estado} style={{ width: `${porcentaje ?? 0}%`, background: COLOR_ESTADO[estado] }} />
          ))}
        </div>
        <ul className="leyenda-estados">
          {filas.map(({ estado, cantidad, porcentaje }) => (
            <li key={estado}>
              <InsigniaEstado estado={estado} texto={NOMBRE_ESTADO[estado]} />
              <span className="numero">{cantidad ?? "—"}</span>
              <span className="numero porcentaje">{porcentaje === null ? "" : `${formatoPorcentaje.format(porcentaje)} %`}</span>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}

const ACCESOS: { ruta: string; texto: string; icono: LucideIcon }[] = [
  { ruta: "listar", texto: "Listar", icono: List },
  { ruta: "consultar", texto: "Consultar", icono: Search },
  { ruta: "agregar", texto: "Adicionar", icono: Plus },
  { ruta: "actualizar", texto: "Actualizar", icono: Pencil },
  { ruta: "eliminar", texto: "Eliminar", icono: Trash2 }
];

function Accesos({ titulo, base }: { titulo: string; base: string }) {
  const singular = titulo === "Libros" ? "libro" : "ejemplar";
  return (
    <div>
      <h3>{titulo}</h3>
      <ul>
        {ACCESOS.map(({ ruta, texto, icono: Icono }) => (
          <li key={ruta}>
            <Link className="acceso" to={`${base}/${ruta}`}>
              <Icono size={16} aria-hidden="true" />
              {ruta === "listar" ? `${texto} ${titulo.toLowerCase()}` : `${texto} ${singular}`}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
