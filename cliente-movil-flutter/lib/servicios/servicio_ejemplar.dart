import '../modelos/ejemplar.dart';
import 'cliente_graphql.dart';

const String _camposEjemplar = 'codigo estado ubicacion fechaIngreso precioReposicion numeroPrestamos isbnLibro';

List<Ejemplar> _aEjemplares(Object? lista) =>
    (lista as List).map((e) => Ejemplar.desdeJson(e as Map<String, dynamic>)).toList();

/// Listar con filtro: el servidor filtra y también cuenta cuántos ejemplares cumplen
/// el filtro (las dos cosas en una sola petición GraphQL).
Future<({List<Ejemplar> ejemplares, int total})> listarEjemplaresFiltrados({String? estado, String? isbnLibro}) async {
  final data = await ClienteGraphQL().ejecutar(
    '''query (\$estado: EstadoEjemplar, \$isbnLibro: String) {
         ejemplaresFiltrados(estado: \$estado, isbnLibro: \$isbnLibro) { $_camposEjemplar }
         totalEjemplaresFiltrados(estado: \$estado, isbnLibro: \$isbnLibro)
       }''',
    variables: {
      'estado': (estado == null || estado.isEmpty) ? null : estado,
      'isbnLibro': (isbnLibro == null || isbnLibro.trim().isEmpty) ? null : isbnLibro.trim(),
    },
  );
  return (ejemplares: _aEjemplares(data['ejemplaresFiltrados']), total: data['totalEjemplaresFiltrados'] as int);
}

Future<Ejemplar?> buscarEjemplarPorCodigo(String codigo) async {
  final data = await ClienteGraphQL().ejecutar(
    'query (\$codigo: ID!) { ejemplarPorCodigo(codigo: \$codigo) { $_camposEjemplar } }',
    variables: {'codigo': codigo.trim()},
  );
  final ejemplar = data['ejemplarPorCodigo'];
  return ejemplar == null ? null : Ejemplar.desdeJson(ejemplar as Map<String, dynamic>);
}

/// Número de revisión de la colección en el servidor (lo usa el Observer de Listar).
Future<int> consultarRevisionEjemplares() async {
  final data = await ClienteGraphQL().ejecutar('query { revisionEjemplares }');
  return data['revisionEjemplares'] as int;
}

Future<Ejemplar> crearEjemplar({
  required String codigo,
  required String estado,
  required String ubicacion,
  required String fechaIngreso,
  required double precioReposicion,
  required int numeroPrestamos,
  required String isbnLibro,
}) async {
  final data = await ClienteGraphQL().ejecutar(
    'mutation (\$input: EjemplarInput!) { crearEjemplar(input: \$input) { $_camposEjemplar } }',
    variables: {
      'input': {
        'codigo': codigo,
        'estado': estado,
        'ubicacion': ubicacion,
        'fechaIngreso': fechaIngreso,
        'precioReposicion': precioReposicion,
        'numeroPrestamos': numeroPrestamos,
        'isbnLibro': isbnLibro,
      },
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
  required int numeroPrestamos,
}) async {
  final data = await ClienteGraphQL().ejecutar(
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
        'numeroPrestamos': numeroPrestamos,
      },
    },
  );
  return Ejemplar.desdeJson(data['actualizarEjemplar'] as Map<String, dynamic>);
}

Future<Ejemplar> eliminarEjemplar(String codigo) async {
  final data = await ClienteGraphQL().ejecutar(
    'mutation (\$codigo: ID!) { eliminarEjemplar(codigo: \$codigo) { $_camposEjemplar } }',
    variables: {'codigo': codigo},
  );
  return Ejemplar.desdeJson(data['eliminarEjemplar'] as Map<String, dynamic>);
}
