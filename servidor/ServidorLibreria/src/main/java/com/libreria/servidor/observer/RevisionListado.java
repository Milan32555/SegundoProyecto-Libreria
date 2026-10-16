package com.libreria.servidor.observer;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Observador concreto: lleva un número de revisión que aumenta cada vez que el
 * listado observado cambia.
 *
 * Los servicios lo exponen por GraphQL (revisionLibros / revisionEjemplares) para que
 * el Observer de los clientes detecte cambios hechos desde OTRO cliente y refresque
 * su pantalla de Listar sin descargar la colección completa en cada consulta.
 */
public class RevisionListado<T> implements ObservadorListado<T> {

    private final AtomicInteger revision = new AtomicInteger();

    @Override
    public void alActualizarListado(List<T> listadoActual) {
        revision.incrementAndGet();
    }

    public int getRevision() {
        return revision.get();
    }
}
