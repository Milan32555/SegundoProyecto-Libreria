/// Estados posibles de un Ejemplar (enum EstadoEjemplar en el schema GraphQL).
const List<String> estadosEjemplar = ['DISPONIBLE', 'PRESTADO', 'DANIADO', 'DADO_DE_BAJA'];

const Map<String, String> _etiquetasEstado = {
  'DISPONIBLE': 'Disponible',
  'PRESTADO': 'Prestado',
  'DANIADO': 'Dañado',
  'DADO_DE_BAJA': 'Dado de baja',
};

/// Nombre legible del estado para la interfaz (al servidor se envía el valor del enum).
String etiquetaEstado(String estado) => _etiquetasEstado[estado] ?? estado;

/// Objeto detalle: Ejemplar (1..1 con su Libro, un Libro tiene 0..* Ejemplares).
class Ejemplar {
  final String codigo;
  final String estado;
  final String ubicacion;
  final String fechaIngreso;
  final double precioReposicion;
  final int numeroPrestamos;
  final String isbnLibro;

  Ejemplar({
    required this.codigo,
    required this.estado,
    required this.ubicacion,
    required this.fechaIngreso,
    required this.precioReposicion,
    required this.numeroPrestamos,
    required this.isbnLibro,
  });

  factory Ejemplar.desdeJson(Map<String, dynamic> json) => Ejemplar(
    codigo: json['codigo'] as String,
    estado: json['estado'] as String,
    ubicacion: json['ubicacion'] as String,
    fechaIngreso: json['fechaIngreso'] as String,
    precioReposicion: (json['precioReposicion'] as num).toDouble(),
    numeroPrestamos: json['numeroPrestamos'] as int,
    isbnLibro: json['isbnLibro'] as String,
  );
}
