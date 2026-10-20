import { useCallback, useEffect, useState } from "react";
import { Database, Monitor, RotateCw, Server, Smartphone } from "lucide-react";
import { URL_GRAPHQL } from "../graphql/clienteGraphQL";
import { consultarRevisionLibros } from "../graphql/servicioLibro";
import { Boton } from "../componentes/ui/Boton";
import { Encabezado } from "../componentes/ui/Encabezado";

const VERSION = "1.0.0";

const INTEGRANTES = ["Misael Gallo Tangarife", "Sara Zambrano", "Santiago Guimel", "Alejandra González"];

const PATRONES = [
  { nombre: "MVC", donde: "Modelos y servicios de datos, observadores y pantallas en paquetes separados, en los tres proyectos." },
  { nombre: "Singleton", donde: "Un único ClienteGraphQL en cada cliente y repositorios únicos en el servidor." },
  { nombre: "Observer", donde: "Las pantallas de Listar y el Inicio se actualizan solas cuando cambian los datos." },
  { nombre: "Builder", donde: "LibroBuilder y EjemplarBuilder construyen los objetos en el servidor." },
  { nombre: "SOLID", donde: "Una responsabilidad por clase e inyección de dependencias en el servidor." }
];

const TECNOLOGIAS = ["Java 17", "Spring Boot", "Spring for GraphQL", "React 18", "TypeScript", "Radix UI", "Flutter", "Dart"];

const iniciales = (nombre: string) => nombre.split(" ").slice(0, 2).map((parte) => parte[0]).join("");

/** Ayuda → Acerca de...: versión, integrantes, arquitectura (con el estado real del servidor) y patrones. */
export default function AcercaDe() {
  return (
    <>
      <Encabezado seccion="Ayuda" titulo="Acerca de" descripcion="Librería: gestión del inventario de libros y ejemplares." />

      <div className="pila">
        <section className="panel" aria-labelledby="titulo-aplicacion">
          <header className="panel-cabecera">
            <h2 className="panel-titulo" id="titulo-aplicacion">Aplicación</h2>
          </header>
          <dl className="panel-cuerpo dato-lista">
            <dt>Nombre</dt>
            <dd>Librería · Cliente web</dd>
            <dt>Versión</dt>
            <dd>{VERSION}</dd>
            <dt>Proyecto</dt>
            <dd>Segundo Proyecto · Diseño de Soluciones · Universidad de Ibagué · 2026B</dd>
          </dl>
        </section>

        <section className="panel" aria-labelledby="titulo-equipo">
          <header className="panel-cabecera">
            <h2 className="panel-titulo" id="titulo-equipo">Integrantes</h2>
            <span className="panel-subtitulo">{INTEGRANTES.length} personas</span>
          </header>
          <ul className="panel-cuerpo equipo">
            {INTEGRANTES.map((nombre) => (
              <li key={nombre} className="integrante">
                <span className="avatar" aria-hidden="true">{iniciales(nombre)}</span>
                <span>{nombre}</span>
              </li>
            ))}
          </ul>
        </section>

        <section className="panel" aria-labelledby="titulo-arquitectura">
          <header className="panel-cabecera">
            <h2 className="panel-titulo" id="titulo-arquitectura">Arquitectura</h2>
          </header>
          <div className="panel-cuerpo">
            <Diagrama />
          </div>
        </section>

        <section className="panel" aria-labelledby="titulo-patrones">
          <header className="panel-cabecera">
            <h2 className="panel-titulo" id="titulo-patrones">Patrones de diseño</h2>
          </header>
          <div className="tabla-contenedor">
            <table className="tabla patrones">
              <caption className="visualmente-oculto">Patrones de diseño y dónde se aplican</caption>
              <thead>
                <tr><th scope="col">Patrón</th><th scope="col">Dónde se aplica</th></tr>
              </thead>
              <tbody>
                {PATRONES.map((p) => (
                  <tr key={p.nombre}><td>{p.nombre}</td><td>{p.donde}</td></tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

        <section className="panel" aria-labelledby="titulo-tecnologias">
          <header className="panel-cabecera">
            <h2 className="panel-titulo" id="titulo-tecnologias">Tecnologías</h2>
          </header>
          <ul className="panel-cuerpo tecnologias">
            {TECNOLOGIAS.map((t) => <li key={t} className="insignia insignia-categoria">{t}</li>)}
          </ul>
        </section>
      </div>

      <p className="pie-pagina">© 2026 Equipo Librería · Universidad de Ibagué</p>
    </>
  );
}

type EstadoServidor = { tipo: "comprobando" } | { tipo: "conectado"; ms: number } | { tipo: "sin-conexion" };

/**
 * Diagrama estático de la arquitectura distribuida. Debajo, el resultado de una consulta real
 * al servidor y cuánto tardó.
 */
function Diagrama() {
  const [estado, setEstado] = useState<EstadoServidor>({ tipo: "comprobando" });

  const medir = useCallback(async () => {
    setEstado({ tipo: "comprobando" });
    const inicio = performance.now();
    try {
      await consultarRevisionLibros();
      setEstado({ tipo: "conectado", ms: Math.round(performance.now() - inicio) });
    } catch {
      setEstado({ tipo: "sin-conexion" });
    }
  }, []);

  useEffect(() => {
    void medir();
  }, [medir]);

  return (
    <figure className="diagrama" aria-label="Arquitectura: dos clientes se comunican con el servidor GraphQL, que guarda los datos en listas">
      <div className="diagrama-fila">
        <Nodo icono={Monitor} titulo="Cliente web" detalle="React · TypeScript" />
        <Nodo icono={Smartphone} titulo="App móvil" detalle="Flutter · Dart" />
      </div>
      <span className="conector">GraphQL sobre HTTP (POST)</span>
      <Nodo icono={Server} titulo="Servidor GraphQL" detalle="Java 17 · Spring Boot · toda la lógica de negocio" />
      <span className="conector">en memoria</span>
      <Nodo icono={Database} titulo="Repositorios" detalle="List<Libro> · List<Ejemplar>" />

      <figcaption className="estado-servidor" role="status">
        {estado.tipo === "comprobando" && <span>Comprobando el servidor…</span>}
        {estado.tipo === "conectado" && <span>Servidor conectado · {estado.ms} ms</span>}
        {estado.tipo === "sin-conexion" && <span>Sin conexión con el servidor</span>}
        <span className="apagado">({URL_GRAPHQL})</span>
        <Boton variante="fantasma" icono={RotateCw} onClick={() => void medir()} disabled={estado.tipo === "comprobando"}>
          Medir de nuevo
        </Boton>
      </figcaption>
    </figure>
  );
}

function Nodo({ icono: Icono, titulo, detalle }: { icono: typeof Server; titulo: string; detalle: string }) {
  return (
    <div className="nodo">
      <Icono size={20} aria-hidden="true" />
      <div>
        <strong>{titulo}</strong>
        <small>{detalle}</small>
      </div>
    </div>
  );
}
