// Recorrido de TODOS los casos de uso en el celular real, contra el servidor real
// (con `adb reverse tcp:8081 tcp:8081` el celular ve el servidor del computador en localhost).
// Toma una captura de cada pantalla. Conviene correrlo con el servidor recién iniciado
// (datos de prueba limpios): elimina "Delirio" y presta EJ-001.
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/recorrido_test.dart -d <id-del-celular> \
//     --dart-define=URL_GRAPHQL=http://localhost:8081/graphql [--dart-define=SUFIJO=123]

import 'package:cliente_movil_libreria/main.dart';
import 'package:cliente_movil_libreria/pantallas/comunes/campo_fecha.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _sufijoDefinido = String.fromEnvironment('SUFIJO');

/// Para ensayar el recorrido en otro dispositivo (p. ej. Windows) sin el conductor de capturas.
const _sinCapturas = bool.fromEnvironment('SIN_CAPTURAS');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final sufijo = _sufijoDefinido.isNotEmpty ? _sufijoDefinido : '${DateTime.now().millisecondsSinceEpoch % 10000000}';
  final isbnNuevo = '978-MOV-$sufijo';
  final codigoNuevo = 'EJ-MOV-$sufijo';

  testWidgets('recorrido de todos los casos de uso en el celular', (tester) async {
    /// Pide una captura de la pantalla real del celular: imprime una marca que el computador lee
    /// del registro (adb logcat) y responde con `adb exec-out screencap`; mientras tanto la
    /// pantalla queda quieta. (takeScreenshot de integration_test se cuelga en algunos equipos.)
    Future<void> captura(String nombre) async {
      if (_sinCapturas) return;
      await tester.pumpAndSettle();
      debugPrint('CAPTURA:$nombre');
      await Future<void>.delayed(const Duration(milliseconds: 2500));
    }

    MaterialLocalizations textos() => MaterialLocalizations.of(tester.element(find.byType(Scaffold).last));

    /// Espera (en tiempo real) a que aparezca algo que depende de la respuesta del servidor.
    Future<void> esperar(Finder objetivo, {int segundos = 20}) async {
      final limite = DateTime.now().add(Duration(seconds: segundos));
      while (objetivo.evaluate().isEmpty) {
        if (DateTime.now().isAfter(limite)) throw TestFailure('No apareció a tiempo: $objetivo');
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pumpAndSettle();
    }

    /// Lleva a la vista un elemento de una lista larga (aunque todavía no esté construido).
    Future<void> mostrar(Finder objetivo) async {
      if (objetivo.evaluate().isEmpty) {
        await tester.scrollUntilVisible(objetivo, 300, scrollable: find.byType(Scrollable).first, maxScrolls: 40);
      }
      await tester.ensureVisible(objetivo.first);
      await tester.pumpAndSettle();
    }

    Future<void> tocar(Finder objetivo) async {
      await mostrar(objetivo);
      await tester.tap(objetivo.first);
      await tester.pumpAndSettle();
    }

    /// Escribe en un campo a través de su controlador. En el teléfono real no se usa el teclado
    /// simulado: el teclado del sistema puede devolver el texto anterior y pisar lo escrito.
    Future<void> escribirEn(Finder campo, String texto) async {
      await mostrar(campo);
      tester.widget<TextField>(campo.first).controller!.text = texto;
      await tester.pumpAndSettle();
    }

    Future<void> escribir(String etiqueta, String texto) => escribirEn(find.widgetWithText(TextField, etiqueta), texto);

    Future<void> elegir(String etiqueta, String opcion) async {
      await tocar(find.widgetWithText(DropdownButtonFormField<String>, etiqueta));
      await tocar(find.text(opcion).last);
    }

    Future<void> elegirFechaYHora() async {
      await tocar(find.byType(CampoFecha));
      await tocar(find.text(textos().okButtonLabel)); // día de hoy
      await tocar(find.text(textos().okButtonLabel)); // hora
    }

    Future<void> volverAlInicio() async {
      while (find.byTooltip(textos().backButtonTooltip).evaluate().isNotEmpty) {
        await tester.tap(find.byTooltip(textos().backButtonTooltip).first);
        await tester.pumpAndSettle();
      }
    }

    /// Abre una opción del menú principal. [grupo] 0 = Libros, 1 = Ejemplares.
    Future<void> irA(String opcion, {int grupo = 0}) async {
      await volverAlInicio();
      await tester.tap(find.byTooltip(textos().openAppDrawerTooltip));
      await tester.pumpAndSettle();
      final destino = find.descendant(of: find.byType(NavigationDrawer), matching: find.text(opcion));
      await tester.tap(destino.at(destino.evaluate().length > 1 ? grupo : 0));
      await tester.pumpAndSettle();
    }

    Future<void> buscar(String etiqueta, String valor) async {
      await escribir(etiqueta, valor);
      await tocar(find.widgetWithText(FilledButton, 'Buscar'));
    }

    await tester.pumpWidget(const AplicacionLibreria());

    // ── Inicio, menú y Acerca de ──────────────────────────────────────────────
    await esperar(find.textContaining('copias · calculado por el servidor'));
    await captura('01-inicio');
    await tester.tap(find.byTooltip(textos().openAppDrawerTooltip));
    await tester.pumpAndSettle();
    await captura('02-menu');
    await tester.tap(find.text('Acerca de...'));
    await tester.pumpAndSettle();
    await esperar(find.textContaining('Servidor conectado'));
    await captura('03-acerca-de');

    // ── Libro: adicionar (inválido y válido) ──────────────────────────────────
    await irA('Adicionar');
    await tocar(find.widgetWithText(FilledButton, 'Adicionar libro'));
    expect(find.text('Este campo es obligatorio.'), findsWidgets);
    await mostrar(find.text('Identificación'));
    await captura('10-libro-adicionar-validacion');

    await escribir('ISBN', isbnNuevo);
    await escribir('Título', 'Interoperabilidad $sufijo');
    await escribir('Autor', 'App móvil');
    await elegirFechaYHora();
    await elegir('Género', 'No ficción');
    await escribir('Precio', '35500');
    await escribir('Número de páginas', '180');
    await captura('11-libro-adicionar-formulario');
    await tocar(find.widgetWithText(FilledButton, 'Adicionar libro'));
    await esperar(find.text('Libro adicionado: «Interoperabilidad $sufijo».'));
    await captura('12-libro-adicionar-exito');

    // ── Libro: consultar ──────────────────────────────────────────────────────
    await irA('Consultar');
    await buscar('ISBN', isbnNuevo);
    await esperar(find.text('Interoperabilidad $sufijo'));
    await captura('20-libro-consultar-isbn');
    await tocar(find.text('Por título'));
    await buscar('Título', 'la voragine');
    await esperar(find.text('La vorágine'));
    await captura('21-libro-consultar-titulo');
    await buscar('Título', 'No existe este título');
    await esperar(find.text('Sin resultados'));
    await captura('22-libro-consultar-no-encontrado');

    // ── Libro: actualizar ─────────────────────────────────────────────────────
    await irA('Actualizar');
    await buscar('ISBN del libro', isbnNuevo);
    await esperar(find.text('Datos actuales'));
    await captura('30-libro-actualizar-datos-actuales');
    await escribir('Precio', '36900');
    await captura('31-libro-actualizar-formulario');
    await tocar(find.widgetWithText(FilledButton, 'Guardar cambios'));
    await esperar(find.text('Datos guardados'));
    expect(find.text('\$ 36.900'), findsOneWidget);
    await captura('32-libro-actualizar-guardado');

    // ── Libro: eliminar (rechazado por tener ejemplares; cancelar; confirmar) ──
    await irA('Eliminar');
    await buscar('ISBN del libro', '978-0307474728');
    await esperar(find.text('Libro a eliminar'));
    await tocar(find.widgetWithText(FilledButton, 'Eliminar libro'));
    await captura('40-libro-eliminar-hoja');
    await tocar(find.widgetWithText(FilledButton, 'Eliminar'));
    await esperar(find.text('El servidor no permitió eliminar el libro'));
    await captura('41-libro-eliminar-rechazo');

    await buscar('ISBN del libro', '978-8420401751'); // Delirio: no tiene ejemplares
    await esperar(find.text('Delirio'));
    await captura('42-libro-eliminar-ficha');
    await tocar(find.widgetWithText(FilledButton, 'Eliminar libro'));
    await tocar(find.widgetWithText(OutlinedButton, 'Cancelar').last); // cancelar no elimina
    expect(find.text('Libro a eliminar'), findsOneWidget);
    await tocar(find.widgetWithText(FilledButton, 'Eliminar libro'));
    await tocar(find.widgetWithText(FilledButton, 'Eliminar'));
    await esperar(find.text('Libro eliminado: «Delirio».'));
    await captura('43-libro-eliminar-exito');

    // ── Libro: listar con filtros ─────────────────────────────────────────────
    await irA('Listar');
    await esperar(find.text('Cien años de soledad'));
    await captura('50-libro-listar');
    await tester.drag(find.text('Ficción').last, const Offset(-260, 0)); // desliza la tabla
    await tester.pumpAndSettle();
    await captura('51-libro-listar-desplazada');
    await escribirEn(find.descendant(of: find.byType(SearchBar), matching: find.byType(TextField)), 'garcia');
    await tocar(find.byTooltip('Filtrar'));
    await esperar(find.text('1 libro'));
    await captura('52-libro-listar-autor');
    await tocar(find.byTooltip('Limpiar filtros'));
    await tocar(find.widgetWithText(ChoiceChip, 'Poesía'));
    await esperar(find.text('Veinte poemas de amor y una canción desesperada'));
    await captura('53-libro-listar-genero');

    // ── Ejemplar: adicionar (inválido y válido) ───────────────────────────────
    await irA('Adicionar', grupo: 1);
    await escribir('Código del ejemplar', codigoNuevo);
    await escribir('ISBN del libro', '978-8420633121');
    await escribir('Ubicación', 'Estante D2');
    await elegirFechaYHora();
    await escribir('Precio de reposición', '52000');
    await escribir('Número de préstamos', '-1');
    await tocar(find.widgetWithText(FilledButton, 'Adicionar ejemplar'));
    await mostrar(find.text('No puede ser negativo.'));
    await captura('60-ejemplar-adicionar-validacion');
    await escribir('Número de préstamos', '0');
    await tocar(find.widgetWithText(FilledButton, 'Adicionar ejemplar'));
    await esperar(find.text('Ejemplar adicionado: $codigoNuevo.'));
    await captura('61-ejemplar-adicionar-exito');

    // ── Ejemplar: consultar ───────────────────────────────────────────────────
    await irA('Consultar', grupo: 1);
    await buscar('Código del ejemplar', 'EJ-007');
    await esperar(find.text('Bodega'));
    await captura('70-ejemplar-consultar');
    await buscar('Código del ejemplar', 'EJ-999');
    await esperar(find.text('Sin resultados'));
    await captura('71-ejemplar-consultar-no-encontrado');

    // ── Ejemplar: actualizar (prestar EJ-001: el servidor suma un préstamo) ───
    await irA('Actualizar', grupo: 1);
    await buscar('Código del ejemplar', 'EJ-001');
    await esperar(find.text('Datos actuales'));
    await captura('80-ejemplar-actualizar-datos-actuales');
    await elegir('Estado', 'Prestado');
    await captura('81-ejemplar-actualizar-formulario');
    await tocar(find.widgetWithText(FilledButton, 'Guardar cambios'));
    await esperar(find.text('Datos guardados'));
    expect(find.textContaining('quedó prestado con 5 préstamos'), findsOneWidget);
    await captura('82-ejemplar-actualizar-guardado');

    // ── Ejemplar: eliminar ────────────────────────────────────────────────────
    await irA('Eliminar', grupo: 1);
    await buscar('Código del ejemplar', codigoNuevo);
    await esperar(find.text('Ejemplar a eliminar'));
    await captura('90-ejemplar-eliminar-ficha');
    await tocar(find.widgetWithText(FilledButton, 'Eliminar ejemplar'));
    await captura('91-ejemplar-eliminar-hoja');
    await tocar(find.widgetWithText(FilledButton, 'Eliminar'));
    await esperar(find.text('Ejemplar eliminado: $codigoNuevo.'));
    await captura('92-ejemplar-eliminar-exito');

    // ── Ejemplar: listar con filtros ──────────────────────────────────────────
    await irA('Listar', grupo: 1);
    await esperar(find.text('EJ-001'));
    await captura('95-ejemplar-listar');
    await tocar(find.widgetWithText(ChoiceChip, 'Prestado'));
    await esperar(find.text('7 ejemplares'));
    await captura('96-ejemplar-listar-prestados');
  });
}
