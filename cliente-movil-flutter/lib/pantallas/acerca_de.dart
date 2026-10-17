import 'package:flutter/material.dart';

import '../servicios/cliente_graphql.dart';
import '../servicios/servicio_libro.dart';
import '../tema/tema.dart';
import 'comunes/componentes.dart';
import 'comunes/estanteria.dart';

const _version = '1.0.0';

/// Integrantes con el color de su avatar (tonos de la estantería).
const _integrantes = [
  (nombre: 'Misael Gallo Tangarife', color: kPrimario),
  (nombre: 'Sara Zambrano', color: Color(0xFF8E3B36)),
  (nombre: 'Santiago Guimel', color: Color(0xFF2F4A6B)),
  (nombre: 'Alejandra González', color: Color(0xFFA8741F)),
];

const _patrones = [
  (
    icono: Icons.layers_rounded,
    nombre: 'MVC',
    detalle: 'Modelos, servicios de datos y pantallas separados en cada proyecto.',
  ),
  (
    icono: Icons.looks_one_rounded,
    nombre: 'Singleton',
    detalle: 'Un único cliente GraphQL y repositorios únicos en el servidor.',
  ),
  (
    icono: Icons.construction_rounded,
    nombre: 'Builder',
    detalle: 'LibroBuilder y EjemplarBuilder construyen los objetos en el servidor.',
  ),
  (
    icono: Icons.visibility_rounded,
    nombre: 'Observer',
    detalle: 'Las pantallas se actualizan solas cuando cambian los datos.',
  ),
  (
    icono: Icons.verified_rounded,
    nombre: 'SOLID',
    detalle: 'Una responsabilidad por clase e inyección de dependencias.',
  ),
];

const _tecnologias = [
  'Java 17',
  'Spring Boot 4',
  'Spring for GraphQL',
  'Flutter',
  'Dart',
  'React 18',
  'TypeScript',
  'Vite',
];

/// Ayuda → Acerca de...: la aplicación y su versión, el equipo, la arquitectura del
/// sistema (con el estado real del servidor), los patrones de diseño y las tecnologías.
class AcercaDe extends StatefulWidget {
  const AcercaDe({super.key});

  @override
  State<AcercaDe> createState() => _AcercaDeState();
}

class _AcercaDeState extends State<AcercaDe> with TickerProviderStateMixin {
  late final AnimationController _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  /// Mueve los "paquetes" del diagrama de arquitectura (de los clientes al servidor).
  late final AnimationController _flujo = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat();

  bool? _conectado;
  int? _latencia;

  @override
  void initState() {
    super.initState();
    _medirServidor();
  }

  @override
  void dispose() {
    _entrada.dispose();
    _flujo.dispose();
    super.dispose();
  }

  /// Hace una consulta real al servidor y mide cuánto tarda en responder.
  Future<void> _medirServidor() async {
    setState(() => _conectado = null);
    final reloj = Stopwatch()..start();
    try {
      await consultarRevisionLibros();
      reloj.stop();
      if (mounted) {
        setState(() {
          _conectado = true;
          _latencia = reloj.elapsedMilliseconds;
        });
      }
    } on ErrorGraphQL {
      if (mounted) setState(() => _conectado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget seccion(double inicio, Widget child) => Aparecer(animacion: _entrada, inicio: inicio, child: child);

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de...')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
        children: [
          seccion(0, _TarjetaProducto(entrada: _entrada)),
          const SizedBox(height: Espacio.xl),
          seccion(
            0.15,
            const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TituloSeccion(icono: Icons.groups_rounded, titulo: 'Equipo de desarrollo', detalle: '4 integrantes'),
                SizedBox(height: 12),
                _Equipo(),
              ],
            ),
          ),
          const SizedBox(height: Espacio.xl),
          seccion(
            0.25,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TituloSeccion(icono: Icons.hub_rounded, titulo: 'Arquitectura del sistema'),
                const SizedBox(height: 12),
                _DiagramaArquitectura(
                  flujo: _flujo,
                  conectado: _conectado,
                  latencia: _latencia,
                  alMedir: _medirServidor,
                ),
              ],
            ),
          ),
          const SizedBox(height: Espacio.xl),
          seccion(
            0.35,
            const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TituloSeccion(icono: Icons.architecture_rounded, titulo: 'Patrones de diseño'),
                SizedBox(height: 12),
                _Patrones(),
              ],
            ),
          ),
          const SizedBox(height: Espacio.xl),
          seccion(
            0.45,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TituloSeccion(icono: Icons.code_rounded, titulo: 'Tecnologías'),
                const SizedBox(height: 12),
                Wrap(spacing: Espacio.sm, runSpacing: Espacio.sm, children: [for (final t in _tecnologias) _Chip(t)]),
              ],
            ),
          ),
          const SizedBox(height: 40),
          seccion(0.55, const _PiePagina()),
        ],
      ),
    );
  }
}

// ── Tarjeta del producto ──────────────────────────────────────────────────────

class _TarjetaProducto extends StatelessWidget {
  const _TarjetaProducto({required this.entrada});

  final Animation<double> entrada;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x40133B30), blurRadius: 28, offset: Offset(0, 12))],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF24684F), kPrimarioOscuro],
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        child: Stack(
          children: [
            Positioned(
              right: -70,
              top: -70,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFFE9C46A).withValues(alpha: 0.25), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 0, height: 58, child: Estanteria(progreso: entrada)),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 58 + 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícono de la app: placa dorada con brillo.
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF1D58A), Color(0xFFC9973F)],
                      ),
                      boxShadow: [BoxShadow(color: const Color(0xFFE9C46A).withValues(alpha: 0.45), blurRadius: 24)],
                    ),
                    child: const Icon(Icons.local_library_rounded, size: 36, color: kPrimarioOscuro),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Librería',
                    style: TextStyle(
                      fontFamily: fuenteTitulos,
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sistema de gestión de inventario para librerías: títulos, ejemplares y su estado.',
                    style: TextStyle(color: kCrema.withValues(alpha: 0.85), fontSize: 14, height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: Espacio.sm,
                    runSpacing: Espacio.sm,
                    children: [
                      _Insignia(icono: Icons.new_releases_rounded, texto: 'Versión $_version'),
                      _Insignia(icono: Icons.phone_android_rounded, texto: 'Android · Flutter'),
                    ],
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

/// Insignia translúcida sobre el fondo verde.
class _Insignia extends StatelessWidget {
  const _Insignia({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: const Color(0xFFF1D58A)),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(color: kCrema, fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Equipo ────────────────────────────────────────────────────────────────────

class _Equipo extends StatelessWidget {
  const _Equipo();

  static String _iniciales(String nombre) =>
      nombre.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, limites) {
        final ancho = (limites.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final integrante in _integrantes)
              Container(
                width: ancho,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kHoja,
                  borderRadius: Redondeo.tarjeta,
                  border: Border.all(color: kBorde),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color.lerp(integrante.color, Colors.white, 0.2)!, integrante.color],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: integrante.color.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _iniciales(integrante.nombre),
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      integrante.nombre,
                      style: const TextStyle(color: kTinta, fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Arquitectura ──────────────────────────────────────────────────────────────

/// Diagrama de la arquitectura distribuida: los dos clientes envían peticiones
/// GraphQL al servidor (paquetes animados) y el servidor guarda los datos en listas.
class _DiagramaArquitectura extends StatelessWidget {
  const _DiagramaArquitectura({
    required this.flujo,
    required this.conectado,
    required this.latencia,
    required this.alMedir,
  });

  final Animation<double> flujo;
  final bool? conectado;
  final int? latencia;
  final VoidCallback alMedir;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPergamino.withValues(alpha: 0.6),
        borderRadius: Redondeo.hero,
        border: Border.all(color: kBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _Nodo(icono: Icons.language_rounded, titulo: 'Cliente web', detalle: 'React · TypeScript'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _Nodo(
                    icono: Icons.phone_android_rounded,
                    titulo: 'App móvil',
                    detalle: 'Flutter · Dart',
                    actual: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: flujo,
                    builder: (context, _) => CustomPaint(painter: _PintorConexion(flujo.value, ramas: true)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: kTinta, borderRadius: BorderRadius.circular(999)),
                  child: const Text(
                    'GraphQL · HTTP POST',
                    style: TextStyle(color: kPapel, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: Redondeo.tarjeta,
              onTap: alMedir,
              child: _Nodo(
                icono: Icons.dns_rounded,
                titulo: 'Servidor GraphQL',
                detalle: 'Java 17 · Spring Boot',
                horizontal: true,
                extra: _EstadoServidor(conectado: conectado, latencia: latencia),
              ),
            ),
          ),
          SizedBox(
            height: 30,
            child: AnimatedBuilder(
              animation: flujo,
              builder: (context, _) => CustomPaint(painter: _PintorConexion(flujo.value, ramas: false)),
            ),
          ),
          const _Nodo(
            icono: Icons.storage_rounded,
            titulo: 'Repositorios en memoria',
            detalle: 'List<Libro> · List<Ejemplar>',
            horizontal: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.link_rounded, size: 15, color: kTinta3),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  urlGraphQL,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kTinta3, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Nodo extends StatelessWidget {
  const _Nodo({
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.horizontal = false,
    this.actual = false,
    this.extra,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final bool horizontal;

  /// Marca el nodo de este cliente ("Este dispositivo").
  final bool actual;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final textos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titulo,
          style: const TextStyle(color: kTinta, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(detalle, style: const TextStyle(color: kTinta3, fontSize: 12)),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kHoja,
        borderRadius: Redondeo.tarjeta,
        border: Border.all(color: actual ? kPrimario : kBorde, width: actual ? 1.5 : 1),
        boxShadow: sombraSuave,
      ),
      child: horizontal
          ? Row(
              children: [
                IconoAcento(icono, tamano: 38),
                const SizedBox(width: 12),
                Expanded(child: textos),
                ?extra,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconoAcento(icono, tamano: 38),
                const SizedBox(height: 10),
                textos,
                if (actual) ...[const SizedBox(height: 8), const Pastilla('Este dispositivo')],
              ],
            ),
    );
  }
}

/// Resultado de medir el servidor: comprobando, conectado (con latencia) o sin conexión.
class _EstadoServidor extends StatelessWidget {
  const _EstadoServidor({required this.conectado, required this.latencia});

  final bool? conectado;
  final int? latencia;

  @override
  Widget build(BuildContext context) {
    if (conectado == null) {
      return const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2));
    }
    final color = conectado! ? kVerde : kRojo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              conectado! ? 'Conectado' : 'Sin conexión',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        if (conectado! && latencia != null)
          Text(
            '$latencia ms',
            style: const TextStyle(color: kTinta3, fontSize: 11, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}

/// Líneas punteadas con "paquetes" que viajan hacia el servidor.
/// Con [ramas], las líneas salen de los dos clientes (25 % y 75 % del ancho) y se unen al centro.
class _PintorConexion extends CustomPainter {
  _PintorConexion(this.fase, {required this.ramas});

  final double fase;
  final bool ramas;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final medio = ramas ? h / 2 : 0.0;
    // Cada tramo con la parte del ciclo (0..1) en la que su paquete lo recorre: con ramas,
    // los paquetes bajan de los clientes hasta la unión y uno sigue hacia el servidor.
    final caminos = <(Path, double, double)>[
      if (ramas) ...[
        (
          Path()
            ..moveTo(w * 0.25, 0)
            ..lineTo(w * 0.25, medio)
            ..lineTo(w / 2, medio),
          0,
          0.6,
        ),
        (
          Path()
            ..moveTo(w * 0.75, 0)
            ..lineTo(w * 0.75, medio)
            ..lineTo(w / 2, medio),
          0,
          0.6,
        ),
      ],
      (
        Path()
          ..moveTo(w / 2, medio)
          ..lineTo(w / 2, h),
        ramas ? 0.6 : 0,
        1,
      ),
    ];

    final linea = Paint()
      ..color = kPrimario.withValues(alpha: 0.45)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final halo = Paint()
      ..color = const Color(0xFFE9C46A).withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final paquete = Paint()..color = kDorado;

    const guion = 5.0;
    const periodo = 10.0;
    for (final (camino, desde, hasta) in caminos) {
      for (final medida in camino.computeMetrics()) {
        // Guiones que avanzan en el sentido de la petición.
        for (var d = -periodo + (fase * periodo * 4) % periodo; d < medida.length; d += periodo) {
          final a = d.clamp(0.0, medida.length);
          final b = (d + guion).clamp(0.0, medida.length);
          if (b > a) canvas.drawPath(medida.extractPath(a, b), linea);
        }
        if (fase < desde || fase > hasta) continue;
        final t = Curves.easeInOut.transform((fase - desde) / (hasta - desde));
        final punto = medida.getTangentForOffset(medida.length * t)?.position;
        if (punto != null) {
          canvas.drawCircle(punto, 6, halo);
          canvas.drawCircle(punto, 3.2, paquete);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PintorConexion viejo) => viejo.fase != fase;
}

// ── Patrones, tecnologías y pie ───────────────────────────────────────────────

class _Patrones extends StatelessWidget {
  const _Patrones();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (final (i, patron) in _patrones.indexed) ...[
            if (i > 0) const Divider(indent: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconoAcento(patron.icono, tamano: 40),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patron.nombre,
                          style: const TextStyle(color: kTinta, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(patron.detalle, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kHoja,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorde2),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: kTinta2, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PiePagina extends StatelessWidget {
  const _PiePagina();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.local_library_rounded, color: kPrimario, size: 22),
        SizedBox(height: 8),
        Text(
          'Diseño de Soluciones · Universidad de Ibagué',
          textAlign: TextAlign.center,
          style: TextStyle(color: kTinta2, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 2),
        Text(
          'Segundo Proyecto · 2026B',
          textAlign: TextAlign.center,
          style: TextStyle(color: kTinta3, fontSize: 12),
        ),
        SizedBox(height: 10),
        Text(
          '© 2026 Equipo Librería',
          textAlign: TextAlign.center,
          style: TextStyle(color: kTinta3, fontSize: 11),
        ),
      ],
    );
  }
}
