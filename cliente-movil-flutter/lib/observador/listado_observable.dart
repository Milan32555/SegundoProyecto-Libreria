import 'dart:async';

import '../servicios/servicio_ejemplar.dart';
import '../servicios/servicio_libro.dart';

/// Patrón Observer (lado cliente): un "sujeto" al que se suscriben las pantallas
/// de Listar para enterarse de que la colección cambió.
///
/// El sujeto avisa a sus observadores en dos casos:
///  1. Una pantalla de esta app (Adicionar/Actualizar/Eliminar) llama a [notificar]
///     después de una operación exitosa.
///  2. Mientras haya al menos un observador, consulta cada pocos segundos el número
///     de revisión de la colección en el servidor; si cambió (por ejemplo, el cliente
///     web agregó un libro), notifica a sus observadores.
///
/// La pantalla de Listar se suscribe en `initState` y se desuscribe en `dispose`.
typedef Observador = void Function();

class ListadoObservable {
  ListadoObservable({this.consultarRevision, this.intervalo = const Duration(seconds: 3)});

  final Future<int> Function()? consultarRevision;
  final Duration intervalo;

  final List<Observador> _observadores = [];
  Timer? _temporizador;
  int? _ultimaRevision;

  void suscribir(Observador observador) {
    _observadores.add(observador);
    if (_observadores.length == 1) _iniciarVigilancia();
  }

  void desuscribir(Observador observador) {
    _observadores.remove(observador);
    if (_observadores.isEmpty) _detenerVigilancia();
  }

  void notificar() {
    for (final observador in List<Observador>.of(_observadores)) {
      observador();
    }
  }

  void _iniciarVigilancia() {
    if (consultarRevision == null) return;
    _ultimaRevision = null;
    _revisarServidor();
    _temporizador = Timer.periodic(intervalo, (_) => _revisarServidor());
  }

  void _detenerVigilancia() {
    _temporizador?.cancel();
    _temporizador = null;
  }

  Future<void> _revisarServidor() async {
    try {
      final revision = await consultarRevision!();
      final cambio = _ultimaRevision != null && revision != _ultimaRevision;
      _ultimaRevision = revision;
      if (cambio) notificar();
    } on Exception {
      // Servidor no disponible por un momento: se vuelve a intentar en el siguiente ciclo.
    }
  }
}

// Un sujeto observable por cada colección (maestro y detalle).
final ListadoObservable libroObservable = ListadoObservable(consultarRevision: consultarRevisionLibros);
final ListadoObservable ejemplarObservable = ListadoObservable(consultarRevision: consultarRevisionEjemplares);
