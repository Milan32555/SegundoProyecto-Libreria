// Prueba de integración contra el servidor GraphQL REAL (debe estar en ejecución).
// Se omite si no se indica la URL:
//   flutter test test/integracion_servidor_test.dart --dart-define=URL_GRAPHQL=http://localhost:8081/graphql

import 'package:cliente_movil_libreria/servicios/cliente_graphql.dart';
import 'package:cliente_movil_libreria/servicios/servicio_ejemplar.dart';
import 'package:cliente_movil_libreria/servicios/servicio_libro.dart';
import 'package:cliente_movil_libreria/utilidades/formato.dart';
import 'package:flutter_test/flutter_test.dart';

const _url = String.fromEnvironment('URL_GRAPHQL');

void main() {
  final sufijo = DateTime.now().millisecondsSinceEpoch;
  final isbn = 'FLUTTER-$sufijo';
  final codigo = 'EJ-FLUTTER-$sufijo';

  test(
    'CRUD completo de Libro y Ejemplar contra el servidor real',
    () async {
      final revisionInicial = await consultarRevisionLibros();

      final creado = await crearLibro(
        isbn: isbn,
        titulo: 'Libro desde Flutter',
        autor: 'App Móvil',
        precio: 12345.5,
        numeroPaginas: 99,
        fechaPublicacion: aFechaServidor(DateTime(2020, 1, 2, 3, 4)),
        genero: 'CIENCIA',
      );
      expect(creado.fechaPublicacion, '2020-01-02T03:04:00');
      expect(await consultarRevisionLibros(), greaterThan(revisionInicial));

      expect((await buscarLibroPorTitulo('libro desde flutter'))!.isbn, isbn);
      final filtrados = await listarLibrosFiltrados(autor: 'app movil', genero: 'CIENCIA');
      expect(filtrados.map((l) => l.isbn), contains(isbn));

      await crearEjemplar(
        codigo: codigo,
        estado: 'PRESTADO',
        ubicacion: 'Estante F',
        fechaIngreso: aFechaServidor(DateTime(2024, 6, 1)),
        precioReposicion: 5000,
        isbnLibro: isbn,
      );
      await expectLater(
        eliminarLibro(isbn),
        throwsA(isA<ErrorGraphQL>().having((e) => e.mensaje, 'mensaje', contains('ejemplar(es)'))),
      );

      final actualizado = await actualizarEjemplar(
        codigo: codigo,
        estado: 'DISPONIBLE',
        ubicacion: 'Mostrador',
        fechaIngreso: aFechaServidor(DateTime(2024, 6, 1)),
        precioReposicion: 5500,
      );
      expect(actualizado.estado, 'DISPONIBLE');
      expect((await listarEjemplaresFiltrados(estado: 'DISPONIBLE', isbnLibro: isbn)).single.codigo, codigo);

      await eliminarEjemplar(codigo);
      expect(await buscarEjemplarPorCodigo(codigo), isNull);
      expect((await eliminarLibro(isbn)).isbn, isbn);
      expect(await buscarLibroPorIsbn(isbn), isNull);
    },
    skip: _url.isEmpty ? 'Requiere el servidor: use --dart-define=URL_GRAPHQL=...' : null,
  );
}
