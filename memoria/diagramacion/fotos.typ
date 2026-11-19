// ===========================================================================
// fotos.typ — LÁMINAS FOTOGRÁFICAS DE LA SESIÓN DEL 16 NOV 2026
// Material: «seleccion memoria - blanco y negro» (disco disenoUdp) → fotos-sesion/
// Páginas oscuras: el blanco y negro sobre negro, pie APA abajo.
// Composición por cantidad de fotos:
//   1 → una grande · 2 → par · 3 → grande + dos apiladas · 4 → grande + tres
//   5 → grande + cuatro en grilla
// Uso desde el markdown: <!-- fig:foto-ID -->
// ===========================================================================
#import "rastro.typ": *
#import "reglas.typ": R
#import "identidad.typ": rotulo, dato, en, pie-lamina, pagina-lamina, X0, ANCHO

#let F = "/diagramacion/fotos-sesion/"
#let FUENTE-F = "Registro fotográfico de la sesión de revelación, 16 de noviembre de 2026. Elaboración propia."

// --- VENTANA: marco tipo visor de macOS (barra gris, tres botones, nombre del
// archivo centrado con su flecha, borde fino). `h` es el alto TOTAL del marco.
#let BARRA = 34pt
#let ventana(w, h, nombre, imagen, ajuste: "cover") = box(width: w, height: h,
    radius: (top: 10pt, bottom: 3pt), clip: true, stroke: 1pt + rgb("#B4B4B4"), fill: white)[
  #box(width: w, height: BARRA, fill: gradient.linear(rgb("#EDEDED"), rgb("#DCDCDC"), angle: 90deg))[
    #place(left + horizon, dx: 14pt)[
      #stack(dir: ltr, spacing: 8pt,
        ..range(3).map(_ => circle(radius: 6.5pt, fill: rgb("#D4D4D4"), stroke: 0.8pt + rgb("#BEBEBE"))))
    ]
    #align(center + horizon)[
      #text(font: "Inter Tight", weight: 600, size: 14pt, fill: rgb("#2A2A2A"))[#nombre]
      #box(width: 5pt)#text(font: "Inter Tight", size: 11pt, fill: rgb("#8A8A8A"))[⌄]
    ]
  ]
  #place(top + left, dy: BARRA - 1pt, line(length: w, stroke: 1pt + rgb("#C2C2C2")))
  #place(top + left, dy: BARRA)[#box(width: w, height: h - BARRA, clip: true)[
    #image(imagen, width: 100%, height: 100%, fit: ajuste)]]
]

// archivo sin extensión → foto del testeo (fotos-sesion/IMG_xxxx.jpg);
// con extensión → imagen del repositorio (imagenes/archivo.ext)
#let ruta-foto(archivo) = if archivo.contains(".") { ("/diagramacion/imagenes/" + archivo, archivo) } else { (F + archivo + ".jpg", archivo + ".jpg") }
#let foto(x, y, w, h, archivo, cap) = {
  let (src, nombre) = ruta-foto(archivo)
  en(x, y, w, h)[#if R.figuras.marco_ventana { ventana(w, h, nombre, src) } else { box(width: w, height: h, clip: true)[#image(src, width: 100%, height: 100%, fit: "cover")] }]
  if cap != none {
    en(x, y + h + 10pt, w, 24pt)[#text(font: f-mono, weight: 500, size: 12.5pt, fill: tenueO, tracking: 0.06em)[#upper(cap)]]
  }
}

#let lam-fotos(rot, fotos, tit, fuente: FUENTE-F) = pagina-lamina(osc: true, {
  en(X0, 100pt, ANCHO, 30pt)[#align(right)[#rotulo(rot, color: tintaO)]]
  let y = 150pt
  let H = 690pt            // alto útil para fotos (deja aire a los pies)
  let g = 20pt
  let n = fotos.len()
  if n == 1 {
    let (a, c) = fotos.at(0)
    let w = H * 3 / 2
    foto(X0 + (ANCHO - w) / 2, y, w, H, a, c)
  } else if n == 2 {
    let w = (ANCHO - g) / 2
    for (i, (a, c)) in fotos.enumerate() { foto(X0 + i * (w + g), y + 60pt, w, w * 2 / 3, a, c) }
  } else {
    // grande a la izquierda, el resto a la derecha
    let wg = 1080pt
    let wr = ANCHO - wg - g
    let (a, c) = fotos.at(0)
    foto(X0, y, wg, H, a, c)
    let resto = fotos.slice(1)
    let m = resto.len()
    if m <= 3 {
      let hr = (H - (m - 1) * (g + 24pt)) / m
      for (i, (a, c)) in resto.enumerate() { foto(X0 + wg + g, y + i * (hr + g + 24pt), wr, hr, a, c) }
    } else {
      let w2 = (wr - g) / 2
      let h2 = (H - g - 24pt) / 2
      for (i, (a, c)) in resto.enumerate() {
        foto(X0 + wg + g + calc.rem(i, 2) * (w2 + g), y + calc.floor(i / 2) * (h2 + g + 24pt), w2, h2, a, c)
      }
    }
  }
  pie-lamina(tit, fuente, osc: true)
})
// composición libre desde el repositorio: archivos con extensión, sin rótulos
#let lam-fotos-rutas(archivos, tit, fuente) = lam-fotos("", archivos.map(a => (a, none)), tit, fuente: fuente)

// --- catálogo ----------------------------------------------------------------
#let LAMINAS-FOTO = (
  // §4.3 · el expediente como objeto
  "foto-expedientes": ("Los expedientes", (
      ("IMG_1398", "expediente térmico: rostro, mapa de movimientos, línea de tiempo"),
      ("IMG_1407", "la mesa antes de la sesión"),
      ("IMG_1376", "cada tira en su sobre"),
      ("IMG_1379", none), ("IMG_1382", none)),
    "Los expedientes impresos en papel térmico, uno por participante, antes de entregarse"),
  // §7.7 · el panel
  "foto-panel": ("El panel de rastro", (
      ("IMG_1354", "el panel en la ficha de un participante, junto a la claqueta"),
      ("IMG_1226", "la investigadora opera la sesión desde el panel"),
      ("IMG_1240", "estación: monitor vertical, computador e iPad escáner"),
      ("IMG_1314", "operación y entrevista en paralelo")),
    "El panel de rastro en la sesión: desde un solo computador se operaba toda la revelación"),
  // §7.7 · escáner y monitor
  "foto-escaner": ("Escáner y monitor", (
      ("IMG_1414", "el iPad reconoce el rostro"),
      ("IMG_1260", "el escáner en su soporte"),
      ("IMG_1287", "la identidad confirmada aparece en el monitor"),
      ("IMG_1281", "el monitor muestra la galería de la persona")),
    "El escáner en iPad y el monitor: reconocimiento local, confirmación humana y proyección"),
  // §7.7 · impresión
  "foto-impresion": ("La impresora térmica", (
      ("IMG_1365", "el expediente sale de la Sewoo SLK-TS400"),
      ("IMG_1367", none)),
    "La impresión del expediente: el papel avanza frente a la persona"),
  // §10.8 · la medición
  "foto-medicion": ("La medición", (
      ("IMG_1283", "post-encuesta después del desengaño"),
      ("IMG_1256", "MAIA y escala de 0 a 10"),
      ("IMG_1246", "la conductora acompaña sin intervenir"),
      ("IMG_1391", "instrumentos: MAIA y pauta de observación"),
      ("IMG_1258", "la pantalla de la participante durante la revelación")),
    "Los instrumentos de medición aplicados en la sesión"),
  // §10.8 · entrevista y registro
  "foto-entrevista": ("Entrevista y registro", (
      ("IMG_1327", "entrevista uno a uno"),
      ("IMG_1239", "claqueta: cada sesión queda registrada"),
      ("IMG_1308", "la escucha después del expediente"),
      ("IMG_1341", "la cámara de registro"),
      ("IMG_1223", "la sala")),
    "La entrevista posterior al desengaño y su registro audiovisual"),
  // §10.8 · Mon
  "foto-mon": ("Expediente 07 · Mon", (
      ("IMG_1393", "el sobre del expediente 07, a nombre de Mon"),),
    "El sobre del expediente de Mon, la única participante que no concedió los permisos que la extracción necesitaba"),
)

#let lamina-foto(id) = {
  let (rot, fotos, tit) = LAMINAS-FOTO.at(id)
  lam-fotos(rot, fotos, tit)
}
