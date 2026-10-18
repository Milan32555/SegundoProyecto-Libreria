package com.libreria.servidor;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.boot.test.web.server.LocalServerPort;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Levanta el servidor en un puerto real y le habla por HTTP, como lo hacen los clientes
 * (incluida la petición CORS "preflight" que hace el navegador para el cliente web).
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ExtendWith(OutputCaptureExtension.class)
class ServidorHttpTest {

    private static final String ORIGEN_CLIENTE_WEB = "http://localhost:5173";

    @LocalServerPort
    private int puerto;

    private final HttpClient http = HttpClient.newHttpClient();

    private URI urlGraphQl() {
        return URI.create("http://localhost:" + puerto + "/graphql");
    }

    @Test
    void respondeConsultasGraphQlPorPost() throws Exception {
        HttpRequest peticion = HttpRequest.newBuilder(urlGraphQl())
                .header("Content-Type", "application/json")
                .header("Origin", ORIGEN_CLIENTE_WEB)
                .POST(HttpRequest.BodyPublishers.ofString("{\"query\":\"{ libros { isbn titulo } }\"}"))
                .build();

        HttpResponse<String> respuesta = http.send(peticion, HttpResponse.BodyHandlers.ofString());

        assertThat(respuesta.statusCode()).isEqualTo(200);
        assertThat(respuesta.body()).contains("\"data\"").contains("978-0307474728");
        assertThat(respuesta.headers().firstValue("Access-Control-Allow-Origin")).isPresent();
    }

    @Test
    void registraEnConsolaCadaOperacionConElClienteQueLaHizo(CapturedOutput consola) throws Exception {
        enviar("movil", "{\"query\":\"query ($isbn: ID!) { libroPorIsbn(isbn: $isbn) { titulo } }\","
                + "\"variables\":{\"isbn\":\"978-8420471839\"}}");
        enviar("web", "{\"query\":\"mutation { eliminarLibro(isbn: \\\"978-0307474728\\\") { isbn } }\"}");
        enviar("web", "{\"query\":\"{ revisionLibros }\"}");

        assertThat(consola.getOut())
                .contains("App móvil    | consulta libroPorIsbn (isbn=978-8420471839)")
                .contains("Cliente web  | mutación eliminarLibro  -> RECHAZADA: No se puede eliminar el libro")
                .doesNotContain("revisionLibros"); // el sondeo del Observer no llena la consola
    }

    private void enviar(String cliente, String cuerpo) throws Exception {
        HttpRequest peticion = HttpRequest.newBuilder(urlGraphQl())
                .header("Content-Type", "application/json")
                .header("X-Cliente", cliente)
                .POST(HttpRequest.BodyPublishers.ofString(cuerpo))
                .build();
        assertThat(http.send(peticion, HttpResponse.BodyHandlers.ofString()).statusCode()).isEqualTo(200);
    }

    @Test
    void permiteElPreflightCorsDelClienteWeb() throws Exception {
        HttpRequest preflight = HttpRequest.newBuilder(urlGraphQl())
                .header("Origin", ORIGEN_CLIENTE_WEB)
                .header("Access-Control-Request-Method", "POST")
                .header("Access-Control-Request-Headers", "content-type, x-cliente")
                .method("OPTIONS", HttpRequest.BodyPublishers.noBody())
                .build();

        HttpResponse<String> respuesta = http.send(preflight, HttpResponse.BodyHandlers.ofString());

        assertThat(respuesta.statusCode()).isEqualTo(200);
        assertThat(respuesta.headers().firstValue("Access-Control-Allow-Origin")).isPresent();
    }
}
