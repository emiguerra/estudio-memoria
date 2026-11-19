// MEMORIA COMPLETA paginada en la grilla (portadilla + cuerpo a 2 columnas).
// El cuerpo viene de limpias/*.md vía cmarker. Flujo:
// · cada título grande (##) abre página y ocupa el ancho completo;
// · el texto corre a 2 columnas (medianil MED);
// · las TABLAS ocupan el ancho completo de la caja (nunca dentro de una columna,
//   donde se apretaban y el texto de las celdas se montaba);
// · cada DIAGRAMA (`<!-- fig:ID -->`) va en su propia página completa, en modo
//   oscuro, con su pie APA.
// Compilar: typst compile memoria.typ "pag-{p}.png" --font-path fonts --root ..
#import "rastro.typ": *
#import "reglas.typ": R, RP
#import "identidad.typ": laminas-identidad
#import "app.typ": lamina-app
#import "fotos.typ": lamina-foto
#import "arbol.typ": lamina-arbol
#import "/vendor/cmarker/lib.typ" as cmarker
#show: conf

#let secs = (
  ("01", "Introducción", "01-introduccion.md"),
  ("02", "Marco teórico", "02-marco-teorico.md"),
  ("02b", "El expediente en América Latina", "02b-expediente-america-latina.md"),
  ("03", "Fundamentación y problemática", "03-fundamentacion-problematica.md"),
  ("04", "Descripción del proyecto", "04-descripcion-proyecto.md"),
  ("05", "Objetivos del proyecto", "05-objetivos.md"),
  ("06", "Área de intervención", "06-area-intervencion.md"),
  ("07", "Proceso de diseño", "07-proceso-diseno.md"),
  ("08", "Gestión estratégica", "08-gestion-estrategica.md"),
  ("09", "Referentes", "09-referentes.md"),
  ("10", "Metodología", "10-metodologia.md"),
  ("11", "Referencias", "11-referencias.md"),
)

#import "laminas.typ": *

// --- FLUJO DE TEXTO (continuo) ------------------------------------------------
// Todo el texto de un tramo (entre láminas) corre en UN flujo a dos columnas:
// · los títulos ## van dentro de la columna, pegados a su texto (sticky), sin
//   abrir página → no quedan páginas a medio llenar a mitad de capítulo;
// · las tablas van dentro de la columna, al costado del texto;
// · la ÚLTIMA página de cada tramo se equilibra: se lee (de la pasada anterior de
//   maquetación) qué piezas cayeron en esa página y se corta la columna a la
//   mitad de su alto, con colbreak. Las páginas anteriores no se tocan, así que
//   la decisión es estable entre pasadas.
#let ALTO-COL = PG.alto - MG-TEXTO.sup - MG.inf
#let ANCHO-COL = (PG.ancho - MG.izq - MG.der - MED) / 2

#let h2-col(t, num) = block(width: 100%, above: 54pt, below: 30pt, breakable: false, sticky: true)[
  #metadata(t)#label("idx:" + t + "@" + num)
  #set par(justify: false, leading: 18pt)
  #highlight(fill: lima, top-edge: "ascender", bottom-edge: "descender", extent: 4pt)[
    #text(font: f-display, weight: 600, size: RP("tipografia", "titulo_h2"), fill: negro, hyphenate: false)[#upper(t)]
  ]
]

// Trozos del markdown: títulos ##, tablas (con su pie) y bloques de texto
// separados por línea en blanco. Cada trozo es una pieza medible.
#let trozos(s) = {
  let out = ()
  let lineas = s.replace(regex("(?m)^# [^\n]*$"), "").split("\n")
  let buf = ()
  let tabla = ()
  let J(a) = if a.len() == 0 { "" } else { a.join("\n") }
  for l in lineas {
    let t = l.trim()
    if t.starts-with("#") and not t.starts-with("## ") {
      if J(buf).trim() != "" { out.push(("t", J(buf))) }; buf = ()
      if tabla.len() > 0 { out.push(("t", tabla.join("\n"))); tabla = () }
      out.push(("t", t))
    } else if t.starts-with("## ") {
      if J(buf).trim() != "" { out.push(("t", J(buf))) }; buf = ()
      if tabla.len() > 0 { out.push(("t", tabla.join("\n"))); tabla = () }
      out.push(("h2", t.slice(3).trim()))
    } else if t.starts-with("|") or (t.starts-with("*Tabla ") and tabla.len() > 0) {
      if J(buf).trim() != "" { out.push(("t", J(buf))) }; buf = ()
      tabla.push(l)
    } else if t.starts-with("*Tabla ") and out.len() > 0 and out.last().at(1).trim().starts-with("|") and buf.len() == 0 and tabla.len() == 0 {
      let ult = out.pop(); out.push(("t", ult.at(1) + "\n\n" + l))
    } else if t == "" {
      if tabla.len() > 0 { out.push(("t", tabla.join("\n"))); tabla = () }
      if J(buf).trim() != "" { out.push(("t", J(buf))) }; buf = ()
    } else {
      if tabla.len() > 0 { out.push(("t", tabla.join("\n"))); tabla = () }
      buf.push(l)
    }
  }
  if tabla.len() > 0 { out.push(("t", tabla.join("\n"))) }
  if J(buf).trim() != "" { out.push(("t", J(buf))) }
  out
}

#let cont-tramo = counter("tramo")
// Corta un texto markdown en frases (puntos de corte después de . ! ? » : ;).
#let frases(x) = {
  let cortes = x.matches(regex("[.!?»:;] +")).map(m => m.end)
  let out = ()
  let ini = 0
  for c in cortes { out.push(x.slice(ini, c)); ini = c }
  out.push(x.slice(ini))
  out.filter(f => f.trim() != "")
}
#let flujo(s, num: "") = {
  let tz = trozos(s)
  if tz.len() == 0 { return }
  cont-tramo.step()
  context {
    let id = str(cont-tramo.get().first())
    let render(k, x) = if k == "h2" { h2-col(x, num) } else { md(x) }
    let marca(i) = label("pz-" + id + "-" + str(i))
    let fin = label("pz-" + id + "-fin")
    let alto(items) = if items.len() == 0 { 0pt } else {
      measure(block(width: ANCHO-COL)[#for (k, x) in items { render(k, x) }]).height }
    // piezas con su marca: (indice, tipo, texto)
    let A = range(tz.len()).map(i => (i, tz.at(i).at(0), tz.at(i).at(1)))
    let B = ()
    let qf = if R.flujo.equilibrar { query(fin) } else { () }
    if qf.len() > 0 {
      let pf = qf.first().location().page()
      let pos = range(tz.len()).map(i => { let q = query(marca(i)); if q.len() > 0 { q.first().location().position() } else { none } })
      let top = MG-TEXTO.sup
      let mitad = MG.izq + ANCHO-COL + MED / 2
      let f = pos.position(p => p != none and p.page == pf)
      // k: pieza que viene cortada desde la página anterior (si la hay)
      let k = if f == none { tz.len() - 1 } else if pos.at(f).y <= top + 4pt { none } else { f - 1 }
      if k == none {
        // un título al pie de la página anterior baja con su texto
        let es-tit(i) = tz.at(i).at(0) == "h2" or tz.at(i).at(1).trim().starts-with("#")
        let g = if f > 0 and es-tit(f - 1) { f - 1 } else { f }
        A = A.slice(0, g); B = range(g, tz.len()).map(i => (i, tz.at(i).at(0), tz.at(i).at(1)))
      } else if k >= 0 and pos.at(k) != none and pos.at(k).page == pf - 1 {
        let pk = pos.at(k)
        let libre = if pk.x > mitad { ALTO-COL - (pk.y - top) } else { 2 * ALTO-COL - (pk.y - top) }
        let (tk, xk) = tz.at(k)
        let siguientes = range(k + 1, tz.len()).map(i => (i, tz.at(i).at(0), tz.at(i).at(1)))
        let pre = ""
        let resto = xk
        if tk == "t" and not xk.trim().starts-with("|") and not xk.trim().starts-with("-") {
          let fs = frases(xk)
          let JJ(a) = if a.len() == 0 { "" } else { a.join("") }
          let n = 0
          for j in range(1, fs.len()) {
            if measure(block(width: ANCHO-COL, md(JJ(fs.slice(0, j))))).height <= libre - 10pt { n = j } else { break }
          }
          let despues = alto(siguientes.map(((i, q, x)) => (q, x)))
          while n > 0 and measure(block(width: ANCHO-COL, md(JJ(fs.slice(n))))).height + despues < ALTO-COL * R.flujo.minimo_ultima { n -= 1 }
          if n > 0 { pre = JJ(fs.slice(0, n)); resto = JJ(fs.slice(n)) }
        }
        A = A.slice(0, k)
        if pre != "" { A.push((k, tk, pre)) }
        B = if resto.trim() != "" { (((if pre != "" { -1 } else { k }), tk, resto),) + siguientes } else { siguientes }
      }
    }
    let es-titulo(k, x) = k == "h2" or x.trim().starts-with("#")
    let pinta(items) = for (i, k, x) in items {
      if i >= 0 [#metadata(none)#marca(i)]
      render(k, x)
    }
    // un título que abre página (inicio de tramo o de la última página) va a
    // ancho completo: así las dos columnas parten a la altura del párrafo
    let con-cabeza(items) = R.flujo.titulos_ancho_completo and items.len() > 0 and es-titulo(items.first().at(1), items.first().at(2))
    let cabeza(items) = {
      let (i, k, x) = items.first()
      block(width: 100%, above: 0pt, below: 30pt, sticky: true)[#if i >= 0 [#metadata(none)#marca(i)]#render(k, x)]
    }
    show table: set text(size: 14.5pt)
    show table: set par(leading: 7pt)
    set table(inset: (x: 7pt, y: 6pt))
    if A.len() > 0 {
      // títulos que en la pasada anterior cayeron al tope de la columna izquierda:
      // ahí se corta el flujo y el título abre la página a ancho completo
      let corta = (:)
      if qf.len() > 0 {
        for (j, (i, k, x)) in A.enumerate() {
          if j > 0 and i >= 0 and es-titulo(k, x) {
            let q = query(marca(i))
            if q.len() > 0 {
              let p = q.first().location().position()
              if p.y <= MG-TEXTO.sup + 4pt and p.x < MG.izq + ANCHO-COL / 2 { corta.insert(str(j), true) }
            }
          }
        }
      }
      let tramos = ()
      let actual = ()
      for (j, it) in A.enumerate() {
        if corta.at(str(j), default: false) and actual.len() > 0 { tramos.push(actual); actual = () }
        actual.push(it)
      }
      if actual.len() > 0 { tramos.push(actual) }
      for (t, tr) in tramos.enumerate() {
        if t > 0 { pagebreak(weak: true) }
        if con-cabeza(tr) { cabeza(tr) }
        let resto = if con-cabeza(tr) { tr.slice(1) } else { tr }
        if resto.len() > 0 { columns(2, gutter: MED)[#pinta(resto)] }
      }
    }
    // B es la última página: si hubo páginas antes, parte siempre en una nueva
    // (si no, podría subir al hueco que deja A y la decisión oscilaría)
    if A.len() > 0 and B.len() > 0 { pagebreak(weak: true) }
    if B.len() == 1 and B.first().at(2).trim().starts-with("|") {
      let (i, k, x) = B.first()
      [#metadata(none)#marca(i)]
      block(width: 100%)[#md(x)]
    } else if B.len() > 0 {
      let hh = if con-cabeza(B) { let (i, k, x) = B.first(); measure(block(width: 2 * ANCHO-COL + MED, render(k, x))).height + 30pt } else { 0pt }
      let cap = ALTO-COL - hh
      if con-cabeza(B) { cabeza(B) }
      let B2 = if con-cabeza(B) { B.slice(1) } else { B }
      let hB = alto(B2.map(((i, k, x)) => (k, x)))
      if hB / 2 + 2 * base > cap {
        columns(2, gutter: MED)[#pinta(B2)]
      } else if B2.len() > 0 {
        // última página: bloque de alto justo → las columnas se reparten por líneas
        block(width: 100%, height: hB / 2 + 2 * base, breakable: false)[
          #columns(2, gutter: MED)[#pinta(B2)]
        ]
      }
    }
    [#metadata(none)#fin]
  }
}

// Parte un archivo por marcadores de diagrama. Si el marcador viene justo
// después de un título, el diagrama va ANTES del título (el título nunca queda
// huérfano al pie de una página).
// --- TABLAS como lámina (norma APA: número y título arriba, nota abajo) -------
#let cont-tabla = counter("tabla-apa")
#let TITULOS-TABLA = (
  "Dato": ("Resultados de la encuesta propia (N=49)", "Elaboración propia a partir de encuesta propia (2026)."),
  "Hito": ("Plan operativo y de hitos", "Elaboración propia."),
  "Riesgo": ("Riesgos y mitigaciones aplicadas", "Elaboración propia a partir de la bitácora del proyecto."),
  "Enfoque": ("Integración de métodos mixtos en el proyecto", "Elaboración propia a partir de Fetters et al. (2013)."),
  "Eje": ("Criterios de decisión fijados antes del test", "Elaboración propia."),
)
#let pagina-tabla(filas, titulo, nota) = {
  cont-tabla.step()
  page(margin: (top: MG-TEXTO.sup, bottom: MG.inf, left: 240pt, right: 240pt))[
    #context {
      let n = cont-tabla.get().first()
      text(font: f-mono, weight: 700, size: T.figcap + 2pt, fill: verdeT, tracking: 0.08em)[TABLA #(if n < 10 { "0" + str(n) } else { str(n) })]
    }
    #v(4pt)
    #text(font: f-cuerpo, style: "italic", size: 22pt, fill: tintaC)[#titulo]
    #v(18pt)
    #set text(size: RP("tipografia", "tabla"))
    #set par(leading: 10pt)
    #set table(inset: (x: 16pt, y: 12pt), stroke: 0.8pt + lineaC)
    #md(filas)
    #v(12pt)
    #text(font: f-cuerpo, size: T.figcap, fill: tenueC)[#emph[Nota.] #nota]
  ]
}
#let datos-tabla(bloque) = {
  let ls = bloque.split("\n")
  let filas = ls.filter(l => l.trim().starts-with("|")).join("\n")
  let pl = ls.filter(l => not l.trim().starts-with("|"))
  let pie = if pl.len() == 0 { "" } else { pl.join(" ").trim() }
  let (titulo, nota) = ("", "Elaboración propia.")
  if pie != "" {
    let t = pie.replace(regex("^\*|\*$"), "").replace(regex("^Tabla \d+\.\s*"), "")
    let m = t.match(regex("\s(Elaboración|Fuente)[^.]*\.?\s*$"))
    if m != none { titulo = t.slice(0, m.start).trim().trim("."); nota = t.slice(m.start).trim() } else { titulo = t.trim(".") }
  } else {
    let cab = filas.split("\n").first().split("|").at(1).trim()
    let (t0, n0) = TITULOS-TABLA.at(cab, default: ("Tabla", "Elaboración propia."))
    titulo = t0; nota = n0
  }
  (filas, titulo, nota)
}

// --- PÁGINA CON DIAGRAMA AL COSTADO (texto a la izquierda, figura a la derecha)
#let pagina-lado(texto, id, num) = {
  let (tit, fuente) = FIG.at(id)
  cont-fig.step()
  page(fill: negro,
       margin: (top: MG-TEXTO.sup, bottom: MG.inf, left: 100pt, right: 100pt),
       header: { modo.update("oscuro"); encabezado(margin-izq: 100pt) },
       footer: folio(margin-izq: 100pt), background: folio-lateral())[
    #modo.update("oscuro")
    #set text(fill: tintaO)
    #grid(columns: (760pt, 1fr), column-gutter: 80pt,
      [
        #for (k, x) in trozos(texto) { if k == "h2" { h2-col(x, num) } else { md(x) } }
      ],
      [
        #box(width: 100%, height: 640pt)[#align(center + horizon)[
          #image("/diagramacion/figs-diagramas/" + id + ".svg", width: 100%, height: 100%, fit: "contain")]]
        #v(16pt)
        #set par(justify: false, leading: 6pt)
        #context {
          let n = cont-fig.get().first()
          text(font: f-mono, weight: 500, size: T.figcap, fill: lima, tracking: 0.08em)[FIGURA #(if n < 10 { "0" + str(n) } else { str(n) })]
        }
        #linebreak()
        #text(font: f-cuerpo, style: "italic", size: T.figcap, fill: tintaO)[#tit.]
        #text(font: f-cuerpo, size: T.figcap, fill: tenueO)[ #fuente]
      ])
  ]
  modo.update("claro")
}

#let componer(s0, num: "") = {
  // las tablas salen del texto corrido y se vuelven láminas
  let tablas = ()
  let bl = s0.split("\n\n")
  let out = ()
  let i = 0
  while i < bl.len() {
    let b = bl.at(i)
    if b.trim().starts-with("|") {
      let blk = b
      if i + 1 < bl.len() and bl.at(i + 1).trim().starts-with("*Tabla ") { blk = blk + "\n" + bl.at(i + 1); i += 1 }
      out.push("<!-- fig:tabla-" + str(tablas.len()) + " -->")
      tablas.push(datos-tabla(blk))
    } else { out.push(b) }
    i += 1
  }
  let s = out.join("\n\n")
  let re = regex("<!-- (fig|lado|pagina|img|fotos)(?::\\s*(.*?))? -->")
  // partes de un marcador de imagen: «archivo(s) | título | fuente»
  let partes(arg) = { let p = arg.split("|").map(x => x.trim()); (p.at(0, default: ""), p.at(1, default: "Imagen"), p.at(2, default: "Elaboración propia.")) }
  let lamina(id) = {
    if id.starts-with("tabla-") { let (f, t, n) = tablas.at(int(id.slice(6))); pagina-tabla(f, t, n) }
    else if id.starts-with("img:") { let (a, t, f) = partes(id.slice(4)); lamina-imagen(a, t, f) }
    else if id.starts-with("fotos:") { let (a, t, f) = partes(id.slice(6)); lam-fotos-rutas(a.split(",").map(x => x.trim()).filter(x => x != ""), t, f) }
    else { lamina-por-id(id) }
  }
  // texto corto entre láminas: no corta el flujo; las láminas esperan hasta
  // juntar ~una página de texto (MIN palabras) y entran todas seguidas.
  let MIN = R.flujo.palabras_laminas
  let palabras(t) = t.split(regex("\s+")).filter(w => w.match(regex("\w")) != none).len()
  let pos = 0
  let texto = ""
  let figs = ()
  for m in s.matches(re) {
    texto += s.slice(pos, m.start)
    pos = m.end
    let tipo = m.captures.at(0)
    let id = m.captures.at(1)
    if tipo == "lado" {
      for f in figs { lamina(f) }; figs = ()
      pagina-lado(texto, id, num); texto = ""
      continue
    }
    if tipo == "pagina" {
      flujo(texto, num: num); for f in figs { lamina(f) }
      texto = ""; figs = ()
      pagebreak(weak: true)
      continue
    }
    figs.push(if tipo == "img" or tipo == "fotos" { tipo + ":" + id } else { id })
    if palabras(texto) >= MIN {
      // un título con poco texto justo antes de la lámina pasa al tramo siguiente
      let arrastre = ""
      let t2 = "\n" + texto
      let hs = t2.matches(regex("\n#{2,4} [^\n]*"))
      if hs.len() > 0 {
        let ult = hs.last()
        if palabras(t2.slice(ult.end)) < R.flujo.arrastre_titulo and palabras(t2.slice(0, ult.start)) > 80 {
          arrastre = t2.slice(ult.start).trim() + "\n\n"; texto = t2.slice(0, ult.start)
        }
      }
      flujo(texto, num: num)
      for f in figs { lamina(f) }
      texto = arrastre
      figs = ()
    }
  }
  texto += s.slice(pos)
  flujo(texto, num: num)
  for f in figs { lamina(f) }
}

#set page(header: { modo.update("claro"); encabezado() })

// --- PORTADA (pág. 01) -------------------------------------------------------
// Arte de Downloads/portada.svg (foreignObject → PNG con Chrome, 2×). Los logos
// ocupan las esquinas superiores, así que los permanentes van solo en el pie:
// autora a la izquierda, profesores guía a la derecha. Sin folio lateral.
#page(fill: negro, margin: 0pt, header: none, footer: none,
      background: place(top + left, image("/diagramacion/portada/portada.jpg",
                                          width: PG.ancho, height: PG.alto)))[
  #modo.update("oscuro")
  #place(top + left, dx: 50pt, dy: 1020pt)[
    #box(height: 30pt)[#align(horizon)[#c-etiqueta(EXP.autor, color: tintaO)]]
  ]
  #place(top + right, dx: -50pt, dy: 1020pt)[
    #box(height: 30pt)[#align(horizon)[#c-etiqueta("Profesores guía · Sergio Majluf · Simón Gallardo", color: tintaO)]]
  ]
  // bajada: justo bajo el logotipo, al mismo ancho que la palabra «rastro.»
  // (medida en el PNG: x 484–1434,5 pt → 950,5 pt). El cuerpo se calcula para calzar.
  #place(top + left, dx: 484pt, dy: 725pt)[
    #context {
      let b(tam) = text(font: f-display, weight: 500, size: tam, fill: white, tracking: 0.08em)[
        #upper("Diseño crítico para hacer sentir la extracción invisible de datos")]
      let w0 = measure(b(28pt)).width
      box(width: 950.5pt)[#align(center)[#b(28pt * (950.5pt / w0))]]
    }
  ]
]
#modo.update("claro")

// --- RESUMEN / ABSTRACT (preliminares, orden del seminario) -----------------
// Una página clara: Resumen a la izquierda, Abstract a la derecha, cada uno con
// su título lima y sus palabras clave.
#{
  seccion-actual.update("PRELIMINARES")
  let partes = read("/diagramacion/limpias/00-resumen.md").split("## Abstract")
  let bloque(tit, cuerpo) = {
    block(width: 100%, below: 36pt)[
      #highlight(fill: lima, top-edge: "ascender", bottom-edge: "descender", extent: 4pt)[
        #text(font: f-display, weight: 600, size: T.h2, fill: negro)[#upper(tit)]
      ]
    ]
    set par(justify: false, leading: 11pt, spacing: base)
    set text(font: f-cuerpo, size: 18pt)
    md(cuerpo)
  }
  page(margin: (top: MG.sup, bottom: MG.inf, left: 100pt, right: 100pt),
       header: { modo.update("claro"); encabezado(margin-izq: 100pt) },
       footer: folio(margin-izq: 100pt))[
    #align(center + horizon)[
      #grid(columns: (1fr, 1fr), column-gutter: 100pt, align: left + top,
        bloque("Resumen", partes.at(0).replace("## Resumen", "")),
        bloque("Abstract", partes.at(1)))
    ]
  ]
}


// --- ÍNDICE (molde: Janis Sepúlveda) ------------------------------------------
// Una página negra: «Índice» arriba a la izquierda y los capítulos en cuatro
// columnas, cada uno con sus títulos ## y el número de página. Se arma solo
// desde limpias/*.md; cada entrada es un enlace a su página.
#let pag-de(lbl) = context {
  let r = query(lbl)
  if r.len() > 0 {
    let loc = r.first().location()
    link(loc)[#counter(page).at(loc).first()]
  }
}
#let entrada-idx(t, lbl, nivel) = {
  let (fuente, peso, tam, color) = if nivel == 1 {
    (f-display, 600, 21pt, lima)
  } else { (f-cuerpo, 400, 15.5pt, tintaO) }
  block(width: 100%, above: if nivel == 1 {40pt} else {12pt}, below: 0pt, breakable: false)[
    #set par(justify: false, leading: 7pt)
    #grid(columns: (1fr, 42pt), column-gutter: 8pt,
      context { let r = query(lbl); if r.len() > 0 { link(r.first().location())[#text(font: fuente, weight: peso, size: tam, fill: color, hyphenate: false)[#t]] } else { text(font: fuente, weight: peso, size: tam, fill: color)[#t] } },
      align(right)[#text(font: f-mono, weight: 500, size: 13.5pt, fill: if nivel == 1 {lima} else {tenueO})[#pag-de(lbl)]])
  ]
}
#{
  seccion-actual.update("ÍNDICE")
  let col(grupo) = {
    for (num, tit, archivo) in grupo {
      entrada-idx(num + "  " + upper(tit), label("cap:" + num), 1)
      for l in read("/diagramacion/limpias/" + archivo).split("\n") {
        if l.starts-with("## ") {
          let t = l.slice(3).trim()
          entrada-idx(t, label("idx:" + t + "@" + num), 2)
        }
      }
    }
  }
  page(fill: negro,
       margin: (top: MG.sup, bottom: MG.inf, left: 100pt, right: 100pt),
       header: { modo.update("oscuro"); encabezado(margin-izq: 100pt) },
       footer: folio(margin-izq: 100pt))[
    #modo.update("oscuro")
    #block(below: 80pt)[
      #highlight(fill: lima, top-edge: "ascender", bottom-edge: "descender", extent: 6pt)[
        #text(font: f-display, weight: 600, size: 60pt, fill: negro)[ÍNDICE]]
    ]
    #grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 46pt,
      col(secs.slice(0, 3)), col(secs.slice(3, 6)), col(secs.slice(6, 8)), col(secs.slice(8)))
  ]
  modo.update("claro")
}

// Intro corta (texto entre «# Título» y el primer «##», sin figuras y de hasta
// 80 palabras) → va como bajada en la portadilla y sale del flujo.
#let partir-intro(txt) = {
  let m = txt.match(regex("^# [^\n]*\n"))
  let resto = if m != none { txt.slice(m.end) } else { txt }
  let i = resto.position("\n## ")
  if i == none { return (none, txt) }
  let intro = resto.slice(0, i).trim()
  if intro == "" or intro.contains("<!--") or intro.split(" ").len() > 80 { return (none, txt) }
  (intro.replace("\n", " "), resto.slice(i))
}
#for (num, tit, archivo) in secs {
  let cuerpo = read("/diagramacion/limpias/" + archivo)
  portadilla(num: num, codigo: "", titulo: tit,
             arte: "/diagramacion/portadillas-svg/" + num + ".jpg",
             etiqueta: "cap:" + num)
  componer(cuerpo, num: num)
}

// --- MAPA PARA EL EDITOR: página donde abre cada capítulo (typst query) --------
#context [#metadata(secs.map(((num, tit, archivo)) => {
  let q = query(label("cap:" + num))
  (num: num, titulo: tit, archivo: archivo, pagina: if q.len() > 0 { counter(page).at(q.first().location()).first() } else { none })
}))<mapa-paginas>]
