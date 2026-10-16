import { FormEvent, useState } from "react";
import { crearEjemplar } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { ESTADOS_EJEMPLAR, EstadoEjemplar } from "../../types";

/** Caso de uso: Adicionar Ejemplar a un Libro existente. */
export default function AgregarEjemplar() {
  const [codigo, setCodigo] = useState("");
  const [estado, setEstado] = useState<EstadoEjemplar>("DISPONIBLE");
  const [ubicacion, setUbicacion] = useState("");
  const [fechaIngreso, setFechaIngreso] = useState("");
  const [precioReposicion, setPrecioReposicion] = useState("");
  const [isbnLibro, setIsbnLibro] = useState("");

  const [error, setError] = useState<string | null>(null);
  const [exito, setExito] = useState<string | null>(null);
  const [enviando, setEnviando] = useState(false);

  async function manejarEnvio(e: FormEvent) {
    e.preventDefault();
    setError(null); setExito(null); setEnviando(true);
    try {
      const ejemplar = await crearEjemplar({
        codigo, estado, ubicacion, fechaIngreso,
        precioReposicion: Number(precioReposicion),
        isbnLibro
      });
      setExito(`Ejemplar "${ejemplar.codigo}" creado correctamente.`);
      ejemplarObservable.notificar();
      setCodigo(""); setUbicacion(""); setFechaIngreso("");
      setPrecioReposicion(""); setIsbnLibro("");
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setEnviando(false);
    }
  }

  return (
    <div className="tarjeta">
      <h1>Adicionar Ejemplar</h1>
      {error && <p className="mensaje-error">{error}</p>}
      {exito && <p className="mensaje-exito">{exito}</p>}
      <form onSubmit={manejarEnvio}>
        <label>Código del ejemplar
          <input value={codigo} onChange={(e) => setCodigo(e.target.value)} required />
        </label>
        <label>ISBN del libro al que pertenece
          <input value={isbnLibro} onChange={(e) => setIsbnLibro(e.target.value)} required />
        </label>
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
          <input type="number" min="0.01" step="0.01" value={precioReposicion}
                 onChange={(e) => setPrecioReposicion(e.target.value)} required />
        </label>
        <button type="submit" disabled={enviando}>{enviando ? "Guardando..." : "Adicionar"}</button>
      </form>
    </div>
  );
}
