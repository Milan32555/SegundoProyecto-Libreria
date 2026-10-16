/// Géneros literarios soportados por el servidor (enum Genero en el schema GraphQL).
const List<String> generos = [
  'FICCION',
  'NO_FICCION',
  'CIENCIA',
  'HISTORIA',
  'INFANTIL',
  'POESIA',
  'OTRO',
];

/// Objeto maestro: Libro.
class Libro {
  final String isbn;
  final String titulo;
  final String autor;
  final double precio;
  final int numeroPaginas;
  final String fechaPublicacion; // ISO-8601, p.ej. 2024-05-10T14:30:00
  final String genero;

  Libro({
    required this.isbn,
    required this.titulo,
    required this.autor,
    required this.precio,
    required this.numeroPaginas,
    required this.fechaPublicacion,
    required this.genero,
  });

  factory Libro.desdeJson(Map<String, dynamic> json) => Libro(
        isbn: json['isbn'] as String,
        titulo: json['titulo'] as String,
        autor: json['autor'] as String,
        precio: (json['precio'] as num).toDouble(),
        numeroPaginas: json['numeroPaginas'] as int,
        fechaPublicacion: json['fechaPublicacion'] as String,
        genero: json['genero'] as String,
      );
}
