import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../modelos/resumen_inventario.dart';
import '../observador/listado_observable.dart';
import '../servicios/cliente_graphql.dart';
import '../servicios/servicio_resumen.dart';
import '../tema/tema.dart';
import '../utilidades/formato.dart';
import 'comunes/componentes.dart';
import 'comunes/estanteria.dart';
import 'menu_lateral.dart';

/// Ventana principal: encabezado con el resumen del inventario (se actualiza solo,
/// patrón Observer), estado de los ejemplares y accesos a cada caso de uso.
/// El menú lateral tiene las mismas opciones y "Ayuda".
///
/// Los totales y la distribución por estado los calcula el servidor (query
/// resumenInventario): esta pantalla no cuenta nada, solo muestra lo que recibe.
class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> with SingleTickerProviderStateMixin {
  /// Animación de entrada: la estantería crece y el contenido aparece escalonado.
  late final AnimationController _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  ResumenInventario? _resumen;
  String? _error;

  @override
  void initState() {
    super.initState();
    _entrada.forward();
    _cargar();
    libroObservable.suscribir(_cargar);
    ejemplarObservable.suscribir(_cargar);
  }

  @override
  void dispose() {
    libroObservable.desuscribir(_cargar);
    ejemplarObservable.desuscribir(_cargar);
    _entrada.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final resumen = await consultarResumenInventario();
      if (!mounted) return;
      setState(() {
        _error = null;
        _resumen = resumen;
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arriba = MediaQuery.paddingOf(context).top;
    return Scaffold(
      drawer: const MenuLateral(),
      body: RefreshIndicator(
        color: kPrimario,
        edgeOffset: arriba + kToolbarHeight,
        onRefresh: _cargar,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _EncabezadoInicio(entrada: _entrada, libros: _resumen?.totalLibros, ejemplares: _resumen?.totalEjemplares),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.lg, Espacio.md, Espacio.xl),
              sliver: SliverList.list(
                children: [
                  Aparecer(
                    animacion: _entrada,
                    inicio: 0.35,
                    child: _error != null
                        ? _TarjetaError(mensaje: _error!, alReintentar: _cargar)
                        : _TarjetaEstados(conteos: _resumen?.ejemplaresPorEstado),
                  ),
                  const SizedBox(height: Espacio.lg),
                  Aparecer(
                    animacion: _entrada,
                    inicio: 0.45,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TituloSeccion(icono: Icons.menu_book_rounded, titulo: 'Libros'),
                        SizedBox(height: 12),
                        _GrupoAcciones(rutaBase: '/libros', objeto: 'libros'),
                      ],
                    ),
                  ),
                  const SizedBox(height: Espacio.lg),
                  Aparecer(
                    animacion: _entrada,
                    inicio: 0.55,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TituloSeccion(icono: Icons.inventory_2_rounded, titulo: 'Ejemplares'),
                        SizedBox(height: 12),
                        _GrupoAcciones(rutaBase: '/ejemplares', objeto: 'ejemplares'),
                      ],
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

// ── Encabezado ────────────────────────────────────────────────────────────────

const _altoEstante = 70.0;

/// Encabezado verde de borde a borde: saludo, fecha, cifras del inventario y una
/// estantería dibujada. Al desplazar se contrae y deja solo la barra con "Librería".
class _EncabezadoInicio extends StatelessWidget {
  const _EncabezadoInicio({required this.entrada, required this.libros, required this.ejemplares});

  final Animation<double> entrada;
  final int? libros;
  final int? ejemplares;

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    // Barra + espacio para el texto (crece con el tamaño de letra del sistema) + estantería.
    final altoAbierto = kToolbarHeight + 52 + MediaQuery.textScalerOf(context).scale(186) + _altoEstante;
    return SliverAppBar(
      pinned: true,
      expandedHeight: altoAbierto,
      backgroundColor: kPrimarioOscuro,
      foregroundColor: kCrema,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      title: const Text(
        'Librería',
        style: TextStyle(fontFamily: fuenteTitulos, color: kCrema, fontSize: 22, fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          tooltip: 'Acerca de...',
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: () => Navigator.pushNamed(context, '/acerca-de'),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, limites) {
          final arriba = MediaQuery.paddingOf(context).top;
          // 1 = completamente abierto, 0 = contraído a la barra.
          final abierto = ((limites.maxHeight - arriba - kToolbarHeight) / (altoAbierto - kToolbarHeight)).clamp(
            0.0,
            1.0,
          );
          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF24684F), kPrimarioOscuro],
              ),
            ),
            child: ClipRect(
              child: Opacity(
                opacity: Curves.easeIn.transform(abierto),
                child: Stack(
                  children: [
                    // Halo de luz cálida, como una lámpara de biblioteca.
                    Positioned(
                      right: -80,
                      top: -60,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [const Color(0xFFE9C46A).withValues(alpha: 0.22), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: _altoEstante,
                      child: Estanteria(progreso: entrada),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: _altoEstante + 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Aparecer(
                            animacion: entrada,
                            inicio: 0,
                            child: Text(
                              formatearFechaLarga(ahora).toUpperCase(),
                              style: TextStyle(
                                color: kCrema.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Aparecer(
                            animacion: entrada,
                            inicio: 0.05,
                            child: Text(
                              '${saludo(ahora)}.',
                              style: const TextStyle(
                                fontFamily: fuenteTitulos,
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Aparecer(
                            animacion: entrada,
                            inicio: 0.1,
                            child: Text(
                              'Así está tu inventario hoy.',
                              style: TextStyle(color: kCrema.withValues(alpha: 0.85), fontSize: 14, height: 1.4),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Aparecer(
                            animacion: entrada,
                            inicio: 0.18,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _Cifra(valor: libros, leyenda: 'Títulos'),
                                ),
                                Container(width: 1, height: 48, color: kCrema.withValues(alpha: 0.22)),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _Cifra(valor: ejemplares, leyenda: 'Ejemplares'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Cifra grande que cuenta desde su valor anterior hasta el nuevo.
class _Cifra extends StatelessWidget {
  const _Cifra({required this.valor, required this.leyenda});

  final int? valor;
  final String leyenda;

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(
      color: Colors.white,
      fontSize: 46,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: -1.5,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (valor == null)
          const Text('—', style: estilo)
        else
          TweenAnimationBuilder<double>(
            tween: Tween(end: valor!.toDouble()),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(v.round().toString(), style: estilo),
          ),
        const SizedBox(height: 6),
        Text(
          leyenda,
          style: TextStyle(color: kCrema.withValues(alpha: 0.75), fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ── Cuerpo ────────────────────────────────────────────────────────────────────

/// Nombre de cada estado en la leyenda (en plural).
const _nombreEstado = {
  'DISPONIBLE': 'Disponibles',
  'PRESTADO': 'Prestados',
  'DANIADO': 'Dañados',
  'DADO_DE_BAJA': 'Dados de baja',
};

/// Distribución de los ejemplares por estado: barra proporcional + leyenda.
/// Cantidad y porcentaje de cada estado vienen calculados del servidor.
class _TarjetaEstados extends StatelessWidget {
  const _TarjetaEstados({required this.conteos});

  final List<ConteoEstado>? conteos;

  @override
  Widget build(BuildContext context) {
    // Mientras llega la respuesta del servidor: los cuatro estados, sin cifras.
    final filas = [
      for (final c in conteos ?? _nombreEstado.keys.map((e) => ConteoEstado(estado: e, cantidad: 0, porcentaje: 0)))
        (estado: c.estado, cantidad: conteos == null ? null : c.cantidad, porcentaje: c.porcentaje),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kHoja,
        borderRadius: Redondeo.hero,
        border: Border.all(color: kBorde),
        boxShadow: sombraSuave,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado de los ejemplares', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            conteos == null ? 'Cargando…' : 'Copias físicas registradas en el inventario',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: Espacio.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: LayoutBuilder(
                builder: (context, limites) => Container(
                  color: kPergamino,
                  child: Row(
                    children: [
                      for (final e in filas)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          width: limites.maxWidth * e.porcentaje / 100,
                          color: colorEstado(e.estado),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Espacio.md),
          LayoutBuilder(
            builder: (context, limites) => Wrap(
              runSpacing: 10,
              children: [
                for (final e in filas)
                  SizedBox(
                    width: limites.maxWidth / 2,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: colorEstado(e.estado), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _nombreEstado[e.estado] ?? e.estado,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: kTinta2, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          e.cantidad == null ? '—' : '${e.cantidad}',
                          style: const TextStyle(color: kTinta, fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaError extends StatelessWidget {
  const _TarjetaError({required this.mensaje, required this.alReintentar});

  final String mensaje;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return TarjetaHero(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const EtiquetaSeccion('Sin conexión', color: kRojo),
          const SizedBox(height: Espacio.sm),
          Text(mensaje, style: const TextStyle(color: kRojo, fontSize: 14, height: 1.35)),
          const SizedBox(height: Espacio.md),
          OutlinedButton.icon(
            onPressed: alReintentar,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
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
    this.color = kPrimario,
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
        style: TextStyle(color: destacada ? Colors.white : kTinta, fontSize: 16, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 2),
      Text(
        descripcion,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: destacada
            ? TextStyle(color: kCrema.withValues(alpha: 0.8), fontSize: 12)
            : Theme.of(context).textTheme.bodySmall,
      ),
    ];
    return Card(
      color: destacada ? kPrimario : null,
      shape: RoundedRectangleBorder(
        borderRadius: Redondeo.tarjeta,
        side: BorderSide(color: destacada ? kPrimario : kBorde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, ruta),
        child: Padding(
          padding: const EdgeInsets.all(Espacio.md),
          child: destacada
              ? Row(
                  children: [
                    IconoAcento(icono, color: kCrema),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: textos),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: kCrema.withValues(alpha: 0.9)),
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
