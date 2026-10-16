import { FormEvent, useState } from "react";
import { buscarEjemplarPorCodigo, eliminarEjemplar } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { Aviso, Encabezado } from "../../componentes/Basicos";
import FichaEjemplar from "../../componentes/FichaEjemplar";
import Icono from "../../componentes/Icono";
import { Ejemplar } from "../../types";

/**
 * Caso de uso: Eliminar Ejemplar. Primero se busca y se muestra TODA su información;
 * solo después de confirmar se elimina.
 */
export default function EliminarEjemplar() {
  const [codigo, setCodigo] = useState("");
  const [ejemplar, setEjemplar] = useState<Ejemplar | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [exito, setExito] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function buscar(e: FormEvent) {
    e.preventDefault();
    setError(null); setExito(null); setEjemplar(null);
    setCargando(true);
    try {
      const resultado = await buscarEjemplarPorCodigo(codigo);
      if (!resultado) {
        setError(`No se encontró ningún ejemplar con el código "${codigo}".`);
      } else {
        setEjemplar(resultado);
      }
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  async function confirmarEliminacion() {
    if (!ejemplar) return;
    setCargando(true); setError(null);
    try {
      await eliminarEjemplar(ejemplar.codigo);
      setExito(`Ejemplar "${ejemplar.codigo}" eliminado correctamente.`);
      ejemplarObservable.notificar();
      setEjemplar(null);
      setCodigo("");
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  return (
    <>
      <Encabezado etiqueta="Ejemplar" titulo="Eliminar ejemplar">
        Busca el ejemplar por su código para revisar toda su información antes de eliminarlo.
      </Encabezado>
      {exito && <Aviso tipo="exito">{exito}</Aviso>}

      <form className="tarjeta filtros-fila" role="search" onSubmit={buscar}>
        <label>Código del ejemplar a eliminar
          <input value={codigo} onChange={(e) => setCodigo(e.target.value)} required />
        </label>
        <button type="submit" disabled={cargando}><Icono nombre="buscar" /> Buscar</button>
      </form>

      {!ejemplar && error && <Aviso>{error}</Aviso>}

      {ejemplar && (
        <>
          <FichaEjemplar ejemplar={ejemplar} />
          <Aviso tipo="advertencia">¿Seguro que desea eliminar este ejemplar? Esta acción no se puede deshacer.</Aviso>
          {error && <Aviso>{error}</Aviso>}
          <div className="acciones">
            <button type="button" className="peligro" onClick={confirmarEliminacion} disabled={cargando}>
              <Icono nombre="eliminar" /> Confirmar eliminación
            </button>
            <button type="button" className="secundario" onClick={() => setEjemplar(null)}>Cancelar</button>
          </div>
        </>
      )}
    </>
  );
}
