import 'package:flutter/material.dart';

import '../../tema/tema.dart';

/// Una columna de [TablaDatos]: título, ancho fijo y cómo dibujar la celda de cada fila.
class ColumnaTabla<T> {
  const ColumnaTabla({required this.titulo, required this.ancho, required this.celda, this.numerica = false});

  final String titulo;
  final double ancho;
  final Widget Function(T fila) celda;

  /// Números: alineados a la derecha y con cifras tabulares.
  final bool numerica;
}

/// Grilla de datos para pantallas pequeñas: el encabezado queda fijo al desplazar en vertical
/// y la primera columna (título / código) queda fija al desplazar en horizontal.
class TablaDatos<T> extends StatefulWidget {
  const TablaDatos({super.key, required this.columnas, required this.filas, this.altoFila = 60, required this.etiqueta});

  /// La primera columna es la que queda fija.
  final List<ColumnaTabla<T>> columnas;
  final List<T> filas;
  final double altoFila;

  /// Nombre de la tabla para lectores de pantalla.
  final String etiqueta;

  @override
  State<TablaDatos<T>> createState() => _TablaDatosState<T>();
}

class _TablaDatosState<T> extends State<TablaDatos<T>> {
  // El encabezado de las columnas desplazables sigue al cuerpo cuando se desliza en horizontal.
  final _horizontalCuerpo = ScrollController();
  final _horizontalEncabezado = ScrollController();

  @override
  void initState() {
    super.initState();
    _horizontalCuerpo.addListener(() {
      if (_horizontalEncabezado.hasClients) _horizontalEncabezado.jumpTo(_horizontalCuerpo.offset);
    });
  }

  @override
  void dispose() {
    _horizontalCuerpo.dispose();
    _horizontalEncabezado.dispose();
    super.dispose();
  }

  Widget _encabezado(ColumnaTabla<T> c) => Container(
    width: c.ancho,
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: Espacio.e3),
    alignment: c.numerica ? Alignment.centerRight : Alignment.centerLeft,
    child: Text(
      c.titulo,
      style: const TextStyle(color: kGris600, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );

  Widget _celda(ColumnaTabla<T> c, T fila) => Container(
    width: c.ancho,
    height: widget.altoFila,
    padding: const EdgeInsets.symmetric(horizontal: Espacio.e3),
    alignment: c.numerica ? Alignment.centerRight : Alignment.centerLeft,
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kGris100))),
    child: DefaultTextStyle.merge(
      style: TextStyle(fontSize: 14, color: kGris900, fontFeatures: c.numerica ? cifrasTabulares : null),
      child: c.celda(fila),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final fija = widget.columnas.first;
    final resto = widget.columnas.skip(1).toList();
    const sombraFija = BoxDecoration(
      color: kGris0,
      border: Border(right: BorderSide(color: kGris100)),
    );

    return Semantics(
      label: widget.etiqueta,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: kGris0, borderRadius: Radios.panel, border: Border.all(color: kGris100)),
        child: ClipRRect(
          borderRadius: Radios.panel,
          child: Column(
            children: [
              // Encabezado fijo
              Container(
                decoration: const BoxDecoration(color: kGris50, border: Border(bottom: BorderSide(color: kGris100))),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(color: kGris50, border: Border(right: BorderSide(color: kGris100))),
                      child: _encabezado(fija),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _horizontalEncabezado,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Row(children: [for (final c in resto) _encabezado(c)]),
                      ),
                    ),
                  ],
                ),
              ),
              // Cuerpo: columna fija + columnas desplazables, con un mismo desplazamiento vertical
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: sombraFija,
                        child: Column(children: [for (final fila in widget.filas) _celda(fija, fila)]),
                      ),
                      Expanded(
                        child: Scrollbar(
                          controller: _horizontalCuerpo,
                          child: SingleChildScrollView(
                            controller: _horizontalCuerpo,
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                for (final fila in widget.filas) Row(children: [for (final c in resto) _celda(c, fila)]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Celda con un dato principal y uno secundario debajo (título y autor, código y ubicación).
class CeldaDoble extends StatelessWidget {
  const CeldaDoble({super.key, required this.principal, required this.secundario, this.esLibro = false});

  final String principal;
  final String secundario;
  final bool esLibro;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          principal,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: esLibro
              ? const TextStyle(fontFamily: fuenteLibro, fontSize: 15, fontWeight: FontWeight.w500, color: kGris900)
              : const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kGris900),
        ),
        Text(
          secundario,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: kGris600, fontSize: 13),
        ),
      ],
    );
  }
}
