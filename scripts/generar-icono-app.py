"""Genera el ícono de la app Android con el logotipo del sistema de diseño.

Glifo "library" de Lucide (el mismo del logotipo web y de la app) en blanco sobre el verde de
marca #1F5C4A, plano. Crea el ícono clásico (ic_launcher.png) y la capa frontal del ícono
adaptativo (ic_launcher_foreground.png) en todas las densidades.

    python scripts/generar-icono-app.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

MARCA = (0x1F, 0x5C, 0x4A, 255)
BLANCO = (255, 255, 255, 255)
RES = Path(__file__).resolve().parent.parent / "cliente-movil-flutter/android/app/src/main/res"

# Trazos del ícono "library" de Lucide en su caja de 24x24 (stroke 2, extremos redondeados).
TRAZOS = [((16, 6), (20, 20)), ((12, 6), (12, 20)), ((8, 8), (8, 20)), ((4, 4), (4, 20))]

DENSIDADES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
ESCALA = 8  # se dibuja grande y se reduce: bordes suaves


def glifo(dibujo: ImageDraw.ImageDraw, origen: tuple[float, float], lado: float) -> None:
    """Dibuja el glifo de 24x24 dentro de un cuadrado de `lado` px que empieza en `origen`."""
    k = lado / 24
    grosor = 2 * k
    for (x1, y1), (x2, y2) in TRAZOS:
        a = (origen[0] + x1 * k, origen[1] + y1 * k)
        b = (origen[0] + x2 * k, origen[1] + y2 * k)
        dibujo.line([a, b], fill=BLANCO, width=round(grosor))
        for cx, cy in (a, b):  # extremos redondeados
            r = grosor / 2
            dibujo.ellipse([cx - r, cy - r, cx + r, cy + r], fill=BLANCO)


def icono_clasico(px: int) -> Image.Image:
    lado = px * ESCALA
    img = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, lado - 1, lado - 1], radius=round(lado * 0.22), fill=MARCA)
    g = lado * 0.56
    glifo(d, ((lado - g) / 2, (lado - g) / 2), g)
    return img.resize((px, px), Image.LANCZOS)


def capa_frontal(px: int) -> Image.Image:
    # Lienzo de 108 dp; el glifo ocupa ~46 dp centrados (dentro de la zona segura de 66 dp).
    lado = px * ESCALA
    img = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    g = lado * 46 / 108
    glifo(d, ((lado - g) / 2, (lado - g) / 2), g)
    return img.resize((px, px), Image.LANCZOS)


if __name__ == "__main__":
    for nombre, factor in DENSIDADES.items():
        carpeta = RES / f"mipmap-{nombre}"
        icono_clasico(round(48 * factor)).save(carpeta / "ic_launcher.png")
        capa_frontal(round(108 * factor)).save(carpeta / "ic_launcher_foreground.png")
        print(f"{nombre}: {round(48 * factor)} px y {round(108 * factor)} px")
