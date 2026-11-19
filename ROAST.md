# Roast de la versión web

El editor local (`local/ROAST.md`) ya resolvía los riesgos de un editor con servidor. Pasar
a GitHub Pages, sin servidor y con la memoria publicada, trae riesgos nuevos.

| Riesgo | Decisión |
|---|---|
| **La web diagrama distinto que el computador.** Typst 0.14 cortaba líneas en otro lugar e ignoraba las negritas de las fuentes variables: daba 125 páginas en vez de 124. | El navegador usa Typst 0.15.1 (typst.ts 0.8.0-rc4), la misma versión local. Verificado: 124 páginas y el mismo texto en cada una; la única diferencia es el espacio junto al ✨ (emoji). |
| **Fuentes del sistema** (Inter, Inter Tight, Apple Color Emoji) que en la web no existen. | `sincronizar.py` publica Inter e Inter Tight (OFL) junto a las fuentes de la memoria. Apple Color Emoji no se puede publicar: va Noto Emoji (OFL, monocromática). La copia se verifica compilando sin fuentes del sistema. |
| **Paquetes de Typst descargados de afuera** (`cmarker`). | `cmarker` se publica dentro del proyecto (`memoria/vendor/`) y el import apunta a esa copia. |
| **Publicar lo que no corresponde.** | Solo se publica lo que `memoria.typ` usa (según `typst --deps`), más los capítulos y las reglas. Las fotos del testeo quedan como recuadros salvo `--con-fotos`. Nada de `fotos/`, `fotos-cap/`, perfiles ni consentimientos. |
| **Editar en la web y perder lo hecho.** | Cada cambio queda en el navegador (IndexedDB) y la barra muestra cuántos hay sin bajar. «Descargar cambios» arma un .zip con las mismas rutas de la carpeta `memoria/`. |
| **Editar sobre una versión publicada vieja.** | Cada cambio guarda la huella del archivo publicado. Si la memoria se vuelve a publicar y ese archivo cambió, el editor lo avisa al abrir. |
| **Un valor que rompe la compilación.** | Igual que en local: la regla se prueba antes y, si no compila, se vuelve al valor anterior. |
| **28 MB de Typst y 12 MB de memoria en cada visita.** | Se descargan una vez y quedan en la caché del navegador. La pantalla de carga muestra el avance. |
