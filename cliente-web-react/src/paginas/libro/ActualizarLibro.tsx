import { FormEvent, useState } from "react";
import { RotateCcw, Save } from "lucide-react";
import { actualizarLibro, buscarLibroPorIsbn } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { aValorDeInputFecha } from "../../formato";
import FichaLibro from "../../componentes/FichaLibro";
import { OPCIONES_GENERO } from "../../componentes/opciones";
import { useAvisos } from "../../componentes/ui/Avisos";
import { Banner } from "../../componentes/ui/Banner";
import { Boton } from "../../componentes/ui/Boton";
import { BuscadorClave } from "../../componentes/ui/BuscadorClave";
import { Campo } from "../../componentes/ui/Campo";
import { Encabezado } from "../../componentes/ui/Encabezado";
import { Selector } from "../../componentes/ui/Selector";
import { SinResultados } from "../../componentes/ui/SinResultados";
import { Genero, Libro } from "../../types";
import {
  Errores, hayErrores, validar, validarDecimalPositivo, validarEnteroPositivo, validarFecha, validarObligatorio
} from "../../validaciones";

type CampoEditable = "titulo" | "autor" | "precio" | "numeroPaginas" | "fechaPublicacion";

/**
 * Caso de uso: Actualizar Libro. Primero se busca y se muestra TODA su información actual;
 * luego se editan los datos y, al guardar, se muestra lo que respondió el servidor.
 */
export default function ActualizarLibro() {
  const [libro, setLibro] = useState<Libro | null>(null);
  const [guardado, setGuardado] = useState<Libro | null>(null);
  const [datos, setDatos] = useState<Record<CampoEditable, string>>({
    titulo: "", autor: "", precio: "", numeroPaginas: "", fechaPublicacion: ""
  });
  const [genero, setGenero] = useState<Genero>("FICCION");
  const [errores, setErrores] = useState<Errores<CampoEditable>>({});
  const [sinResultado, setSinResultado] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [cargando, setCargando] = useState(false);
  const avisar = useAvisos();

  async function buscar(isbn: string) {
    setError(null); setSinResultado(null); setLibro(null); setGuardado(null); setErrores({});
    setCargando(true);
    try {
      const resultado = await buscarLibroPorIsbn(isbn);
      if (!resultado) {
        setSinResultado(`No hay ningún libro con el ISBN «${isbn}».`);
        return;
      }
      setLibro(resultado);
      setDatos({
        titulo: resultado.titulo,
        autor: resultado.autor,
        precio: String(resultado.precio),
        numeroPaginas: String(resultado.numeroPaginas),
        fechaPublicacion: aValorDeInputFecha(resultado.fechaPublicacion)
      });
      setGenero(resultado.genero);
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
    if (!libro) return;
    const encontrados = validar<CampoEditable>({
      titulo: validarObligatorio(datos.titulo),
      autor: validarObligatorio(datos.autor),
      precio: validarDecimalPositivo(datos.precio),
      numeroPaginas: validarEnteroPositivo(datos.numeroPaginas),
      fechaPublicacion: validarFecha(datos.fechaPublicacion)
    });
    setErrores(encontrados);
    if (hayErrores(encontrados)) return;

    setCargando(true); setError(null);
    try {
      const actualizado = await actualizarLibro(libro.isbn, {
        titulo: datos.titulo.trim(),
        autor: datos.autor.trim(),
        precio: Number(datos.precio),
        numeroPaginas: Number(datos.numeroPaginas),
        fechaPublicacion: datos.fechaPublicacion,
        genero
      });
      libroObservable.notificar();
      avisar({ titulo: "Cambios guardados", descripcion: `«${actualizado.titulo}» se actualizó en el servidor.` });
      setGuardado(actualizado);
      setLibro(null);
    } catch (err) {
      setError(mensajeDeError(err));
    } finally {
      setCargando(false);
    }
  }

  const reiniciar = () => { setLibro(null); setGuardado(null); setError(null); };

  return (
    <>
      <Encabezado
        seccion="Libros"
        titulo="Actualizar libro"
        descripcion="Busca el libro por su ISBN: verás sus datos actuales y podrás modificarlos."
      />

      <div className="pila">
        {!libro && !guardado && (
          <BuscadorClave etiqueta="ISBN del libro" placeholder="978-0307474728" cargando={cargando} alBuscar={buscar} />
        )}
        {error && <Banner titulo={libro ? "No se pudieron guardar los cambios" : "No se pudo buscar el libro"}>{error}</Banner>}
        {sinResultado && <SinResultados titulo="Sin resultados">{sinResultado}</SinResultados>}

        {guardado && (
          <>
            <FichaLibro libro={guardado} titulo="Datos guardados" />
            <div className="acciones">
              <Boton icono={RotateCcw} onClick={reiniciar}>Actualizar otro libro</Boton>
            </div>
          </>
        )}

        {libro && (
          <>
            <FichaLibro libro={libro} titulo="Datos actuales" />
            <form className="panel formulario-secciones" onSubmit={guardar} noValidate aria-label="Nuevos datos del libro">
              <section className="seccion-formulario" aria-labelledby="sec-datos">
                <div>
                  <h2 id="sec-datos">Nuevos datos</h2>
                  <p className="seccion-formulario-ayuda">El ISBN {libro.isbn} identifica al libro y no se puede modificar.</p>
                </div>
                <div className="rejilla-campos">
                  <Campo etiqueta="Título" value={datos.titulo} onChange={cambiar("titulo")} error={errores.titulo} ancho />
                  <Campo etiqueta="Autor" value={datos.autor} onChange={cambiar("autor")} error={errores.autor} ancho />
                  <Campo etiqueta="Precio" type="number" inputMode="decimal" min="0" step="0.01" prefijo="$"
                         value={datos.precio} onChange={cambiar("precio")} error={errores.precio} />
                  <Campo etiqueta="Número de páginas" type="number" inputMode="numeric" min="1" step="1"
                         value={datos.numeroPaginas} onChange={cambiar("numeroPaginas")} error={errores.numeroPaginas} />
                  <Campo etiqueta="Fecha de publicación" type="datetime-local" value={datos.fechaPublicacion}
                         onChange={cambiar("fechaPublicacion")} error={errores.fechaPublicacion} />
                  <Selector etiqueta="Género" valor={genero} opciones={OPCIONES_GENERO} alCambiar={(g) => setGenero(g || genero)} />
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
