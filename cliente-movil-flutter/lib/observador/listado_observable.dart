/// Patrón Observer (lado cliente): un "sujeto" al que las pantallas de Listar
/// se suscriben para enterarse cuando la colección cambió (tras un Adicionar,
/// Actualizar o Eliminar en cualquier otra pantalla).
///
/// Las pantallas de mutación llaman a `notificar()` tras una operación exitosa;
/// la pantalla de Listar se suscribe en `initState` y se desuscribe en `dispose`.
typedef Observador = void Function();

class ListadoObservable {
  final List<Observador> _observadores = [];

  void suscribir(Observador observador) {
    _observadores.add(observador);
  }

  void desuscribir(Observador observador) {
    _observadores.remove(observador);
  }

  void notificar() {
    for (final observador in List<Observador>.from(_observadores)) {
      observador();
    }
  }
}

// Un sujeto observable por cada colección (maestro y detalle).
final ListadoObservable libroObservable = ListadoObservable();
final ListadoObservable ejemplarObservable = ListadoObservable();
