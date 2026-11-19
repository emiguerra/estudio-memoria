// ===========================================================================
// rastro.typ — SISTEMA EDITORIAL (horizontal · digital · blanco/negro + verde)
// InDesign en código:
//   TOKENS · ESTILOS CARÁCTER (c-*) · ESTILOS PÁRRAFO (p-*)
//   PERMANENTES (encabezado/folio, modo claro y oscuro) · FIGURA · PORTADILLA
// Alternancia: portadillas en NEGRO, contenido en BLANCO. Verde en ambos.
// ===========================================================================

// --- COLOR ---------------------------------------------------------------
#import "reglas.typ": R, RP
#let blanco  = rgb(R.color.papel)   // fondo claro
#let negro   = rgb(R.color.negro)   // fondo oscuro / texto en claro
#let verde   = rgb(R.color.verde)   // acento único
#let lima    = rgb(R.color.lima)   // verde de la app rastro (--verde): resaltado h3
#let verdeT  = rgb(R.color.verde_texto)   // verde para texto chico sobre blanco
#let tintaC  = rgb(R.color.tinta_clara)   // texto sobre blanco
#let tintaO  = rgb(R.color.tinta_oscura)   // texto sobre negro
#let tenueC  = rgb(R.color.tenue_claro)   // secundario sobre blanco
#let tenueO  = rgb(R.color.tenue_oscuro)   // secundario sobre negro
#let lineaC  = rgb("#D8D3C6")
#let lineaO  = rgb("#34342C")
#let cajaC   = rgb("#EFEDE4")
#let cajaO   = rgb("#1E1E1A")

// --- FUENTES -------------------------------------------------------------
// Nekst Mono es de pago (sin fuente gratuita legítima) — se usa Martian Mono
// como alternativa libre (OFL), variable, misma familia para permanentes
// (peso regular/medium) y títulos (peso bold/black, "variable diferente").
// Cuerpo de texto: JetBrains Mono, libre, variable, lectura continua estilo
// monospace con hartos pesos disponibles.
#let f-display = R.tipografia.fuente_titulos
#let f-cuerpo  = R.tipografia.fuente_cuerpo
#let f-mono    = R.tipografia.fuente_titulos

// --- GRILLA (todo deriva de u=10pt y línea base=30pt) --------------------
#let u    = 10pt
#let base = RP("tipografia", "linea_base")                 // línea base: rige el ritmo vertical
#let PG   = (ancho: 1920pt, alto: 1080pt)
// texto en los 4 módulos centrales (2–5): aire en los módulos 1 y 6
#let MG   = (sup: 90pt, inf: RP("pagina", "margen_inf"), izq: RP("pagina", "margen_lat"), der: RP("pagina", "margen_lat"))
// páginas de TEXTO: todas parten en la misma línea, más abajo (haya título o no)
#let MG-TEXTO = (sup: RP("pagina", "margen_sup_texto"))
#let GUT  = 20pt                 // gutter = 2u
#let MED  = RP("pagina", "medianil")                 // medianil entre columnas de texto (más ancho que GUT para separar las columnas)
#let MOD  = 270pt                // módulo = (1720 - 5·20)/6
#let NCOL = 6
// ancho de n módulos (para figuras/leyendas por módulo)
#let w(n) = n * MOD + (n - 1) * GUT

// --- METADATOS DE EXPEDIENTE (códigos permanentes) -----------------------
#let EXP = (vol: "VOL 01", fecha: "11.2026", obra: "RASTRO", doc: "MEMORIA DE TÍTULO",
            autor: "EMILIA GUERRA", edicion: "2-2026")

// --- ESCALA (ligada a la línea base; saltos por proporción ~1.5) ---------
#let T = (
  cuerpo: RP("tipografia", "cuerpo"), cita: RP("tipografia", "cuerpo"),
  h1-num: 270pt, h1: 68pt, h2: 30pt, h3: RP("tipografia", "titulo_h3"),
  pull: 44pt, etiqueta: 15pt, figcap: RP("tipografia", "pie"), folio: 15pt,
)

// estado de modo (para color de permanentes)
#let modo = state("modo", "claro")
#let seccion-actual = state("seccion", "")

// ===========================================================================
// ESTILOS DE CARÁCTER (c-*)
// ===========================================================================
#let c-etiqueta(it, color: verdeT) = text(font: f-mono, weight: 500, size: T.etiqueta,
                                          fill: color, tracking: 0.14em)[#upper(it)]
#let c-cita(it) = text(font: f-cuerpo, style: "italic")[#it]

// ===========================================================================
// ESTILOS DE PÁRRAFO (p-*)
// ===========================================================================
#let p-cuerpo(it) = {
  // 20/30: leading para que el avance de línea caiga en la base de 30pt
  set text(font: f-cuerpo, size: T.cuerpo)
  set par(justify: false, leading: 11pt, spacing: base, first-line-indent: 0pt)
  it
}

// ESTILO DE TEXTO 1 — "texto plano": se aplica cuando NO hay diagrama/figura
// acompañando en la página. Dos columnas de 1 módulo c/u, módulos 1–2 y 3–4,
// línea 4 a línea 30 (ocupan también el módulo 1, normalmente reservado para
// aire/marginalia). Los módulos 5–6 quedan libres a la derecha.
// Coordenadas fijas (en pt, absolutas de página), via place() + dx negativo
// para escapar del margen igual que los permanentes.
#let texto-plano(col1, col2) = {
  let x0a = 100pt; let x1a = 660pt
  let x0b = 680pt; let x1b = 1240pt
  let y0 = 180pt; let y1 = 990pt
  place(top + left, dx: x0a - MG.izq, dy: y0 - MG.sup)[
    #block(width: x1a - x0a, height: y1 - y0)[#p-cuerpo(col1)]
  ]
  place(top + left, dx: x0b - MG.izq, dy: y0 - MG.sup)[
    #block(width: x1b - x0b, height: y1 - y0)[#p-cuerpo(col2)]
  ]
}

// ESTILO DE TEXTO 2 — "texto + figura": se aplica cuando SÍ hay un diagrama
// acompañando. Texto a 2 columnas en módulos 1–4 (870pt), diagrama desde la
// mitad del módulo 4 hasta el margen derecho (715pt), con su pie/referencia
// APA justo debajo. Mismas coordenadas fijas de página vía place() + dx.
#let texto-figura(texto, diagrama, pie: none) = {
  place(top + left, dx: 100pt - MG.izq, dy: 90pt - MG.sup)[
    #block(width: 870pt, height: 885pt)[
      #set par(justify: false, leading: 11pt, spacing: base, first-line-indent: 0pt)
      #set text(font: f-cuerpo, size: T.cuerpo)
      #columns(2, gutter: GUT)[#texto]
    ]
  ]
  place(top + left, dx: 1105pt - MG.izq, dy: 90pt - MG.sup)[
    #box(width: 715pt, height: 810pt)[#diagrama]
  ]
  if pie != none {
    place(top + left, dx: 1105pt - MG.izq, dy: 930pt - MG.sup)[
      #box(width: 715pt, height: 60pt)[
        #text(font: f-mono, weight: 500, size: T.figcap, fill: verdeT)[#pie]
      ]
    ]
  }
}

// bloque de IMAGEN snapeado a la grilla: ocupa n módulos, pie en 1 módulo
#let imagen(ruta: none, modulos: 3, alto: 8, titulo: "", fuente: "Elaboración propia.") = {
  cont-fig.step()
  block(width: w(modulos), breakable: false, spacing: base)[
    #context {
      let osc = modo.get() == "oscuro"
      if ruta == none {
        box(width: 100%, height: alto * base, fill: if osc {cajaO} else {cajaC},
            stroke: 0.8pt + (if osc {lineaO} else {lineaC}))[
          #align(center + horizon)[#c-etiqueta("imagen pendiente · " + str(modulos) + " módulos", color: tenueC)]]
      } else { image(ruta, width: 100%, height: alto * base, fit: "cover") }
    }
    #v(9pt)
    #context {
      let osc = modo.get() == "oscuro"
      text(font: f-mono, weight: 500, size: T.figcap, fill: verdeT)[FIGURA #cont-fig.display("01")]
      h(10pt)
      text(font: f-cuerpo, style: "italic", size: T.figcap, fill: if osc {tintaO} else {tintaC})[#titulo]
      text(font: f-cuerpo, size: T.figcap, fill: if osc {tenueO} else {tenueC})[ #fuente]
    }
  ]
}
// DESTACADO (reemplaza la cita con barra verde). Referente: ficha editorial con
// número grande —«01», «02»— en el display, texto recto (sin cursiva) en el
// display a peso medio y una línea fina de cierre. Sin barra, sin color de acento:
// la jerarquía la da el número y el cambio de familia/peso.
#let cont-dest = counter("destacado")
#let p-cita(it) = {
  cont-dest.step()
  block(width: 100%, above: 40pt, below: 40pt, breakable: false)[
    #context {
      let osc = modo.get() == "oscuro"
      let n = cont-dest.get().first()
      text(font: f-display, weight: 300, size: 96pt, fill: if osc {tintaO} else {tintaC},
           tracking: -0.04em, top-edge: "cap-height", bottom-edge: "baseline")[
        #(if n < 10 { "0" + str(n) } else { str(n) })]
    }
    #v(22pt)
    #set text(font: f-display, weight: 500, size: 19pt, style: "normal")
    #set par(justify: false, leading: 11pt, spacing: 18pt)
    #show emph: set text(style: "normal")
    #show strong: it => text(weight: 800, upper(it.body))
    #it
    #v(-6pt)
    #context line(length: 100%, stroke: 0.7pt + (if modo.get() == "oscuro" {lineaO} else {tintaC}))
  ]
}
#let pull(it) = block(width: 100%, spacing: 1.3em, breakable: false)[
  #set par(leading: 0.32em, justify: false)
  #text(font: f-display, weight: 700, size: T.pull, hyphenate: false)[#it]
]

// subtítulos — costos en múltiplos de la línea base (60 arriba / 30 abajo · 30 arriba)
// cada tópico (h2) parte en página nueva — nunca queda pegado al que lo
// precede aunque sobre espacio — y sus títulos van en mayúscula. Se ancla
// con scope: "parent" para que ocupe el ancho completo de la página (no
// solo la columna 1): así el párrafo en ambas columnas arranca a la misma
// altura, debajo del título, en vez de que la columna 2 empiece más arriba.
// Título grande: mismo tratamiento que h3 —texto negro sobre franja lima rastro—.
#let h2(it) = place(top, scope: "parent", float: true)[
  #block(width: 100%, above: 60pt, below: 36pt, breakable: false)[
    #set par(justify: false, leading: 24pt)
    #highlight(fill: lima, top-edge: "ascender", bottom-edge: "descender", extent: 4pt)[
      #text(font: f-display, weight: 600, size: T.h2, fill: negro, hyphenate: false)[#upper(it)]
    ]
  ]
]
// h3 — texto negro sobre subrayado lima (referente: resaltado tipo marcador).
// El resaltado se ajusta a cada línea; leading amplio para que las franjas
// de líneas consecutivas no se toquen ni pisen el párrafo.
#let h3(it) = block(above: 30pt, below: 24pt, breakable: false, sticky: true)[
  #set par(justify: false, leading: 20pt)
  #highlight(fill: lima, top-edge: "ascender", bottom-edge: "descender", extent: 3pt)[
    #text(font: f-mono, weight: 600, size: T.h3, fill: negro, tracking: 0.04em)[#upper(it)]
  ]
]

// LEYENDA (caja de referencia) — se adapta a modo
#let leyenda(titulo: "LEYENDA", ..filas) = context {
  let osc = modo.get() == "oscuro"
  block(width: 100%, fill: if osc {cajaO} else {cajaC}, inset: 18pt, radius: 3pt,
        spacing: 1.2em)[
    #c-etiqueta(titulo, color: verde)
    #v(9pt)
    #set text(font: f-mono, size: T.figcap, fill: if osc {tintaO} else {tintaC})
    #stack(spacing: 7pt, ..filas.pos())
  ]
}

// ===========================================================================
// FIGURA — placeholder/imagen + pie numerado (con código FIGURA NN)
// ===========================================================================
#let cont-fig = counter("figura")
#let figura(cuerpo: none, alto: 300pt, titulo: "", fuente: "Elaboración propia.") = {
  cont-fig.step()
  block(width: 100%, spacing: 1.2em)[
    #context {
      let osc = modo.get() == "oscuro"
      if cuerpo == none {
        box(width: 100%, height: alto, fill: if osc {cajaO} else {cajaC},
            stroke: 0.8pt + (if osc {lineaO} else {lineaC}))[
          #align(center + horizon)[#c-etiqueta("imagen pendiente", color: tenueC)]
        ]
      } else { cuerpo }
    }
    #v(9pt)
    #context {
      let osc = modo.get() == "oscuro"
      text(font: f-mono, weight: 500, size: T.figcap, fill: verdeT)[FIGURA #cont-fig.display("01")]
      h(10pt)
      text(font: f-cuerpo, style: "italic", size: T.figcap, fill: if osc {tintaO} else {tintaC})[#titulo]
      text(font: f-cuerpo, size: T.figcap, fill: if osc {tenueO} else {tenueC})[ #fuente]
    }
  ]
}

// ===========================================================================
// PERMANENTES — 4 cajas fijas en las esquinas (320×30pt), fuera de la caja
// tipográfica, dentro del margen. Siempre en la misma posición absoluta de
// página; se escapan del área confinada de header/footer con place() + dx
// negativo. margin-izq permite reusar esto en portadilla (margen 100pt).
// ===========================================================================
// una-linea: el contenido no se corta ni se parte; crece hacia la derecha
// desde x0 en una sola línea (nombre de capítulo en el encabezado).
#let permanente(x0, y0, x1, y1, margin-izq: MG.izq, align-h: left, una-linea: false, body) = {
  place(top + left, dx: x0 - margin-izq, dy: y0)[
    #if una-linea {
      box(height: y1 - y0)[#align(horizon + align-h)[#box[#body]]]
    } else {
      box(width: x1 - x0, height: y1 - y0, clip: true)[
        #align(horizon + align-h)[#body]
      ]
    }
  ]
}

#let encabezado(margin-izq: MG.izq) = context {
  let osc = modo.get() == "oscuro"
  let sec = if osc {tenueO} else {tenueC}
  permanente(50pt, 30pt, 370pt, 60pt, margin-izq: margin-izq, una-linea: true)[
    #c-etiqueta(seccion-actual.get(), color: sec)
  ]
  permanente(1550pt, 30pt, 1870pt, 60pt, margin-izq: margin-izq, align-h: right)[
    #c-etiqueta(EXP.obra, color: sec)
  ]
}

#let folio(margin-izq: MG.izq) = context {
  let osc = modo.get() == "oscuro"
  let sec = if osc {tenueO} else {tenueC}
  let n = counter(page).get().first()
  let tot = counter(page).final().first()
  // dy relativo a la base del footer: borde superior del footer = PG.alto - MG.inf
  permanente(50pt, 1020pt - (PG.alto - MG.inf), 370pt, 1050pt - (PG.alto - MG.inf),
             margin-izq: margin-izq)[
    #c-etiqueta(EXP.autor, color: sec)
  ]
  permanente(1550pt, 1020pt - (PG.alto - MG.inf), 1870pt, 1050pt - (PG.alto - MG.inf),
             margin-izq: margin-izq, align-h: right)[
    #c-etiqueta(EXP.edicion, color: sec)
  ]
}

// folio lateral — número de página, en el borde derecho, centrado
// verticalmente (no junto al resto de permanentes del footer). Va en el
// fondo de página (background), que cubre la página completa (no el área
// confinada por el margen como header/footer/body) — por eso dx/dy van en
// coordenadas absolutas de página, sin restar margen.
#let folio-lateral() = context {
  let osc = modo.get() == "oscuro"
  let sec = if osc {tenueO} else {tenueC}
  let n = counter(page).get().first()
  place(top + left, dx: 1820pt, dy: 480pt)[
    #box(width: 50pt, height: 60pt, clip: true)[
      #align(center + horizon)[
        #c-etiqueta(str(n), color: sec)
      ]
    ]
  ]
}

// ===========================================================================
// PLANTILLA — página clara por defecto
// ===========================================================================
// citas APA: mismo tratamiento que los títulos (franja lima, texto negro)
#let c-cita-apa(it) = highlight(fill: lima, top-edge: "ascender", bottom-edge: "descender", extent: 2pt,
                                text(weight: 600, fill: negro, it))

#let conf(doc) = {
  set page(
    width: PG.ancho, height: PG.alto,
    margin: (top: MG-TEXTO.sup, bottom: MG.inf, left: MG.izq, right: MG.der),
    fill: blanco, header: encabezado(), header-ascent: 0pt,
    footer: folio(), footer-descent: 0pt,
    background: folio-lateral(),
  )
  // sin partición de palabras: si no cabe en la línea, pasa entera a la siguiente
  set text(font: f-cuerpo, size: T.cuerpo, fill: tintaC, lang: "es", hyphenate: false)
  set par(justify: false, leading: RP("tipografia", "interlineado"), spacing: base)  // avance 30pt, gap 1 línea base
  set table(stroke: 0.7pt + lineaC, inset: 10pt)
  show strong: set text(weight: 600)
  // citas APA en negrita: parentéticas «(Autor, 2024)», «(Autor et al., 2019; Otro, 2018)»,
  // «(AWS, s. f.)», y narrativas «Autor (2019)», «Autor y Otro (2018)», «Autor et al. (2020)»
  show regex("\([^()]*\p{L}[^()]*,\s*(?:\d{4}[a-z]?(?:/\d{4})?|s\.\s?f\.)[^()]*\)"): it => if R.texto.citas_destacadas { c-cita-apa(it) } else { it }
  show regex("\p{Lu}[\p{L}'’-]+(?:\s(?:et al\.|(?:y|e|&)\s\p{Lu}[\p{L}'’-]+))?\s\((?:\d{4}[a-z]?(?:/\d{4})?|s\.\s?f\.)(?:;\s?\d{4})?(?:,\s*pp?\.\s*[\d–-]+)?\)"): it => if R.texto.citas_destacadas { c-cita-apa(it) } else { it }
  show link: set text(fill: verdeT)
  show raw: set text(font: f-mono, size: T.cuerpo - 3pt)
  // reglas para texto que viene de markdown (cmarker)
  show heading.where(level: 1): it => none   // los títulos de sección van en portadilla
  // cada tópico (h2) parte en página nueva — nunca queda pegado al anterior
  show heading.where(level: 2): it => h2(it.body)
  show heading.where(level: 3): it => h3(it.body)
  show heading.where(level: 4): it => h3(it.body)
  show quote.where(block: true): it => p-cita(it.body)
  doc
}

// --- MOTIVO GRÁFICO — portadilla de capítulo ------------------------------
// Insumo gráfico tomado del lenguaje visual de los diagramas de
// estudio-diagramas.html y del referente de cajas-collage: marcos vacíos
// (misma lógica que las cajas de imagen del referente), pixeles decorativos
// sueltos, línea punteada con nodo (anotaciones tipo anatomiaExpediente) y
// asterisco firma. Composición fija, no depende de que el diagrama de cada
// sección esté terminado — es el mismo insumo en las 12 secciones.
#let motivo-diagrama(width: 1450pt, height: 260pt) = {
  box(width: width, height: height)[
    // marcos vacíos — misma lógica compositiva que las cajas de imagen del referente
    #place(top + left, dx: 0pt, dy: 10pt)[
      #rect(width: 150pt, height: 190pt, stroke: 1pt + verde, fill: none)
    ]
    #place(top + left, dx: 205pt, dy: 76pt)[
      #rect(width: 100pt, height: 120pt, stroke: 1pt + verde, fill: none)
    ]
    #place(top + left, dx: width - 180pt, dy: 0pt)[
      #rect(width: 180pt, height: 140pt, stroke: 1pt + verde, fill: none)
    ]
    // pixeles decorativos
    #for (px, py) in ((380pt, 24pt), (width - 210pt, 162pt), (160pt, 224pt), (width - 4pt, 162pt)) {
      place(top + left, dx: px, dy: py)[#rect(width: 8pt, height: 8pt, fill: verde, stroke: none)]
    }
    // línea punteada + nodo — conecta dos de los marcos
    #place(top + left, dx: 150pt, dy: 100pt)[
      #line(length: 55pt, stroke: (paint: verde, thickness: 0.8pt, dash: "dashed"))
    ]
    #place(top + left, dx: 310pt, dy: 100pt)[
      #line(length: 55pt, stroke: (paint: verde, thickness: 0.8pt, dash: "dashed"))
    ]
    #place(top + left, dx: 205pt, dy: 96pt)[#circle(radius: 2.5pt, fill: verde, stroke: none)]
    #place(top + left, dx: 305pt, dy: 96pt)[#circle(radius: 2.5pt, fill: verde, stroke: none)]
    // asterisco firma
    #place(top + left, dx: width / 2 + 40pt, dy: 150pt)[
      #text(font: f-display, size: 46pt, fill: verde)[\*]
    ]
  ]
}

// --- PORTADILLA en NEGRO (página oscura local) ---------------------------
// `arte`: ruta a la portadilla exportada (1920×1080, a sangre). Va en el
// background, debajo de los permanentes (encabezado, pie, folio lateral),
// que se mantienen en sus coordenadas absolutas del JSON. El título ya viene
// dibujado en el arte, así que no se compone texto encima.
#let portadilla(num: "", codigo: "", titulo: "", bajada: "", arte: none, etiqueta: none) = {
  page(fill: negro,
       margin: (left: 100pt, right: 100pt, top: 90pt, bottom: 90pt),
       header: { modo.update("oscuro"); seccion-actual.update(upper(num) + " " + titulo); encabezado(margin-izq: 100pt) },
       header-ascent: 0pt,
       footer: folio(margin-izq: 100pt),
       footer-descent: 0pt,
       background: {
         if arte != none {
           place(top + left, image(arte, width: PG.ancho, height: PG.alto, fit: "cover"))
         }
         folio-lateral()
       })[
    #modo.update("oscuro")
    #if etiqueta != none [#metadata(titulo)#label(etiqueta)]
    #if bajada != "" and arte != none {
      place(top + left, dx: 0pt, dy: 700pt)[
        #block(width: 980pt)[
          #set par(justify: false, leading: 12pt)
          #text(font: f-cuerpo, size: 22pt, fill: tintaO)[#bajada]
        ]
      ]
    }
    #set text(fill: tintaO)
    #if arte == none {
      place(top + left, dx: 135pt, dy: 50pt)[
        #motivo-diagrama()
      ]
      place(top + left, dx: 135pt, dy: 330pt)[
        #block(width: 1450pt, height: 210pt)[
          #align(horizon)[
            #text(font: f-display, weight: 400, size: T.h1, fill: tintaO, hyphenate: false)[#upper(titulo)]
          ]
        ]
      ]
    }
  ]
  modo.update("claro")
}

// --- página de CONTENIDO en NEGRO (variante oscura puntual) --------------
// El blanco era el estado intermedio; algunas páginas de contenido también
// deben poder ir en negro. Misma grilla/margen que conf(), pero fondo negro,
// texto claro y permanentes en su variante oscura (via modo.update).
#let pagina-oscura(body) = {
  page(fill: negro,
       margin: (top: MG.sup, bottom: MG.inf, left: MG.izq, right: MG.der),
       header: { modo.update("oscuro"); encabezado() },
       header-ascent: 0pt,
       footer: folio(),
       footer-descent: 0pt,
       background: folio-lateral())[
    #modo.update("oscuro")
    #set text(fill: tintaO)
    #set table(stroke: 0.7pt + lineaO)
    #body
  ]
  modo.update("claro")
}
