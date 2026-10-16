import 'package:cliente_movil_libreria/modelos/ejemplar.dart';
import 'package:cliente_movil_libreria/modelos/libro.dart';
import 'package:cliente_movil_libreria/observador/listado_observable.dart';
import 'package:cliente_movil_libreria/servicios/cliente_graphql.dart';
import 'package:cliente_movil_libreria/servicios/servicio_libro.dart';
import 'package:cliente_movil_libreria/utilidades/formato.dart';
import 'package:cliente_movil_libreria/utilidades/validaciones.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'servidor_simulado.dart';

void main() {
  group('Modelos', () {
    test('Libro se construye desde el JSON del servidor', () {
      final libro = Libro.desdeJson(libroJson(precio: 55000));

      expect(libro.isbn, '978-9584276193');
      expect(libro.precio, 55000.0); // un entero del JSON se convierte a double
      expect(libro.numeroPaginas, 352);
      expect(libro.genero, 'FICCION');
    });

    test('Ejemplar se construye desde el JSON del servidor', () {
      final ejemplar = Ejemplar.desdeJson(ejemplarJson(precioReposicion: 65000.5));

      expect(ejemplar.codigo, 'EJ-001');
      expect(ejemplar.precioReposicion, 65000.5);
      expect(ejemplar.isbnLibro, '978-0307474728');
    });

    test('los valores de los enums tienen una etiqueta legible', () {
      expect(etiquetaGenero('NO_FICCION'), 'No ficción');
      expect(etiquetaGenero('POESIA'), 'Poesía');
      expect(etiquetaEstado('DANIADO'), 'Dañado');
      expect(etiquetaEstado('DADO_DE_BAJA'), 'Dado de baja');
      expect(generos.every((g) => etiquetaGenero(g) != g), isTrue);
      expect(estadosEjemplar.every((e) => etiquetaEstado(e) != e), isTrue);
    });
  });

  group('ClienteGraphQL', () {
    test('es un Singleton', () {
      expect(identical(ClienteGraphQL(), ClienteGraphQL()), isTrue);
    });

    test('envía variables y devuelve data', () async {
      final servidor = ServidorSimulado({'libroPorIsbn': (v) => libroJson(isbn: v['isbn'] as String)})..instalar();

      final libro = await buscarLibroPorIsbn('  123  ');

      expect(libro!.isbn, '123');
      expect(servidor.variablesDe('libroPorIsbn').single, {'isbn': '123'});
    });

    test('convierte los errores del servidor en ErrorGraphQL con su mensaje', () async {
      ServidorSimulado({'crearLibro': (_) => throw ErrorSimulado('Ya existe un libro con el ISBN 1.')}).instalar();

      expect(
        () => crearLibro(
          isbn: '1',
          titulo: 't',
          autor: 'a',
          precio: 1,
          numeroPaginas: 1,
          fechaPublicacion: '2020-01-01T00:00:00',
          genero: 'OTRO',
        ),
        throwsA(isA<ErrorGraphQL>().having((e) => e.mensaje, 'mensaje', 'Ya existe un libro con el ISBN 1.')),
      );
    });

    test('informa el código HTTP cuando la respuesta no es GraphQL', () async {
      ClienteGraphQL().clienteHttp = MockClient((_) async => http.Response('Error interno', 500));

      expect(
        () => listarLibros(),
        throwsA(isA<ErrorGraphQL>().having((e) => e.mensaje, 'mensaje', contains('HTTP 500'))),
      );
    });

    test('da un mensaje claro si el servidor no está disponible', () async {
      ClienteGraphQL().clienteHttp = MockClient((_) async => throw http.ClientException('Connection refused'));

      expect(
        () => listarLibros(),
        throwsA(isA<ErrorGraphQL>().having((e) => e.mensaje, 'mensaje', contains('No se pudo conectar'))),
      );
    });
  });

  group('ListadoObservable (Observer)', () {
    test('notifica a los suscritos y no a los que se desuscribieron', () {
      final sujeto = ListadoObservable();
      var primero = 0;
      var segundo = 0;
      void observadorPrimero() => primero++;
      void observadorSegundo() => segundo++;

      sujeto.suscribir(observadorPrimero);
      sujeto.suscribir(observadorSegundo);
      sujeto.notificar();
      sujeto.desuscribir(observadorSegundo);
      sujeto.notificar();
      sujeto.desuscribir(observadorPrimero);

      expect(primero, 2);
      expect(segundo, 1);
    });

    test('notifica cuando cambia la revisión del servidor y deja de consultar sin observadores', () async {
      var revision = 1;
      var consultas = 0;
      final sujeto = ListadoObservable(
        consultarRevision: () async {
          consultas++;
          return revision;
        },
        intervalo: const Duration(milliseconds: 20),
      );
      var notificaciones = 0;
      void observador() => notificaciones++;

      sujeto.suscribir(observador);
      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(notificaciones, 0);

      revision = 2;
      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(notificaciones, 1);

      sujeto.desuscribir(observador);
      final consultasAlSalir = consultas;
      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(consultas, consultasAlSalir);
    });
  });

  group('Utilidades', () {
    test('validaciones de formulario', () {
      expect(validarObligatorio('  '), 'Obligatorio');
      expect(validarObligatorio('x'), isNull);
      expect(validarDecimalPositivo('abc'), 'Número inválido');
      expect(validarDecimalPositivo('0'), 'Debe ser mayor que cero');
      expect(validarDecimalPositivo('1500.5'), isNull);
      expect(validarEnteroPositivo('1.5'), 'Número entero inválido');
      expect(validarEnteroPositivo('-3'), 'Debe ser mayor que cero');
      expect(validarEnteroPositivo('120'), isNull);
    });

    test('formatos de fecha y precio', () {
      expect(aFechaServidor(DateTime(1967, 5, 30)), '1967-05-30T00:00:00');
      expect(formatearFecha(DateTime(2024, 2, 10)), '10/02/2024');
      expect(formatearFechaIso('2024-02-10T09:05:00'), '10/02/2024 09:05');
      expect(formatearFechaIso('no es fecha'), 'no es fecha');
      expect(formatearPrecio(65000), '\$ 65.000');
    });
  });
}
