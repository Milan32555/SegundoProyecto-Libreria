import 'package:cliente_movil_libreria/main.dart';
import 'package:cliente_movil_libreria/modelos/ejemplar.dart';
import 'package:cliente_movil_libreria/modelos/libro.dart';
import 'package:cliente_movil_libreria/observador/listado_observable.dart';
import 'package:cliente_movil_libreria/pantallas/comunes/campo_fecha.dart';
import 'package:cliente_movil_libreria/pantallas/comunes/tabla_datos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'servidor_simulado.dart';

/// Abre la app directamente en [ruta] (con el inicio debajo en la pila).
Future<void> abrir(WidgetTester tester, String ruta) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(AplicacionLibreria(rutaInicial: ruta));
  await tester.pumpAndSettle();
}

Future<void> escribir(WidgetTester tester, String etiqueta, String texto) =>
    tester.enterText(find.widgetWithText(TextField, etiqueta), texto);

Future<void> tocar(WidgetTester tester, Finder objetivo) async {
  await tester.ensureVisible(objetivo);
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

/// Abre una lista desplegable por su etiqueta y elige una opción.
Future<void> elegir(WidgetTester tester, String etiqueta, String opcion) async {
  await tocar(tester, find.widgetWithText(DropdownButtonFormField<String>, etiqueta));
  await tocar(tester, find.text(opcion).last);
}

/// Abre el campo de fecha, acepta el día de hoy y luego la hora (opcionalmente escribiéndola).
Future<void> elegirFechaYHora(WidgetTester tester, {String? hora, String? minuto}) async {
  await tocar(tester, find.byType(CampoFecha));
  await tocar(tester, find.text('OK')); // calendario
  if (hora != null && minuto != null) {
    await tocar(tester, find.byIcon(Icons.keyboard_outlined)); // escribir la hora en vez de usar el reloj
    final campos = find.descendant(of: find.byType(Dialog), matching: find.byType(TextField));
    await tester.enterText(campos.at(0), hora);
    await tester.enterText(campos.at(1), minuto);
  }
  await tocar(tester, find.text('OK')); // hora
}

Finder campoDeBusqueda() => find.descendant(of: find.byType(SearchBar), matching: find.byType(TextField));

void main() {
  group('Inicio', () {
    testWidgets('muestra las cifras que calcula el servidor (la pantalla no cuenta nada)', (tester) async {
      final servidor = ServidorSimulado({
        'resumenInventario': (_) => resumenJson(
          totalLibros: 12,
          porEstado: const {'DISPONIBLE': 10, 'PRESTADO': 6, 'DANIADO': 3, 'DADO_DE_BAJA': 1},
        ),
        'revisionLibros': (_) => 1,
        'revisionEjemplares': (_) => 1,
      })..instalar();
      await abrir(tester, '/');

      expect(servidor.peticiones.map((p) => p.campo), isNot(contains('libros')));
      expect(servidor.peticiones.map((p) => p.campo), isNot(contains('ejemplares')));
      expect(find.text('12'), findsOneWidget); // títulos
      expect(find.text('20'), findsOneWidget); // ejemplares
      expect(find.text('10'), findsNWidgets(2)); // cifra "Disponibles" + fila de la leyenda
      for (final estado in ['Disponibles', 'Prestados', 'Dañados', 'Dados de baja']) {
        expect(find.text(estado), findsWidgets);
      }
      expect(find.text('50 %'), findsOneWidget);
      expect(find.text('15 %'), findsOneWidget);
      expect(find.text('20 copias · calculado por el servidor'), findsOneWidget);
    });

    testWidgets('avisa si no hay conexión y permite reintentar', (tester) async {
      var fallar = true;
      ServidorSimulado({
        'resumenInventario': (_) => fallar ? throw ErrorSimulado('No se pudo conectar con el servidor.') : resumenJson(),
        'revisionLibros': (_) => 1,
        'revisionEjemplares': (_) => 1,
      }).instalar();
      await abrir(tester, '/');

      expect(find.text('No se pudo conectar con el servidor.'), findsOneWidget);
      fallar = false;
      await tocar(tester, find.text('Reintentar'));

      expect(find.text('No se pudo conectar con el servidor.'), findsNothing);
      expect(find.text('2 copias · calculado por el servidor'), findsOneWidget);
    });

    testWidgets('el menú tiene una opción por caso de uso y Ayuda > "Acerca de..."', (tester) async {
      ServidorSimulado({'resumenInventario': (_) => resumenJson(), 'revisionLibros': (_) => 3, 'revisionEjemplares': (_) => 1})
        .instalar();
      await abrir(tester, '/');

      await tocar(tester, find.byTooltip('Open navigation menu'));

      final menu = find.byType(NavigationDrawer);
      for (final seccion in ['Libros', 'Ejemplares', 'Ayuda']) {
        expect(find.descendant(of: menu, matching: find.text(seccion)), findsOneWidget);
      }
      for (final opcion in ['Listar', 'Consultar', 'Adicionar', 'Actualizar', 'Eliminar']) {
        expect(find.descendant(of: menu, matching: find.text(opcion)), findsNWidgets(2));
      }

      await tocar(tester, find.descendant(of: menu, matching: find.text('Acerca de...')));

      expect(find.text('Acerca de'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
      for (final integrante in ['Misael Gallo Tangarife', 'Sara Zambrano', 'Santiago Guimel', 'Alejandra González']) {
        expect(find.text(integrante), findsOneWidget);
      }
      expect(find.textContaining(RegExp(r'^Servidor conectado · \d+ ms$')), findsOneWidget);
    });

    testWidgets('el menú abre la pantalla de cada caso de uso', (tester) async {
      ServidorSimulado({'resumenInventario': (_) => resumenJson(), 'revisionLibros': (_) => 1, 'revisionEjemplares': (_) => 1})
        .instalar();
      await abrir(tester, '/');

      await tocar(tester, find.byTooltip('Open navigation menu'));
      await tocar(tester, find.descendant(of: find.byType(NavigationDrawer), matching: find.text('Adicionar')).last);

      expect(find.text('Adicionar ejemplar'), findsWidgets);
      expect(find.widgetWithText(TextField, 'Código del ejemplar'), findsOneWidget);
    });

    testWidgets('los accesos directos y el buscador llevan a su caso de uso', (tester) async {
      final servidor = ServidorSimulado({
        'resumenInventario': (_) => resumenJson(),
        'revisionLibros': (_) => 1,
        'revisionEjemplares': (_) => 1,
        'libroPorTitulo': (_) => libroJson(titulo: 'La vorágine', autor: 'José Eustasio Rivera'),
      })..instalar();
      await abrir(tester, '/');

      await tester.enterText(campoDeBusqueda(), 'la voragine');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(servidor.variablesDe('libroPorTitulo').single, {'titulo': 'la voragine'});
      expect(find.text('La vorágine'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tocar(tester, find.text('Adicionar libro'));
      expect(find.widgetWithText(FilledButton, 'Adicionar libro'), findsOneWidget);
    });
  });

  group('Listar Libros', () {
    testWidgets('muestra los libros en una grilla y filtra en el servidor', (tester) async {
      final servidor = ServidorSimulado({
        'librosFiltrados': (_) => [libroJson()],
        'totalLibrosFiltrados': (_) => 1,
        'revisionLibros': (_) => 1,
      })..instalar();
      await abrir(tester, '/libros/listar');

      expect(find.byType(TablaDatos<Libro>), findsOneWidget);
      expect(find.text('Delirio'), findsOneWidget);
      expect(find.text('Laura Restrepo'), findsOneWidget);
      expect(find.text('Páginas'), findsOneWidget);
      expect(find.text('352'), findsOneWidget);
      expect(find.text('1 libro'), findsOneWidget);
      expect(find.text('Total calculado por el servidor'), findsOneWidget);

      await tester.enterText(campoDeBusqueda(), 'restrepo');
      await tocar(tester, find.byTooltip('Filtrar'));
      expect(servidor.variablesDe('librosFiltrados').last, {'autor': 'restrepo', 'genero': null});

      await tocar(tester, find.widgetWithText(ChoiceChip, 'Poesía'));
      expect(servidor.variablesDe('librosFiltrados').last, {'autor': 'restrepo', 'genero': 'POESIA'});
    });

    testWidgets('Observer: se refresca sola cuando el sujeto notifica un cambio', (tester) async {
      var libros = [libroJson()];
      ServidorSimulado({
        'librosFiltrados': (_) => libros,
        'totalLibrosFiltrados': (_) => libros.length, // en el servidor real lo cuenta el servidor
        'revisionLibros': (_) => 1,
      }).instalar();
      await abrir(tester, '/libros/listar');
      expect(find.text('Pedro Páramo'), findsNothing);

      libros = [libroJson(), libroJson(isbn: '978-9681649500', titulo: 'Pedro Páramo', autor: 'Juan Rulfo')];
      libroObservable.notificar();
      await tester.pumpAndSettle();

      expect(find.text('Pedro Páramo'), findsOneWidget);
      expect(find.text('2 libros'), findsOneWidget);
    });

    testWidgets('estado vacío con filtro, limpiar filtros y error con reintento', (tester) async {
      var fallar = false;
      final servidor = ServidorSimulado({
        'librosFiltrados': (v) => fallar ? throw ErrorSimulado('No se pudo conectar con el servidor.') : (v['autor'] == null ? [libroJson()] : []),
        'totalLibrosFiltrados': (v) => v['autor'] == null ? 1 : 0,
        'revisionLibros': (_) => 1,
      })..instalar();
      await abrir(tester, '/libros/listar');

      await tester.enterText(campoDeBusqueda(), 'nadie');
      await tocar(tester, find.byTooltip('Filtrar'));
      expect(find.text('Ningún libro coincide con el filtro'), findsOneWidget);

      await tocar(tester, find.widgetWithText(OutlinedButton, 'Limpiar filtros'));
      expect(servidor.variablesDe('librosFiltrados').last, {'autor': null, 'genero': null});
      expect(find.text('Delirio'), findsOneWidget);

      fallar = true;
      libroObservable.notificar();
      await tester.pumpAndSettle();
      expect(find.text('No se pudo cargar la lista'), findsOneWidget);
      fallar = false;
      await tocar(tester, find.text('Reintentar'));
      expect(find.text('No se pudo cargar la lista'), findsNothing);
    });
  });

  group('Eliminar Libro', () {
    testWidgets('muestra TODA la información y elimina solo al confirmar en la hoja inferior', (tester) async {
      final servidor = ServidorSimulado({
        'libroPorIsbn': (_) => libroJson(),
        'eliminarLibro': (_) => libroJson(),
        'resumenInventario': (_) => resumenJson(),
        'revisionLibros': (_) => 1,
        'revisionEjemplares': (_) => 1,
      })..instalar();
      await abrir(tester, '/libros/eliminar');

      await escribir(tester, 'ISBN del libro', '978-8420401751');
      await tocar(tester, find.widgetWithText(FilledButton, 'Buscar'));

      expect(find.text('Libro a eliminar'), findsOneWidget);
      expect(find.text('Delirio'), findsOneWidget);
      expect(find.text('Laura Restrepo'), findsNWidgets(2)); // cabecera + dato "Autor"
      expect(find.text('\$ 55.000'), findsOneWidget);
      expect(find.text('352'), findsOneWidget);
      expect(find.text('01/03/2004 10:30'), findsOneWidget); // fecha CON hora
      expect(find.text('Ficción'), findsOneWidget);

      // Cancelar en la hoja inferior no elimina nada.
      await tocar(tester, find.widgetWithText(FilledButton, 'Eliminar libro'));
      expect(find.text('¿Eliminar «Delirio»?'), findsOneWidget);
      await tocar(tester, find.widgetWithText(OutlinedButton, 'Cancelar').last);
      expect(servidor.variablesDe('eliminarLibro'), isEmpty);

      await tocar(tester, find.widgetWithText(FilledButton, 'Eliminar libro'));
      await tocar(tester, find.widgetWithText(FilledButton, 'Eliminar'));

      expect(servidor.variablesDe('eliminarLibro').single, {'isbn': '978-8420401751'});
      expect(find.text('Libro eliminado: «Delirio».'), findsOneWidget);
    });

    testWidgets('muestra el motivo cuando el servidor rechaza la eliminación', (tester) async {
      ServidorSimulado({
        'libroPorIsbn': (_) => libroJson(),
        'eliminarLibro': (_) => throw ErrorSimulado('No se puede eliminar: tiene 2 ejemplar(es).'),
      }).instalar();
      await abrir(tester, '/libros/eliminar');

      await escribir(tester, 'ISBN del libro', '978-8420401751');
      await tocar(tester, find.widgetWithText(FilledButton, 'Buscar'));
      await tocar(tester, find.widgetWithText(FilledButton, 'Eliminar libro'));
      await tocar(tester, find.widgetWithText(FilledButton, 'Eliminar'));

      expect(find.text('El servidor no permitió eliminar el libro'), findsOneWidget);
      expect(find.text('No se puede eliminar: tiene 2 ejemplar(es).'), findsOneWidget);
      expect(find.text('Libro a eliminar'), findsOneWidget);
    });

    testWidgets('no busca con el campo vacío e informa si no existe', (tester) async {
      final servidor = ServidorSimulado({'libroPorIsbn': (_) => null})..instalar();
      await abrir(tester, '/libros/eliminar');

      await tocar(tester, find.widgetWithText(FilledButton, 'Buscar'));
      expect(find.text('Este campo es obligatorio.'), findsOneWidget);
      expect(servidor.variablesDe('libroPorIsbn'), isEmpty);

      await escribir(tester, 'ISBN del libro', '000');
      await tocar(tester, find.widgetWithText(FilledButton, 'Buscar'));
      expect(find.text('No hay ningún libro con el ISBN «000».'), findsOneWidget);
    });
  });

  group('Adicionar Libro', () {
    testWidgets('valida en línea antes de enviar', (tester) async {
      final servidor = ServidorSimulado({})..instalar();
      await abrir(tester, '/libros/agregar');

      await tocar(tester, find.widgetWithText(FilledButton, 'Adicionar libro'));

      expect(find.text('Este campo es obligatorio.'), findsNWidgets(5));
      expect(find.text('Elige la fecha y la hora.'), findsOneWidget);
      expect(servidor.variablesDe('crearLibro'), isEmpty);
    });

    testWidgets('envía todos los atributos con su tipo', (tester) async {
      final servidor = ServidorSimulado({
        'crearLibro': (v) => v['input'],
        'resumenInventario': (_) => resumenJson(),
        'revisionLibros': (_) => 1,
        'revisionEjemplares': (_) => 1,
      })..instalar();
      await abrir(tester, '/libros/agregar');

      await escribir(tester, 'ISBN', '978-9681649500');
      await escribir(tester, 'Título', 'Pedro Páramo');
      await escribir(tester, 'Autor', 'Juan Rulfo');
      await escribir(tester, 'Precio', '42000.5');
      await escribir(tester, 'Número de páginas', '129');
      await elegir(tester, 'Género', 'No ficción');
      await elegirFechaYHora(tester, hora: '14', minuto: '30');
      expect(find.textContaining(' 14:30'), findsOneWidget); // el campo muestra fecha y hora
      await tocar(tester, find.widgetWithText(FilledButton, 'Adicionar libro'));

      final hoy = DateTime.now();
      final input = servidor.variablesDe('crearLibro').single['input'] as Map<String, dynamic>;
      expect(input['isbn'], '978-9681649500');
      expect(input['precio'], 42000.5);
      expect(input['numeroPaginas'], 129);
      expect(input['genero'], 'NO_FICCION');
      expect(
        input['fechaPublicacion'],
        '${hoy.year}-${'${hoy.month}'.padLeft(2, '0')}-${'${hoy.day}'.padLeft(2, '0')}T14:30:00',
      );
      expect(find.text('Libro adicionado: «Pedro Páramo».'), findsOneWidget);
    });

    testWidgets('muestra el rechazo del servidor', (tester) async {
      ServidorSimulado({'crearLibro': (_) => throw ErrorSimulado('Ya existe un libro con el ISBN 978-1.')}).instalar();
      await abrir(tester, '/libros/agregar');

      await escribir(tester, 'ISBN', '978-1');
      await escribir(tester, 'Título', 'Rayuela');
      await escribir(tester, 'Autor', 'Julio Cortázar');
      await escribir(tester, 'Precio', '89000');
      await escribir(tester, 'Número de páginas', '746');
      await elegirFechaYHora(tester);
      await tocar(tester, find.widgetWithText(FilledButton, 'Adicionar libro'));

      expect(find.text('No se pudo adicionar el libro'), findsOneWidget);
      expect(find.text('Ya existe un libro con el ISBN 978-1.'), findsOneWidget);
    });
  });

  group('Consultar Libro', () {
    testWidgets('consulta UN SOLO libro por título como criterio alternativo', (tester) async {
      final servidor = ServidorSimulado({
        'libroPorTitulo': (_) => libroJson(titulo: 'La vorágine', autor: 'José Eustasio Rivera'),
      })..instalar();
      await abrir(tester, '/libros/consultar');

      await tocar(tester, find.text('Por título'));
      await escribir(tester, 'Título', 'la voragine');
      await tocar(tester, find.widgetWithText(FilledButton, 'Buscar'));

      expect(servidor.variablesDe('libroPorTitulo').single, {'titulo': 'la voragine'});
      expect(find.text('José Eustasio Rivera'), findsNWidgets(2));
    });

    testWidgets('informa cuando no encuentra el libro', (tester) async {
      ServidorSimulado({'libroPorIsbn': (_) => null}).instalar();
      await abrir(tester, '/libros/consultar');

      await escribir(tester, 'ISBN', '000');
      await tocar(tester, find.widgetWithText(FilledButton, 'Buscar'));

      expect(find.text('Sin resultados'), findsOneWidget);
      expect(find.text('No hay ningún libro con el ISBN «000».'), findsOneWidget);
    });
  });

  group('Actualizar Libro', () {
    testWidgets('busca primero, muestra los datos actuales y luego guarda', (tester) async {
      final servidor = ServidorSimulado({
        'libroPorIsbn': (_) => libroJson(),
        'actualizarLibro': (v) => {...(v['input'] as Map<String, dynamic>), 'isbn': v['isbn']},
        'revisionLibros': (_) => 1,
      })..instalar();
      await abrir(tester, '/libros/actualizar');

      await escribir(tester, 'ISBN del libro', '978-8420401751');
      await tocar(tester, find.widgetWithText(FilledButton, 'Buscar'));

      expect(find.text('Datos actuales'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Delirio'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '55000'), findsOneWidget);
      expect(find.text('01/03/2004 10:30'), findsNWidgets(2)); // ficha + campo de fecha

      await escribir(tester, 'Precio', '57000');
      await tocar(tester, find.widgetWithText(FilledButton, 'Guardar cambios'));

      expect(servidor.variablesDe('actualizarLibro').single, {
        'isbn': '978-8420401751',
        'input': {
          'titulo': 'Delirio',
          'autor': 'Laura Restrepo',
          'precio': 57000.0,
          'numeroPaginas': 352,
          'fechaPublicacion': '2004-03-01T10:30:00',
          'genero': 'FICCION',
        },
      });
      expect(find.text('Datos guardados'), findsOneWidget);
      expect(find.text('\$ 57.000'), findsOneWidget);
    });
  });

  group('Actualizar Ejemplar', () {
    testWidgets('busca primero, préstamos bloqueado y muestra el valor que calculó el servidor', (tester) async {
      final servidor = ServidorSimulado({
        'ejemplarPorCodigo': (_) => ejemplarJson(),
        'actualizarEjemplar': (_) => ejemplarJson(estado: 'PRESTADO', ubicacion: 'Mostrador', numeroPrestamos: 5),
        'revisionEjemplares': (_) => 1,
      })..instalar();
      await abrir(tester, '/ejemplares/actualizar');

      await escribir(tester, 'Código del ejemplar', 'EJ-001');
      await tocar(tester, find.widgetWithText(FilledButton, 'Buscar'));

      expect(find.text('El código EJ-001 y el libro 978-0307474728 no se pueden modificar.'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Estante A1'), findsOneWidget);
      expect(find.text('10/02/2024 09:00'), findsNWidgets(2)); // ficha + campo: fecha Y hora de ingreso
      final prestamos = find.widgetWithText(TextFormField, '4');
      expect(prestamos, findsOneWidget);
      expect(tester.widget<TextField>(find.descendant(of: prestamos, matching: find.byType(TextField))).readOnly, isTrue);
      expect(find.text('Lo calcula el servidor: suma 1 cada vez que el ejemplar pasa a Prestado.'), findsOneWidget);

      await escribir(tester, 'Ubicación', 'Mostrador');
      await elegir(tester, 'Estado', 'Prestado');
      await tocar(tester, find.widgetWithText(FilledButton, 'Guardar cambios'));

      expect(servidor.variablesDe('actualizarEjemplar').single, {
        'codigo': 'EJ-001',
        'input': {'estado': 'PRESTADO', 'ubicacion': 'Mostrador', 'fechaIngreso': '2024-02-10T09:00:00', 'precioReposicion': 65000.0},
      });
      expect(find.text('Datos guardados'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // préstamos que calculó el servidor
      expect(find.textContaining('quedó prestado con 5 préstamos'), findsOneWidget);
    });
  });

  group('Adicionar Ejemplar', () {
    testWidgets('envía el número de préstamos y valida que no sea negativo', (tester) async {
      final servidor = ServidorSimulado({
        'crearEjemplar': (v) => v['input'],
        'resumenInventario': (_) => resumenJson(),
        'revisionLibros': (_) => 1,
        'revisionEjemplares': (_) => 1,
      })..instalar();
      await abrir(tester, '/ejemplares/agregar');

      await escribir(tester, 'Código del ejemplar', 'EJ-100');
      await escribir(tester, 'ISBN del libro', '978-0307474728');
      await escribir(tester, 'Ubicación', 'Estante C3');
      await escribir(tester, 'Precio de reposición', '45000');
      await escribir(tester, 'Número de préstamos', '-2');
      await elegirFechaYHora(tester);
      await tocar(tester, find.widgetWithText(FilledButton, 'Adicionar ejemplar'));

      expect(find.text('No puede ser negativo.'), findsOneWidget);
      expect(servidor.variablesDe('crearEjemplar'), isEmpty);

      await escribir(tester, 'Número de préstamos', '3');
      await elegir(tester, 'Estado', 'Prestado');
      await tocar(tester, find.widgetWithText(FilledButton, 'Adicionar ejemplar'));

      final input = servidor.variablesDe('crearEjemplar').single['input'] as Map<String, dynamic>;
      expect(input['codigo'], 'EJ-100');
      expect(input['estado'], 'PRESTADO');
      expect(input['precioReposicion'], 45000.0);
      expect(input['numeroPrestamos'], 3);
      expect(find.text('Ejemplar adicionado: EJ-100.'), findsOneWidget);
    });
  });

  group('Listar Ejemplares', () {
    testWidgets('muestra el estado con punto y texto y filtra por estado', (tester) async {
      final servidor = ServidorSimulado({
        'ejemplaresFiltrados': (_) => [ejemplarJson(estado: 'DANIADO', numeroPrestamos: 9)],
        'totalEjemplaresFiltrados': (_) => 1,
        'revisionEjemplares': (_) => 1,
      })..instalar();
      await abrir(tester, '/ejemplares/listar');

      expect(find.byType(TablaDatos<Ejemplar>), findsOneWidget);
      expect(find.text('EJ-001'), findsOneWidget);
      expect(find.text('Préstamos'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('Dañado'), findsNWidgets(2)); // chip del filtro + insignia de la fila
      expect(find.text('1 ejemplar'), findsOneWidget);

      await tocar(tester, find.widgetWithText(ChoiceChip, 'Prestado'));
      expect(servidor.variablesDe('ejemplaresFiltrados').last, {'estado': 'PRESTADO', 'isbnLibro': null});

      await tester.enterText(campoDeBusqueda(), '978-0307474728');
      await tocar(tester, find.byTooltip('Filtrar'));
      expect(servidor.variablesDe('ejemplaresFiltrados').last, {'estado': 'PRESTADO', 'isbnLibro': '978-0307474728'});
    });
  });

  group('Consultar y Eliminar Ejemplar', () {
    testWidgets('consulta UN SOLO ejemplar con todos sus atributos', (tester) async {
      ServidorSimulado({'ejemplarPorCodigo': (_) => ejemplarJson(estado: 'DANIADO', ubicacion: 'Bodega')}).instalar();
      await abrir(tester, '/ejemplares/consultar');

      await escribir(tester, 'Código del ejemplar', 'EJ-001');
      await tocar(tester, find.widgetWithText(FilledButton, 'Buscar'));

      expect(find.text('Bodega'), findsOneWidget);
      expect(find.text('Dañado'), findsNWidgets(2)); // cabecera + dato "Estado"
      expect(find.text('10/02/2024 09:00'), findsOneWidget);
      expect(find.text('Lo calcula el servidor'), findsOneWidget);
    });

    testWidgets('elimina el ejemplar solo después de confirmar', (tester) async {
      final servidor = ServidorSimulado({
        'ejemplarPorCodigo': (_) => ejemplarJson(codigo: 'EJ-020', estado: 'DADO_DE_BAJA'),
        'eliminarEjemplar': (_) => ejemplarJson(codigo: 'EJ-020'),
        'resumenInventario': (_) => resumenJson(),
        'revisionLibros': (_) => 1,
        'revisionEjemplares': (_) => 1,
      })..instalar();
      await abrir(tester, '/ejemplares/eliminar');

      await escribir(tester, 'Código del ejemplar', 'EJ-020');
      await tocar(tester, find.widgetWithText(FilledButton, 'Buscar'));
      expect(find.text('Ejemplar a eliminar'), findsOneWidget);
      expect(find.text('Dado de baja'), findsNWidgets(2));

      await tocar(tester, find.widgetWithText(FilledButton, 'Eliminar ejemplar'));
      await tocar(tester, find.widgetWithText(FilledButton, 'Eliminar'));

      expect(servidor.variablesDe('eliminarEjemplar').single, {'codigo': 'EJ-020'});
      expect(find.text('Ejemplar eliminado: EJ-020.'), findsOneWidget);
    });
  });
}
