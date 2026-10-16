package com.libreria.servidor.config;

import graphql.GraphQLContext;
import graphql.execution.CoercedVariables;
import graphql.language.StringValue;
import graphql.language.Value;
import graphql.schema.Coercing;
import graphql.schema.CoercingParseLiteralException;
import graphql.schema.CoercingParseValueException;
import graphql.schema.CoercingSerializeException;
import graphql.schema.GraphQLScalarType;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.graphql.execution.RuntimeWiringConfigurer;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Locale;

/** Define cómo GraphQL serializa/parsea el tipo escalar LocalDateTime (ISO-8601). */
@Configuration
public class LocalDateTimeScalarConfig {

    private static final DateTimeFormatter FORMATO = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    @Bean
    public RuntimeWiringConfigurer localDateTimeScalar() {
        GraphQLScalarType scalar = GraphQLScalarType.newScalar()
                .name("LocalDateTime")
                .description("Fecha y hora en formato ISO-8601 (yyyy-MM-ddTHH:mm:ss)")
                .coercing(new Coercing<LocalDateTime, String>() {

                    @Override
                    public String serialize(Object valor, GraphQLContext ctx, Locale locale) {
                        if (valor instanceof LocalDateTime fecha) {
                            return fecha.format(FORMATO);
                        }
                        throw new CoercingSerializeException("Se esperaba un LocalDateTime");
                    }

                    @Override
                    public LocalDateTime parseValue(Object valor, GraphQLContext ctx, Locale locale) {
                        try {
                            return convertir(valor.toString());
                        } catch (DateTimeParseException e) {
                            throw new CoercingParseValueException("Fecha inválida: " + valor);
                        }
                    }

                    @Override
                    public LocalDateTime parseLiteral(Value<?> valor, CoercedVariables vars,
                                                       GraphQLContext ctx, Locale locale) {
                        if (valor instanceof StringValue texto) {
                            try {
                                return convertir(texto.getValue());
                            } catch (DateTimeParseException e) {
                                throw new CoercingParseLiteralException("Fecha inválida: " + texto.getValue());
                            }
                        }
                        throw new CoercingParseLiteralException("La fecha debe enviarse como texto");
                    }
                })
                .build();

        return wiring -> wiring.scalar(scalar);
    }

    private static LocalDateTime convertir(String texto) {
        try {
            return LocalDateTime.parse(texto, FORMATO);
        } catch (DateTimeParseException e) {
            return OffsetDateTime.parse(texto).toLocalDateTime();
        }
    }
}
