import '../modelos/resumen_inventario.dart';
import 'cliente_graphql.dart';

/// Resumen del inventario para la ventana principal: totales y ejemplares por estado.
/// Todo lo calcula el servidor; la pantalla solo lo muestra.
Future<ResumenInventario> consultarResumenInventario() async {
  final data = await ClienteGraphQL().ejecutar('''query {
       resumenInventario {
         totalLibros
         totalEjemplares
         ejemplaresPorEstado { estado cantidad porcentaje }
       }
     }''');
  return ResumenInventario.desdeJson(data['resumenInventario'] as Map<String, dynamic>);
}
