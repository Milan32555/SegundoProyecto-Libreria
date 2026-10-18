package com.libreria.servidor.model;

import com.libreria.servidor.enums.EstadoEjemplar;

/**
 * Cuántos ejemplares hay en un estado y qué porcentaje del inventario representan
 * (0 a 100). Lo calcula el servidor para que los clientes solo lo muestren.
 */
public record ConteoEstado(EstadoEjemplar estado, int cantidad, double porcentaje) {
}
