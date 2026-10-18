import 'package:cliente_movil_libreria/modelos/ejemplar.dart';
import 'package:cliente_movil_libreria/modelos/libro.dart';
import 'package:cliente_movil_libreria/modelos/resumen_inventario.dart';
import 'package:cliente_movil_libreria/observador/listado_observable.dart';
import 'package:cliente_movil_libreria/servicios/cliente_graphql.dart';
import 'package:cliente_movil_libreria/servicios/servicio_libro.dart';
import 'package:cliente_movil_libreria/servicios/servicio_resumen.dart';
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
      final ejemplar = Ejemplar.desdeJson(ejemplarJson(precioReposicion: 65000.5, numeroPrestamos: 7));

      expect(ejemplar.codigo, 'EJ-001');
      expect(ejemplar.precioReposicion, 65000.5);
      expect(ejemplar.numeroPrestamos, 7);
      expect(ejemplar.isbnLibro, '978-0307474728');
    });

    test('ResumenInventario se construye desde el JSON del servidor', () {
      final resumen = ResumenInventario.desdeJson(resumenJson(totalLibros: 5));

      expect(resumen.totalLibros, 5);
      expect(resumen.totalEjemplares, 2);
      expect(resumen.ejemplaresPorEstado.map((c) => c.estado), estadosEjemplar);
      expect(resumen.ejemplaresPorEstado.first.cantidad, 1);
      expect(resumen.ejemplaresPorEstado.first.porcentaje, 50.0);
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

    test('pide la lista y su total (calculado por el servidor) en una sola petición', () async {
      final servidor = ServidorSimulado({
        'librosFiltrados': (_) => [libroJson()],
        'totalLibrosFiltrados': (_) => 1,
      })..instalar();

      final listado = await listarLibrosFiltrados(autor: ' restrepo ', genero: '');

      expect(listado.libros.single.titulo, 'Delirio');
      expect(listado.total, 1);
      expect(servidor.variablesDe('totalLibrosFiltrados').single, {'autor': 'restrepo', 'genero': null});
    });

    test('consulta el resumen del inventario al servidor', () async {
      ServidorSimulado({'resumenInventario': (_) => resumenJson(totalLibros: 3)}).instalar();

      final resumen = await consultarResumenInventario();

      expect(resumen.totalLibros, 3);
      expect(resumen.totalEjemplares, 2);
    });

    test('se identifica ante el servidor con el encabezado X-Cliente', () async {
      String? cliente;
      ClienteGraphQL().clienteHttp = MockClient((request) async {
        cliente = request.headers['X-Cliente'];
        return http.Response('{"data":{"revisionLibros":1}}', 200);
      });

      await consultarRevisionLibros();

      expect(cliente, 'movil');
    });

    test('informa el código HTTP cuando la respuesta no es GraphQL', () async {
      ClienteGraphQL().clienteHttp = MockClient((_) async => http.Response('Error interno', 500));

      expect(
        () => consultarRevisionLibros(),
        throwsA(isA<ErrorGraphQL>().having((e) => e.mensaje, 'mensaje', contains('HTTP 500'))),
      );
    });

    test('da un mensaje claro si el servidor no está disponible', () async {
      ClienteGraphQL().clienteHttp = MockClient((_) async => throw http.ClientException('Connection refused'));

      expect(
        () => consultarRevisionLibros(),
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

    test('por defecto revisa los cambios de otros clientes cada 15 s', () {
      expect(intervaloRevision, const Duration(seconds: 15));
      expect(libroObservable.intervalo, intervaloRevision);
      expect(ejemplarObservable.intervalo, intervaloRevision);
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
      expect(validarEnteroNoNegativo('0'), isNull);
      expect(validarEnteroNoNegativo('-1'), 'No puede ser negativo');
      expect(validarEnteroNoNegativo('2.5'), 'Número entero inválido');
    });

    test('formatos de fecha y precio', () {
      expect(aFechaServidor(DateTime(1967, 5, 30)), '1967-05-30T00:00:00');
      expect(formatearFecha(DateTime(2024, 2, 10)), '10/02/2024');
      expect(formatearFechaHora(DateTime(2024, 2, 10, 9, 5)), '10/02/2024 09:05');
      expect(formatearFechaIso('2024-02-10T09:05:00'), '10/02/2024 09:05');
      expect(formatearFechaIso('no es fecha'), 'no es fecha');
      expect(formatearPrecio(65000), '\$ 65.000');
    });

    test('fecha larga y saludo del inicio', () {
      expect(formatearFechaLarga(DateTime(2026, 10, 17)), 'Sábado, 17 de octubre');
      expect(formatearFechaLarga(DateTime(2026, 3, 2)), 'Lunes, 2 de marzo');
      expect(saludo(DateTime(2026, 1, 1, 8)), 'Buenos días');
      expect(saludo(DateTime(2026, 1, 1, 15)), 'Buenas tardes');
      expect(saludo(DateTime(2026, 1, 1, 22)), 'Buenas noches');
      expect(saludo(DateTime(2026, 1, 1, 2)), 'Buenas noches');
    });
  });
}
