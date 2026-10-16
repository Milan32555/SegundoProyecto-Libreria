package com.libreria.servidor.observer;

import java.util.List;

/**
 * Patrón Observer: cualquiera que necesite enterarse de cambios en una colección
 * (se agregó, actualizó o eliminó un elemento) implementa esta interfaz y se
 * suscribe a un {@link ListadoObservable}.
 *
 * En el servidor se usa para que el "sujeto" (el servicio) avise a sus observadores
 * cada vez que la lista cambia; los clientes (ver Observer en React/Flutter) aplican
 * el mismo patrón para refrescar su propia vista de Listar en cuanto detectan un cambio.
 */
public interface ObservadorListado<T> {
    void alActualizarListado(List<T> listadoActual);
}
