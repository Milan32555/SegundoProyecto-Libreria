package com.libreria.servidor.model;

import com.libreria.servidor.enums.EstadoEjemplar;

import java.time.LocalDateTime;

/** DTO de entrada para actualizar un Ejemplar ya existente (el codigo llega aparte). */
public record EjemplarUpdateInput(EstadoEjemplar estado, String ubicacion,
                                   LocalDateTime fechaIngreso, double precioReposicion) {
}
