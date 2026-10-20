import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../servicios/cliente_graphql.dart';
import '../servicios/servicio_libro.dart';
import '../tema/tema.dart';
import 'comunes/componentes.dart';

const _version = '1.0.0';

const _integrantes = ['Misael Gallo Tangarife', 'Sara Zambrano', 'Santiago Guimel', 'Alejandra González'];

const _patrones = [
  (nombre: 'MVC', donde: 'Modelos y servicios de datos, observadores y pantallas en paquetes separados.'),
  (nombre: 'Singleton', donde: 'Un único ClienteGraphQL en cada cliente y repositorios únicos en el servidor.'),
  (nombre: 'Observer', donde: 'Las pantallas de Listar y el Inicio se actualizan solas cuando cambian los datos.'),
  (nombre: 'Builder', donde: 'LibroBuilder y EjemplarBuilder construyen los objetos en el servidor.'),
  (nombre: 'SOLID', donde: 'Una responsabilidad por clase e inyección de dependencias en el servidor.'),
];

const _tecnologias = ['Java 17', 'Spring Boot', 'Spring for GraphQL', 'React 18', 'TypeScript', 'Flutter', 'Dart'];

/// Ayuda → Acerca de...: versión, integrantes, arquitectura (con el estado real del servidor),
/// patrones de diseño y tecnologías.
class AcercaDe extends StatelessWidget {
  const AcercaDe({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    Widget titulo(String texto) => Padding(
      padding: const EdgeInsets.only(top: Espacio.e6, bottom: Espacio.e2),
      child: Semantics(header: true, child: Text(texto, style: textos.titleMedium)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e4, Espacio.e4, Espacio.e8),
        children: [
          const EncabezadoPantalla(titulo: 'Acerca de', descripcion: 'Librería: gestión del inventario de libros y ejemplares.'),
          Panel(
            child: Column(
              children: [
                _Dato('Aplicación', 'Librería · App móvil'),
                const _Dato('Versión', _version),
                _Dato('Proyecto', 'Segundo Proyecto · Diseño de Soluciones\nUniversidad de Ibagué · 2026B'),
              ],
            ),
          ),
          titulo('Integrantes'),
          Panel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final nombre in _integrantes)
                  ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: kGris50,
                      foregroundColor: kGris600,
                      child: Text(
                        nombre.split(' ').take(2).map((p) => p[0]).join(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    title: Text(nombre),
                  ),
              ],
            ),
          ),
          titulo('Arquitectura'),
          const Panel(child: _Diagrama()),
          titulo('Patrones de diseño'),
          Panel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final p in _patrones)
                  ListTile(title: Text(p.nombre), subtitle: Text(p.donde)),
              ],
            ),
          ),
          titulo('Tecnologías'),
          Wrap(
            spacing: Espacio.e2,
            runSpacing: Espacio.e2,
            children: [
              for (final t in _tecnologias)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Espacio.e2, vertical: 2),
                  decoration: BoxDecoration(
                    color: kGris0,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: kGris100),
                  ),
                  child: Text(t, style: const TextStyle(fontSize: 12, color: kGris600, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
          const SizedBox(height: Espacio.e8),
          Text(
            '© 2026 Equipo Librería · Universidad de Ibagué',
            textAlign: TextAlign.center,
            style: textos.bodySmall!.copyWith(color: kGris500),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.termino, this.valor);

  final String termino;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Espacio.e1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 104, child: Text(termino, style: const TextStyle(color: kGris500, fontSize: 14))),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

/// Diagrama estático de la arquitectura distribuida y, debajo, el resultado de una consulta
/// real al servidor y cuánto tardó.
class _Diagrama extends StatefulWidget {
  const _Diagrama();

  @override
  State<_Diagrama> createState() => _DiagramaState();
}

class _DiagramaState extends State<_Diagrama> {
  bool _comprobando = true;
  int? _milisegundos;

  @override
  void initState() {
    super.initState();
    _medir();
  }

  Future<void> _medir() async {
    setState(() => _comprobando = true);
    final cronometro = Stopwatch()..start();
    int? resultado;
    try {
      await consultarRevisionLibros();
      resultado = cronometro.elapsedMilliseconds;
    } on ErrorGraphQL {
      resultado = null;
    }
    if (mounted) {
      setState(() {
        _comprobando = false;
        _milisegundos = resultado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = _comprobando
        ? 'Comprobando el servidor…'
        : _milisegundos == null
        ? 'Sin conexión con el servidor'
        : 'Servidor conectado · $_milisegundos ms';
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: _Nodo(icono: LucideIcons.monitor, titulo: 'Cliente web', detalle: 'React · TypeScript')),
            SizedBox(width: Espacio.e3),
            Expanded(child: _Nodo(icono: LucideIcons.smartphone, titulo: 'App móvil', detalle: 'Flutter · Dart')),
          ],
        ),
        const _Conector('GraphQL sobre HTTP (POST)'),
        const _Nodo(icono: LucideIcons.server, titulo: 'Servidor GraphQL', detalle: 'Java 17 · Spring Boot · toda la lógica'),
        const _Conector('en memoria'),
        const _Nodo(icono: LucideIcons.database, titulo: 'Repositorios', detalle: 'List<Libro> · List<Ejemplar>'),
        const SizedBox(height: Espacio.e3),
        Semantics(liveRegion: true, child: Text(estado, style: const TextStyle(color: kGris600, fontSize: 14))),
        Text(urlGraphQL, style: const TextStyle(color: kGris500, fontSize: 12)),
        TextButton.icon(
          onPressed: _comprobando ? null : _medir,
          icon: const Icon(LucideIcons.rotateCw, size: 16),
          label: const Text('Medir de nuevo'),
        ),
      ],
    );
  }
}

class _Nodo extends StatelessWidget {
  const _Nodo({required this.icono, required this.titulo, required this.detalle});

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espacio.e3),
      decoration: BoxDecoration(borderRadius: Radios.panel, border: Border.all(color: kGris200)),
      child: Row(
        children: [
          Icon(icono, size: 18, color: kGris600),
          const SizedBox(width: Espacio.e2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(detalle, style: const TextStyle(color: kGris600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Conector extends StatelessWidget {
  const _Conector(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 1, height: 12, color: kGris400),
        Text(texto, style: const TextStyle(color: kGris500, fontSize: 12)),
        Container(width: 1, height: 12, color: kGris400),
      ],
    );
  }
}
