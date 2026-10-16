import { Encabezado, IconoAcento, Pastilla } from "../componentes/Basicos";

const INTEGRANTES = ["Misael Gallo Tangarife", "Sara Zambrano", "Santiago Guimel", "Alejandra González"];

const iniciales = (nombre: string) =>
  nombre.split(" ").filter(Boolean).slice(0, 2).map((parte) => parte[0]).join("");

/** Ayuda → Acerca de...: integrantes del equipo y versión de la aplicación. */
export default function AcercaDe() {
  return (
    <>
      <Encabezado etiqueta="Ayuda" titulo="Acerca de...">
        Sistema de gestión de libros y ejemplares (cliente web).
      </Encabezado>

      <article className="ficha" style={{ marginTop: 0 }}>
        <IconoAcento nombre="libreria" />
        <h2 className="ficha-titulo">Librería</h2>
        <p className="ficha-subtitulo">Cliente web · React + TypeScript</p>
        <p style={{ display: "flex", gap: "0.5rem", flexWrap: "wrap", marginBottom: 0 }}>
          <Pastilla>Versión: 1.0.0</Pastilla>
          <Pastilla color="var(--azul)">Servidor GraphQL · Java Spring Boot</Pastilla>
        </p>
      </article>

      <div className="dos-columnas seccion">
        <section className="tarjeta">
          <span className="etiqueta">Integrantes del equipo</span>
          <ul className="integrantes">
            {INTEGRANTES.map((nombre) => (
              <li key={nombre}>
                <span className="avatar" aria-hidden="true">{iniciales(nombre)}</span>
                {nombre}
              </li>
            ))}
          </ul>
        </section>
        <section className="tarjeta">
          <span className="etiqueta">Curso</span>
          <p className="titulo-serif" style={{ fontSize: "1.25rem", margin: "0.6rem 0 0.2rem" }}>Diseño de Soluciones</p>
          <p className="descripcion">Universidad de Ibagué · Segundo Proyecto 2026B</p>
          <span className="etiqueta" style={{ marginTop: "1.4rem" }}>Arquitectura</span>
          <p className="descripcion">
            Un servidor GraphQL (Java · Spring Boot) y dos clientes: este cliente web (React) y la app móvil (Flutter).
          </p>
        </section>
      </div>
    </>
  );
}
