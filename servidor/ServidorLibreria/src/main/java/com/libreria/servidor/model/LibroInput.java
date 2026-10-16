package com.libreria.servidor.model;

import com.libreria.servidor.enums.Genero;

import java.time.LocalDateTime;

/** DTO de entrada para crear un Libro (incluye isbn porque aún no existe en el sistema). */
public record LibroInput(String isbn, String titulo, String autor, double precio,
                          int numeroPaginas, LocalDateTime fechaPublicacion, Genero genero) {
}
