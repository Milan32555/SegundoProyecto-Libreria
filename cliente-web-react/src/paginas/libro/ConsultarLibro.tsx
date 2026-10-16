import { FormEvent, useState } from "react";
import { buscarLibroPorIsbn, buscarLibroPorTitulo } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import FichaLibro from "../../componentes/FichaLibro";
import { Libro } from "../../types";

type Criterio = "isbn" | "titulo";

const ETIQUETAS: Record<Criterio, string> = { isbn: "ISBN", titulo: "Título" };

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
    <div className="tarjeta">
      <h1>Consultar Libro</h1>
      {error && <p className="mensaje-error">{error}</p>}
      <form onSubmit={buscar}>
        <label>Buscar por
          <select value={criterio} onChange={(e) => setCriterio(e.target.value as Criterio)}>
            <option value="isbn">ISBN</option>
            <option value="titulo">Título</option>
          </select>
        </label>
        <label>{ETIQUETAS[criterio]}
          <input value={valor} onChange={(e) => setValor(e.target.value)} required />
        </label>
        <button type="submit" disabled={cargando}>Buscar</button>
      </form>

      {sinResultado && <p className="sin-datos">{sinResultado}</p>}
      {libro && <FichaLibro libro={libro} />}
    </div>
  );
}
