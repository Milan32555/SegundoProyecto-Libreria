package com.libreria.servidor.model;

import com.libreria.servidor.enums.Genero;

import java.time.LocalDateTime;

/**
 * DTO de entrada para crear o actualizar un Libro.
 * Al crear, el isbn es la clave del libro nuevo; al actualizar, indica qué libro se modifica.
 */
public record LibroInput(String isbn, String titulo, String autor, double precio,
                          int numeroPaginas, LocalDateTime fechaPublicacion, Genero genero) {
}
