import { CSSProperties, useCallback, useEffect, useState } from "react";
import { Encabezado, IconoAcento, Pastilla, TituloSeccion } from "../componentes/Basicos";
import Estanteria from "../componentes/Estanteria";
import Icono, { NombreIcono } from "../componentes/Icono";
import { URL_GRAPHQL } from "../graphql/clienteGraphQL";
import { consultarRevisionLibros } from "../graphql/servicioLibro";

const VERSION = "1.0.0";

/** Integrantes con el color de su avatar (tonos de la estantería). */
const INTEGRANTES = [
  { nombre: "Misael Gallo Tangarife", color: "#1f5c4a" },
  { nombre: "Sara Zambrano", color: "#8e3b36" },
  { nombre: "Santiago Guimel", color: "#2f4a6b" },
  { nombre: "Alejandra González", color: "#a8741f" }
];

const PATRONES: { icono: NombreIcono; nombre: string; detalle: string }[] = [
  { icono: "capas", nombre: "MVC", detalle: "Modelos, servicios de datos y pantallas separados en cada proyecto." },
  { icono: "uno", nombre: "Singleton", detalle: "Un único cliente GraphQL y repositorios únicos en el servidor." },
  { icono: "construccion", nombre: "Builder", detalle: "LibroBuilder y EjemplarBuilder construyen los objetos en el servidor." },
  { icono: "ver", nombre: "Observer", detalle: "Las pantallas se actualizan solas cuando cambian los datos." },
  { icono: "verificado", nombre: "SOLID", detalle: "Una responsabilidad por clase e inyección de dependencias." }
];

const TECNOLOGIAS = ["Java 17", "Spring Boot 4", "Spring for GraphQL", "React 18", "TypeScript", "Vite", "Flutter", "Dart"];

const iniciales = (nombre: string) =>
  nombre.split(" ").filter(Boolean).slice(0, 2).map((parte) => parte[0]).join("");

const retraso = (ms: number) => ({ "--retraso": `${ms}ms` }) as CSSProperties;

/**
 * Ayuda → Acerca de...: la aplicación y su versión, el equipo, la arquitectura del sistema
 * (con el estado real del servidor), los patrones de diseño y las tecnologías.
 */
export default function AcercaDe() {
  return (
    <>
      <Encabezado etiqueta="Ayuda" titulo="Acerca de...">
        La aplicación, el equipo que la construyó y cómo está hecha por dentro.
      </Encabezado>

      <section className="producto aparecer" style={retraso(0)} aria-label="Aplicación">
        <div className="producto-contenido">
          <span className="producto-icono"><Icono nombre="libreria" tamano={38} /></span>
          <h2 className="producto-nombre">Librería</h2>
          <p className="producto-descripcion">
            Sistema de gestión de inventario para librerías: títulos, ejemplares y su estado.
          </p>
          <div className="insignias">
            <span className="insignia"><Icono nombre="version" tamano={16} />Versión {VERSION}</span>
            <span className="insignia"><Icono nombre="web" tamano={16} />Web · React</span>
          </div>
        </div>
        <Estanteria />
      </section>

      <section className="seccion aparecer" style={retraso(150)}>
        <TituloSeccion icono="equipo" titulo="Equipo de desarrollo" detalle={`${INTEGRANTES.length} integrantes`} />
        <ul className="equipo">
          {INTEGRANTES.map(({ nombre, color }) => (
            <li key={nombre} className="integrante">
              <span className="avatar" style={{ "--color": color } as CSSProperties} aria-hidden="true">
                {iniciales(nombre)}
              </span>
              <strong>{nombre}</strong>
            </li>
          ))}
        </ul>
      </section>

      <section className="seccion aparecer" style={retraso(250)}>
        <TituloSeccion icono="red" titulo="Arquitectura del sistema" />
        <DiagramaArquitectura />
      </section>

      <section className="seccion aparecer" style={retraso(350)}>
        <TituloSeccion icono="arquitectura" titulo="Patrones de diseño" />
        <ul className="patrones">
          {PATRONES.map(({ icono, nombre, detalle }) => (
            <li key={nombre}>
              <IconoAcento nombre={icono} />
              <div>
                <strong>{nombre}</strong>
                <p>{detalle}</p>
              </div>
            </li>
          ))}
        </ul>
      </section>

      <section className="seccion aparecer" style={retraso(450)}>
        <TituloSeccion icono="codigo" titulo="Tecnologías" />
        <ul className="tecnologias">
          {TECNOLOGIAS.map((t) => <li key={t}>{t}</li>)}
        </ul>
      </section>

      <footer className="pie aparecer" style={retraso(550)}>
        <Icono nombre="libreria" tamano={22} />
        <strong>Diseño de Soluciones · Universidad de Ibagué</strong>
        <span>Segundo Proyecto · 2026B</span>
        <small>© 2026 Equipo Librería</small>
      </footer>
    </>
  );
}

type EstadoServidor = { tipo: "comprobando" } | { tipo: "conectado"; ms: number } | { tipo: "sin-conexion" };

/**
 * Diagrama de la arquitectura distribuida: los dos clientes envían peticiones GraphQL al
 * servidor (paquetes animados) y el servidor guarda los datos en listas. El nodo del servidor
 * muestra el resultado de una consulta real y cuánto tardó.
 */
function DiagramaArquitectura() {
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
    <div className="diagrama">
      <div className="diagrama-clientes">
        <Nodo icono="web" titulo="Cliente web" detalle="React · TypeScript" actual />
        <Nodo icono="movil" titulo="App móvil" detalle="Flutter · Dart" />
      </div>

      <div className="conexion conexion-ramas">
        <span className="linea linea-v" style={{ left: "25%", top: 0, height: "50%" }} />
        <span className="linea linea-v" style={{ left: "75%", top: 0, height: "50%" }} />
        <span className="linea linea-h" style={{ left: "25%", width: "25%" }} />
        <span className="linea linea-h linea-inversa" style={{ left: "50%", width: "25%" }} />
        <span className="linea linea-v" style={{ left: "50%", top: "50%", height: "50%" }} />
        <span className="paquete paquete-izquierda" />
        <span className="paquete paquete-derecha" />
        <span className="paquete paquete-tronco" />
        <span className="protocolo">GraphQL · HTTP POST</span>
      </div>

      <div className="nodo nodo-horizontal">
        <IconoAcento nombre="servidor" />
        <div className="nodo-textos">
          <strong>Servidor GraphQL</strong>
          <small>Java 17 · Spring Boot</small>
        </div>
        <button
          type="button"
          className={`estado-servidor estado-${estado.tipo}`}
          onClick={() => void medir()}
          title="Medir de nuevo"
        >
          {estado.tipo === "comprobando" && <span className="girando" aria-hidden="true" />}
          {estado.tipo === "conectado" && <><span className="punto" />Conectado<small>{estado.ms} ms</small></>}
          {estado.tipo === "sin-conexion" && <><span className="punto" />Sin conexión</>}
          {estado.tipo === "comprobando" && "Comprobando…"}
        </button>
      </div>

      <div className="conexion conexion-corta" aria-hidden="true">
        <span className="linea linea-v" style={{ left: "50%", top: 0, height: "100%" }} />
        <span className="paquete paquete-datos" />
      </div>

      <div className="nodo nodo-horizontal">
        <IconoAcento nombre="almacen" />
        <div className="nodo-textos">
          <strong>Repositorios en memoria</strong>
          <small>List&lt;Libro&gt; · List&lt;Ejemplar&gt;</small>
        </div>
      </div>

      <p className="diagrama-url"><Icono nombre="enlace" tamano={16} />{URL_GRAPHQL}</p>
    </div>
  );
}

function Nodo({ icono, titulo, detalle, actual = false }: {
  icono: NombreIcono; titulo: string; detalle: string; actual?: boolean;
}) {
  return (
    <div className={actual ? "nodo nodo-actual" : "nodo"}>
      <IconoAcento nombre={icono} />
      <strong>{titulo}</strong>
      <small>{detalle}</small>
      {actual && <Pastilla>Este navegador</Pastilla>}
    </div>
  );
}
