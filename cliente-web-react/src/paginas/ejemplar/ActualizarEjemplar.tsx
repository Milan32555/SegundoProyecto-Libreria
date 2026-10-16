import { FormEvent, useState } from "react";
import { actualizarEjemplar, buscarEjemplarPorCodigo } from "../../graphql/servicioEjemplar";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { ESTADOS_EJEMPLAR, EstadoEjemplar, Ejemplar } from "../../types";

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
        setFechaIngreso(resultado.fechaIngreso.slice(0, 16));
        setPrecioReposicion(String(resultado.precioReposicion));
      }
    } catch (err) {
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
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
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
    } finally {
      setCargando(false);
    }
  }

  return (
    <div className="tarjeta">
      <h1>Actualizar Ejemplar</h1>
      {error && <p className="mensaje-error">{error}</p>}
      {exito && <p className="mensaje-exito">{exito}</p>}

      {!ejemplar && (
        <form onSubmit={buscar}>
          <label>Código del ejemplar a actualizar
            <input value={codigo} onChange={(e) => setCodigo(e.target.value)} required />
          </label>
          <button type="submit" disabled={cargando}>Buscar</button>
        </form>
      )}

      {ejemplar && (
        <form onSubmit={guardarCambios}>
          <p style={{ color: "#5a6378" }}>
            Código (no editable): <strong>{ejemplar.codigo}</strong> — Libro: <strong>{ejemplar.isbnLibro}</strong>
          </p>
          <label>Estado
            <select value={estado} onChange={(e) => setEstado(e.target.value as EstadoEjemplar)}>
              {ESTADOS_EJEMPLAR.map((s) => <option key={s} value={s}>{s}</option>)}
            </select>
          </label>
          <label>Ubicación
            <input value={ubicacion} onChange={(e) => setUbicacion(e.target.value)} required />
          </label>
          <label>Fecha de ingreso
            <input type="datetime-local" value={fechaIngreso}
                   onChange={(e) => setFechaIngreso(e.target.value)} required />
          </label>
          <label>Precio de reposición
            <input type="number" min="0" step="0.01" value={precioReposicion}
                   onChange={(e) => setPrecioReposicion(e.target.value)} required />
          </label>
          <div className="acciones">
            <button type="submit" disabled={cargando}>Guardar cambios</button>
            <button type="button" className="secundario" onClick={() => setEjemplar(null)}>Cancelar</button>
          </div>
        </form>
      )}
    </div>
  );
}
