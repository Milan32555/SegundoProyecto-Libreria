import { describe, expect, it } from "vitest";
import {
  hayErrores, validar, validarDecimalPositivo, validarEnteroNoNegativo, validarEnteroPositivo, validarFecha,
  validarObligatorio
} from "./validaciones";

describe("validaciones de formato", () => {
  it("obligatorio y fecha", () => {
    expect(validarObligatorio("  ")).toBe("Este campo es obligatorio.");
    expect(validarObligatorio("María")).toBeNull();
    expect(validarFecha("")).toBe("Elige la fecha y la hora.");
    expect(validarFecha("2024-02-10T09:00")).toBeNull();
  });

  it("decimal positivo (precios)", () => {
    expect(validarDecimalPositivo("")).toBe("Este campo es obligatorio.");
    expect(validarDecimalPositivo("abc")).toBe("Escribe un número válido.");
    expect(validarDecimalPositivo("0")).toBe("Debe ser mayor que cero.");
    expect(validarDecimalPositivo("39000.5")).toBeNull();
  });

  it("enteros (páginas y préstamos)", () => {
    expect(validarEnteroPositivo("")).toBe("Este campo es obligatorio.");
    expect(validarEnteroPositivo("1.5")).toBe("Escribe un número entero.");
    expect(validarEnteroPositivo("0")).toBe("Debe ser mayor que cero.");
    expect(validarEnteroPositivo("129")).toBeNull();
    expect(validarEnteroNoNegativo("")).toBe("Este campo es obligatorio.");
    expect(validarEnteroNoNegativo("2.5")).toBe("Escribe un número entero.");
    expect(validarEnteroNoNegativo("-1")).toBe("No puede ser negativo.");
    expect(validarEnteroNoNegativo("0")).toBeNull();
  });

  it("reúne solo los campos con error", () => {
    const errores = validar({ isbn: validarObligatorio(""), titulo: validarObligatorio("Rayuela") });
    expect(errores).toEqual({ isbn: "Este campo es obligatorio." });
    expect(hayErrores(errores)).toBe(true);
    expect(hayErrores(validar({ titulo: null }))).toBe(false);
  });
});
