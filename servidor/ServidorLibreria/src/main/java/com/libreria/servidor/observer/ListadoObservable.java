package com.libreria.servidor.observer;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.function.Supplier;

/**
 * Patrón Observer: "sujeto" observable genérico. Mantiene una lista de observadores
 * y los notifica (push del listado completo) cada vez que se llama a notificarCambio().
 *
 * Los servicios (ServicioLibro, ServicioEjemplar) usan esta clase para avisar
 * tras cada inserción, actualización o eliminación, cumpliendo el requisito de aplicar
 * Observer en el caso de uso Listar.
 *
 * Se usa CopyOnWriteArrayList porque el servidor atiende peticiones de varios clientes
 * en paralelo: se puede suscribir/notificar desde distintos hilos sin errores de concurrencia.
 */
public class ListadoObservable<T> {

    private final List<ObservadorListado<T>> observadores = new CopyOnWriteArrayList<>();

    public void suscribir(ObservadorListado<T> observador) {
        observadores.add(observador);
    }

    public void desuscribir(ObservadorListado<T> observador) {
        observadores.remove(observador);
    }

    /** Notifica a todos los observadores con el listado actual (obtenido perezosamente). */
    public void notificarCambio(Supplier<List<T>> listadoActual) {
        List<T> snapshot = listadoActual.get();
        for (ObservadorListado<T> observador : observadores) {
            observador.alActualizarListado(snapshot);
        }
    }
}
