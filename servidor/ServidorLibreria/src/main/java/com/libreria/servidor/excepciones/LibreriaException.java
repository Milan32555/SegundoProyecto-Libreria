package com.libreria.servidor.excepciones;

/** Excepción de negocio: datos inválidos, objeto no encontrado, violación de reglas, etc. */
public class LibreriaException extends RuntimeException {
    public LibreriaException(String mensaje) {
        super(mensaje);
    }
}
