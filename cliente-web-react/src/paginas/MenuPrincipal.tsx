import { CSSProperties, useState } from "react";
import { Link } from "react-router-dom";
import { listarLibros } from "../graphql/servicioLibro";
import { listarEjemplares } from "../graphql/servicioEjemplar";
import { mensajeDeError } from "../graphql/clienteGraphQL";
import { ejemplarObservable, libroObservable } from "../observer/Observable";
import { useListadoObservado } from "../observer/useListadoObservado";
import { Aviso, IconoAcento, TituloSeccion, colorEstado } from "../componentes/Basicos";
import Estanteria from "../componentes/Estanteria";
import Icono, { NombreIcono } from "../componentes/Icono";
import { useContador } from "../componentes/useContador";
import { formatearFechaLarga, saludo } from "../formato";
import { EstadoEjemplar } from "../types";

/** Estados de un ejemplar con su nombre en la leyenda. */
const ESTADOS: { estado: EstadoEjemplar; nombre: string }[] = [
  { estado: "DISPONIBLE", nombre: "Disponibles" },
  { estado: "PRESTADO", nombre: "Prestados" },
  { estado: "DANIADO", nombre: "Dañados" },
  { estado: "DADO_DE_BAJA", nombre: "Dados de baja" }
];

interface Resumen {
  libros: number;
  porEstado: Record<EstadoEjemplar, number>;
}

/** Retraso de la animación de entrada de cada bloque (aparecen uno tras otro). */
const retraso = (ms: number) => ({ "--retraso": `${ms}ms` }) as CSSProperties;

/**
 * Ventana principal: encabezado con el resumen del inventario (se actualiza solo, patrón
 * Observer), estado de los ejemplares y accesos a cada caso de uso. El menú superior tiene
 * las mismas opciones y "Ayuda".
 */
export default function MenuPrincipal() {
  const [resumen, setResumen] = useState<Resumen | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function cargar() {
    try {
      const [libros, ejemplares] = await Promise.all([listarLibros(), listarEjemplares()]);
      const porEstado = Object.fromEntries(
        ESTADOS.map(({ estado }) => [estado, ejemplares.filter((e) => e.estado === estado).length])
      ) as Record<EstadoEjemplar, number>;
      setResumen({ libros: libros.length, porEstado });
      setError(null);
    } catch (err) {
      setError(mensajeDeError(err));
    }
  }

  useListadoObservado(libroObservable, cargar);
  useListadoObservado(ejemplarObservable, cargar, { cargarAlInicio: false });

  const ahora = new Date();
  const totalEjemplares = resumen ? Object.values(resumen.porEstado).reduce((a, b) => a + b, 0) : null;

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
            <Cifra valor={resumen?.libros ?? null} leyenda="Títulos" />
            <Cifra valor={totalEjemplares} leyenda="Ejemplares" />
          </div>
        </div>
        <Estanteria />
      </section>

      <div className="aparecer" style={retraso(420)}>
        {error ? <Aviso>{error}</Aviso> : <TarjetaEstados resumen={resumen} total={totalEjemplares ?? 0} />}
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

/** Distribución de los ejemplares por estado: barra proporcional + leyenda. */
function TarjetaEstados({ resumen, total }: { resumen: Resumen | null; total: number }) {
  return (
    <section className="tarjeta estados" aria-label="Estado de los ejemplares">
      <h2 className="estados-titulo">Estado de los ejemplares</h2>
      <p className="leyenda">{resumen ? "Copias físicas registradas en el inventario" : "Cargando…"}</p>
      <div className="estados-barra">
        {ESTADOS.map(({ estado }) => (
          <span
            key={estado}
            style={{
              width: total === 0 || !resumen ? 0 : `${(resumen.porEstado[estado] / total) * 100}%`,
              background: colorEstado(estado)
            }}
          />
        ))}
      </div>
      <ul className="estados-leyenda">
        {ESTADOS.map(({ estado, nombre }) => (
          <li key={estado}>
            <span className="punto" style={{ background: colorEstado(estado) }} />
            <span>{nombre}</span>
            <strong>{resumen ? resumen.porEstado[estado] : "—"}</strong>
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
