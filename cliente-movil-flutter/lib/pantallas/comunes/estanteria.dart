import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Estantería dibujada con lomos de libros de distintos altos, anchos y colores.
/// Se usa sobre fondos verdes oscuros (inicio y "Acerca de..."). Los libros "crecen"
/// uno tras otro a medida que [progreso] va de 0 a 1.
class Estanteria extends StatelessWidget {
  const Estanteria({super.key, required this.progreso});

  final Animation<double> progreso;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progreso,
      builder: (context, _) => CustomPaint(painter: _PintorEstante(progreso.value)),
    );
  }
}

class _PintorEstante extends CustomPainter {
  _PintorEstante(this.progreso);

  final double progreso;

  static const _colores = [
    Color(0xFFF2E6CC), // crema
    Color(0xFFC9973F), // dorado
    Color(0xFF8E3B36), // vino
    Color(0xFF2F4A6B), // azul tinta
    Color(0xFF3F8A6B), // verde claro
    Color(0xFFD9C7A3), // arena
    Color(0xFF5B3A29), // cuero
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final azar = math.Random(7); // siempre la misma estantería
    final base = size.height - 6;
    final pintura = Paint();
    final banda = Paint()..color = const Color(0xFFE9C46A).withValues(alpha: 0.85);
    var x = 14.0;
    var i = 0;
    while (x < size.width - 10) {
      final ancho = 12 + azar.nextDouble() * 14;
      final alto = (0.5 + azar.nextDouble() * 0.5) * (size.height - 10);
      final color = _colores[azar.nextInt(_colores.length)];
      final conBandas = azar.nextDouble() < 0.45;
      final hueco = azar.nextDouble() < 0.12 ? 10.0 : 2.5;

      // Cada libro arranca un poco después del anterior.
      final t = Curves.easeOutBack.transform(((progreso - i * 0.022) / 0.45).clamp(0.0, 1.0));
      final h = alto * t;
      if (h > 0.5) {
        final lomo = RRect.fromRectAndCorners(
          Rect.fromLTWH(x, base - h, ancho, h),
          topLeft: const Radius.circular(2.5),
          topRight: const Radius.circular(2.5),
        );
        pintura.color = color.withValues(alpha: 0.92);
        canvas.drawRRect(lomo, pintura);
        if (conBandas && h > 24) {
          canvas.drawRect(Rect.fromLTWH(x + 2, base - h + 7, ancho - 4, 2), banda);
          canvas.drawRect(Rect.fromLTWH(x + 2, base - 12, ancho - 4, 2), banda);
        }
      }
      x += ancho + hueco;
      i++;
    }
    // La tabla del estante.
    pintura.color = const Color(0xFF0B271F);
    canvas.drawRect(Rect.fromLTWH(0, base, size.width, 6), pintura);
  }

  @override
  bool shouldRepaint(_PintorEstante viejo) => viejo.progreso != progreso;
}
