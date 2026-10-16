import 'package:flutter/material.dart';

import '../modelos/ejemplar.dart';
import '../modelos/libro.dart';
import '../observador/listado_observable.dart';
import '../servicios/cliente_graphql.dart';
import '../servicios/servicio_ejemplar.dart';
import '../servicios/servicio_libro.dart';
import '../tema/tema.dart';
import 'comunes/componentes.dart';
import 'menu_lateral.dart';

/// Ventana principal: resumen del inventario (se actualiza solo, patrón Observer)
/// y accesos a cada caso de uso. El menú lateral tiene las mismas opciones y "Ayuda".
class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int? _libros;
  int? _ejemplares;
  int _disponibles = 0;
  int _prestados = 0;
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
      final resultados = await Future.wait([listarLibros(), listarEjemplares()]);
      final libros = resultados[0] as List<Libro>;
      final ejemplares = resultados[1] as List<Ejemplar>;
      if (!mounted) return;
      setState(() {
        _error = null;
        _libros = libros.length;
        _ejemplares = ejemplares.length;
        _disponibles = ejemplares.where((e) => e.estado == 'DISPONIBLE').length;
        _prestados = ejemplares.where((e) => e.estado == 'PRESTADO').length;
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Librería'),
        actions: [
          IconButton(
            tooltip: 'Acerca de...',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => Navigator.pushNamed(context, '/acerca-de'),
          ),
        ],
      ),
      drawer: const MenuLateral(),
      body: RefreshIndicator(
        color: kAcento,
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
          children: [
            const EtiquetaSeccion('Segundo proyecto · 2026B', color: kAcento),
            const SizedBox(height: Espacio.xs),
            Text('Tu librería,\nen orden.', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: Espacio.sm),
            Text(
              'Libros y ejemplares sincronizados con el servidor GraphQL.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: Espacio.lg),
            _TarjetaResumen(
              libros: _libros,
              ejemplares: _ejemplares,
              disponibles: _disponibles,
              prestados: _prestados,
              error: _error,
              alReintentar: _cargar,
            ),
            const SizedBox(height: Espacio.lg),
            const EtiquetaSeccion('Libros'),
            const SizedBox(height: Espacio.sm),
            const _GrupoAcciones(rutaBase: '/libros', objeto: 'libros'),
            const SizedBox(height: Espacio.lg),
            const EtiquetaSeccion('Ejemplares'),
            const SizedBox(height: Espacio.sm),
            const _GrupoAcciones(rutaBase: '/ejemplares', objeto: 'ejemplares'),
          ],
        ),
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
    required this.libros,
    required this.ejemplares,
    required this.disponibles,
    required this.prestados,
    required this.error,
    required this.alReintentar,
  });

  final int? libros;
  final int? ejemplares;
  final int disponibles;
  final int prestados;
  final String? error;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return TarjetaHero(
      colorBorde: error == null ? kBorde2 : kRojo.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [const EtiquetaSeccion('Inventario'), const Spacer(), if (error == null) const IndicadorEnVivo()],
          ),
          const SizedBox(height: Espacio.md),
          if (error != null) ...[
            Text(error!, style: const TextStyle(color: kRojo, fontSize: 14, height: 1.35)),
            const SizedBox(height: Espacio.md),
            OutlinedButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _Cifra(valor: libros, leyenda: 'libros'),
                ),
                Container(width: 1, height: 48, color: kBorde2),
                const SizedBox(width: Espacio.lg),
                Expanded(
                  child: _Cifra(valor: ejemplares, leyenda: 'ejemplares'),
                ),
              ],
            ),
            const SizedBox(height: Espacio.md),
            Wrap(
              spacing: Espacio.sm,
              runSpacing: Espacio.sm,
              children: [
                Pastilla(disponibles == 1 ? '1 disponible' : '$disponibles disponibles', color: kVerde),
                Pastilla(prestados == 1 ? '1 prestado' : '$prestados prestados', color: kAzul),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Cifra extends StatelessWidget {
  const _Cifra({required this.valor, required this.leyenda});

  final int? valor;
  final String leyenda;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          valor?.toString() ?? '—',
          style: const TextStyle(color: kAcento, fontSize: 40, fontWeight: FontWeight.w900, height: 1),
        ),
        const SizedBox(height: 4),
        Text(leyenda, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

/// Accesos a los cinco casos de uso de un objeto (cada uno abre su propia pantalla).
class _GrupoAcciones extends StatelessWidget {
  const _GrupoAcciones({required this.rutaBase, required this.objeto});

  final String rutaBase;
  final String objeto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TarjetaAccion(
          destacada: true,
          icono: Icons.view_list_rounded,
          titulo: 'Listar',
          descripcion: 'Ver todos los $objeto y filtrar',
          ruta: '$rutaBase/listar',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TarjetaAccion(
                icono: Icons.add_rounded,
                titulo: 'Adicionar',
                descripcion: 'Registrar nuevo',
                ruta: '$rutaBase/agregar',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TarjetaAccion(
                icono: Icons.search_rounded,
                titulo: 'Buscar',
                descripcion: 'Consultar uno',
                ruta: '$rutaBase/consultar',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TarjetaAccion(
                icono: Icons.edit_rounded,
                titulo: 'Actualizar',
                descripcion: 'Modificar datos',
                ruta: '$rutaBase/actualizar',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TarjetaAccion(
                icono: Icons.delete_outline_rounded,
                titulo: 'Eliminar',
                descripcion: 'Quitar del sistema',
                ruta: '$rutaBase/eliminar',
                color: kRojo,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TarjetaAccion extends StatelessWidget {
  const _TarjetaAccion({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.ruta,
    this.color = kAcento,
    this.destacada = false,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final String ruta;
  final Color color;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    final textos = [
      Text(
        titulo,
        style: const TextStyle(color: kTexto, fontSize: 16, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 2),
      Text(descripcion, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
    ];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: Redondeo.tarjeta,
        side: BorderSide(color: destacada ? kAcento.withValues(alpha: 0.45) : kBorde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, ruta),
        child: Padding(
          padding: const EdgeInsets.all(Espacio.md),
          child: destacada
              ? Row(
                  children: [
                    IconoAcento(icono, color: color),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: textos),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: kTexto3),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconoAcento(icono, color: color, tamano: 40),
                    const SizedBox(height: 12),
                    ...textos,
                  ],
                ),
        ),
      ),
    );
  }
}
