import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../modelos/libro.dart';
import '../../tema/tema.dart';
import '../../utilidades/formato.dart';
import 'componentes.dart';

const _estiloTitulo = TextStyle(
  fontFamily: fuenteTitulos,
  color: kTinta,
  fontSize: 24,
  fontWeight: FontWeight.w700,
  height: 1.2,
);
const _estiloPrecio = TextStyle(color: kDorado, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5);

/// Muestra TODA la información de un Libro (se usa al consultar y antes de eliminar).
class FichaLibro extends StatelessWidget {
  const FichaLibro({super.key, required this.libro});

  final Libro libro;

  @override
  Widget build(BuildContext context) {
    return _MarcoFicha(
      etiqueta: 'Libro',
      pastilla: Pastilla(etiquetaGenero(libro.genero)),
      titulo: libro.titulo,
      subtitulo: 'por ${libro.autor}',
      precio: formatearPrecio(libro.precio),
      leyendaPrecio: 'Precio de venta',
      datos: {
        'ISBN': libro.isbn,
        'Páginas': '${libro.numeroPaginas}',
        'Publicación': formatearFechaIso(libro.fechaPublicacion),
        'Género': etiquetaGenero(libro.genero),
      },
    );
  }
}

/// Muestra TODA la información de un Ejemplar (se usa al consultar y antes de eliminar).
class FichaEjemplar extends StatelessWidget {
  const FichaEjemplar({super.key, required this.ejemplar});

  final Ejemplar ejemplar;

  @override
  Widget build(BuildContext context) {
    return _MarcoFicha(
      etiqueta: 'Ejemplar',
      pastilla: Pastilla(etiquetaEstado(ejemplar.estado), color: colorEstado(ejemplar.estado)),
      titulo: ejemplar.codigo,
      subtitulo: 'Ubicación: ${ejemplar.ubicacion}',
      precio: formatearPrecio(ejemplar.precioReposicion),
      leyendaPrecio: 'Precio de reposición',
      datos: {
        'Estado': etiquetaEstado(ejemplar.estado),
        'Ingreso': formatearFechaIso(ejemplar.fechaIngreso),
        'Libro (ISBN)': ejemplar.isbnLibro,
      },
    );
  }
}

class _MarcoFicha extends StatelessWidget {
  const _MarcoFicha({
    required this.etiqueta,
    required this.pastilla,
    required this.titulo,
    required this.subtitulo,
    required this.precio,
    required this.leyendaPrecio,
    required this.datos,
  });

  final String etiqueta;
  final Widget pastilla;
  final String titulo;
  final String subtitulo;
  final String precio;
  final String leyendaPrecio;
  final Map<String, String> datos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Espacio.lg),
      child: TarjetaHero(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EtiquetaSeccion(etiqueta, color: kPrimario),
                const Spacer(),
                pastilla,
              ],
            ),
            const SizedBox(height: Espacio.sm),
            Text(titulo, style: _estiloTitulo),
            const SizedBox(height: 2),
            Text(subtitulo, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: Espacio.md),
            Text(precio, style: _estiloPrecio),
            Text(leyendaPrecio, style: Theme.of(context).textTheme.bodySmall),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Espacio.md),
              child: Divider(),
            ),
            _CuadriculaDatos(datos),
          ],
        ),
      ),
    );
  }
}

/// Pares etiqueta/valor en dos columnas.
class _CuadriculaDatos extends StatelessWidget {
  const _CuadriculaDatos(this.datos);

  final Map<String, String> datos;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = (restricciones.maxWidth - Espacio.md) / 2;
        return Wrap(
          spacing: Espacio.md,
          runSpacing: Espacio.md,
          children: [
            for (final MapEntry(key: etiqueta, value: valor) in datos.entries)
              SizedBox(
                width: ancho,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EtiquetaSeccion(etiqueta),
                    const SizedBox(height: 3),
                    Text(
                      valor,
                      style: const TextStyle(color: kTinta, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
