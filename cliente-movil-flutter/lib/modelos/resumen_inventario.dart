/// Cuántos ejemplares hay en un estado y qué porcentaje (0 a 100) del inventario
/// representan. Lo calcula el servidor; la app solo lo muestra.
class ConteoEstado {
  final String estado;
  final int cantidad;
  final double porcentaje;

  ConteoEstado({required this.estado, required this.cantidad, required this.porcentaje});

  factory ConteoEstado.desdeJson(Map<String, dynamic> json) => ConteoEstado(
    estado: json['estado'] as String,
    cantidad: json['cantidad'] as int,
    porcentaje: (json['porcentaje'] as num).toDouble(),
  );
}

/// Resumen del inventario para la ventana principal (query resumenInventario).
class ResumenInventario {
  final int totalLibros;
  final int totalEjemplares;
  final List<ConteoEstado> ejemplaresPorEstado;

  ResumenInventario({required this.totalLibros, required this.totalEjemplares, required this.ejemplaresPorEstado});

  factory ResumenInventario.desdeJson(Map<String, dynamic> json) => ResumenInventario(
    totalLibros: json['totalLibros'] as int,
    totalEjemplares: json['totalEjemplares'] as int,
    ejemplaresPorEstado: (json['ejemplaresPorEstado'] as List)
        .map((c) => ConteoEstado.desdeJson(c as Map<String, dynamic>))
        .toList(),
  );
}
