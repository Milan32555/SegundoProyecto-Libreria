"""Contraste WCAG 2.1 de los pares de color del sistema de diseño (AA: 4.5 texto, 3.0 UI/grande)."""
import sys

sys.stdout.reconfigure(encoding="utf-8")


def lum(hex_color: str) -> float:
    h = hex_color.lstrip("#")
    canales = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    lin = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in canales]
    return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2]


def contraste(a: str, b: str) -> float:
    la, lb = sorted((lum(a), lum(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


# (descripción, primer plano, fondo, mínimo)
PARES = [
    ("Texto principal / superficie", "#1C1917", "#FFFFFF", 4.5),
    ("Texto principal / fondo página", "#1C1917", "#FAFAF9", 4.5),
    ("Texto secundario / superficie", "#57534E", "#FFFFFF", 4.5),
    ("Texto secundario / fondo página", "#57534E", "#FAFAF9", 4.5),
    ("Texto secundario / gris-50 (encabezado tabla)", "#57534E", "#F5F5F4", 4.5),
    ("Texto terciario / superficie", "#78716C", "#FFFFFF", 4.5),
    ("Texto terciario / fondo página", "#78716C", "#FAFAF9", 4.5),
    ("Borde de campo / superficie (UI)", "#8F8882", "#FFFFFF", 3.0),
    ("Marca (enlace/acento) / superficie", "#1F5C4A", "#FFFFFF", 4.5),
    ("Blanco / botón de marca", "#FFFFFF", "#1F5C4A", 4.5),
    ("Blanco / botón de marca hover", "#FFFFFF", "#174A3B", 4.5),
    ("Marca / marca-50 (nav activa)", "#1F5C4A", "#EDF5F1", 4.5),
    ("Foco (anillo) / superficie (UI)", "#1F5C4A", "#FFFFFF", 3.0),
    ("Disponible texto / fondo", "#116329", "#E8F5EC", 4.5),
    ("Disponible punto / fondo (UI)", "#1A7F37", "#E8F5EC", 3.0),
    ("Prestado texto / fondo", "#1D4E89", "#E9F1FB", 4.5),
    ("Prestado punto / fondo (UI)", "#2F6FBF", "#E9F1FB", 3.0),
    ("Dañado texto / fondo", "#7A4300", "#FDF1DC", 4.5),
    ("Dañado punto / fondo (UI)", "#B86E00", "#FDF1DC", 3.0),
    ("Dado de baja texto / fondo", "#4A4541", "#EFEDEB", 4.5),
    ("Dado de baja punto / fondo (UI)", "#78716C", "#EFEDEB", 3.0),
    ("Error texto / fondo banner", "#9B1C1C", "#FDEDEC", 4.5),
    ("Error texto campo / superficie", "#B42318", "#FFFFFF", 4.5),
    ("Blanco / botón peligro", "#FFFFFF", "#B42318", 4.5),
    ("Barra Disponible / superficie (UI)", "#1A7F37", "#FFFFFF", 3.0),
    ("Barra Prestado / superficie (UI)", "#2F6FBF", "#FFFFFF", 3.0),
    ("Barra Dañado / superficie (UI)", "#B86E00", "#FFFFFF", 3.0),
    ("Barra Dado de baja / superficie (UI)", "#78716C", "#FFFFFF", 3.0),
    ("Toast texto / fondo oscuro", "#FAFAF9", "#1C1917", 4.5),
]

fallos = 0
for nombre, frente, fondo, minimo in PARES:
    c = contraste(frente, fondo)
    ok = c >= minimo
    fallos += not ok
    print(f"{'OK ' if ok else 'MAL'} {c:5.2f}:1 (mín {minimo})  {nombre}  {frente} sobre {fondo}")
print(f"\n{len(PARES) - fallos}/{len(PARES)} pares cumplen AA")
sys.exit(1 if fallos else 0)
