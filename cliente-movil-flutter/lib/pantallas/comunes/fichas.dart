import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../modelos/libro.dart';
import '../../utilidades/formato.dart';

/// Muestra TODA la información de un Libro (se usa al consultar y antes de eliminar).
class FichaLibro extends StatelessWidget {
  const FichaLibro({super.key, required this.libro});

  final Libro libro;

  @override
  Widget build(BuildContext context) {
    return _Ficha(datos: {
      'ISBN': libro.isbn,
      'Título': libro.titulo,
      'Autor': libro.autor,
      'Precio': formatearPrecio(libro.precio),
      'Páginas': '${libro.numeroPaginas}',
      'Fecha de publicación': formatearFechaIso(libro.fechaPublicacion),
      'Género': libro.genero,
    });
  }
}

/// Muestra TODA la información de un Ejemplar (se usa al consultar y antes de eliminar).
class FichaEjemplar extends StatelessWidget {
  const FichaEjemplar({super.key, required this.ejemplar});

  final Ejemplar ejemplar;

  @override
  Widget build(BuildContext context) {
    return _Ficha(datos: {
      'Código': ejemplar.codigo,
      'Estado': ejemplar.estado,
      'Ubicación': ejemplar.ubicacion,
      'Fecha de ingreso': formatearFechaIso(ejemplar.fechaIngreso),
      'Precio de reposición': formatearPrecio(ejemplar.precioReposicion),
      'ISBN del libro': ejemplar.isbnLibro,
    });
  }
}

class _Ficha extends StatelessWidget {
  const _Ficha({required this.datos});

  final Map<String, String> datos;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final MapEntry(key: etiqueta, value: valor) in datos.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: '$etiqueta: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: valor),
                ])),
              ),
          ],
        ),
      ),
    );
  }
}
