import '../modelos/ejemplar.dart';
import 'cliente_graphql.dart';

const String _camposEjemplar =
    'codigo estado ubicacion fechaIngreso precioReposicion isbnLibro';

Future<List<Ejemplar>> listarEjemplares() async {
  final data = await ejecutarGraphQL('query { ejemplares { $_camposEjemplar } }');
  return (data['ejemplares'] as List)
      .map((e) => Ejemplar.desdeJson(e as Map<String, dynamic>))
      .toList();
}

Future<List<Ejemplar>> listarEjemplaresFiltrados({String? estado, String? isbnLibro}) async {
  final data = await ejecutarGraphQL(
    '''query (\$estado: EstadoEjemplar, \$isbnLibro: String) {
         ejemplaresFiltrados(estado: \$estado, isbnLibro: \$isbnLibro) { $_camposEjemplar }
       }''',
    variables: {
      'estado': (estado == null || estado.isEmpty) ? null : estado,
      'isbnLibro': (isbnLibro == null || isbnLibro.isEmpty) ? null : isbnLibro,
    },
  );
  return (data['ejemplaresFiltrados'] as List)
      .map((e) => Ejemplar.desdeJson(e as Map<String, dynamic>))
      .toList();
}

Future<Ejemplar?> buscarEjemplarPorCodigo(String codigo) async {
  final data = await ejecutarGraphQL(
    'query (\$codigo: ID!) { ejemplarPorCodigo(codigo: \$codigo) { $_camposEjemplar } }',
    variables: {'codigo': codigo},
  );
  final ejemplar = data['ejemplarPorCodigo'];
  return ejemplar == null ? null : Ejemplar.desdeJson(ejemplar as Map<String, dynamic>);
}

Future<Ejemplar> crearEjemplar({
  required String codigo,
  required String estado,
  required String ubicacion,
  required String fechaIngreso,
  required double precioReposicion,
  required String isbnLibro,
}) async {
  final data = await ejecutarGraphQL(
    'mutation (\$input: EjemplarInput!) { crearEjemplar(input: \$input) { $_camposEjemplar } }',
    variables: {
      'input': {
        'codigo': codigo,
        'estado': estado,
        'ubicacion': ubicacion,
        'fechaIngreso': fechaIngreso,
        'precioReposicion': precioReposicion,
        'isbnLibro': isbnLibro,
      }
    },
  );
  return Ejemplar.desdeJson(data['crearEjemplar'] as Map<String, dynamic>);
}

Future<Ejemplar> actualizarEjemplar({
  required String codigo,
  required String estado,
  required String ubicacion,
  required String fechaIngreso,
  required double precioReposicion,
}) async {
  final data = await ejecutarGraphQL(
    '''mutation (\$codigo: ID!, \$input: EjemplarUpdateInput!) {
         actualizarEjemplar(codigo: \$codigo, input: \$input) { $_camposEjemplar }
       }''',
    variables: {
      'codigo': codigo,
      'input': {
        'estado': estado,
        'ubicacion': ubicacion,
        'fechaIngreso': fechaIngreso,
        'precioReposicion': precioReposicion,
      }
    },
  );
  return Ejemplar.desdeJson(data['actualizarEjemplar'] as Map<String, dynamic>);
}

Future<Ejemplar> eliminarEjemplar(String codigo) async {
  final data = await ejecutarGraphQL(
    'mutation (\$codigo: ID!) { eliminarEjemplar(codigo: \$codigo) { $_camposEjemplar } }',
    variables: {'codigo': codigo},
  );
  return Ejemplar.desdeJson(data['eliminarEjemplar'] as Map<String, dynamic>);
}
