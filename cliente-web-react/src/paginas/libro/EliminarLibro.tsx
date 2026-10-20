import { useState } from "react";
import { buscarLibroPorIsbn, eliminarLibro } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import FichaLibro from "../../componentes/FichaLibro";
import { useAvisos } from "../../componentes/ui/Avisos";
import { Banner } from "../../componentes/ui/Banner";
import { Boton } from "../../componentes/ui/Boton";
import { BuscadorClave } from "../../componentes/ui/BuscadorClave";
import { ConfirmarEliminacion } from "../../componentes/ui/ConfirmarEliminacion";
import { Encabezado } from "../../componentes/ui/Encabezado";
import { SinResultados } from "../../componentes/ui/SinResultados";
import { Libro } from "../../types";

/**
 * Caso de uso: Eliminar Libro. Primero se busca y se muestra TODA su información; la
 * eliminación solo ocurre después de confirmarla en el diálogo. Si el libro tiene ejemplares,
 * el servidor la rechaza y aquí se muestra el motivo.
 */
export default function EliminarLibro() {
  const [libro, setLibro] = useState<Libro | null>(null);
  const [sinResultado, setSinResultado] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);
  const [busqueda, setBusqueda] = useState(0);
  const avisar = useAvisos();

  async function buscar(isbn: string) {
    setError(null); setSinResultado(null); setLibro(null);
    setCargando(true);
    try {
      const resultado = await buscarLibroPorIsbn(isbn);
      if (resultado) setLibro(resultado);
      else setSinResultado(`No hay ningún libro con el ISBN «${isbn}».`);
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  async function confirmar() {
    if (!libro) return;
    setCargando(true); setError(null);
    try {
      await eliminarLibro(libro.isbn);
      libroObservable.notificar();
      avisar({ titulo: "Libro eliminado", descripcion: `«${libro.titulo}» (ISBN ${libro.isbn}) ya no está en el inventario.` });
      setLibro(null);
      setBusqueda((n) => n + 1); // limpia el buscador
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  return (
    <>
      <Encabezado
        seccion="Libros"
        titulo="Eliminar libro"
        descripcion="Busca el libro por su ISBN y revisa toda su información antes de eliminarlo."
      />

      <div className="pila">
        <BuscadorClave key={busqueda} etiqueta="ISBN del libro" placeholder="978-8420401751" cargando={cargando && !libro} alBuscar={buscar} />
        {error && <Banner titulo={libro ? "El servidor no permitió eliminar el libro" : "No se pudo buscar el libro"}>{error}</Banner>}
        {sinResultado && <SinResultados titulo="Sin resultados">{sinResultado}</SinResultados>}
        {libro && (
          <>
            <FichaLibro libro={libro} titulo="Libro a eliminar" />
            <div className="acciones">
              <Boton onClick={() => { setLibro(null); setError(null); }}>Cancelar</Boton>
              <ConfirmarEliminacion
                textoBoton="Eliminar libro"
                titulo={`¿Eliminar «${libro.titulo}»?`}
                descripcion={`Se eliminará el libro con ISBN ${libro.isbn}. Esta acción no se puede deshacer.`}
                cargando={cargando}
                alConfirmar={confirmar}
              />
            </div>
          </>
        )}
      </div>
    </>
  );
}
