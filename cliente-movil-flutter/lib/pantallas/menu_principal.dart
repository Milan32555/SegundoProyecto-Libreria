import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../modelos/ejemplar.dart';
import '../modelos/resumen_inventario.dart';
import '../observador/listado_observable.dart';
import '../servicios/cliente_graphql.dart';
import '../servicios/servicio_resumen.dart';
import '../tema/tema.dart';
import '../utilidades/formato.dart';
import 'comunes/componentes.dart';
import 'menu_lateral.dart';

const _nombreEstado = {
  'DISPONIBLE': 'Disponibles',
  'PRESTADO': 'Prestados',
  'DANIADO': 'Dañados',
  'DADO_DE_BAJA': 'Dados de baja',
};

/// Ventana principal: buscador de libros, resumen del inventario y accesos a cada caso de uso
/// (el menú lateral tiene las mismas opciones y "Ayuda").
///
/// Todas las cifras las calcula el servidor (query resumenInventario): esta pantalla no cuenta
/// nada, solo muestra lo que recibe. Se suscribe a los dos sujetos del Observer, así que se
/// actualiza sola cuando cambian los libros o los ejemplares.
class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  ResumenInventario? _resumen;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
    libroObservable.suscribir(_cargar);
    ejemplarObservable.suscribir(_cargar);
  }

  @override
  void dispose() {
    libroObservable.desuscribir(_cargar);
    ejemplarObservable.desuscribir(_cargar);
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final resumen = await consultarResumenInventario();
      if (mounted) {
        setState(() {
          _resumen = resumen;
          _error = null;
        });
      }
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    }
  }

  /// La búsqueda del inicio abre Consultar libro; si el texto parece un ISBN busca por ISBN.
  void _buscar(String texto) {
    final valor = texto.trim();
    if (valor.isEmpty) return;
    final criterio = RegExp(r'^[0-9Xx-]+$').hasMatch(valor) ? 'isbn' : 'titulo';
    Navigator.pushNamed(context, '/libros/consultar', arguments: (criterio: criterio, valor: valor));
  }

  int? _cantidad(String estado) {
    for (final c in _resumen?.ejemplaresPorEstado ?? const <ConteoEstado>[]) {
      if (c.estado == estado) return c.cantidad;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Marca()),
      drawer: const MenuLateral(),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e4, Espacio.e4, Espacio.e8),
          children: [
            Text('Inicio', style: textos.headlineSmall),
            Text(formatearFechaLarga(DateTime.now()), style: textos.bodyMedium!.copyWith(color: kGris600)),
            const SizedBox(height: Espacio.e4),
            SearchBar(
              hintText: 'Buscar un libro por ISBN o título',
              leading: const Icon(LucideIcons.search, size: 18, color: kGris500),
              textInputAction: TextInputAction.search,
              onSubmitted: _buscar,
            ),
            if (_error != null)
              Aviso(
                _error!,
                titulo: 'No se pudo cargar el resumen del inventario',
                accion: OutlinedButton.icon(
                  onPressed: _cargar,
                  icon: const Icon(LucideIcons.rotateCw, size: 16),
                  label: const Text('Reintentar'),
                ),
              ),
            const SizedBox(height: Espacio.e4),
            Semantics(
              container: true,
              label: 'Inventario',
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: Espacio.e3,
                crossAxisSpacing: Espacio.e3,
                childAspectRatio: 1.55,
                children: [
                  _Cifra(etiqueta: 'Títulos', valor: _resumen?.totalLibros, detalle: 'Libros en el catálogo'),
                  _Cifra(etiqueta: 'Ejemplares', valor: _resumen?.totalEjemplares, detalle: 'Copias físicas'),
                  _Cifra(etiqueta: 'Disponibles', valor: _cantidad('DISPONIBLE'), detalle: 'Listas para prestar'),
                  _Cifra(etiqueta: 'Prestados', valor: _cantidad('PRESTADO'), detalle: 'Fuera de la librería'),
                ],
              ),
            ),
            const SizedBox(height: Espacio.e4),
            _EstadoEjemplares(conteos: _resumen?.ejemplaresPorEstado, total: _resumen?.totalEjemplares),
            const SizedBox(height: Espacio.e6),
            Text('Accesos directos', style: textos.titleMedium),
            const SizedBox(height: Espacio.e2),
            const _Accesos(titulo: 'Libros', base: '/libros', singular: 'libro'),
            const SizedBox(height: Espacio.e3),
            const _Accesos(titulo: 'Ejemplares', base: '/ejemplares', singular: 'ejemplar'),
          ],
        ),
      ),
    );
  }
}

class _Cifra extends StatelessWidget {
  const _Cifra({required this.etiqueta, required this.valor, required this.detalle});

  final String etiqueta;
  final int? valor;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Panel(
      padding: const EdgeInsets.all(Espacio.e3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: textos.labelMedium!.copyWith(color: kGris600)),
          Text(
            valor?.toString() ?? '—',
            style: textos.headlineSmall!.copyWith(fontFeatures: cifrasTabulares),
          ),
          Text(detalle, maxLines: 1, overflow: TextOverflow.ellipsis, style: textos.bodySmall!.copyWith(color: kGris500)),
        ],
      ),
    );
  }
}

/// Distribución de los ejemplares por estado; cantidades y porcentajes vienen del servidor.
class _EstadoEjemplares extends StatelessWidget {
  const _EstadoEjemplares({required this.conteos, required this.total});

  final List<ConteoEstado>? conteos;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final filas = [
      for (final estado in estadosEjemplar)
        conteos?.where((c) => c.estado == estado).firstOrNull ?? ConteoEstado(estado: estado, cantidad: -1, porcentaje: 0),
    ];
    final porcentaje = NumberFormatoPorcentaje.formatear;
    return Semantics(
      container: true,
      label: 'Estado de los ejemplares',
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado de los ejemplares', style: textos.titleMedium),
            Text(
              total == null ? 'Cargando…' : '$total copias · calculado por el servidor',
              style: textos.bodySmall!.copyWith(color: kGris500),
            ),
            const SizedBox(height: Espacio.e3),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: LayoutBuilder(
                  builder: (context, restricciones) => Row(
                    children: [
                      for (final f in filas)
                        if (f.porcentaje > 0)
                          Container(
                            width: (restricciones.maxWidth * f.porcentaje / 100 - 2).clamp(0, double.infinity),
                            margin: const EdgeInsets.only(right: 2),
                            color: coloresEstado(f.estado).$2,
                          ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: Espacio.e2),
            for (final f in filas)
              Container(
                height: 40,
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kGris100))),
                child: Row(
                  children: [
                    InsigniaEstado(f.estado, texto: _nombreEstado[f.estado]),
                    const Spacer(),
                    SizedBox(
                      width: 48,
                      child: Text(
                        f.cantidad < 0 ? '—' : '${f.cantidad}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14, fontFeatures: cifrasTabulares),
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        f.cantidad < 0 ? '' : porcentaje(f.porcentaje),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14, color: kGris500, fontFeatures: cifrasTabulares),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const _accesos = [
  (ruta: 'listar', texto: 'Listar', icono: LucideIcons.list),
  (ruta: 'consultar', texto: 'Consultar', icono: LucideIcons.search),
  (ruta: 'agregar', texto: 'Adicionar', icono: LucideIcons.plus),
  (ruta: 'actualizar', texto: 'Actualizar', icono: LucideIcons.pencil),
  (ruta: 'eliminar', texto: 'Eliminar', icono: LucideIcons.trash2),
];

class _Accesos extends StatelessWidget {
  const _Accesos({required this.titulo, required this.base, required this.singular});

  final String titulo;
  final String base;
  final String singular;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e3, Espacio.e4, Espacio.e1),
            child: Text(titulo, style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w600)),
          ),
          for (final a in _accesos)
            ListTile(
              dense: true,
              leading: Icon(a.icono, size: 18),
              title: Text(a.ruta == 'listar' ? '${a.texto} ${titulo.toLowerCase()}' : '${a.texto} $singular'),
              trailing: const Icon(LucideIcons.chevronRight, size: 16, color: kGris400),
              onTap: () => Navigator.pushNamed(context, '$base/${a.ruta}'),
            ),
        ],
      ),
    );
  }
}

/// Porcentaje con una cifra decimal como máximo: 33,3 %.
class NumberFormatoPorcentaje {
  NumberFormatoPorcentaje._();

  static String formatear(double valor) {
    final redondeado = (valor * 10).round() / 10;
    final texto = redondeado == redondeado.roundToDouble()
        ? redondeado.toStringAsFixed(0)
        : redondeado.toStringAsFixed(1).replaceAll('.', ',');
    return '$texto %';
  }
}
