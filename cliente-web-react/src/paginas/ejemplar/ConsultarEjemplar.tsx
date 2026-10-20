import { useState } from "react";
import { buscarEjemplarPorCodigo } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import FichaEjemplar from "../../componentes/FichaEjemplar";
import { Banner } from "../../componentes/ui/Banner";
import { BuscadorClave } from "../../componentes/ui/BuscadorClave";
import { Encabezado } from "../../componentes/ui/Encabezado";
import { SinResultados } from "../../componentes/ui/SinResultados";
import { Ejemplar } from "../../types";

/** Caso de uso: Consultar UN SOLO Ejemplar por su código. */
export default function ConsultarEjemplar() {
  const [ejemplar, setEjemplar] = useState<Ejemplar | null>(null);
  const [sinResultado, setSinResultado] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function buscar(codigo: string) {
    setError(null); setEjemplar(null); setSinResultado(null);
    setCargando(true);
    try {
      const resultado = await buscarEjemplarPorCodigo(codigo);
      setEjemplar(resultado);
      if (!resultado) setSinResultado(`No hay ningún ejemplar con el código «${codigo}».`);
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  return (
    <>
      <Encabezado seccion="Ejemplares" titulo="Consultar ejemplar" descripcion="Busca una copia por su código (sin importar mayúsculas)." />
      <div className="pila">
        <BuscadorClave etiqueta="Código del ejemplar" placeholder="EJ-001" cargando={cargando} alBuscar={buscar} />
        {error && <Banner titulo="No se pudo consultar">{error}</Banner>}
        {sinResultado && <SinResultados titulo="Sin resultados">{sinResultado}</SinResultados>}
        {ejemplar && <FichaEjemplar ejemplar={ejemplar} />}
      </div>
    </>
  );
}
