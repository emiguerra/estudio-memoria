// ===========================================================================
// arbol.typ — ÁRBOL DE PROBLEMAS (§3) como lámina legible
// Reemplaza figs-diagramas/arbol.svg: mismo contenido, texto a tamaño de lectura.
// ===========================================================================
#import "rastro.typ": *
#import "identidad.typ": rotulo, dato, en, pie-lamina, pagina-lamina, X0, ANCHO

#let caja(x, y, w, h, etiqueta, texto, destacado: false) = en(x, y, w, h)[
  #box(width: w, height: h, fill: if destacado { rgb("#1b1f0a") } else { cajaO },
       stroke: if destacado { 2pt + lima } else { 1pt + lineaO }, inset: (x: 22pt, y: 18pt))[
    #set par(justify: false, leading: 9pt)
    #text(font: f-mono, weight: 600, size: 13pt, fill: if destacado { lima } else { tenueO }, tracking: 0.12em)[#upper(etiqueta)]
    #v(10pt)
    #text(font: f-mono, weight: 500, size: if destacado { 21pt } else { 19pt }, fill: tintaO, tracking: 0.02em)[#upper(texto)]
  ]
]
#let linea(p0, p1) = place(top + left, line(start: p0, end: p1, stroke: 1.4pt + tenueO))

#let lamina-arbol() = pagina-lamina(osc: true, {
  let w = 470pt
  let g = (ANCHO - 200pt - 3 * w) / 2
  let x0 = X0 + 200pt
  let xs = range(3).map(i => x0 + i * (w + g))
  let ye = 110pt
  let yc = 680pt
  let h = 150pt
  // rótulos de nivel
  for (y, t, c) in ((ye + 60pt, "Efectos", tenueO), (400pt, "Problema", lima), (yc + 60pt, "Causas", tenueO)) {
    en(X0, y, 180pt, 30pt)[#text(font: f-mono, weight: 700, size: 15pt, fill: c, tracking: 0.12em)[#upper(t)]]
  }
  let efectos = ("Resignación informada como respuesta", "Vulneración de la privacidad como derecho", "Sesgo algorítmico sistémico y permanente")
  let causas = ("Arquitecturas diseñadas para operar en la sombra", "Consentimiento inoperante (términos no leídos)", "Ausencia de regulación efectiva")
  // problema central
  let wc = 1080pt
  let xc = x0 + (ANCHO - 200pt - wc) / 2
  let yp = 330pt
  let hp = 250pt
  // conectores
  for x in xs {
    let cx = x + w / 2
    linea((cx, ye + h), (cx, ye + h + 40pt))
    linea((cx, yc - 40pt), (cx, yc))
  }
  linea((xs.at(0) + w / 2, ye + h + 40pt), (xs.at(2) + w / 2, ye + h + 40pt))
  linea((xs.at(0) + w / 2, yc - 40pt), (xs.at(2) + w / 2, yc - 40pt))
  linea((x0 + (ANCHO - 200pt) / 2, ye + h + 40pt), (x0 + (ANCHO - 200pt) / 2, yp))
  linea((x0 + (ANCHO - 200pt) / 2, yp + hp), (x0 + (ANCHO - 200pt) / 2, yc - 40pt))
  for (i, t) in efectos.enumerate() { caja(xs.at(i), ye, w, h, "Efecto", t) }
  for (i, t) in causas.enumerate() { caja(xs.at(i), yc, w, h, "Causa", t) }
  caja(xc, yp, wc, hp, "Problema central",
       "La extracción invisible de datos personales crea una asimetría de poder que el usuario no puede percibir. Los sistemas capturan sin consentimiento real, sin rastro visible, sin posibilidad de resistencia informada.",
       destacado: true)
  en(X0 + 200pt, 865pt, ANCHO - 200pt, 30pt)[#align(center)[
    #text(font: f-mono, weight: 600, size: 15pt, fill: lima, tracking: 0.06em)[EL NODO RAÍZ DE #text(style: "italic", weight: 800)[rastro]: OPERAR EN LA SOMBRA HACE IMPOSIBLE EL CONSENTIMIENTO REAL.]]]
  pie-lamina("Árbol de problemas", "Elaboración propia.", osc: true)
})
