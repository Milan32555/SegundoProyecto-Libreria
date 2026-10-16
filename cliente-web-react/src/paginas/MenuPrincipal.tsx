import { useState } from "react";
import { Link } from "react-router-dom";
import { listarLibros } from "../graphql/servicioLibro";
import { listarEjemplares } from "../graphql/servicioEjemplar";
import { mensajeDeError } from "../graphql/clienteGraphQL";
import { ejemplarObservable, libroObservable } from "../observer/Observable";
import { useListadoObservado } from "../observer/useListadoObservado";
import { Aviso, EnVivo, IconoAcento, Pastilla } from "../componentes/Basicos";
import Icono, { NombreIcono } from "../componentes/Icono";

interface Resumen {
  libros: number;
  ejemplares: number;
  disponibles: number;
  prestados: number;
}

const plural = (n: number, singular: string, varios: string) => `${n} ${n === 1 ? singular : varios}`;

/**
 * Ventana principal: resumen del inventario (se actualiza solo, patrón Observer)
 * y accesos a cada caso de uso. El menú superior tiene las mismas opciones y "Ayuda".
 */
export default function MenuPrincipal() {
  const [resumen, setResumen] = useState<Resumen | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function cargar() {
    try {
      const [libros, ejemplares] = await Promise.all([listarLibros(), listarEjemplares()]);
      setResumen({
        libros: libros.length,
        ejemplares: ejemplares.length,
        disponibles: ejemplares.filter((e) => e.estado === "DISPONIBLE").length,
        prestados: ejemplares.filter((e) => e.estado === "PRESTADO").length
      });
      setError(null);
    } catch (err) {
      setError(mensajeDeError(err));
    }
  }

  useListadoObservado(libroObservable, cargar);
  useListadoObservado(ejemplarObservable, cargar, { cargarAlInicio: false });

  return (
    <>
      <header className="encabezado">
        <span className="etiqueta etiqueta-acento">Segundo proyecto · 2026B</span>
        <h1 className="inicio-titulo">Tu librería,<br />en orden.</h1>
        <p className="descripcion">Libros y ejemplares sincronizados con el servidor GraphQL.</p>
      </header>

      {error ? (
        <Aviso>{error}</Aviso>
      ) : (
        <section className="portada" aria-label="Inventario">
          <span className="marca-agua"><Icono nombre="libreria" tamano={190} /></span>
          <div className="portada-cabecera">
            <span className="etiqueta">Inventario</span>
            <EnVivo />
          </div>
          <div className="portada-cifras">
            <div><div className="cifra">{resumen?.libros ?? "—"}</div><span className="cifra-leyenda">libros</span></div>
            <div><div className="cifra">{resumen?.ejemplares ?? "—"}</div><span className="cifra-leyenda">ejemplares</span></div>
          </div>
          <Pastilla color="#9fe6be">{plural(resumen?.disponibles ?? 0, "disponible", "disponibles")}</Pastilla>
          <Pastilla color="#bcd4ff">{plural(resumen?.prestados ?? 0, "prestado", "prestados")}</Pastilla>
        </section>
      )}

      <GrupoAcciones titulo="Libros" base="/libros" objeto="libros" />
      <GrupoAcciones titulo="Ejemplares" base="/ejemplares" objeto="ejemplares" />
    </>
  );
}

function GrupoAcciones({ titulo, base, objeto }: { titulo: string; base: string; objeto: string }) {
  return (
    <section className="seccion">
      <span className="etiqueta">{titulo}</span>
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
      <IconoAcento nombre={icono} color={color} />
      <span>
        <strong>{titulo}</strong>
        <small>{detalle}</small>
      </span>
      {destacada && <span className="flecha"><Icono nombre="flecha" /></span>}
    </Link>
  );
}
