import { Link } from "react-router-dom";
import Icono, { NombreIcono } from "./Icono";

const OPCIONES: { ruta: string; texto: string; icono: NombreIcono }[] = [
  { ruta: "agregar", texto: "Adicionar", icono: "agregar" },
  { ruta: "eliminar", texto: "Eliminar", icono: "eliminar" },
  { ruta: "actualizar", texto: "Actualizar", icono: "editar" },
  { ruta: "listar", texto: "Listar", icono: "lista" },
  { ruta: "consultar", texto: "Buscar por criterios", icono: "buscar" }
];

function Desplegable({ titulo, base }: { titulo: string; base: string }) {
  return (
    <div className="menu-desplegable">
      <button type="button" className="menu-boton" aria-haspopup="true">{titulo}</button>
      <div className="menu-desplegable-contenido">
        {OPCIONES.map((o) => (
          <Link key={o.ruta} to={`${base}/${o.ruta}`}>
            <Icono nombre={o.icono} tamano={18} />
            {o.texto}
          </Link>
        ))}
      </div>
    </div>
  );
}

/**
 * Menú principal (equivalente al menú de la ventana principal en un cliente de escritorio):
 * permite ir a cada caso de uso, y tiene un menú "Ayuda" con "Acerca de...".
 */
export default function BarraMenu() {
  return (
    <header className="barra-superior">
      <div className="barra-contenido">
        <Link to="/" className="marca">
          <span className="marca-icono"><Icono nombre="libreria" /></span>
          Librería
        </Link>
        <nav className="menu" aria-label="Menú principal">
          <Desplegable titulo="Libro" base="/libros" />
          <Desplegable titulo="Ejemplar" base="/ejemplares" />
          <div className="menu-desplegable">
            <button type="button" className="menu-boton" aria-haspopup="true">Ayuda</button>
            <div className="menu-desplegable-contenido">
              <Link to="/acerca-de">
                <Icono nombre="info" tamano={18} />
                Acerca de...
              </Link>
            </div>
          </div>
        </nav>
      </div>
    </header>
  );
}
