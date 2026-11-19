// ===========================================================================
// identidad.typ — LÁMINAS DE IDENTIDAD (§7.2 Logotipo e identidad)
// Formato «brand board»: bandas de color a todo el ancho de la caja, rótulo
// centrado en mono, sin aire entre tiles. Tres láminas:
//   1 · logotipo, versión bitmap, ícono + paleta (dos pieles)
//   2 · tipografía + recursos gráficos
//   3 · aplicaciones (piel rastro / piel camuflaje)
// Caja de la lámina: x 100–1820, y 90–910; pie APA en y 930–990.
// Recursos: identidad-assets.py → diagramacion/identidad/
// ===========================================================================
#import "rastro.typ": *

#let R = "/diagramacion/identidad/"
#let X0 = 100pt
#let ANCHO = 1720pt

// rótulo centrado (equivale a «LOGOTYPE», «COLOR PALETTE» del referente)
#let rotulo(t, color: tintaC) = text(font: f-mono, weight: 700, size: 17pt,
                                      fill: color, tracking: 0.12em)[#upper(t)]
#let dato(t, color: tenueC) = text(font: f-mono, weight: 500, size: 14pt,
                                    fill: color, tracking: 0.06em)[#t]

// caja absoluta de página (coordenadas del JSON de la grilla)
#let en(x, y, w, h, cuerpo) = place(top + left, dx: x, dy: y)[
  #box(width: w, height: h)[#cuerpo]
]

// tile con rótulo arriba y contenido centrado
#let tile(x, y, w, h, fondo, rot, rot-color, cuerpo) = en(x, y, w, h)[
  #box(width: w, height: h, fill: fondo)[
    #place(top + center, dy: 34pt)[#rotulo(rot, color: rot-color)]
    #align(center + horizon)[#cuerpo]
  ]
]

// pie APA con el contador de figuras de la memoria
#let pie-lamina(tit, fuente, osc: false) = en(X0, 930pt, ANCHO, 60pt)[
  #set par(justify: false, leading: 6pt)
  #context {
    let n = cont-fig.get().first()
    text(font: f-mono, weight: 500, size: T.figcap, fill: if osc {lima} else {verdeT},
         tracking: 0.08em)[FIGURA #(if n < 10 { "0" + str(n) } else { str(n) })]
  }
  #linebreak()
  #text(font: f-cuerpo, style: "italic", size: T.figcap, fill: if osc {tintaO} else {tintaC})[#tit.]
  #text(font: f-cuerpo, size: T.figcap, fill: if osc {tenueO} else {tenueC})[ #fuente]
]

// página de lámina: permanentes en su lugar, todo lo demás en el fondo
#let pagina-lamina(osc: false, fondo) = {
  cont-fig.step()
  page(fill: if osc {negro} else {blanco},
       margin: (left: 100pt, right: 100pt, top: 90pt, bottom: 90pt),
       header: { modo.update(if osc {"oscuro"} else {"claro"}); encabezado(margin-izq: 100pt) },
       header-ascent: 0pt,
       footer: folio(margin-izq: 100pt), footer-descent: 0pt,
       background: { fondo; folio-lateral() })[
    #modo.update(if osc {"oscuro"} else {"claro"})
  ]
  modo.update("claro")
}

// --- muestra de color -------------------------------------------------------
#let muestra(x, y, d, c, nombre, hex, borde: false, osc: false) = en(x - 60pt, y, d + 120pt, d + 80pt)[
  #align(center)[
    #circle(radius: d / 2, fill: c, stroke: if borde {0.8pt + tenueC} else {none})
    #v(14pt)
    #text(font: f-cuerpo, size: 15pt, fill: tintaC)[#nombre]
    #v(-4pt)
    #dato(upper(hex))
  ]
]

// ===========================================================================
// LÁMINA 1 · LOGOTIPO Y PALETA
// ===========================================================================
#let lamina-1() = pagina-lamina({
  let tw = ANCHO / 3
  let th = 420pt
  // fila de marcas
  tile(X0, 90pt, tw, th, cajaC, "Logotipo", tintaC)[
    #image(R + "logo-negro.png", width: 62%)
  ]
  en(X0 + tw, 90pt, tw, th)[
    #box(width: tw, height: th, clip: true)[
      #image(R + "bitmap-tile.jpg", width: 100%, height: 100%, fit: "cover")
      #place(top + center, dy: 34pt)[#rotulo("Versión bitmap", color: lima)]
    ]
  ]
  tile(X0 + 2 * tw, 90pt, tw, th, lima, "Ícono de app", negro)[
    #pad(top: 30pt)[
      #box(width: 210pt, height: 210pt, radius: 46pt, clip: true)[
        #image(R + "icono.png", width: 100%, height: 100%)
      ]
    ]
  ]

  // paleta — dos pieles
  en(X0, 552pt, ANCHO, 30pt)[#align(center)[#rotulo("Paleta")]]
  // separador vertical entre grupos
  en(X0 + 1120pt, 610pt, 1pt, 250pt)[#line(angle: 90deg, length: 250pt, stroke: 0.8pt + lineaC)]

  en(X0, 604pt, 1120pt, 24pt)[#align(center)[#dato("PIEL RASTRO · REVELACIÓN, PANEL, EXPEDIENTE, MEMORIA", color: verdeT)]]
  let d = 116pt
  let rev = (
    (negro, "Negro expediente", "#121210", false),
    (blanco, "Papel", "#FBFBF8", true),
    (lima, "Lima rastro", "#C8F31D", false),
    (verde, "Verde señal", "#8FE000", false),
    (tenueC, "Gris tenue", "#8C8A7C", false),
  )
  for (i, (c, n, h, b)) in rev.enumerate() {
    muestra(X0 + 112pt + i * 224pt - d / 2, 650pt, d, c, n, h, borde: b)
  }

  en(X0 + 1120pt, 604pt, 600pt, 24pt)[#align(center)[#dato("PIEL CAMUFLAJE · LA APP")]]
  let cam = (
    (rgb("#000000"), "Negro puro", "#000000", false),
    (rgb("#1A1A1C"), "Superficie", "#1A1A1C", false),
    (rgb("#FFFFFF"), "Blanco", "#FFFFFF", true),
    (rgb("#8E8E93"), "Gris iOS", "#8E8E93", false),
  )
  let d2 = 96pt
  for (i, (c, n, h, b)) in cam.enumerate() {
    muestra(X0 + 1120pt + 75pt + i * 150pt - d2 / 2, 660pt, d2, c, n, h, borde: b)
  }

  pie-lamina("Identidad de rastro: marcas y paleta en sus dos pieles",
             "Elaboración propia a partir de la bitácora del proyecto (1 y 3 nov 2026).")
})

// ===========================================================================
// LÁMINA 2 · TIPOGRAFÍA Y RECURSOS
// ===========================================================================
#let especimen(x, y, w, fuente, peso, nombre, rol, color-aa) = en(x, y, w, 420pt)[
  #set align(center)
  #text(font: fuente, weight: peso, size: 190pt, fill: color-aa)[Aa]
  #v(-4pt)
  #text(font: fuente, weight: 600, size: 22pt, fill: tintaO)[#nombre]
  #v(-2pt)
  #dato(upper(rol), color: lima)
  #v(4pt)
  #block(width: 330pt)[
    #set par(leading: 7pt, justify: false)
    #text(font: fuente, size: 13pt, fill: tenueO)[ABCDEFGHIJKLMNÑOPQRSTUVWXYZ abcdefghijklmnñopqrstuvwxyz 0123456789 ¿?¡!·\#\&\@]
  ]
]

#let lamina-2() = pagina-lamina(osc: true, {
  en(X0, 100pt, ANCHO, 30pt)[#align(center)[#rotulo("Tipografía", color: tintaO)]]
  let cw = ANCHO / 4
  especimen(X0, 150pt, cw, "Martian Mono", 700, "Martian Mono", "Memoria · títulos y permanentes", lima)
  especimen(X0 + cw, 150pt, cw, "JetBrains Mono", 400, "JetBrains Mono", "Memoria · cuerpo de lectura", tintaO)
  especimen(X0 + 2 * cw, 150pt, cw, "Space Mono", 700, "Space Mono", "Convocatoria · bitmap", lima)
  especimen(X0 + 3 * cw, 150pt, cw, "IBM Plex Mono", 500, "IBM Plex Mono", "Panel y proyección", tintaO)

  // recursos gráficos
  let tw = ANCHO / 3
  let y = 540pt
  let th = 360pt
  en(X0, y, tw, th)[
    #box(width: tw, height: th, clip: true)[
      #image(R + "destello.jpg", width: 100%, height: 100%, fit: "cover")
      #place(top + center, dy: 26pt)[
        #box(fill: negro, inset: (x: 10pt, y: 6pt))[#rotulo("Grano y destello", color: lima)]
      ]
    ]
  ]
  en(X0 + tw, y, tw, th)[
    #box(width: tw, height: th, clip: true, fill: negro)[
      // zoom al punto rombo de la versión bitmap
      #place(center + horizon, dx: 40pt)[#image(R + "bitmap.jpg", width: 1500pt)]
      #place(top + center, dy: 26pt)[
        #box(fill: negro, inset: (x: 10pt, y: 6pt))[#rotulo("Punto rombo", color: lima)]
      ]
    ]
  ]
  tile(X0 + 2 * tw, y, tw, th, rgb("#1A1A1C"), "Inter · camuflaje", rgb("#8E8E93"))[
    #pad(top: 30pt)[
      #text(font: "Inter Tight", weight: 800, size: 96pt, fill: white)[Aa]
      #v(-6pt)
      #text(font: "Inter Tight", weight: 500, size: 16pt, fill: rgb("#8E8E93"))[sin verde · sin pixel · sin grano]
    ]
  ]

  pie-lamina("Identidad de rastro: familias tipográficas y recursos gráficos",
             "Elaboración propia a partir de los archivos de diseño del proyecto (oct – nov 2026).", osc: true)
})

// ===========================================================================
// LÁMINA 3 · APLICACIONES
// ===========================================================================
#let pieza(x, y, w, h, ruta, cap) = en(x, y, w, h + 50pt)[
  #box(width: w, height: h, clip: true, stroke: 0.8pt + lineaC)[
    #image(ruta, width: 100%, height: 100%, fit: "cover")
  ]
  #v(10pt)
  #dato(upper(cap))
]

#let lamina-3() = pagina-lamina({
  en(X0, 100pt, ANCHO, 30pt)[#align(center)[#rotulo("Aplicaciones")]]
  let h = 610pt
  let wp = h * 4 / 5          // post 4:5
  let wv = h * 9 / 16         // vertical 9:16
  let g = 24pt
  let gg = 90pt               // aire entre pieles
  let total = wp + 3 * wv + 2 * g + gg
  let x = X0 + (ANCHO - total) / 2
  let y = 200pt
  // piel rastro
  en(x, 156pt, wp + g + wv, 24pt)[#align(center)[#dato("PIEL RASTRO", color: verdeT)]]
  pieza(x, y, wp, h, R + "app-post.jpg", "Convocatoria · post 4:5")
  pieza(x + wp + g, y, wv, h, R + "app-historia.jpg", "Convocatoria · historia")
  // separador
  let xs = x + wp + g + wv + gg / 2
  en(xs, 156pt, 1pt, h + 44pt)[#line(angle: 90deg, length: h + 44pt, stroke: 0.8pt + lineaC)]
  // piel camuflaje
  let x2 = x + wp + g + wv + gg
  en(x2, 156pt, 2 * wv + g, 24pt)[#align(center)[#dato("PIEL CAMUFLAJE")]]
  pieza(x2, y, wv, h, R + "app-feed.jpg", "App · feed")
  pieza(x2 + wv + g, y, wv, h, R + "app-recordatorio.jpg", "Difusión · recordatorio")

  pie-lamina("Identidad de rastro aplicada: la piel del proyecto y la piel de la app",
             "Elaboración propia (oct – nov 2026).")
})

#let laminas-identidad() = { lamina-1(); lamina-2(); lamina-3() }
