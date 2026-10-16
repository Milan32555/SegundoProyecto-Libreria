import { FormEvent, useState } from "react";
import { buscarEjemplarPorCodigo } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { Aviso, Encabezado } from "../../componentes/Basicos";
import FichaEjemplar from "../../componentes/FichaEjemplar";
import Icono from "../../componentes/Icono";
import { Ejemplar } from "../../types";

/** Caso de uso: Buscar/Consultar UN SOLO Ejemplar a partir de su código. */
export default function ConsultarEjemplar() {
  const [codigo, setCodigo] = useState("");
  const [ejemplar, setEjemplar] = useState<Ejemplar | null>(null);
  const [sinResultado, setSinResultado] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function buscar(e: FormEvent) {
    e.preventDefault();
    setError(null); setEjemplar(null); setSinResultado(null);
    setCargando(true);
    try {
      const resultado = await buscarEjemplarPorCodigo(codigo);
      setEjemplar(resultado);
      if (!resultado) {
        setSinResultado(`No se encontró ningún ejemplar con el código "${codigo}".`);
      }
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  return (
    <>
      <Encabezado etiqueta="Ejemplar" titulo="Buscar un ejemplar">
        Consulta un solo ejemplar por su código.
      </Encabezado>

      <form className="tarjeta filtros-fila" role="search" onSubmit={buscar}>
        <label>Código del ejemplar
          <input value={codigo} onChange={(e) => setCodigo(e.target.value)} required />
        </label>
        <button type="submit" disabled={cargando}><Icono nombre="buscar" /> Buscar</button>
      </form>

      {error && <Aviso>{error}</Aviso>}
      {sinResultado && <Aviso tipo="advertencia">{sinResultado}</Aviso>}
      {ejemplar && <FichaEjemplar ejemplar={ejemplar} />}
    </>
  );
}
