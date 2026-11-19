# Roast del editor de la memoria — antes de construir

Qué puede salir mal con un editor que cambia las reglas de diagramación, inserta
láminas e imágenes y recompila en vivo, y qué decisión de construcción responde a cada
riesgo. Medido sobre el sistema real (18 nov 2026): PDF completo 2,4 s · miniaturas de
124 páginas a 16 ppi 1,6 s · una página a 100 ppi 1,4 s.

## 1. Datos y archivos

| # | Riesgo | Por qué es real aquí | Decisión |
|---|---|---|---|
| 1 | **Dos fuentes de verdad.** `compilar.sh` regenera `limpias/` desde `secciones/` y borra el trabajo. | Ya casi pasó hoy. | El editor solo lee y escribe `limpias/`. `compilar.sh` deja de llamar a `limpiar.py`. |
| 2 | **Pisar cambios hechos en otra parte.** Emilia en VS Code, Claude en terminal y el editor a la vez. | Pasó varias veces en esta sesión. | Cada archivo viaja con su huella (hash). Si cambió en disco desde que se abrió, el editor no guarda y avisa. |
| 3 | **No poder volver atrás.** | Un control mal movido puede romper 100 páginas. | Cada guardado deja una copia con fecha en `editor/historial/`. Botón «Deshacer último cambio». |
| 4 | **Reglas inválidas rompen la compilación** (texto donde va un número, margen negativo). | Typst se cae y no hay vista. | Esquema con tipo, mínimo, máximo y unidad por regla. Se valida en el navegador y en el servidor. Una regla nueva se compila de prueba y **solo se guarda si compila**. Si falla, queda la última vista buena y el error en lenguaje claro. |
| 5 | **`reglas.json` borrado o corrupto.** | Typst no tendría de dónde leer, y Typst no puede capturar ese error. | El servidor (y `compilar.sh`) recrean el archivo desde los valores por defecto si falta o no es JSON válido. Typst además une cada clave con su valor por defecto de `reglas.typ`: una regla ausente nunca rompe nada. |
| 6 | **iCloud desaloja archivos del Escritorio** y las lecturas se cuelgan. | Lo registra la bitácora del 10 nov. | Las vistas previas (cientos de PNG) van a `~/Library/Caches/editor-memoria`, fuera de iCloud. |

## 2. Compilación y vista previa

| # | Riesgo | Decisión |
|---|---|---|
| 7 | **Compilaciones encimadas** al mover un deslizador: diez compilaciones en cola. | Una sola compilación a la vez, con espera de 400 ms tras el último cambio. Gana la última; las anteriores se descartan. |
| 8 | **El navegador muestra la imagen vieja** (caché). | Cada vista lleva el número de compilación en la URL. |
| 9 | **Advertencias de convergencia** (páginas que oscilan) que nadie ve. | Las advertencias de Typst aparecen en la barra de estado, resumidas y con la línea. |
| 10 | **La página que miras se mueve** al cambiar una regla: la página 40 deja de ser la misma. | Navegación por capítulo y miniaturas de todo el documento. La vista se queda en el capítulo aunque cambie el número de página. |
| 11 | **Dependencias**: Typst 0.15, el paquete `cmarker` offline, fuentes en `fonts/` e Inter del sistema. | El servidor revisa todo al partir y lo informa en la pantalla de estado, sin fallar en silencio. |

## 3. Láminas, diagramas e imágenes

| # | Riesgo | Decisión |
|---|---|---|
| 12 | **Insertar una lámina en mitad de un párrafo** rompe el texto. | Las láminas se insertan solo entre bloques: el editor muestra los puntos válidos («después de este párrafo»), no un cursor libre. |
| 13 | **Llamar una lámina que no existe** (error de tipeo): hoy se salta en silencio. | Catálogo cerrado: solo se insertan láminas que existen. Un marcador desconocido se marca en rojo en el texto. |
| 14 | **Imágenes enormes** que inflan el PDF (hoy está en 9,9 MB, bajo el límite de 10). | Al subir, se convierten a JPEG de hasta 2000 px. El editor muestra el peso del PDF y avisa sobre 10 MB. |
| 15 | **Borrar una imagen que está en uso.** | Cada imagen muestra dónde se usa. No se puede borrar si está en uso. |
| 16 | **Nombres de archivo peligrosos** (`../`, espacios, tildes) o archivos que no son imagen. | El servidor limpia el nombre, solo acepta JPG, PNG y WebP comprobando el contenido real, y escribe solo dentro de `imagenes/`. |
| 17 | **Imágenes subidas por la investigadora con rostros de participantes.** | La carpeta es local y el servidor no la expone fuera del computador. Recordatorio visible: el consentimiento cubre el uso en la memoria, no la difusión. |

## 4. Seguridad del servidor local

| # | Riesgo | Decisión |
|---|---|---|
| 18 | Que el servidor quede abierto a la red del lugar. | Escucha solo en `127.0.0.1`. |
| 19 | Que una ruta permita leer o escribir fuera del proyecto. | Lista cerrada de carpetas. Toda ruta se resuelve y se comprueba que quede dentro. |
| 20 | Que se pueda ejecutar cualquier comando. | El servidor solo llama a `typst` con argumentos fijos. No hay ejecución de texto del usuario. |

## 5. Lo que no puede hacer (y se dice)

- Las reglas que son lógica, como «dónde cortar la columna para equilibrar», se pueden
  prender, apagar y ajustar por umbral, pero no rediseñar desde el panel.
- El texto se edita en el editor, pero no es un procesador de texto: es Markdown con una
  vista previa. Para escribir largo sigue siendo mejor un editor de texto.
- El límite de 20.000 palabras no se puede forzar desde el diseño: el editor lo muestra en
  vivo para que no se pase sin darse cuenta.

## 6. UX

- Panel de edición **a la izquierda**, vista al centro, miniaturas abajo. Lo que estás
  cambiando está siempre a la vista junto a su efecto.
- Cada control muestra su valor y su unidad, el valor por defecto, y se puede restaurar
  con un clic.
- Estado siempre visible: *guardado · compilando · error*, con la hora.
- Atajos: ← → páginas, ⌘S guardar, ⌘Z deshacer.
- Mismo lenguaje visual del estudio de Instagram: oscuro, mono, verde como único acento.
