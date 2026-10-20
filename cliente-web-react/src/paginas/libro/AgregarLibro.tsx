import { FormEvent, useState } from "react";
import { Check } from "lucide-react";
import { crearLibro } from "../../graphql/servicioLibro";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { libroObservable } from "../../observer/Observable";
import { useAvisos } from "../../componentes/ui/Avisos";
import { Banner } from "../../componentes/ui/Banner";
import { Boton } from "../../componentes/ui/Boton";
import { Campo } from "../../componentes/ui/Campo";
import { Encabezado } from "../../componentes/ui/Encabezado";
import { Selector } from "../../componentes/ui/Selector";
import { OPCIONES_GENERO } from "../../componentes/opciones";
import { Genero } from "../../types";
import {
  Errores, hayErrores, validar, validarDecimalPositivo, validarEnteroPositivo, validarFecha, validarObligatorio
} from "../../validaciones";

type CampoLibro = "isbn" | "titulo" | "autor" | "precio" | "numeroPaginas" | "fechaPublicacion";

const VACIO = { isbn: "", titulo: "", autor: "", precio: "", numeroPaginas: "", fechaPublicacion: "" };

/** Caso de uso: Adicionar Libro (único propósito de esta pantalla). */
export default function AgregarLibro() {
  const [datos, setDatos] = useState(VACIO);
  const [genero, setGenero] = useState<Genero>("FICCION");
  const [errores, setErrores] = useState<Errores<CampoLibro>>({});
  const [errorServidor, setErrorServidor] = useState<string | null>(null);
  const [enviando, setEnviando] = useState(false);
  const avisar = useAvisos();

  const cambiar = (campo: CampoLibro) => (e: { target: { value: string } }) => {
    setDatos((d) => ({ ...d, [campo]: e.target.value }));
    if (errores[campo]) setErrores((err) => ({ ...err, [campo]: undefined }));
  };

  async function manejarEnvio(e: FormEvent) {
    e.preventDefault();
    setErrorServidor(null);
    const encontrados = validar<CampoLibro>({
      isbn: validarObligatorio(datos.isbn),
      titulo: validarObligatorio(datos.titulo),
      autor: validarObligatorio(datos.autor),
      precio: validarDecimalPositivo(datos.precio),
      numeroPaginas: validarEnteroPositivo(datos.numeroPaginas),
      fechaPublicacion: validarFecha(datos.fechaPublicacion)
    });
    setErrores(encontrados);
    if (hayErrores(encontrados)) return;

    setEnviando(true);
    try {
      const libro = await crearLibro({
        isbn: datos.isbn.trim(),
        titulo: datos.titulo.trim(),
        autor: datos.autor.trim(),
        precio: Number(datos.precio),
        numeroPaginas: Number(datos.numeroPaginas),
        fechaPublicacion: datos.fechaPublicacion,
        genero
      });
      libroObservable.notificar(); // Observer: avisa a Listar que debe refrescarse
      avisar({ titulo: "Libro adicionado", descripcion: `«${libro.titulo}» quedó registrado con el ISBN ${libro.isbn}.` });
      setDatos(VACIO);
      setGenero("FICCION");
    } catch (err) {
      setErrorServidor(mensajeDeError(err));
    } finally {
      setEnviando(false);
    }
  }

  return (
    <>
      <Encabezado seccion="Libros" titulo="Adicionar libro" descripcion="Registra un título nuevo en el inventario." />

      {errorServidor && <Banner titulo="No se pudo adicionar el libro" className="espacio-abajo">{errorServidor}</Banner>}

      <form className="panel formulario-secciones" onSubmit={manejarEnvio} noValidate>
        <section className="seccion-formulario" aria-labelledby="sec-identificacion">
          <div>
            <h2 id="sec-identificacion">Identificación</h2>
            <p className="seccion-formulario-ayuda">El ISBN identifica la edición y no se puede cambiar después.</p>
          </div>
          <div className="rejilla-campos">
            <Campo etiqueta="ISBN" value={datos.isbn} onChange={cambiar("isbn")} error={errores.isbn}
                   placeholder="978-0307474728" autoComplete="off" />
            <Campo etiqueta="Título" value={datos.titulo} onChange={cambiar("titulo")} error={errores.titulo} ancho />
            <Campo etiqueta="Autor" value={datos.autor} onChange={cambiar("autor")} error={errores.autor} ancho />
          </div>
        </section>

        <section className="seccion-formulario" aria-labelledby="sec-publicacion">
          <div>
            <h2 id="sec-publicacion">Publicación</h2>
            <p className="seccion-formulario-ayuda">Fecha y hora de publicación y género literario.</p>
          </div>
          <div className="rejilla-campos">
            <Campo etiqueta="Fecha de publicación" type="datetime-local" value={datos.fechaPublicacion}
                   onChange={cambiar("fechaPublicacion")} error={errores.fechaPublicacion} />
            <Selector etiqueta="Género" valor={genero} opciones={OPCIONES_GENERO}
                      alCambiar={(g) => setGenero(g || "FICCION")} />
          </div>
        </section>

        <section className="seccion-formulario" aria-labelledby="sec-venta">
          <div>
            <h2 id="sec-venta">Venta</h2>
            <p className="seccion-formulario-ayuda">Precio en pesos colombianos y extensión del libro.</p>
          </div>
          <div className="rejilla-campos">
            <Campo etiqueta="Precio" type="number" inputMode="decimal" min="0" step="0.01" prefijo="$"
                   value={datos.precio} onChange={cambiar("precio")} error={errores.precio} />
            <Campo etiqueta="Número de páginas" type="number" inputMode="numeric" min="1" step="1"
                   value={datos.numeroPaginas} onChange={cambiar("numeroPaginas")} error={errores.numeroPaginas} />
          </div>
        </section>

        <div className="acciones acciones-pie">
          <Boton type="submit" variante="primario" icono={Check} cargando={enviando}>Adicionar libro</Boton>
        </div>
      </form>
    </>
  );
}
