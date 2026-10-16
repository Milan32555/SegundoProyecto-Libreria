import { FormEvent, useState } from "react";
import { buscarLibroPorIsbn, buscarLibroPorTitulo } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { Aviso, Encabezado, SelectorChips } from "../../componentes/Basicos";
import FichaLibro from "../../componentes/FichaLibro";
import Icono from "../../componentes/Icono";
import { Libro } from "../../types";

type Criterio = "isbn" | "titulo";

const CRITERIOS: readonly Criterio[] = ["isbn", "titulo"];
const ETIQUETAS: Record<Criterio, string> = { isbn: "ISBN", titulo: "Título" };
const OPCIONES_CRITERIO: Record<Criterio, string> = { isbn: "Por ISBN", titulo: "Por título" };

/** Caso de uso: Buscar/Consultar UN SOLO Libro a partir de un criterio (ISBN o título). */
export default function ConsultarLibro() {
  const [criterio, setCriterio] = useState<Criterio>("isbn");
  const [valor, setValor] = useState("");
  const [libro, setLibro] = useState<Libro | null>(null);
  const [sinResultado, setSinResultado] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function buscar(e: FormEvent) {
    e.preventDefault();
    setError(null); setLibro(null); setSinResultado(null);
    setCargando(true);
    try {
      const resultado = criterio === "isbn"
        ? await buscarLibroPorIsbn(valor)
        : await buscarLibroPorTitulo(valor);
      setLibro(resultado);
      if (!resultado) {
        setSinResultado(`No se encontró ningún libro con ${criterio === "isbn" ? "el ISBN" : "el título"} "${valor}".`);
      }
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  return (
    <>
      <Encabezado etiqueta="Libro" titulo="Buscar un libro">
        Consulta un solo libro por su ISBN o por su título exacto.
      </Encabezado>

      <form className="tarjeta" role="search" onSubmit={buscar}>
        <SelectorChips etiqueta="Buscar por" nombre="criterio" opciones={CRITERIOS} valor={criterio}
                       etiquetaDe={(c) => OPCIONES_CRITERIO[c]}
                       alCambiar={(c) => setCriterio(c || criterio)} />
        <div className="filtros-fila">
          <label>{ETIQUETAS[criterio]}
            <input value={valor} onChange={(e) => setValor(e.target.value)} required />
          </label>
          <button type="submit" disabled={cargando}><Icono nombre="buscar" /> Buscar</button>
        </div>
      </form>

      {error && <Aviso>{error}</Aviso>}
      {sinResultado && <Aviso tipo="advertencia">{sinResultado}</Aviso>}
      {libro && <FichaLibro libro={libro} />}
    </>
  );
}
