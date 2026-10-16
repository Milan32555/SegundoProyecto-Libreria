import { FormEvent, useState } from "react";
import { buscarEjemplarPorCodigo } from "../../graphql/servicioEjemplar";
import { ErrorGraphQL } from "../../graphql/clienteGraphQL";
import { Ejemplar } from "../../types";

export default function ConsultarEjemplar() {
  const [codigo, setCodigo] = useState("");
  const [ejemplar, setEjemplar] = useState<Ejemplar | null>(null);
  const [buscado, setBuscado] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function buscar(e: FormEvent) {
    e.preventDefault();
    setError(null); setEjemplar(null); setBuscado(false);
    setCargando(true);
    try {
      const resultado = await buscarEjemplarPorCodigo(codigo);
      setEjemplar(resultado);
      setBuscado(true);
    } catch (err) {
      setError(err instanceof ErrorGraphQL ? err.message : "Error de conexión con el servidor.");
    } finally {
      setCargando(false);
    }
  }

  return (
    <div className="tarjeta">
      <h1>Consultar Ejemplar</h1>
      {error && <p className="mensaje-error">{error}</p>}
      <form onSubmit={buscar}>
        <label>Código del ejemplar
          <input value={codigo} onChange={(e) => setCodigo(e.target.value)} required />
        </label>
        <button type="submit" disabled={cargando}>Buscar</button>
      </form>

      {buscado && !ejemplar && (
        <p style={{ marginTop: "1rem" }}>No se encontró ningún ejemplar con el código "{codigo}".</p>
      )}

      {ejemplar && (
        <div className="ficha-objeto">
          <p><strong>Código:</strong> {ejemplar.codigo}</p>
          <p><strong>Estado:</strong> {ejemplar.estado}</p>
          <p><strong>Ubicación:</strong> {ejemplar.ubicacion}</p>
          <p><strong>Fecha de ingreso:</strong> {ejemplar.fechaIngreso}</p>
          <p><strong>Precio de reposición:</strong> ${ejemplar.precioReposicion.toLocaleString()}</p>
          <p><strong>ISBN del libro:</strong> {ejemplar.isbnLibro}</p>
        </div>
      )}
    </div>
  );
}
