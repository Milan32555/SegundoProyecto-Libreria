import { useState } from "react";
import { buscarLibroPorIsbn, buscarLibroPorTitulo } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import FichaLibro from "../../componentes/FichaLibro";
import { Banner } from "../../componentes/ui/Banner";
import { BuscadorClave } from "../../componentes/ui/BuscadorClave";
import { Encabezado } from "../../componentes/ui/Encabezado";
import { Segmentado } from "../../componentes/ui/Segmentado";
import { SinResultados } from "../../componentes/ui/SinResultados";
import { Libro } from "../../types";

type Criterio = "isbn" | "titulo";

const CRITERIOS = [
  { valor: "isbn", texto: "Por ISBN" },
  { valor: "titulo", texto: "Por título" }
] as const;

/** Caso de uso: Consultar UN SOLO Libro por un criterio (ISBN o título). */
export default function ConsultarLibro() {
  const [criterio, setCriterio] = useState<Criterio>("isbn");
  const [libro, setLibro] = useState<Libro | null>(null);
  const [sinResultado, setSinResultado] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function buscar(valor: string) {
    setError(null); setLibro(null); setSinResultado(null);
    setCargando(true);
    try {
      const resultado = criterio === "isbn" ? await buscarLibroPorIsbn(valor) : await buscarLibroPorTitulo(valor);
      setLibro(resultado);
      if (!resultado) {
        setSinResultado(criterio === "isbn" ? `No hay ningún libro con el ISBN «${valor}».` : `No hay ningún libro titulado «${valor}».`);
      }
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  return (
    <>
      <Encabezado
        seccion="Libros"
        titulo="Consultar libro"
        descripcion="Busca un solo libro por su ISBN o por su título (sin importar mayúsculas ni tildes)."
      />

      <div className="pila">
        <BuscadorClave
          etiqueta={criterio === "isbn" ? "ISBN" : "Título"}
          placeholder={criterio === "isbn" ? "978-0307474728" : "Cien años de soledad"}
          cargando={cargando}
          alBuscar={buscar}
          antes={<Segmentado etiqueta="Buscar por" nombre="criterio" valor={criterio} opciones={CRITERIOS} alCambiar={setCriterio} />}
        />
        {error && <Banner titulo="No se pudo consultar">{error}</Banner>}
        {sinResultado && <SinResultados titulo="Sin resultados">{sinResultado}</SinResultados>}
        {libro && <FichaLibro libro={libro} />}
      </div>
    </>
  );
}
