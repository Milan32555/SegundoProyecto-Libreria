package com.libreria.servidor.registro;

import graphql.language.Document;
import graphql.language.Field;
import graphql.language.OperationDefinition;
import graphql.parser.Parser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.graphql.server.WebGraphQlInterceptor;
import org.springframework.graphql.server.WebGraphQlRequest;
import org.springframework.graphql.server.WebGraphQlResponse;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Escribe en la consola del servidor una línea por cada operación GraphQL que llega:
 * la hora, qué cliente la hizo (encabezado {@code X-Cliente}), si es consulta o mutación,
 * los campos pedidos y los datos clave. Ejemplo:
 * <pre>12:41:05  App móvil    | mutación crearLibro (isbn=978-1, titulo=Pedro Páramo)</pre>
 *
 * Las consultas de revisión que el Observer de los clientes hace cada 15 s no se registran
 * (llenarían la consola); se pueden incluir con {@code libreria.registro.incluir-revisiones=true}.
 */
@Component
public class RegistroOperaciones implements WebGraphQlInterceptor {

    /** Nombre del encabezado HTTP con el que cada cliente se identifica. */
    public static final String ENCABEZADO_CLIENTE = "X-Cliente";

    /** Logger propio: logback-spring.xml lo imprime como "HH:mm:ss  mensaje". */
    private static final Logger REGISTRO = LoggerFactory.getLogger("operaciones");

    private static final Map<String, String> NOMBRES_CLIENTE = Map.of(
            "web", "Cliente web",
            "movil", "App móvil");

    /** Datos que identifican el objeto en una mutación (dentro del input). */
    private static final List<String> CLAVES_INPUT = List.of("isbn", "codigo", "titulo");

    private static final int LARGO_MAXIMO_VALOR = 40;

    private final boolean incluirRevisiones;

    public RegistroOperaciones(@Value("${libreria.registro.incluir-revisiones:false}") boolean incluirRevisiones) {
        this.incluirRevisiones = incluirRevisiones;
    }

    @Override
    public Mono<WebGraphQlResponse> intercept(WebGraphQlRequest request, Chain chain) {
        String cliente = nombreCliente(request.getHeaders().getFirst(ENCABEZADO_CLIENTE));
        Operacion operacion = Operacion.analizar(request.getDocument(), request.getOperationName());
        return chain.next(request).doOnNext(respuesta -> {
            if (operacion.esSoloRevision() && !incluirRevisiones) {
                return;
            }
            String error = respuesta.getErrors().isEmpty() ? null : respuesta.getErrors().get(0).getMessage();
            REGISTRO.info(linea(cliente, operacion, request.getVariables(), error));
        });
    }

    /** Nombre legible del cliente a partir del valor del encabezado X-Cliente. */
    static String nombreCliente(String encabezado) {
        if (encabezado == null || encabezado.isBlank()) {
            return "Desconocido";
        }
        return NOMBRES_CLIENTE.getOrDefault(encabezado.trim().toLowerCase(), encabezado.trim());
    }

    /** Arma la línea que se imprime (sin la hora, que la agrega el logger). */
    static String linea(String cliente, Operacion operacion, Map<String, Object> variables, String error) {
        StringBuilder texto = new StringBuilder()
                .append(String.format("%-12s | %s %s", cliente, operacion.tipo(), String.join(" + ", operacion.campos())));
        String datos = datosClave(variables);
        if (!datos.isEmpty()) {
            texto.append(" (").append(datos).append(')');
        }
        if (error != null) {
            texto.append("  -> RECHAZADA: ").append(error);
        }
        return texto.toString();
    }

    /** Variables con valor; de los input solo se muestran isbn, código y título. */
    private static String datosClave(Map<String, Object> variables) {
        Map<String, Object> datos = new LinkedHashMap<>();
        if (variables != null) {
            variables.forEach((nombre, valor) -> {
                if (valor instanceof Map<?, ?> input) {
                    CLAVES_INPUT.stream()
                            .filter(clave -> input.get(clave) != null)
                            .forEach(clave -> datos.putIfAbsent(clave, input.get(clave)));
                } else if (valor != null && !valor.toString().isBlank()) {
                    datos.putIfAbsent(nombre, valor);
                }
            });
        }
        return datos.entrySet().stream()
                .map(e -> e.getKey() + "=" + recortar(e.getValue().toString()))
                .collect(Collectors.joining(", "));
    }

    private static String recortar(String valor) {
        return valor.length() <= LARGO_MAXIMO_VALOR ? valor : valor.substring(0, LARGO_MAXIMO_VALOR - 1) + "…";
    }

    /** Tipo de operación (consulta o mutación) y campos raíz que pide. */
    record Operacion(String tipo, List<String> campos) {

        static Operacion analizar(String documento, String nombreOperacion) {
            try {
                Document arbol = Parser.parse(documento);
                return arbol.getDefinitionsOfType(OperationDefinition.class).stream()
                        .filter(op -> nombreOperacion == null || nombreOperacion.equals(op.getName()))
                        .findFirst()
                        .map(op -> new Operacion(
                                op.getOperation() == OperationDefinition.Operation.MUTATION ? "mutación" : "consulta",
                                op.getSelectionSet().getSelectionsOfType(Field.class).stream().map(Field::getName).toList()))
                        .orElse(new Operacion("consulta", List.of("(sin operación)")));
            } catch (RuntimeException e) {
                return new Operacion("consulta", List.of("(no válida)"));
            }
        }

        boolean esSoloRevision() {
            return !campos.isEmpty() && campos.stream().allMatch(c -> c.startsWith("revision"));
        }
    }
}
