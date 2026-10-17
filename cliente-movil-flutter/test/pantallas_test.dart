import 'package:cliente_movil_libreria/main.dart';
import 'package:cliente_movil_libreria/observador/listado_observable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'servidor_simulado.dart';

/// Abre la app directamente en [ruta] (con el menú principal debajo en la pila).
Future<void> abrir(WidgetTester tester, String ruta) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(AplicacionLibreria(rutaInicial: ruta));
  await tester.pumpAndSettle();
}

Future<void> escribir(WidgetTester tester, String etiqueta, String texto) =>
    tester.enterText(find.widgetWithText(TextField, etiqueta), texto);

void main() {
  group('Menú principal', () {
    testWidgets('muestra el resumen del inventario que trae del servidor', (tester) async {
      ServidorSimulado({
        'libros': (_) => [libroJson(), libroJson(isbn: '978-1', titulo: 'Pedro Páramo')],
        'ejemplares': (_) => [ejemplarJson(), ejemplarJson(codigo: 'EJ-002', estado: 'PRESTADO')],
        'revisionLibros': (_) => 1,
        'revisionEjemplares': (_) => 1,
      }).instalar();
      await abrir(tester, '/');

      expect(find.text('2'), findsNWidgets(2)); // 2 títulos y 2 ejemplares
      for (final estado in ['Disponibles', 'Prestados', 'Dañados', 'Dados de baja']) {
        expect(find.text(estado), findsOneWidget);
      }
      expect(find.text('1'), findsNWidgets(2)); // 1 disponible y 1 prestado
      expect(find.text('0'), findsNWidgets(2)); // ningún dañado ni dado de baja
    });

    testWidgets('avisa si no hay conexión con el servidor', (tester) async {
      ServidorSimulado({'libros': (_) => throw ErrorSimulado('No se pudo conectar con el servidor.')}).instalar();
      await abrir(tester, '/');

      expect(find.text('No se pudo conectar con el servidor.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('tiene una opción por caso de uso y el menú Ayuda con "Acerca de..."', (tester) async {
      ServidorSimulado({}).instalar();
      await abrir(tester, '/');

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      final menu = find.byType(Drawer);
      for (final seccion in ['LIBRO', 'EJEMPLAR', 'AYUDA']) {
        expect(find.descendant(of: menu, matching: find.text(seccion)), findsOneWidget);
      }
      for (final opcion in ['Adicionar', 'Eliminar', 'Actualizar', 'Listar', 'Buscar por criterios']) {
        expect(find.descendant(of: menu, matching: find.text(opcion)), findsNWidgets(2));
      }

      await tester.tap(find.descendant(of: menu, matching: find.text('Acerca de...')));
      // El diagrama de arquitectura se anima sin fin: se avanza el tiempo en lugar de esperar a que pare.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Versión 1.0.0'), findsOneWidget);
      for (final integrante in ['Misael Gallo Tangarife', 'Sara Zambrano', 'Santiago Guimel', 'Alejandra González']) {
        expect(find.text(integrante), findsOneWidget);
      }
    });

    testWidgets('los accesos directos abren la pantalla de cada caso de uso', (tester) async {
      ServidorSimulado({}).instalar();
      await abrir(tester, '/');

      await tester.tap(find.text('Adicionar').first);
      await tester.pumpAndSettle();

      expect(find.text('Nuevo libro'), findsOneWidget);
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
      expect(find.text('Laura Restrepo'), findsOneWidget);
      expect(find.text('1 libro'), findsOneWidget);

      await escribir(tester, 'Autor contiene', 'restrepo');
      await tester.tap(find.byTooltip('Filtrar'));
      await tester.pumpAndSettle();
      expect(servidor.variablesDe('librosFiltrados').last, {'autor': 'restrepo', 'genero': null});

      await tester.tap(find.widgetWithText(ChoiceChip, 'Poesía'));
      await tester.pumpAndSettle();
      expect(servidor.variablesDe('librosFiltrados').last, {'autor': 'restrepo', 'genero': 'POESIA'});
    });

    testWidgets('Observer: se refresca sola cuando el sujeto notifica un cambio', (tester) async {
      var libros = [libroJson()];
      ServidorSimulado({'librosFiltrados': (_) => libros, 'revisionLibros': (_) => 1}).instalar();
      await abrir(tester, '/libros/listar');
      expect(find.text('Pedro Páramo'), findsNothing);

      libros = [libroJson(), libroJson(isbn: '978-1', titulo: 'Pedro Páramo', autor: 'Juan Rulfo')];
      libroObservable.notificar();
      await tester.pumpAndSettle();

      expect(find.text('Pedro Páramo'), findsOneWidget);
      expect(find.text('2 libros'), findsOneWidget);
    });
  });

  group('Eliminar Libro', () {
    testWidgets('muestra TODA la información antes de eliminar y elimina al confirmar', (tester) async {
      final servidor = ServidorSimulado({'libroPorIsbn': (_) => libroJson(), 'eliminarLibro': (_) => libroJson()})
        ..instalar();
      await abrir(tester, '/libros/eliminar');

      await escribir(tester, 'ISBN del libro a eliminar', '978-9584276193');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(find.text('978-9584276193'), findsWidgets);
      expect(find.text('Delirio'), findsOneWidget);
      expect(find.text('por Laura Restrepo'), findsOneWidget);
      expect(find.text('\$ 55.000'), findsOneWidget);
      expect(find.text('352'), findsOneWidget);
      expect(find.text('01/03/2004 00:00'), findsOneWidget);
      expect(find.text('Ficción'), findsNWidgets(2)); // pastilla + dato "Género"
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
      expect(servidor.variablesDe('crearLibro'), isEmpty);
    });

    testWidgets('envía todos los atributos con su tipo', (tester) async {
      final servidor = ServidorSimulado({'crearLibro': (v) => v['input']})..instalar();
      await abrir(tester, '/libros/agregar');

      await escribir(tester, 'ISBN', '978-1');
      await escribir(tester, 'Título', 'Pedro Páramo');
      await escribir(tester, 'Autor', 'Juan Rulfo');
      await escribir(tester, 'Precio', '39000.5');
      await escribir(tester, 'Páginas', '124');
      await tester.tap(find.widgetWithText(ChoiceChip, 'No ficción'));
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
      expect(input['genero'], 'NO_FICCION');
      expect(
        input['fechaPublicacion'],
        '${hoy.year}-${'${hoy.month}'.padLeft(2, '0')}-${'${hoy.day}'.padLeft(2, '0')}T00:00:00',
      );
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
      expect(find.text('por José Eustasio Rivera'), findsOneWidget);
    });

    testWidgets('informa cuando no encuentra el libro', (tester) async {
      ServidorSimulado({'libroPorIsbn': (_) => null}).instalar();
      await abrir(tester, '/libros/consultar');

      await escribir(tester, 'ISBN', '000');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(find.text('No se encontró ningún libro con ese isbn.'), findsOneWidget);
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

      expect(find.text('Pertenece al libro 978-0307474728. El código no se puede modificar.'), findsOneWidget);
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Disponible')).selected, isTrue);
      expect(find.widgetWithText(TextFormField, 'Estante A1'), findsOneWidget);
      expect(find.text('10/02/2024'), findsOneWidget);

      await escribir(tester, 'Ubicación', 'Mostrador');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Prestado'));
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(servidor.variablesDe('actualizarEjemplar').single, {
        'codigo': 'EJ-001',
        'input': {
          'estado': 'PRESTADO',
          'ubicacion': 'Mostrador',
          'fechaIngreso': '2024-02-10T09:00:00',
          'precioReposicion': 65000.0,
        },
      });
    });
  });

  group('Listar Ejemplares', () {
    testWidgets('muestra el estado con su etiqueta y filtra por estado', (tester) async {
      final servidor = ServidorSimulado({
        'ejemplaresFiltrados': (_) => [ejemplarJson(estado: 'DANIADO')],
        'revisionEjemplares': (_) => 1,
      })..instalar();
      await abrir(tester, '/ejemplares/listar');

      expect(find.text('EJ-001'), findsOneWidget);
      expect(find.text('Dañado'), findsNWidgets(2)); // chip del filtro + pastilla de la fila
      expect(find.text('1 ejemplar'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Prestado'));
      await tester.pumpAndSettle();
      expect(servidor.variablesDe('ejemplaresFiltrados').last, {'estado': 'PRESTADO', 'isbnLibro': null});
    });
  });
}
