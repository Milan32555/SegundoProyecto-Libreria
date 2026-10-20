import { FormEvent, useState } from "react";
import { Check } from "lucide-react";
import { crearEjemplar } from "../../graphql/servicioEjemplar";
import { mensajeDeError } from "../../graphql/clienteGraphQL";
import { ejemplarObservable } from "../../observer/Observable";
import { OPCIONES_ESTADO } from "../../componentes/opciones";
import { useAvisos } from "../../componentes/ui/Avisos";
import { Banner } from "../../componentes/ui/Banner";
import { Boton } from "../../componentes/ui/Boton";
import { Campo } from "../../componentes/ui/Campo";
import { Encabezado } from "../../componentes/ui/Encabezado";
import { Selector } from "../../componentes/ui/Selector";
import { EstadoEjemplar } from "../../types";
import {
  Errores, hayErrores, validar, validarDecimalPositivo, validarEnteroNoNegativo, validarFecha, validarObligatorio
} from "../../validaciones";

type CampoEjemplar = "codigo" | "isbnLibro" | "ubicacion" | "fechaIngreso" | "precioReposicion" | "numeroPrestamos";

const VACIO = { codigo: "", isbnLibro: "", ubicacion: "", fechaIngreso: "", precioReposicion: "", numeroPrestamos: "0" };

/** Caso de uso: Adicionar Ejemplar (una copia física de un libro que ya existe). */
export default function AgregarEjemplar() {
  const [datos, setDatos] = useState(VACIO);
  const [estado, setEstado] = useState<EstadoEjemplar>("DISPONIBLE");
  const [errores, setErrores] = useState<Errores<CampoEjemplar>>({});
  const [errorServidor, setErrorServidor] = useState<string | null>(null);
  const [enviando, setEnviando] = useState(false);
  const avisar = useAvisos();

  const cambiar = (campo: CampoEjemplar) => (e: { target: { value: string } }) => {
    setDatos((d) => ({ ...d, [campo]: e.target.value }));
    if (errores[campo]) setErrores((err) => ({ ...err, [campo]: undefined }));
  };

  async function manejarEnvio(e: FormEvent) {
    e.preventDefault();
    setErrorServidor(null);
    const encontrados = validar<CampoEjemplar>({
      codigo: validarObligatorio(datos.codigo),
      isbnLibro: validarObligatorio(datos.isbnLibro),
      ubicacion: validarObligatorio(datos.ubicacion),
      fechaIngreso: validarFecha(datos.fechaIngreso),
      precioReposicion: validarDecimalPositivo(datos.precioReposicion),
      numeroPrestamos: validarEnteroNoNegativo(datos.numeroPrestamos)
    });
    setErrores(encontrados);
    if (hayErrores(encontrados)) return;

    setEnviando(true);
    try {
      const ejemplar = await crearEjemplar({
        codigo: datos.codigo.trim(),
        estado,
        ubicacion: datos.ubicacion.trim(),
        fechaIngreso: datos.fechaIngreso,
        precioReposicion: Number(datos.precioReposicion),
        numeroPrestamos: Number(datos.numeroPrestamos),
        isbnLibro: datos.isbnLibro.trim()
      });
      ejemplarObservable.notificar();
      avisar({ titulo: "Ejemplar adicionado", descripcion: `${ejemplar.codigo} quedó registrado para el libro ${ejemplar.isbnLibro}.` });
      setDatos(VACIO);
      setEstado("DISPONIBLE");
    } catch (err) {
      setErrorServidor(mensajeDeError(err));
    } finally {
      setEnviando(false);
    }
  }

  return (
    <>
      <Encabezado seccion="Ejemplares" titulo="Adicionar ejemplar" descripcion="Registra una copia física de un libro que ya está en el inventario." />

      {errorServidor && <Banner titulo="No se pudo adicionar el ejemplar" className="espacio-abajo">{errorServidor}</Banner>}

      <form className="panel formulario-secciones" onSubmit={manejarEnvio} noValidate>
        <section className="seccion-formulario" aria-labelledby="sec-ejemplar">
          <div>
            <h2 id="sec-ejemplar">Identificación</h2>
            <p className="seccion-formulario-ayuda">El código es único por copia. El libro debe existir: búscalo por su ISBN.</p>
          </div>
          <div className="rejilla-campos">
            <Campo etiqueta="Código del ejemplar" value={datos.codigo} onChange={cambiar("codigo")} error={errores.codigo}
                   placeholder="EJ-021" autoComplete="off" />
            <Campo etiqueta="ISBN del libro" value={datos.isbnLibro} onChange={cambiar("isbnLibro")} error={errores.isbnLibro}
                   placeholder="978-0307474728" autoComplete="off" />
          </div>
        </section>

        <section className="seccion-formulario" aria-labelledby="sec-estado">
          <div>
            <h2 id="sec-estado">Estado y ubicación</h2>
            <p className="seccion-formulario-ayuda">Dónde está la copia y en qué condición se encuentra.</p>
          </div>
          <div className="rejilla-campos">
            <Selector etiqueta="Estado" valor={estado} opciones={OPCIONES_ESTADO} alCambiar={(s) => setEstado(s || "DISPONIBLE")} />
            <Campo etiqueta="Ubicación" value={datos.ubicacion} onChange={cambiar("ubicacion")} error={errores.ubicacion}
                   placeholder="Estante A1" />
          </div>
        </section>

        <section className="seccion-formulario" aria-labelledby="sec-ingreso">
          <div>
            <h2 id="sec-ingreso">Ingreso y valor</h2>
            <p className="seccion-formulario-ayuda">Préstamos que ya tenía la copia al registrarla (normalmente 0).</p>
          </div>
          <div className="rejilla-campos">
            <Campo etiqueta="Fecha de ingreso" type="datetime-local" value={datos.fechaIngreso}
                   onChange={cambiar("fechaIngreso")} error={errores.fechaIngreso} />
            <Campo etiqueta="Precio de reposición" type="number" inputMode="decimal" min="0" step="0.01" prefijo="$"
                   value={datos.precioReposicion} onChange={cambiar("precioReposicion")} error={errores.precioReposicion} />
            <Campo etiqueta="Número de préstamos" type="number" inputMode="numeric" min="0" step="1"
                   value={datos.numeroPrestamos} onChange={cambiar("numeroPrestamos")} error={errores.numeroPrestamos} />
          </div>
        </section>

        <div className="acciones acciones-pie">
          <Boton type="submit" variante="primario" icono={Check} cargando={enviando}>Adicionar ejemplar</Boton>
        </div>
      </form>
    </>
  );
}
