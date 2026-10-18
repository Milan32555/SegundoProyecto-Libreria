import { FormEvent, useState } from "react";
import { crearEjemplar } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { Aviso, Encabezado, SelectorChips } from "../../componentes/Basicos";
import Icono from "../../componentes/Icono";
import { ESTADOS_EJEMPLAR, EstadoEjemplar, etiquetaEstado } from "../../types";

/** Caso de uso: Adicionar Ejemplar a un Libro existente. */
export default function AgregarEjemplar() {
  const [codigo, setCodigo] = useState("");
  const [estado, setEstado] = useState<EstadoEjemplar>("DISPONIBLE");
  const [ubicacion, setUbicacion] = useState("");
  const [fechaIngreso, setFechaIngreso] = useState("");
  const [precioReposicion, setPrecioReposicion] = useState("");
  const [numeroPrestamos, setNumeroPrestamos] = useState("0");
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
        numeroPrestamos: Number(numeroPrestamos),
        isbnLibro
      });
      setExito(`Ejemplar "${ejemplar.codigo}" creado correctamente.`);
      ejemplarObservable.notificar();
      setCodigo(""); setUbicacion(""); setFechaIngreso("");
      setPrecioReposicion(""); setNumeroPrestamos("0"); setIsbnLibro("");
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setEnviando(false);
    }
  }

  return (
    <>
      <Encabezado etiqueta="Ejemplar" titulo="Nuevo ejemplar">
        Registra una copia física de un libro que ya exista en el sistema.
      </Encabezado>
      {error && <Aviso>{error}</Aviso>}
      {exito && <Aviso tipo="exito">{exito}</Aviso>}

      <form className="tarjeta" onSubmit={manejarEnvio}>
        <div className="campos">
          <label>Código del ejemplar
            <input value={codigo} onChange={(e) => setCodigo(e.target.value)} required />
          </label>
          <label>ISBN del libro al que pertenece
            <input value={isbnLibro} onChange={(e) => setIsbnLibro(e.target.value)} required />
          </label>
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
          <label>Número de préstamos
            <input type="number" min="0" step="1" value={numeroPrestamos}
                   onChange={(e) => setNumeroPrestamos(e.target.value)} required />
          </label>
        </div>
        <SelectorChips etiqueta="Estado" nombre="estado" opciones={ESTADOS_EJEMPLAR} valor={estado}
                       etiquetaDe={etiquetaEstado} alCambiar={(s) => setEstado(s || "DISPONIBLE")} />
        <div className="acciones">
          <button type="submit" disabled={enviando}>
            <Icono nombre="listo" /> {enviando ? "Guardando..." : "Adicionar"}
          </button>
        </div>
      </form>
    </>
  );
}
