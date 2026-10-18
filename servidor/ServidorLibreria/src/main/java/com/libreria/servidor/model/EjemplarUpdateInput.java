package com.libreria.servidor.model;

import com.libreria.servidor.enums.EstadoEjemplar;

import java.time.LocalDateTime;

/**
 * DTO de entrada para actualizar un Ejemplar ya existente (el codigo llega aparte).
 * No incluye numeroPrestamos: al actualizar lo calcula el servidor (aumenta en 1 cuando el
 * ejemplar pasa a PRESTADO).
 */
public record EjemplarUpdateInput(EstadoEjemplar estado, String ubicacion,
                                   LocalDateTime fechaIngreso, double precioReposicion) {
}
