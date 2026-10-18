import { CSSProperties, useState } from "react";
import { Link } from "react-router-dom";
import { consultarResumenInventario } from "../graphql/servicioResumen";
import { mensajeDeError } from "../graphql/clienteGraphQL";
import { ejemplarObservable, libroObservable } from "../observer/Observable";
import { useListadoObservado } from "../observer/useListadoObservado";
import { Aviso, IconoAcento, TituloSeccion, colorEstado } from "../componentes/Basicos";
import Estanteria from "../componentes/Estanteria";
import Icono, { NombreIcono } from "../componentes/Icono";
import { useContador } from "../componentes/useContador";
import { formatearFechaLarga, saludo } from "../formato";
import { ConteoEstado, ESTADOS_EJEMPLAR, EstadoEjemplar, ResumenInventario } from "../types";

/** Nombre de cada estado en la leyenda (en plural). */
const NOMBRE_ESTADO: Record<EstadoEjemplar, string> = {
  DISPONIBLE: "Disponibles",
  PRESTADO: "Prestados",
  DANIADO: "Dañados",
  DADO_DE_BAJA: "Dados de baja"
};

/** Retraso de la animación de entrada de cada bloque (aparecen uno tras otro). */
const retraso = (ms: number) => ({ "--retraso": `${ms}ms` }) as CSSProperties;

/**
 * Ventana principal: encabezado con el resumen del inventario (se actualiza solo, patrón
 * Observer), estado de los ejemplares y accesos a cada caso de uso. El menú superior tiene
 * las mismas opciones y "Ayuda".
 *
 * Los totales y la distribución por estado los calcula el servidor (query resumenInventario):
 * esta pantalla no cuenta nada, solo muestra lo que recibe.
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

  const ahora = new Date();

  return (
    <>
      <section className="inicio-hero" aria-label="Inventario">
        <div className="inicio-hero-contenido">
          <div>
            <span className="inicio-fecha aparecer" style={retraso(0)}>{formatearFechaLarga(ahora)}</span>
            <h1 className="inicio-saludo aparecer" style={retraso(60)}>{saludo(ahora)}.</h1>
            <p className="inicio-subtitulo aparecer" style={retraso(120)}>Así está tu inventario hoy.</p>
          </div>
          <div className="inicio-cifras aparecer" style={retraso(220)}>
            <Cifra valor={resumen?.totalLibros ?? null} leyenda="Títulos" />
            <Cifra valor={resumen?.totalEjemplares ?? null} leyenda="Ejemplares" />
          </div>
        </div>
        <Estanteria />
      </section>

      <div className="aparecer" style={retraso(420)}>
        {error ? <Aviso>{error}</Aviso> : <TarjetaEstados conteos={resumen?.ejemplaresPorEstado ?? null} />}
      </div>

      <div className="aparecer" style={retraso(560)}>
        <GrupoAcciones titulo="Libros" icono="libro" base="/libros" objeto="libros" />
      </div>
      <div className="aparecer" style={retraso(700)}>
        <GrupoAcciones titulo="Ejemplares" icono="inventario" base="/ejemplares" objeto="ejemplares" />
      </div>
    </>
  );
}

/** Cifra grande que cuenta desde su valor anterior hasta el nuevo. */
function Cifra({ valor, leyenda }: { valor: number | null; leyenda: string }) {
  const mostrado = useContador(valor);
  return (
    <div className="cifra">
      <strong>{mostrado ?? "—"}</strong>
      <span>{leyenda}</span>
    </div>
  );
}

type FilaEstado = Omit<ConteoEstado, "cantidad"> & { cantidad: number | null };

/** Mientras llega la respuesta del servidor: los cuatro estados, sin cifras. */
const ESTADOS_CARGANDO: FilaEstado[] = ESTADOS_EJEMPLAR.map((estado) => ({ estado, cantidad: null, porcentaje: 0 }));

/**
 * Distribución de los ejemplares por estado: barra proporcional + leyenda.
 * Cantidad y porcentaje de cada estado vienen calculados del servidor.
 */
function TarjetaEstados({ conteos }: { conteos: ConteoEstado[] | null }) {
  const filas: FilaEstado[] = conteos ?? ESTADOS_CARGANDO;
  return (
    <section className="tarjeta estados" aria-label="Estado de los ejemplares">
      <h2 className="estados-titulo">Estado de los ejemplares</h2>
      <p className="leyenda">{conteos ? "Copias físicas registradas en el inventario" : "Cargando…"}</p>
      <div className="estados-barra">
        {filas.map(({ estado, porcentaje }) => (
          <span key={estado} style={{ width: `${porcentaje}%`, background: colorEstado(estado) }} />
        ))}
      </div>
      <ul className="estados-leyenda">
        {filas.map(({ estado, cantidad }) => (
          <li key={estado}>
            <span className="punto" style={{ background: colorEstado(estado) }} />
            <span>{NOMBRE_ESTADO[estado]}</span>
            <strong>{cantidad ?? "—"}</strong>
          </li>
        ))}
      </ul>
    </section>
  );
}

function GrupoAcciones({ titulo, icono, base, objeto }: {
  titulo: string; icono: NombreIcono; base: string; objeto: string;
}) {
  return (
    <section className="seccion">
      <TituloSeccion icono={icono} titulo={titulo} />
      <div className="acciones-grilla">
        <Accion destacada ruta={`${base}/listar`} icono="lista" titulo="Listar" detalle={`Ver todos los ${objeto} y filtrar`} />
        <Accion ruta={`${base}/agregar`} icono="agregar" titulo="Adicionar" detalle="Registrar nuevo" />
        <Accion ruta={`${base}/consultar`} icono="buscar" titulo="Buscar" detalle="Consultar uno" />
        <Accion ruta={`${base}/actualizar`} icono="editar" titulo="Actualizar" detalle="Modificar datos" />
        <Accion ruta={`${base}/eliminar`} icono="eliminar" titulo="Eliminar" detalle="Quitar del sistema" color="var(--rojo)" />
      </div>
    </section>
  );
}

function Accion({ ruta, icono, titulo, detalle, color, destacada = false }: {
  ruta: string; icono: NombreIcono; titulo: string; detalle: string; color?: string; destacada?: boolean;
}) {
  return (
    <Link to={ruta} className={destacada ? "accion accion-destacada" : "accion"}>
      <IconoAcento nombre={icono} color={destacada ? "var(--crema)" : color} />
      <span>
        <strong>{titulo}</strong>
        <small>{detalle}</small>
      </span>
      {destacada && <span className="flecha"><Icono nombre="flecha" /></span>}
    </Link>
  );
}
