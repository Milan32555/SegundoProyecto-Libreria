import { FormEvent, useState } from "react";
import { Lock, RotateCcw, Save } from "lucide-react";
import { actualizarEjemplar, buscarEjemplarPorCodigo } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { aValorDeInputFecha } from "../../formato";
import FichaEjemplar from "../../componentes/FichaEjemplar";
import { OPCIONES_ESTADO } from "../../componentes/opciones";
import { Ayuda } from "../../componentes/ui/Ayuda";
import { useAvisos } from "../../componentes/ui/Avisos";
import { Banner } from "../../componentes/ui/Banner";
import { Boton } from "../../componentes/ui/Boton";
import { BuscadorClave } from "../../componentes/ui/BuscadorClave";
import { Campo } from "../../componentes/ui/Campo";
import { Encabezado } from "../../componentes/ui/Encabezado";
import { Selector } from "../../componentes/ui/Selector";
import { SinResultados } from "../../componentes/ui/SinResultados";
import { EstadoEjemplar, Ejemplar } from "../../types";
import { Errores, hayErrores, validar, validarDecimalPositivo, validarFecha, validarObligatorio } from "../../validaciones";

type CampoEditable = "ubicacion" | "fechaIngreso" | "precioReposicion";

/**
 * Caso de uso: Actualizar Ejemplar. Primero se busca y se muestra TODA su información actual;
 * luego se editan los datos. El número de préstamos se ve pero no se edita: lo calcula el
 * servidor (suma 1 cuando el ejemplar pasa a Prestado), y al guardar se muestra el valor nuevo.
 */
export default function ActualizarEjemplar() {
  const [ejemplar, setEjemplar] = useState<Ejemplar | null>(null);
  const [guardado, setGuardado] = useState<Ejemplar | null>(null);
  const [estado, setEstado] = useState<EstadoEjemplar>("DISPONIBLE");
  const [datos, setDatos] = useState<Record<CampoEditable, string>>({ ubicacion: "", fechaIngreso: "", precioReposicion: "" });
  const [errores, setErrores] = useState<Errores<CampoEditable>>({});
  const [sinResultado, setSinResultado] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);
  const avisar = useAvisos();

  async function buscar(codigo: string) {
    setError(null); setSinResultado(null); setEjemplar(null); setGuardado(null); setErrores({});
    setCargando(true);
    try {
      const resultado = await buscarEjemplarPorCodigo(codigo);
      if (!resultado) {
        setSinResultado(`No hay ningún ejemplar con el código «${codigo}».`);
        return;
      }
      setEjemplar(resultado);
      setEstado(resultado.estado);
      setDatos({
        ubicacion: resultado.ubicacion,
        fechaIngreso: aValorDeInputFecha(resultado.fechaIngreso),
        precioReposicion: String(resultado.precioReposicion)
      });
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  const cambiar = (campo: CampoEditable) => (e: { target: { value: string } }) => {
    setDatos((d) => ({ ...d, [campo]: e.target.value }));
    if (errores[campo]) setErrores((err) => ({ ...err, [campo]: undefined }));
  };

  async function guardar(e: FormEvent) {
    e.preventDefault();
    if (!ejemplar) return;
    const encontrados = validar<CampoEditable>({
      ubicacion: validarObligatorio(datos.ubicacion),
      fechaIngreso: validarFecha(datos.fechaIngreso),
      precioReposicion: validarDecimalPositivo(datos.precioReposicion)
    });
    setErrores(encontrados);
    if (hayErrores(encontrados)) return;

    setCargando(true); setError(null);
    try {
      const actualizado = await actualizarEjemplar(ejemplar.codigo, {
        estado,
        ubicacion: datos.ubicacion.trim(),
        fechaIngreso: datos.fechaIngreso,
        precioReposicion: Number(datos.precioReposicion)
      });
      ejemplarObservable.notificar();
      avisar({
        titulo: "Cambios guardados",
        descripcion: `${actualizado.codigo} quedó ${estadoEnFrase(actualizado.estado)} con ${actualizado.numeroPrestamos} préstamos.`
      });
      setGuardado(actualizado);
      setEjemplar(null);
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  const reiniciar = () => { setEjemplar(null); setGuardado(null); setError(null); };

  return (
    <>
      <Encabezado
        seccion="Ejemplares"
        titulo="Actualizar ejemplar"
        descripcion="Busca la copia por su código: verás sus datos actuales y podrás modificarlos."
      />

      <div className="pila">
        {!ejemplar && !guardado && (
          <BuscadorClave etiqueta="Código del ejemplar" placeholder="EJ-001" cargando={cargando} alBuscar={buscar} />
        )}
        {error && <Banner titulo={ejemplar ? "No se pudieron guardar los cambios" : "No se pudo buscar el ejemplar"}>{error}</Banner>}
        {sinResultado && <SinResultados titulo="Sin resultados">{sinResultado}</SinResultados>}

        {guardado && (
          <>
            <FichaEjemplar ejemplar={guardado} titulo="Datos guardados" />
            <div className="acciones">
              <Boton icono={RotateCcw} onClick={reiniciar}>Actualizar otro ejemplar</Boton>
            </div>
          </>
        )}

        {ejemplar && (
          <>
            <FichaEjemplar ejemplar={ejemplar} titulo="Datos actuales" />
            <form className="panel formulario-secciones" onSubmit={guardar} noValidate aria-label="Nuevos datos del ejemplar">
              <section className="seccion-formulario" aria-labelledby="sec-datos">
                <div>
                  <h2 id="sec-datos">Nuevos datos</h2>
                  <p className="seccion-formulario-ayuda">
                    El código {ejemplar.codigo} y el libro {ejemplar.isbnLibro} no se pueden modificar.
                  </p>
                </div>
                <div className="rejilla-campos">
                  <Selector etiqueta="Estado" valor={estado} opciones={OPCIONES_ESTADO} alCambiar={(s) => setEstado(s || estado)} />
                  <Campo etiqueta="Ubicación" value={datos.ubicacion} onChange={cambiar("ubicacion")} error={errores.ubicacion} />
                  <Campo etiqueta="Fecha de ingreso" type="datetime-local" value={datos.fechaIngreso}
                         onChange={cambiar("fechaIngreso")} error={errores.fechaIngreso} />
                  <Campo etiqueta="Precio de reposición" type="number" inputMode="decimal" min="0" step="0.01" prefijo="$"
                         value={datos.precioReposicion} onChange={cambiar("precioReposicion")} error={errores.precioReposicion} />
                  <Campo
                    etiqueta="Número de préstamos"
                    value={ejemplar.numeroPrestamos}
                    readOnly
                    sufijo={
                      <Ayuda texto="Este dato no se edita: lo calcula el servidor.">
                        <span tabIndex={0} aria-label="Dato calculado por el servidor"><Lock size={14} aria-hidden="true" /></span>
                      </Ayuda>
                    }
                    ayuda="Lo calcula el servidor: suma 1 cada vez que el ejemplar pasa a Prestado."
                    ancho
                  />
                </div>
              </section>
              <div className="acciones acciones-pie">
                <Boton onClick={reiniciar}>Cancelar</Boton>
                <Boton type="submit" variante="primario" icono={Save} cargando={cargando}>Guardar cambios</Boton>
              </div>
            </form>
          </>
        )}
      </div>
    </>
  );
}

function estadoEnFrase(estado: EstadoEjemplar): string {
  return { DISPONIBLE: "disponible", PRESTADO: "prestado", DANIADO: "dañado", DADO_DE_BAJA: "dado de baja" }[estado];
}
