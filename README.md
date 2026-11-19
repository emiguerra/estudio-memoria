# estudio memoria · rastro

Editor de la memoria de título de ***rastro*** (Diseño, UDP, 2026). Ajusta las reglas de
diagramación, el texto, las láminas y las imágenes, y muestra el resultado en la página
en segundos.

**Ábrelo aquí → [emiguerra.github.io/estudio-memoria](https://emiguerra.github.io/estudio-memoria/)**

![El editor: reglas a la izquierda, la memoria al centro](captura.png)

## Para qué se creó

La memoria se diagrama con [Typst](https://typst.app), un sistema paramétrico como LaTeX:
el diseño son reglas (márgenes, columnas, tamaños, cuándo cortar una página) y no cajas
movidas a mano. Este editor expone esas reglas en un panel para ajustarlas directamente,
ver el efecto al instante y no romper nada en el intento. Primero existió en local, con un
servidor en el computador. Esta versión corre entera en el navegador, desde cualquier lado.

## Qué hace

| Pestaña | Qué permite |
|---|---|
| **Reglas** | 33 reglas en seis grupos: página, tipografía, color, flujo y equilibrio, texto y figuras. Una regla solo se aplica si el documento compila con ella. |
| **Texto** | Editar el Markdown de cada capítulo, con el conteo de palabras contra el límite de 20.000. |
| **Láminas** | Los diagramas de la memoria con miniatura y dónde se usa cada uno. Se insertan en el texto o al costado de él. |
| **Imágenes** | Repositorio de imágenes y fotos del testeo, para armar láminas y composiciones con título y fuente APA. |

## Cómo se usa

**En la web:** abre el link. La primera vez descarga Typst (28 MB) y la memoria publicada
(12 MB), y después queda en la caché.

Lo que edites se guarda en ese navegador, encima de la versión publicada. La barra de
arriba muestra cuántos cambios tienes sin bajar. Para llevarlos a la carpeta de la memoria:
**cambios → Descargar cambios (.zip)** y descomprime el .zip encima de `memoria/`.

**En local:** el editor original vive en `memoria/diagramacion/editor/` (copia en
[`local/`](local/)). Se abre con doble clic en `abrir-editor.command`.

**Para publicar una versión nueva** después de trabajar en local:

```
python3 herramientas/sincronizar.py            # fotos del testeo como recuadros
python3 herramientas/sincronizar.py --con-fotos
git add -A && git commit -m "Memoria actualizada" && git push
```

El script copia solo lo que la memoria usa, junta las fuentes, dibuja las miniaturas de
las láminas y compila la copia sin fuentes del sistema para confirmar que la web va a ver
lo mismo que el computador.

## Qué hay acá

```
index.html              la interfaz (la misma del editor local)
web/motor.js            el servidor del editor, pero en el navegador: Typst, pdf.js y cambios
memoria/                la memoria publicada: .typ, capítulos, imágenes, fuentes y manifiesto
catalogo/               miniaturas e índice de las láminas
herramientas/
  sincronizar.py        publica la memoria desde la carpeta local
local/                  el editor local (servidor Python + Typst instalado)
ROAST.md                qué podía salir mal en la versión web y cómo se resolvió
```

## Referencias

- [Typst](https://typst.app), el motor de composición, y
  [typst.ts](https://github.com/Myriad-Dreamin/typst.ts), que lo corre en el navegador.
- [cmarker](https://typst.app/universe/package/cmarker): Markdown dentro de Typst.
- [pdf.js](https://mozilla.github.io/pdf.js/) para mostrar las páginas y
  [JSZip](https://stuk.github.io/jszip/) para bajar los cambios.
- [Brik](https://brik.space/gallery): referente de la interfaz.
- [Geist](https://vercel.com/font), la tipografía de la interfaz.
- La versión abierta, para cualquier memoria:
  [editor-memoria](https://github.com/emiguerra/editor-memoria).

---

Emilia Guerra · Memoria de título, Diseño, UDP · 2026
