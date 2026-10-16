import { FormEvent, useState } from "react";
import { buscarEjemplarPorCodigo, eliminarEjemplar } from "../../graphql/servicioEjemplar";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { Ejemplar } from "../../types";

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
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
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
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
    } finally {
      setCargando(false);
    }
  }

  return (
    <div className="tarjeta">
      <h1>Eliminar Ejemplar</h1>
      {error && <p className="mensaje-error">{error}</p>}
      {exito && <p className="mensaje-exito">{exito}</p>}

      <form onSubmit={buscar}>
        <label>Código del ejemplar a eliminar
          <input value={codigo} onChange={(e) => setCodigo(e.target.value)} required />
        </label>
        <button type="submit" disabled={cargando}>Buscar</button>
      </form>

      {ejemplar && (
        <>
          <div className="ficha-objeto">
            <p><strong>Código:</strong> {ejemplar.codigo}</p>
            <p><strong>Estado:</strong> {ejemplar.estado}</p>
            <p><strong>Ubicación:</strong> {ejemplar.ubicacion}</p>
            <p><strong>Fecha de ingreso:</strong> {ejemplar.fechaIngreso}</p>
            <p><strong>Precio de reposición:</strong> ${ejemplar.precioReposicion.toLocaleString()}</p>
            <p><strong>ISBN del libro:</strong> {ejemplar.isbnLibro}</p>
          </div>
          <div className="acciones">
            <button className="peligro" onClick={confirmarEliminacion} disabled={cargando}>
              Confirmar eliminación
            </button>
            <button className="secundario" onClick={() => setEjemplar(null)}>Cancelar</button>
          </div>
        </>
      )}
    </div>
  );
}
