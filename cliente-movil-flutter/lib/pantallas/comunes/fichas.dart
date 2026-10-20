import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../modelos/ejemplar.dart';
import '../../modelos/libro.dart';
import '../../tema/tema.dart';
import '../../utilidades/formato.dart';
import 'componentes.dart';

/// Muestra TODA la información de un Libro (la fecha con hora): título y autor arriba y el resto
/// de atributos debajo. Se usa al consultar, antes de eliminar y antes de editar.
class FichaLibro extends StatelessWidget {
  const FichaLibro({super.key, required this.libro, this.titulo = 'Libro'});

  final Libro libro;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return _MarcoFicha(
      tipo: titulo,
      titulo: libro.titulo,
      tituloEsLibro: true,
      subtitulo: libro.autor,
      datos: [
        _Dato('ISBN', Text(libro.isbn)),
        _Dato('Autor', Text(libro.autor)),
        _Dato('Género', InsigniaGenero(libro.genero)),
        _Dato('Precio de venta', Text(formatearPrecio(libro.precio))),
        _Dato('Número de páginas', Text('${libro.numeroPaginas}')),
        _Dato('Fecha de publicación', Text(formatearFechaIso(libro.fechaPublicacion))),
      ],
    );
  }
}

/// Muestra TODA la información de un Ejemplar (la fecha de ingreso con hora).
class FichaEjemplar extends StatelessWidget {
  const FichaEjemplar({super.key, required this.ejemplar, this.titulo = 'Ejemplar'});

  final Ejemplar ejemplar;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return _MarcoFicha(
      tipo: titulo,
      titulo: ejemplar.codigo,
      subtitulo: 'Libro ${ejemplar.isbnLibro}',
      insignia: InsigniaEstado(ejemplar.estado),
      datos: [
        _Dato('Código', Text(ejemplar.codigo)),
        _Dato('Estado', InsigniaEstado(ejemplar.estado)),
        _Dato('Libro (ISBN)', Text(ejemplar.isbnLibro)),
        _Dato('Ubicación', Text(ejemplar.ubicacion)),
        _Dato('Fecha de ingreso', Text(formatearFechaIso(ejemplar.fechaIngreso))),
        _Dato('Precio de reposición', Text(formatearPrecio(ejemplar.precioReposicion))),
        _Dato(
          'Número de préstamos',
          Text('${ejemplar.numeroPrestamos}'),
          nota: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.lock, size: 12, color: kGris500),
              SizedBox(width: 4),
              Text('Lo calcula el servidor', style: TextStyle(color: kGris500, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dato {
  const _Dato(this.termino, this.valor, {this.nota});

  final String termino;
  final Widget valor;
  final Widget? nota;
}

class _MarcoFicha extends StatelessWidget {
  const _MarcoFicha({
    required this.tipo,
    required this.titulo,
    required this.subtitulo,
    required this.datos,
    this.insignia,
    this.tituloEsLibro = false,
  });

  final String tipo;
  final String titulo;
  final String subtitulo;
  final List<_Dato> datos;
  final Widget? insignia;
  final bool tituloEsLibro;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: '$tipo: $titulo',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: Espacio.e4),
        decoration: BoxDecoration(color: kGris0, borderRadius: Radios.panel, border: Border.all(color: kGris100)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(Espacio.e4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tipo, style: textos.labelSmall!.copyWith(color: kGris500, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          titulo,
                          style: tituloEsLibro
                              ? const TextStyle(fontFamily: fuenteLibro, fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: kGris900)
                              : textos.titleLarge,
                        ),
                        Text(subtitulo, style: textos.bodyMedium!.copyWith(color: kGris600)),
                      ],
                    ),
                  ),
                  ?insignia,
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(Espacio.e4),
              child: LayoutBuilder(
                builder: (context, restricciones) {
                  final columnas = restricciones.maxWidth >= 520 ? 3 : 2;
                  final ancho = (restricciones.maxWidth - Espacio.e4 * (columnas - 1)) / columnas;
                  return Wrap(
                    spacing: Espacio.e4,
                    runSpacing: Espacio.e4,
                    children: [
                      for (final dato in datos)
                        SizedBox(
                          width: ancho,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dato.termino, style: textos.labelSmall!.copyWith(color: kGris500)),
                              const SizedBox(height: 2),
                              DefaultTextStyle.merge(
                                style: const TextStyle(fontSize: 14, color: kGris900, fontFeatures: cifrasTabulares),
                                child: dato.valor,
                              ),
                              if (dato.nota != null) ...[const SizedBox(height: 2), dato.nota!],
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
