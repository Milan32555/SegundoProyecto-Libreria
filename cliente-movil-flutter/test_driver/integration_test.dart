// Conductor del recorrido en el celular: recibe las capturas de pantalla que toma la prueba
// y las guarda en la carpeta de capturas (fuera del repositorio).
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/recorrido_test.dart -d <id-del-celular> \
//     --dart-define=URL_GRAPHQL=http://localhost:8081/graphql
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final carpeta = Platform.environment['CAPTURAS_DIR'] ?? '../../Capturas-SegundoProyecto-Libreria/movil';
  await Directory(carpeta).create(recursive: true);
  await integrationDriver(
    onScreenshot: (nombre, bytes, [argumentos]) async {
      await File('$carpeta/$nombre.png').writeAsBytes(bytes);
      return true;
    },
  );
}
