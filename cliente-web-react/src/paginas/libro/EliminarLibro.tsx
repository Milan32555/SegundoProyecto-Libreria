import { FormEvent, useState } from "react";
import { buscarLibroPorIsbn, eliminarLibro } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { Aviso, Encabezado } from "../../componentes/Basicos";
import FichaLibro from "../../componentes/FichaLibro";
import Icono from "../../componentes/Icono";
import { Libro } from "../../types";

/**
 * Caso de uso: Eliminar Libro. Primero se busca el objeto y se muestra TODA su información;
 * solo después de confirmar se ejecuta la eliminación (como exige el enunciado).
 */
export default function EliminarLibro() {
  const [isbn, setIsbn] = useState("");
  const [libro, setLibro] = useState<Libro | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [exito, setExito] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);

  async function buscar(e: FormEvent) {
    e.preventDefault();
    setError(null); setExito(null); setLibro(null);
    setCargando(true);
    try {
      const resultado = await buscarLibroPorIsbn(isbn);
      if (!resultado) {
        setError(`No se encontró ningún libro con el ISBN "${isbn}".`);
      } else {
        setLibro(resultado);
      }
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  async function confirmarEliminacion() {
    if (!libro) return;
    setCargando(true);
    setError(null);
    try {
      await eliminarLibro(libro.isbn);
      setExito(`Libro "${libro.titulo}" (ISBN ${libro.isbn}) eliminado correctamente.`);
      libroObservable.notificar();
      setLibro(null);
      setIsbn("");
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  return (
    <>
      <Encabezado etiqueta="Libro" titulo="Eliminar libro">
        Busca el libro por su ISBN para revisar toda su información antes de eliminarlo.
      </Encabezado>
      {exito && <Aviso tipo="exito">{exito}</Aviso>}

      <form className="tarjeta filtros-fila" role="search" onSubmit={buscar}>
        <label>ISBN del libro a eliminar
          <input value={isbn} onChange={(e) => setIsbn(e.target.value)} required />
        </label>
        <button type="submit" disabled={cargando}><Icono nombre="buscar" /> Buscar</button>
      </form>

      {!libro && error && <Aviso>{error}</Aviso>}

      {libro && (
        <>
          <FichaLibro libro={libro} />
          <Aviso tipo="advertencia">¿Seguro que desea eliminar este libro? Esta acción no se puede deshacer.</Aviso>
          {error && <Aviso>{error}</Aviso>}
          <div className="acciones">
            <button type="button" className="peligro" onClick={confirmarEliminacion} disabled={cargando}>
              <Icono nombre="eliminar" /> Confirmar eliminación
            </button>
            <button type="button" className="secundario" onClick={() => setLibro(null)}>Cancelar</button>
          </div>
        </>
      )}
    </>
  );
}
