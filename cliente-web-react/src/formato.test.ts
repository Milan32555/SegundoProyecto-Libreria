import { describe, expect, it } from "vitest";
import { aValorDeInputFecha, formatearFecha, formatearPrecio } from "./formato";

describe("formato", () => {
  it("formatea el precio como moneda", () => {
    expect(formatearPrecio(65000)).toMatch(/65\.000/);
  });

  it("formatea la fecha ISO del servidor de forma legible", () => {
    expect(formatearFecha("1967-05-30T00:00:00")).toMatch(/1967/);
    expect(formatearFecha("no es fecha")).toBe("no es fecha");
  });

  it("convierte la fecha ISO al formato de <input type='datetime-local'>", () => {
    expect(aValorDeInputFecha("2024-02-10T09:05:00")).toBe("2024-02-10T09:05");
  });
});
