import { FormEvent, useState } from "react";
import { actualizarEjemplar, buscarEjemplarPorCodigo } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { aValorDeInputFecha } from "../../formato";
import { Aviso, Encabezado, SelectorChips } from "../../componentes/Basicos";
import Icono from "../../componentes/Icono";
import { ESTADOS_EJEMPLAR, EstadoEjemplar, Ejemplar, etiquetaEstado } from "../../types";

/**
 * Caso de uso: Actualizar Ejemplar. Primero se busca y se muestra TODA su información
 * actual; luego el usuario la modifica y confirma.
 */
export default function ActualizarEjemplar() {
  const [codigo, setCodigo] = useState("");
  const [ejemplar, setEjemplar] = useState<Ejemplar | null>(null);

  const [estado, setEstado] = useState<EstadoEjemplar>("DISPONIBLE");
  const [ubicacion, setUbicacion] = useState("");
  const [fechaIngreso, setFechaIngreso] = useState("");
  const [precioReposicion, setPrecioReposicion] = useState("");

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
        setEstado(resultado.estado);
        setUbicacion(resultado.ubicacion);
        setFechaIngreso(aValorDeInputFecha(resultado.fechaIngreso));
        setPrecioReposicion(String(resultado.precioReposicion));
      }
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  async function guardarCambios(e: FormEvent) {
    e.preventDefault();
    if (!ejemplar) return;
    setCargando(true); setError(null);
    try {
      await actualizarEjemplar(ejemplar.codigo, {
        estado, ubicacion, fechaIngreso,
        precioReposicion: Number(precioReposicion)
      });
      setExito(`Ejemplar "${ejemplar.codigo}" actualizado correctamente.`);
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
      <Encabezado etiqueta="Ejemplar" titulo="Actualizar ejemplar">
        Busca el ejemplar por su código: verás sus datos actuales y podrás modificarlos.
      </Encabezado>
      {error && <Aviso>{error}</Aviso>}
      {exito && <Aviso tipo="exito">{exito}</Aviso>}

      {!ejemplar && (
        <form className="tarjeta filtros-fila" role="search" onSubmit={buscar}>
          <label>Código del ejemplar a actualizar
            <input value={codigo} onChange={(e) => setCodigo(e.target.value)} required />
          </label>
          <button type="submit" disabled={cargando}><Icono nombre="buscar" /> Buscar</button>
        </form>
      )}

      {ejemplar && (
        <form className="tarjeta" onSubmit={guardarCambios}>
          <p className="nota-edicion">
            Editando el ejemplar <strong>{ejemplar.codigo}</strong> del libro <strong>{ejemplar.isbnLibro}</strong>.
            El código no se puede modificar.
          </p>
          <SelectorChips etiqueta="Estado" nombre="estado" opciones={ESTADOS_EJEMPLAR} valor={estado}
                         etiquetaDe={etiquetaEstado} alCambiar={(s) => setEstado(s || estado)} />
          <div className="campos">
            <label className="campo-ancho">Ubicación
              <input value={ubicacion} onChange={(e) => setUbicacion(e.target.value)} required />
            </label>
            <label>Fecha de ingreso
              <input type="datetime-local" value={fechaIngreso}
                     onChange={(e) => setFechaIngreso(e.target.value)} required />
            </label>
            <label>Precio de reposición
              <input type="number" min="0.01" step="0.01" value={precioReposicion}
                     onChange={(e) => setPrecioReposicion(e.target.value)} required />
            </label>
          </div>
          <div className="acciones">
            <button type="submit" disabled={cargando}><Icono nombre="guardar" /> Guardar cambios</button>
            <button type="button" className="secundario" onClick={() => setEjemplar(null)}>Cancelar</button>
          </div>
        </form>
      )}
    </>
  );
}
