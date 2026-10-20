import { Link, NavLink } from "react-router-dom";
import { House, Info, Library, List, LucideIcon, Pencil, Plus, Search, Trash2 } from "lucide-react";

const VERSION = "1.0.0";

/** Un caso de uso por opción, en el orden en que se usan más. */
const CASOS_DE_USO: { ruta: string; texto: string; icono: LucideIcon }[] = [
  { ruta: "listar", texto: "Listar", icono: List },
  { ruta: "consultar", texto: "Consultar", icono: Search },
  { ruta: "agregar", texto: "Adicionar", icono: Plus },
  { ruta: "actualizar", texto: "Actualizar", icono: Pencil },
  { ruta: "eliminar", texto: "Eliminar", icono: Trash2 }
];

/** Logotipo: ícono + nombre en Literata. */
export function Marca({ alNavegar }: { alNavegar?: () => void }) {
  return (
    <Link to="/" className="marca" onClick={alNavegar}>
      <span className="marca-icono" aria-hidden="true"><Library size={16} /></span>
      <span className="marca-nombre">Librería</span>
    </Link>
  );
}

function Enlace({ a, texto, icono: Icono, alNavegar, exacto = false }: {
  a: string; texto: string; icono: LucideIcon; alNavegar?: () => void; exacto?: boolean;
}) {
  return (
    <li>
      <NavLink to={a} end={exacto} className="nav-enlace" onClick={alNavegar}>
        <Icono size={16} aria-hidden="true" />
        {texto}
      </NavLink>
    </li>
  );
}

function Grupo({ id, titulo, base, alNavegar }: { id: string; titulo: string; base: string; alNavegar?: () => void }) {
  return (
    <div className="nav-grupo">
      <p className="nav-seccion" id={id}>{titulo}</p>
      <ul aria-labelledby={id}>
        {CASOS_DE_USO.map((c) => (
          <Enlace key={c.ruta} a={`${base}/${c.ruta}`} texto={c.texto} icono={c.icono} alNavegar={alNavegar} />
        ))}
      </ul>
    </div>
  );
}

/**
 * Menú principal (el de la ventana principal en una aplicación de escritorio): cada opción
 * abre la pantalla de un único caso de uso, y la sección "Ayuda" tiene "Acerca de...".
 * Se usa en el menú lateral fijo y, en celulares, dentro del cajón.
 */
export default function Navegacion({ prefijo = "nav", alNavegar }: { prefijo?: string; alNavegar?: () => void }) {
  return (
    <nav className="nav" aria-label="Menú principal">
      <ul className="nav-grupo">
        <Enlace a="/" texto="Inicio" icono={House} alNavegar={alNavegar} exacto />
      </ul>
      <Grupo id={`${prefijo}-libros`} titulo="Libros" base="/libros" alNavegar={alNavegar} />
      <Grupo id={`${prefijo}-ejemplares`} titulo="Ejemplares" base="/ejemplares" alNavegar={alNavegar} />
      <div className="nav-grupo">
        <p className="nav-seccion" id={`${prefijo}-ayuda`}>Ayuda</p>
        <ul aria-labelledby={`${prefijo}-ayuda`}>
          <Enlace a="/acerca-de" texto="Acerca de..." icono={Info} alNavegar={alNavegar} />
        </ul>
      </div>
    </nav>
  );
}

export function PieMenu() {
  return <p className="menu-pie">Versión {VERSION}</p>;
}
