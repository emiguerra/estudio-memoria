// ===========================================================================
// laminas.typ — CATÁLOGO DE LÁMINAS: todo lo que se puede llamar desde el texto
// con <!-- fig:ID -->, más imágenes del repositorio (<!-- img:… --> y
// <!-- fotos:… -->). El editor compila cada lámina por separado para mostrarla.
// ===========================================================================
#import "rastro.typ": *
#import "reglas.typ": R, RP
#import "identidad.typ": laminas-identidad
#import "app.typ": lamina-app
#import "fotos.typ": lamina-foto, lam-fotos-rutas, ventana
#import "arbol.typ": lamina-arbol
#import "identidad.typ": pie-lamina, pagina-lamina, en, rotulo, X0, ANCHO
#import "/vendor/cmarker/lib.typ" as cmarker

// --- DIAGRAMAS (exportados de estudio-diagramas.html, modo claro) ----------
// Título y fuente del pie APA. Donde el estudio anotaba una nota de trabajo en
// vez de una fuente (p. ej. «Seminario p.5»), se deja «Elaboración propia.».
#let FIG = (
  "ejes":       ("Los cinco casos organizados en dos ejes", "Elaboración propia."),
  "clearview":  ("Clearview AI: 30.000 millones de imágenes y 3.100 agencias", "Elaboración propia a partir de Autoriteit Persoonsgegevens (2024)."),
  "ambitos":    ("Intersección de los tres ámbitos del marco teórico", "Elaboración propia."),
  "nodos":      ("Tres nodos teóricos", "Elaboración propia."),
  "red":        ("Red del marco teórico y los referentes", "Elaboración propia."),
  "arbol":      ("Árbol de problemas", "Elaboración propia."),
  "encuesta":   ("Resignación informada en la muestra propia (N=49)", "Elaboración propia a partir de encuesta propia (2026)."),
  "anatomia":   ("Anatomía del expediente", "Elaboración propia."),
  "arquitecturas": ("Las tres arquitecturas del proyecto", "Elaboración propia a partir de la bitácora del proyecto."),
  "canal":      ("Prueba de canal: conservación de metadatos por canal de subida", "Elaboración propia a partir de la bitácora del proyecto (10 oct 2026)."),
  "pipeline-metadatos": ("Pipeline de metadatos", "Elaboración propia a partir de la bitácora del proyecto."),
  "timeline-implementacion": ("Implementación en Flutter", "Elaboración propia a partir de la bitácora del proyecto (20 oct – 3 nov 2026)."),
  "evento-vivo": ("El evento de revelación en vivo", "Elaboración propia a partir de la bitácora del proyecto (16 nov 2026)."),
  "hitos":      ("Línea de hitos", "Elaboración propia."),
  "foda":       ("Análisis FODA", "Elaboración propia."),
  "timeline":   ("Fases del estudio", "Elaboración propia."),
  "eva":        ("Reacción corporal (EVA) por participante", "Elaboración propia a partir de hojas de medición (16 nov 2026)."),
  "sorpresa":   ("Mapa de sorpresa del desengaño", "Elaboración propia a partir de la pauta de observación (16 nov 2026)."),
  "emociones":  ("Mapa de lo que sintieron", "Elaboración propia a partir de hojas de medición (16 nov 2026)."),
)

#let md(s) = {
  show regex("\\brastro\\b"): it => if R.texto.rastro_destacado { text(weight: 700, style: "italic")[#it] } else { it }
  cmarker.render(s, smart-punctuation: false)
}
#let cap-actual = state("cap-actual", "")

// --- PÁGINA DE DIAGRAMA: página completa, modo oscuro --------------------
// Diagrama en la caja (100,90)–(1820,900) y pie APA en (100,930)–(1820,990):
// mismos márgenes del JSON, ahora a todo el ancho.
#let pagina-figura(id) = {
  let (tit, fuente) = FIG.at(id)
  cont-fig.step()
  page(fill: negro,
       margin: (left: MG.izq, right: MG.der, top: MG.sup, bottom: MG.inf),
       header: { modo.update("oscuro"); encabezado() },
       footer: folio(),
       background: folio-lateral())[
    #modo.update("oscuro")
    #place(top + left, dx: 100pt - MG.izq, dy: 0pt)[
      #box(width: 1720pt, height: 810pt)[
        #align(center + horizon)[
          #image("/diagramacion/figs-diagramas/" + id + ".svg", width: 100%, height: 100%, fit: "contain")
        ]
      ]
    ]
    #place(top + left, dx: 100pt - MG.izq, dy: 930pt - MG.sup)[
      #box(width: 1720pt, height: 60pt)[
        #set par(justify: false, leading: 6pt)
        #context {
          let n = cont-fig.get().first()
          text(font: f-mono, weight: 500, size: T.figcap, fill: lima, tracking: 0.08em)[FIGURA #(if n < 10 { "0" + str(n) } else { str(n) })]
        }
        #linebreak()
        #text(font: f-cuerpo, style: "italic", size: T.figcap, fill: tintaO)[#tit.]
        #text(font: f-cuerpo, size: T.figcap, fill: tenueO)[ #fuente]
      ]
    ]
  ]
  modo.update("claro")
}


// --- IMAGEN DEL REPOSITORIO (una, a página completa, con pie APA) ------------
// ruta relativa a diagramacion/imagenes/
#let lamina-imagen(ruta, tit, fuente) = pagina-lamina(osc: true, {
  en(X0, 90pt, ANCHO, 800pt)[#align(center + horizon)[
    #image("/diagramacion/imagenes/" + ruta, width: 100%, height: 100%, fit: "contain")]]
  pie-lamina(tit, fuente, osc: true)
})

// --- DESPACHO: id del catálogo → lámina ---------------------------------------
#let lamina-por-id(id) = {
  if id == "arbol" { lamina-arbol() }
  else if id == "identidad" { laminas-identidad() }
  else if id.starts-with("app-") { lamina-app(id) }
  else if id.starts-with("foto-") { lamina-foto(id) }
  else if id in FIG { pagina-figura(id) }
}
