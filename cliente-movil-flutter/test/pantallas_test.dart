import 'package:cliente_movil_libreria/main.dart';
import 'package:cliente_movil_libreria/observador/listado_observable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'servidor_simulado.dart';

/// Abre la app directamente en [ruta] (con el menú principal debajo en la pila).
Future<void> abrir(WidgetTester tester, String ruta) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(AplicacionLibreria(rutaInicial: ruta));
  await tester.pumpAndSettle();
}

Future<void> escribir(WidgetTester tester, String etiqueta, String texto) =>
    tester.enterText(find.widgetWithText(TextField, etiqueta), texto);

void main() {
  group('Menú principal', () {
    testWidgets('tiene una opción por caso de uso y el menú Ayuda con "Acerca de..."', (tester) async {
      await abrir(tester, '/');

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      expect(find.text('LIBRO'), findsOneWidget);
      expect(find.text('EJEMPLAR'), findsOneWidget);
      expect(find.text('AYUDA'), findsOneWidget);
      for (final opcion in ['Adicionar', 'Eliminar', 'Actualizar', 'Listar', 'Buscar por criterios']) {
        expect(find.text(opcion), findsNWidgets(2));
      }

      await tester.tap(find.text('Acerca de...'));
      await tester.pumpAndSettle();

      expect(find.text('Versión: 1.0.0'), findsOneWidget);
      for (final integrante in ['Misael Gallo Tangarife', 'Sara Zambrano', 'Santiago Guimel', 'Alejandra González']) {
        expect(find.text('• $integrante'), findsOneWidget);
      }
    });
  });

  group('Listar Libros', () {
    testWidgets('muestra los libros en una grilla y filtra en el servidor', (tester) async {
      final servidor = ServidorSimulado({
        'librosFiltrados': (_) => [libroJson()],
        'revisionLibros': (_) => 1,
      })..instalar();
      await abrir(tester, '/libros/listar');

      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('Delirio'), findsOneWidget);
      expect(find.text('1 libro(s)'), findsOneWidget);

      await escribir(tester, 'Autor contiene', 'restrepo');
      await tester.tap(find.byTooltip('Filtrar'));
      await tester.pumpAndSettle();

      expect(servidor.variablesDe('librosFiltrados').last, {'autor': 'restrepo', 'genero': null});
    });

    testWidgets('Observer: se refresca sola cuando el sujeto notifica un cambio', (tester) async {
      var libros = [libroJson()];
      ServidorSimulado({
        'librosFiltrados': (_) => libros,
        'revisionLibros': (_) => 1,
      }).instalar();
      await abrir(tester, '/libros/listar');
      expect(find.text('Pedro Páramo'), findsNothing);

      libros = [libroJson(), libroJson(isbn: '978-1', titulo: 'Pedro Páramo', autor: 'Juan Rulfo')];
      libroObservable.notificar();
      await tester.pumpAndSettle();

      expect(find.text('Pedro Páramo'), findsOneWidget);
      expect(find.text('2 libro(s)'), findsOneWidget);
    });
  });

  group('Eliminar Libro', () {
    testWidgets('muestra TODA la información antes de eliminar y elimina al confirmar', (tester) async {
      final servidor = ServidorSimulado({
        'libroPorIsbn': (_) => libroJson(),
        'eliminarLibro': (_) => libroJson(),
      })..instalar();
      await abrir(tester, '/libros/eliminar');

      await escribir(tester, 'ISBN del libro a eliminar', '978-9584276193');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(find.text('ISBN: 978-9584276193'), findsOneWidget);
      expect(find.text('Título: Delirio'), findsOneWidget);
      expect(find.text('Autor: Laura Restrepo'), findsOneWidget);
      expect(find.text('Precio: \$ 55.000'), findsOneWidget);
      expect(find.text('Páginas: 352'), findsOneWidget);
      expect(find.text('Fecha de publicación: 01/03/2004 00:00'), findsOneWidget);
      expect(find.text('Género: FICCION'), findsOneWidget);
      expect(servidor.variablesDe('eliminarLibro'), isEmpty);

      await tester.tap(find.text('Confirmar eliminación'));
      await tester.pumpAndSettle();

      expect(servidor.variablesDe('eliminarLibro').single, {'isbn': '978-9584276193'});
      expect(find.text('Libro "Delirio" eliminado correctamente.'), findsOneWidget);
    });

    testWidgets('muestra el motivo cuando el servidor rechaza la eliminación', (tester) async {
      ServidorSimulado({
        'libroPorIsbn': (_) => libroJson(),
        'eliminarLibro': (_) => throw ErrorSimulado('No se puede eliminar: tiene 2 ejemplar(es).'),
      }).instalar();
      await abrir(tester, '/libros/eliminar');

      await escribir(tester, 'ISBN del libro a eliminar', '978-9584276193');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar eliminación'));
      await tester.pumpAndSettle();

      expect(find.text('No se puede eliminar: tiene 2 ejemplar(es).'), findsOneWidget);
    });
  });

  group('Adicionar Libro', () {
    testWidgets('valida los campos antes de enviar', (tester) async {
      final servidor = ServidorSimulado({})..instalar();
      await abrir(tester, '/libros/agregar');

      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Obligatorio'), findsNWidgets(3));
      expect(find.text('Seleccione la fecha de publicación.'), findsOneWidget);
      expect(servidor.peticiones, isEmpty);
    });

    testWidgets('envía todos los atributos con su tipo', (tester) async {
      final servidor = ServidorSimulado({'crearLibro': (v) => v['input']})..instalar();
      await abrir(tester, '/libros/agregar');

      await escribir(tester, 'ISBN', '978-1');
      await escribir(tester, 'Título', 'Pedro Páramo');
      await escribir(tester, 'Autor', 'Juan Rulfo');
      await escribir(tester, 'Precio', '39000.5');
      await escribir(tester, 'Número de páginas', '124');
      await tester.tap(find.text('Fecha de publicación'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      final hoy = DateTime.now();
      final input = servidor.variablesDe('crearLibro').single['input'] as Map<String, dynamic>;
      expect(input['isbn'], '978-1');
      expect(input['precio'], 39000.5);
      expect(input['numeroPaginas'], 124);
      expect(input['genero'], 'FICCION');
      expect(input['fechaPublicacion'],
          '${hoy.year}-${'${hoy.month}'.padLeft(2, '0')}-${'${hoy.day}'.padLeft(2, '0')}T00:00:00');
      expect(find.text('Libro "Pedro Páramo" creado correctamente.'), findsOneWidget);
    });
  });

  group('Consultar Libro', () {
    testWidgets('consulta UN SOLO libro por título como criterio alternativo', (tester) async {
      final servidor = ServidorSimulado({
        'libroPorTitulo': (_) => libroJson(titulo: 'La vorágine', autor: 'José Eustasio Rivera'),
      })..instalar();
      await abrir(tester, '/libros/consultar');

      await tester.tap(find.text('Por título'));
      await tester.pumpAndSettle();
      await escribir(tester, 'Título', 'la voragine');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(servidor.variablesDe('libroPorTitulo').single, {'titulo': 'la voragine'});
      expect(find.text('Autor: José Eustasio Rivera'), findsOneWidget);
    });
  });

  group('Actualizar Ejemplar', () {
    testWidgets('busca primero, muestra los datos actuales y luego guarda', (tester) async {
      final servidor = ServidorSimulado({
        'ejemplarPorCodigo': (_) => ejemplarJson(),
        'actualizarEjemplar': (_) => ejemplarJson(ubicacion: 'Mostrador'),
      })..instalar();
      await abrir(tester, '/ejemplares/actualizar');

      await escribir(tester, 'Código del ejemplar a actualizar', 'EJ-001');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(find.text('Libro (ISBN): 978-0307474728'), findsOneWidget);
      expect(find.text('DISPONIBLE'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Estante A1'), findsOneWidget);
      expect(find.text('10/02/2024'), findsOneWidget);

      await escribir(tester, 'Ubicación', 'Mostrador');
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(servidor.variablesDe('actualizarEjemplar').single, {
        'codigo': 'EJ-001',
        'input': {
          'estado': 'DISPONIBLE',
          'ubicacion': 'Mostrador',
          'fechaIngreso': '2024-02-10T09:00:00',
          'precioReposicion': 65000.0,
        },
      });
    });
  });
}
