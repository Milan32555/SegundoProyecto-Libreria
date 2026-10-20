import { useState } from "react";
import { buscarEjemplarPorCodigo, eliminarEjemplar } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import FichaEjemplar from "../../componentes/FichaEjemplar";
import { useAvisos } from "../../componentes/ui/Avisos";
import { Banner } from "../../componentes/ui/Banner";
import { Boton } from "../../componentes/ui/Boton";
import { BuscadorClave } from "../../componentes/ui/BuscadorClave";
import { ConfirmarEliminacion } from "../../componentes/ui/ConfirmarEliminacion";
import { Encabezado } from "../../componentes/ui/Encabezado";
import { SinResultados } from "../../componentes/ui/SinResultados";
import { Ejemplar } from "../../types";

/**
 * Caso de uso: Eliminar Ejemplar. Primero se busca y se muestra TODA su información; solo se
 * elimina después de confirmarlo en el diálogo.
 */
export default function EliminarEjemplar() {
  const [ejemplar, setEjemplar] = useState<Ejemplar | null>(null);
  const [sinResultado, setSinResultado] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);
  const [busqueda, setBusqueda] = useState(0);
  const avisar = useAvisos();

  async function buscar(codigo: string) {
    setError(null); setSinResultado(null); setEjemplar(null);
    setCargando(true);
    try {
      const resultado = await buscarEjemplarPorCodigo(codigo);
      if (resultado) setEjemplar(resultado);
      else setSinResultado(`No hay ningún ejemplar con el código «${codigo}».`);
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  async function confirmar() {
    if (!ejemplar) return;
    setCargando(true); setError(null);
    try {
      await eliminarEjemplar(ejemplar.codigo);
      ejemplarObservable.notificar();
      avisar({ titulo: "Ejemplar eliminado", descripcion: `${ejemplar.codigo} ya no está en el inventario.` });
      setEjemplar(null);
      setBusqueda((n) => n + 1);
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  return (
    <>
      <Encabezado
        seccion="Ejemplares"
        titulo="Eliminar ejemplar"
        descripcion="Busca la copia por su código y revisa toda su información antes de eliminarla."
      />
      <div className="pila">
        <BuscadorClave key={busqueda} etiqueta="Código del ejemplar" placeholder="EJ-020" cargando={cargando && !ejemplar} alBuscar={buscar} />
        {error && <Banner titulo={ejemplar ? "El servidor no permitió eliminar el ejemplar" : "No se pudo buscar el ejemplar"}>{error}</Banner>}
        {sinResultado && <SinResultados titulo="Sin resultados">{sinResultado}</SinResultados>}
        {ejemplar && (
          <>
            <FichaEjemplar ejemplar={ejemplar} titulo="Ejemplar a eliminar" />
            <div className="acciones">
              <Boton onClick={() => { setEjemplar(null); setError(null); }}>Cancelar</Boton>
              <ConfirmarEliminacion
                textoBoton="Eliminar ejemplar"
                titulo={`¿Eliminar el ejemplar ${ejemplar.codigo}?`}
                descripcion="La copia se quitará del inventario. Esta acción no se puede deshacer."
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
