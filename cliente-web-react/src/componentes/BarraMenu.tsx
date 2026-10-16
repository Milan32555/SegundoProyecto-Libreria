import { Link } from "react-router-dom";

/**
 * Menú principal (equivalente al menú de la ventana principal en un cliente de escritorio):
 * permite ir a cada caso de uso, y tiene un menú "Ayuda" con "Acerca de...".
 */
export default function BarraMenu() {
  return (
    <nav className="barra-superior">
      <Link to="/">📚 Librería</Link>

      <div className="menu-desplegable" tabIndex={0}>
        <span>Libro ▾</span>
        <div className="menu-desplegable-contenido">
          <Link to="/libros/agregar">Adicionar</Link>
          <Link to="/libros/eliminar">Eliminar</Link>
          <Link to="/libros/actualizar">Actualizar</Link>
          <Link to="/libros/listar">Listar</Link>
          <Link to="/libros/consultar">Buscar por criterios</Link>
        </div>
      </div>

      <div className="menu-desplegable" tabIndex={0}>
        <span>Ejemplar ▾</span>
        <div className="menu-desplegable-contenido">
          <Link to="/ejemplares/agregar">Adicionar</Link>
          <Link to="/ejemplares/eliminar">Eliminar</Link>
          <Link to="/ejemplares/actualizar">Actualizar</Link>
          <Link to="/ejemplares/listar">Listar</Link>
          <Link to="/ejemplares/consultar">Buscar por criterios</Link>
        </div>
      </div>

      <div className="menu-desplegable" tabIndex={0}>
        <span>Ayuda ▾</span>
        <div className="menu-desplegable-contenido">
          <Link to="/acerca-de">Acerca de...</Link>
        </div>
      </div>
    </nav>
  );
}
