package com.libreria.servidor.model;

import com.libreria.servidor.enums.Genero;

import java.time.LocalDateTime;

/** DTO de entrada para actualizar un Libro ya existente (el isbn llega aparte, como argumento). */
public record LibroUpdateInput(String titulo, String autor, double precio,
                                int numeroPaginas, LocalDateTime fechaPublicacion, Genero genero) {
}
