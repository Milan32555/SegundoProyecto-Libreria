package com.libreria.servidor.model;

import com.libreria.servidor.enums.EstadoEjemplar;

import java.time.LocalDateTime;

/** DTO de entrada para crear un Ejemplar, vinculado a un Libro existente por su isbn. */
public record EjemplarInput(String codigo, EstadoEjemplar estado, String ubicacion,
                             LocalDateTime fechaIngreso, double precioReposicion, String isbnLibro) {
}
