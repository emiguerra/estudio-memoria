// ===========================================================================
// app.typ — LÁMINAS DEL DESARROLLO DE LA APLICACIÓN (§7.4)
// Molde: Janis Sepúlveda, cap. 6.2–6.3 (desarrollo del artefacto + UX/UI).
// Mismo formato que identidad.typ: caja x 100–1820, y 90–910; pie en 930.
// Convención gráfica de los flujos (doble carril):
//   · LO QUE VE  → caja blanca con borde negro (la interfaz pública)
//   · LO QUE QUEDA → banda negra, texto lima (la capa de registro)
// Recursos: diagramacion/app/ (capturas de la ficha de Play, capas del ícono)
// ===========================================================================
#import "rastro.typ": *
#import "identidad.typ": rotulo, dato, en, pie-lamina, pagina-lamina, X0, ANCHO

#let A = "/diagramacion/app/"
#let FUENTE-BIT = "Elaboración propia a partir de la bitácora del proyecto y del código de la aplicación"

// --- primitivas -------------------------------------------------------------
#let trazo(c) = (paint: c, thickness: 1.6pt)

#let flecha-h(x0, x1, y, color: tintaC, dash: none) = {
  place(top + left, line(start: (x0, y), end: (x1, y),
                         stroke: (paint: color, thickness: 1.6pt, dash: dash)))
}
#let flecha-v(x, y0, y1, color: tintaC, dash: none) = {
  place(top + left, line(start: (x, y0), end: (x, y1),
                         stroke: (paint: color, thickness: 1.6pt, dash: dash)))
}
#let linea(p0, p1, color: tintaC, dash: none, grosor: 1.6pt) = place(top + left,
  line(start: p0, end: p1, stroke: (paint: color, thickness: grosor, dash: dash)))

// nodo: estilo "ve" (blanco), "queda" (sobre negro), "vacio" (punteado), "lima"
#let nodo(x, y, w, h, tit, sub: none, estilo: "ve", tam: 16pt, tam-sub: 15pt) = {
  let (fondo, borde, ct, cs) = if estilo == "queda" {
    (cajaO, 1.2pt + lineaO, lima, tintaO)
  } else if estilo == "vacio" {
    (none, (paint: tenueC, thickness: 1pt, dash: "dashed"), tenueC, tenueC)
  } else if estilo == "vacio-o" {
    (none, (paint: tenueO, thickness: 1pt, dash: "dashed"), tenueO, tenueO)
  } else if estilo == "lima" {
    (lima, 1.4pt + negro, negro, negro)
  } else if estilo == "negro" {
    (negro, 1.4pt + negro, lima, tintaO)
  } else {
    (blanco, 1.4pt + negro, tintaC, tenueC)
  }
  en(x, y, w, h)[
    #box(width: w, height: h, fill: fondo, stroke: borde, inset: (x: 14pt, y: 12pt))[
      #set par(justify: false, leading: 6pt)
      #text(font: f-mono, weight: 700, size: tam, fill: ct, tracking: 0.05em)[#upper(tit)]
      #if sub != none {
        v(4pt)
        text(font: f-cuerpo, size: tam-sub, fill: cs)[#sub]
      }
    ]
  ]
}

// etiqueta suelta en mono
#let marca(x, y, w, t, color: tenueC, alin: left, tam: 13pt) = en(x, y, w, 24pt)[
  #align(alin)[#text(font: f-mono, weight: 500, size: tam, fill: color, tracking: 0.08em)[#upper(t)]]
]

// ===========================================================================
// DOBLE CARRIL — flujo con «lo que ve» arriba y «lo que queda» abajo
// pasos: ((nombre, ve, queda), ...) con ve/queda = (tit, sub) o none
// ===========================================================================
#let doble-carril(pasos, titulo, alto-ve: 230pt, alto-q: 270pt) = {
  let n = pasos.len()
  let xi = X0 + 170pt                 // después de la columna de rótulos
  let g = 46pt                        // aire entre columnas (lleva la flecha)
  let cw = (ANCHO - 170pt - (n - 1) * g) / n
  let y-num = 160pt
  let y-ve = 200pt
  let y-banda = 480pt
  let y-q = 520pt

  en(X0, 100pt, ANCHO, 30pt)[#rotulo(titulo)]
  // banda negra de la capa oculta
  en(X0, y-banda, ANCHO, 350pt)[#box(width: ANCHO, height: 350pt, fill: negro)]
  // rótulos de carril
  en(X0, y-ve + 4pt, 150pt, 60pt)[
    #text(font: f-mono, weight: 700, size: 15pt, fill: tintaC, tracking: 0.1em)[LO QUE\ VE]
  ]
  en(X0 + 20pt, y-q + 4pt, 140pt, 60pt)[
    #text(font: f-mono, weight: 700, size: 15pt, fill: lima, tracking: 0.1em)[LO QUE\ QUEDA]
  ]

  for (i, (nombre, ve, q)) in pasos.enumerate() {
    let x = xi + i * (cw + g)
    // número + nombre del paso
    en(x, y-num, cw, 40pt)[
      #text(font: f-mono, weight: 500, size: 13pt, fill: verdeT, tracking: 0.1em)[#(if i < 9 {"0"} else {""})#(i + 1)]
      #h(8pt)
      #text(font: f-mono, weight: 700, size: 14pt, fill: tintaC, tracking: 0.06em)[#upper(nombre)]
    ]
    if ve != none { nodo(x, y-ve, cw, alto-ve, ve.at(0), sub: ve.at(1), tam: 17pt, tam-sub: 16pt) }
    else { nodo(x, y-ve, cw, alto-ve, "— nada —", estilo: "vacio", tam: 17pt) }
    if q != none { nodo(x, y-q, cw, alto-q, q.at(0), sub: q.at(1), estilo: "queda", tam: 17pt, tam-sub: 16pt) }
    else { nodo(x, y-q, cw, alto-q, "— nada —", estilo: "vacio-o", tam: 17pt) }
    // el instante: une lo que ve con lo que queda
    linea((x + cw / 2, y-ve + alto-ve), (x + cw / 2, y-q), color: tenueC, dash: "dotted", grosor: 1.4pt)
    if i < n - 1 {
      flecha-h(x + cw + 6pt, x + cw + g - 6pt, y-ve + alto-ve / 2)
      flecha-h(x + cw + 6pt, x + cw + g - 6pt, y-q + alto-q / 2, color: lima)
    }
  }
}

// ===========================================================================
// 1 · ARQUITECTURA DE INFORMACIÓN
// ===========================================================================
#let lam-arquitectura() = pagina-lamina({
  en(X0, 100pt, ANCHO, 30pt)[#align(right)[#rotulo("Arquitectura de información")]]

  // ALTA (una vez)
  marca(X0, 150pt, 400pt, "Alta · se recorre una vez", color: verdeT)
  let ya = 180pt
  let wa = 250pt
  let ga = 62pt
  let alta = (("Inicio", "logotipo + «Comenzar»"), ("Términos", "4 apartados + 13 cláusulas"),
              ("Biometría", "«Crea tu avatar»"), ("Perfil", "alias + foto elegida"),
              ("Permisos", "avisos · cámara · ubicación · fotos"))
  for (i, (t, s)) in alta.enumerate() {
    let x = X0 + i * (wa + ga)
    nodo(x, ya, wa, 92pt, t, sub: s)
    if i < alta.len() - 1 { flecha-h(x + wa + 6pt, x + wa + ga - 6pt, ya + 46pt) }
  }
  // de permisos baja al uso diario
  let xp = X0 + 4 * (wa + ga) + wa / 2
  flecha-v(xp, ya + 92pt + 6pt, 330pt)

  // USO DIARIO
  marca(X0, 300pt, 600pt, "Uso diario · barra inferior de tres pestañas", color: verdeT)
  en(X0, 330pt, ANCHO, 4pt)[#box(width: ANCHO, height: 3pt, fill: negro)]
  let cols = (
    (X0 + 0pt, "Feed", ("Botón de captura", "Cámara dual", "Vista previa · repetir / publicar", "Detalle de publicación")),
    (X0 + 590pt, "Amigos", ("Buscar y agregar", "Perfil de otra persona", "Detalle de publicación")),
    (X0 + 1180pt, "Perfil", ("Memorias · calendario", "Recuerdos · «Un día como hoy»", "Editar perfil", "Ajustes")),
  )
  for (x, tab, hijos) in cols {
    nodo(x, 350pt, 540pt, 62pt, tab, estilo: "lima", tam: 18pt)
    for (j, h) in hijos.enumerate() {
      let y = 440pt + j * 62pt
      linea((x + 24pt, y - 14pt), (x + 24pt, y + 22pt), color: tintaC, grosor: 1.2pt)
      linea((x + 24pt, y + 22pt), (x + 44pt, y + 22pt), color: tintaC, grosor: 1.2pt)
      nodo(x + 50pt, y, 490pt, 46pt, h, tam: 14.5pt)
    }
  }

  // TRASTIENDA (no visible)
  en(X0, 712pt, ANCHO, 188pt)[#box(width: ANCHO, height: 188pt, fill: negro)]
  en(X0 + 30pt, 734pt, 520pt, 120pt)[
    #text(font: f-mono, weight: 700, size: 17pt, fill: lima, tracking: 0.08em)[TRASTIENDA]\
    #v(4pt)
    #text(font: f-cuerpo, size: 14pt, fill: tintaO)[Modo desarrollador, a una pulsación larga del uso diario. El participante no sabe que existe.]
  ]
  let tras = (("GPS por captura", "lat · lng · precisión · hora"), ("Exportar registro", "JSON de la semana"),
              ("Galería (tesis)", "lectura y manifiesto"))
  for (i, (t, s)) in tras.enumerate() {
    nodo(X0 + 600pt + i * 380pt, 742pt, 350pt, 120pt, t, sub: s, estilo: "queda")
  }
  linea((X0 + 8pt, 412pt), (X0 + 8pt, 712pt), color: tenueC, dash: "dashed", grosor: 1.4pt)
  marca(X0 + 60pt, 684pt, 300pt, "pulsación larga", color: tenueC, tam: 12pt)

  pie-lamina("Arquitectura de información de la aplicación: alta, uso diario y trastienda",
             FUENTE-BIT + " (versión 1.0.1+8, 11 nov 2026).")
})

// ===========================================================================
// 2 · FLUJO DE ALTA
// ===========================================================================
#let lam-onboarding() = pagina-lamina({
  doble-carril((
    ("Inicio", ("Logotipo", "Una palabra y un botón: «Comenzar»."), none),
    ("Términos", ("Texto largo", "4 apartados simples y 13 cláusulas jurídicas. «Acepto y continúo»."),
                 ("Aceptación", "El consentimiento queda dado. Todo lo que se recoge está declarado.")),
    ("Biometría", ("«Crea tu avatar»", "Seguir un punto con la nariz hasta llenar el anillo (iPhone) o una selfie (Android)."),
                  ("Rostro de registro", "La llave del expediente en el evento. Rechazo de fotos borrosas.")),
    ("Perfil", ("Nombre y foto", "Una imagen elegida por la persona. Sin correo."),
               ("Dos caras", "Avatar público y rostro retenido, en archivos separados. Alias.")),
    ("Permisos", ("Diálogos del sistema", "Avisos, cámara, ubicación y fotos, con textos neutros."),
                 ("Latido", "Qué permisos concedió cada teléfono, registrado desde el primer día.")),
  ), "Flujo de alta")
  pie-lamina("Flujo de alta: lo que el participante ve y lo que el sistema conserva",
             FUENTE-BIT + " (25 oct – 8 nov 2026).")
})

// ===========================================================================
// 3 · FLUJO DE CAPTURA DIARIA
// ===========================================================================
#let lam-captura() = pagina-lamina({
  doble-carril((
    ("Aviso", ("«¡Es tu momento! ✨»", "Una vez al día, a una hora sorpresa."),
              ("Agenda", "Hora desde el servidor, igual para todos con variación menor. Se reprograma al abrir.")),
    ("Cámara dual", ("Foto doble", "Trasera y frontal en el mismo instante."),
                    ("Dos imágenes", "Lo que la persona mira y su cara mirando, en el mismo segundo.")),
    ("Vista previa", ("Repetir o publicar", "Un toque intercambia las dos fotos."), none),
    ("Subida", ("«Publicando…»", "La pantalla espera el resultado real antes de confirmar."),
               ("Coordenadas", "Latitud, longitud, precisión, hora y alias. Sin GPS no se sube.")),
    ("Feed", ("«Publica para ver»", "Se desbloquea lo de los demás. Nadie mira sin mostrar."),
             ("Comportamiento", "Racha, última conexión y número de capturas, por teléfono.")),
  ), "Flujo de captura diaria")
  pie-lamina("Flujo de captura diaria: la foto visible y la ubicación que no se muestra",
             FUENTE-BIT + " (24 oct – 11 nov 2026).")
})

// ===========================================================================
// 4 · FLUJO DE RECUERDOS
// ===========================================================================
#let lam-recuerdos() = pagina-lamina({
  doble-carril((
    ("Aviso", ("«Un día como hoy»", "Una sola opción, «Activar». Se repite en cada apertura hasta escanear."),
              ("Insistencia", "El aviso no tiene salida: nadie llega a la sesión sin la galería activada.")),
    ("Permiso", ("Acceso a las fotos", "Tiene que ser completo: con acceso limitado no avanza."),
                ("El carrete entero", "Acceso a todas las fotos del teléfono, no solo a las de hoy.")),
    ("Recuerdos", ("Fotos de años anteriores", "Imágenes reales de esta misma fecha."),
                  ("Fecha y GPS", "Leídos del EXIF de cada foto, dentro del teléfono.")),
    ("En silencio", none, ("Lugares", "Coordenadas agrupadas en radios de 80 m: casa, trabajo o estudio, tercer lugar.")),
    ("Después", none, ("De 10 fotos a 5", "Suben a un depósito privado. La investigadora cura cinco para el expediente.")),
  ), "Flujo de Recuerdos")
  pie-lamina("Flujo de Recuerdos: la interfaz se vacía mientras la capa de registro crece",
             FUENTE-BIT + " (8 – 11 nov 2026).")
})

// ===========================================================================
// 5 · ESQUEMAS DE PANTALLA (reconstruidos desde la interfaz implementada)
// ===========================================================================
#let TW = 236pt
#let TH = 484pt
#let gris(x, y, w, h, r: 3pt, f: cajaC) = place(top + left, dx: x, dy: y,
  box(width: w, height: h, radius: r, fill: f))
#let borde(x, y, w, h, r: 3pt, s: 1.4pt + tintaC, f: none) = place(top + left, dx: x, dy: y,
  box(width: w, height: h, radius: r, stroke: s, fill: f))
#let micro(x, y, w, t, color: tintaC, tam: 9pt, alin: center) = place(top + left, dx: x, dy: y,
  box(width: w)[#align(alin)[#text(font: f-mono, weight: 600, size: tam, fill: color, tracking: 0.06em)[#t]]])
#let barra-tabs() = {
  linea((0pt, TH - 50pt), (TW, TH - 50pt), color: lineaC, grosor: 1pt)
  for i in range(3) {
    place(top + left, dx: 38pt + i * 70pt, dy: TH - 36pt, circle(radius: 9pt, stroke: 1.2pt + tenueC))
  }
}
#let tel(x, y, nombre, pide, cuerpo) = {
  en(x, y, TW, TH)[
    #box(width: TW, height: TH, radius: 30pt, stroke: 2pt + tintaC, fill: blanco, clip: true)[#cuerpo]
  ]
  en(x, y + TH + 18pt, TW, 90pt)[
    #align(center)[
      #text(font: f-mono, weight: 700, size: 15pt, fill: tintaC, tracking: 0.06em)[#upper(nombre)]\
      #v(2pt)
      #text(font: f-mono, weight: 500, size: 12.5pt, fill: verdeT, tracking: 0.06em)[#upper(pide)]
    ]
  ]
}

#let lam-esquemas() = pagina-lamina({
  en(X0, 100pt, ANCHO, 30pt)[#align(right)[#rotulo("Esquemas de pantalla")]]
  let g = (ANCHO - 6 * TW) / 5
  let y = 170pt
  let xs = range(6).map(i => X0 + i * (TW + g))

  // 1 inicio
  tel(xs.at(0), y, "Inicio", "pide: un toque", {
    micro(0pt, 200pt, TW, text(font: "Inter Tight", weight: 800, size: 30pt)[rastro.], tam: 30pt)
    place(top + left, dx: 28pt, dy: 400pt, box(width: TW - 56pt, height: 36pt, radius: 18pt, fill: negro)[
      #align(center + horizon)[#text(font: f-mono, size: 9pt, fill: blanco, tracking: 0.08em)[COMENZAR]]])
  })
  // 2 términos
  tel(xs.at(1), y, "Términos", "pide: aceptar", {
    micro(16pt, 34pt, TW - 32pt, "TÉRMINOS Y CONDICIONES", alin: left)
    for i in range(20) {
      let w = (0.92, 0.78, 0.86, 0.6, 0.9, 0.72).at(calc.rem(i, 6))
      gris(16pt, 62pt + i * 16pt, (TW - 32pt) * w, 6pt, f: if calc.rem(i, 5) == 0 { tenueC } else { cajaC })
    }
    place(top + left, dx: 22pt, dy: 410pt, box(width: TW - 44pt, height: 36pt, radius: 18pt, fill: negro)[
      #align(center + horizon)[#text(font: f-mono, size: 8.5pt, fill: blanco, tracking: 0.06em)[ACEPTO Y CONTINÚO]]])
  })
  // 3 biometría
  tel(xs.at(2), y, "Biometría", "pide: el rostro", {
    micro(0pt, 34pt, TW, "CREA TU AVATAR")
    place(top + left, dx: TW / 2 - 70pt, dy: 90pt, ellipse(width: 140pt, height: 176pt, stroke: 1.4pt + tintaC))
    place(top + left, dx: TW / 2 - 92pt, dy: 86pt, circle(radius: 92pt, stroke: (paint: tenueC, thickness: 5pt, dash: "dashed")))
    place(top + left, dx: TW / 2 + 92pt - 9pt, dy: 178pt - 9pt, circle(radius: 9pt, fill: lima, stroke: 1pt + negro))
    for i in range(3) {
      micro(24pt, 300pt + i * 26pt, 20pt, str(i + 1), color: verdeT, alin: left)
      gris(46pt, 304pt + i * 26pt, (150pt, 128pt, 160pt).at(i), 6pt)
    }
    place(top + left, dx: 22pt, dy: 410pt, box(width: TW - 44pt, height: 36pt, radius: 18pt, fill: negro)[
      #align(center + horizon)[#text(font: f-mono, size: 9pt, fill: blanco, tracking: 0.08em)[ESCANEAR]]])
  })
  // 4 feed bloqueado
  tel(xs.at(3), y, "Feed", "pide: una foto", {
    micro(0pt, 22pt, TW, text(font: "Inter Tight", weight: 800, size: 14pt)[rastro.], tam: 14pt)
    borde(14pt, 50pt, TW - 28pt, 32pt, r: 8pt, s: 1pt + lineaC, f: cajaC)
    micro(14pt, 61pt, TW - 28pt, "🔒 CAPTURA PARA VER LO DE LOS DEMÁS", tam: 7pt)
    gris(14pt, 96pt, TW - 28pt, 290pt, r: 12pt)
    gris(26pt, 108pt, 62pt, 88pt, r: 8pt, f: lineaC)
    micro(14pt, 232pt, TW - 28pt, "publica para ver", color: tenueC, tam: 9pt)
    place(top + left, dx: TW / 2 - 24pt, dy: 352pt, circle(radius: 24pt, stroke: 3.5pt + tintaC, fill: blanco))
    barra-tabs()
  })
  // 5 vista previa
  tel(xs.at(4), y, "Vista previa", "pide: publicar", {
    gris(14pt, 30pt, TW - 28pt, 340pt, r: 14pt)
    gris(26pt, 44pt, 70pt, 100pt, r: 8pt, f: lineaC)
    micro(TW - 44pt, 38pt, 20pt, "×", tam: 14pt)
    borde(14pt, 400pt, 96pt, 36pt, r: 18pt)
    micro(14pt, 412pt, 96pt, "REPETIR", tam: 8.5pt)
    place(top + left, dx: 120pt, dy: 400pt, box(width: TW - 134pt, height: 36pt, radius: 18pt, fill: negro)[
      #align(center + horizon)[#text(font: f-mono, size: 8.5pt, fill: blanco, tracking: 0.06em)[PUBLICAR]]])
  })
  // 6 perfil
  tel(xs.at(5), y, "Perfil", "muestra: la racha", {
    micro(0pt, 24pt, TW, "TU PERFIL", tam: 8.5pt)
    place(top + left, dx: TW / 2 - 34pt, dy: 50pt, circle(radius: 34pt, stroke: 1.4pt + tintaC, fill: cajaC))
    gris(TW / 2 - 40pt, 130pt, 80pt, 8pt, f: tenueC)
    borde(TW / 2 - 50pt, 148pt, 100pt, 22pt, r: 11pt, s: 1pt + tintaC)
    for (i, v) in ("6", "5", "🔥5").enumerate() {
      micro(22pt + i * 66pt, 186pt, 60pt, v, tam: 13pt)
    }
    for i in range(6) {
      gris(16pt + calc.rem(i, 3) * 70pt, 230pt + calc.floor(i / 3) * 96pt, 64pt, 88pt, r: 6pt)
    }
    barra-tabs()
  })

  // nota de método
  en(X0, 800pt, ANCHO, 60pt)[
    #align(center)[#dato("Esquemas reconstruidos a partir de las pantallas implementadas en la versión de campo")]
  ]
  pie-lamina("Esquemas de seis pantallas clave: cada una pide una sola cosa",
             "Elaboración propia a partir de la interfaz implementada (versión 1.0.1+8).")
})

// ===========================================================================
// 6 · PANTALLAS FINALES (oscura)
// ===========================================================================
#let lam-pantallas() = pagina-lamina(osc: true, {
  en(X0, 100pt, ANCHO, 30pt)[#align(right)[#rotulo("Pantallas finales · piel de camuflaje", color: tintaO)]]
  let h = 680pt
  let w = h * 9 / 16
  let g = (ANCHO - 4 * w) / 3
  let caps = (("captura-01-feed.jpg", "Feed", "la propia foto doble, recién publicada"),
              ("captura-02-publica-para-ver.jpg", "Publica para ver", "lo de los demás, bloqueado"),
              ("captura-03-perfil.jpg", "Perfil", "momentos, días y racha"),
              ("captura-04-vista-previa.jpg", "Vista previa", "repetir o publicar"))
  for (i, (f, t, s)) in caps.enumerate() {
    let x = X0 + i * (w + g)
    en(x, 150pt, w, h)[#box(width: w, height: h, clip: true, radius: 18pt, stroke: 1pt + lineaO)[
      #image(A + f, width: 100%, height: 100%, fit: "cover")]]
    en(x, 150pt + h + 16pt, w, 60pt)[
      #text(font: f-mono, weight: 700, size: 15pt, fill: lima, tracking: 0.06em)[#upper(t)]\
      #text(font: f-cuerpo, size: 13.5pt, fill: tenueO)[#s]
    ]
  }
  pie-lamina("Pantallas finales de la aplicación en su piel de camuflaje",
             "Elaboración propia. Renders de la interfaz implementada con fotografías de relleno, preparados para la ficha de Google Play (4 nov 2026).", osc: true)
})

// ===========================================================================
// 7 · ÍCONO
// ===========================================================================
#let lam-icono() = pagina-lamina({
  let tw = ANCHO / 3
  let th = 430pt
  let y = 90pt
  let tile(x, w, fondo, rot, rc: tintaC) = {
    en(x, y, w, th)[#box(width: w, height: th, fill: fondo)]
    en(x, y + 30pt, w, 30pt)[#align(center)[#rotulo(rot, color: rc)]]
  }
  // A · iOS
  tile(X0, tw, cajaC, "iOS · arte maestro")
  en(X0 + tw / 2 - 120pt, y + 100pt, 240pt, 240pt)[
    #box(width: 240pt, height: 240pt, radius: 54pt, clip: true)[#image(A + "icono-maestro-1024.png", width: 100%)]]
  en(X0, y + 370pt, tw, 30pt)[#align(center)[#dato("PALABRA AL 76% DEL ANCHO · 1024 × 1024")]]

  // B · Android en dos capas
  tile(X0 + tw, tw, blanco, "Android · ícono adaptativo")
  let bx = X0 + tw + 70pt
  en(bx, y + 110pt, 200pt, 200pt)[#box(width: 200pt, height: 200pt, stroke: 1pt + lineaC)[#image(A + "android-fondo-1024.png", width: 100%)]]
  en(bx + 230pt, y + 110pt, 200pt, 200pt)[
    #box(width: 200pt, height: 200pt, fill: negro, stroke: 1pt + lineaC)[
      #image(A + "android-frente-1024.png", width: 100%)
      #place(center + horizon, circle(radius: 61pt, stroke: (paint: lima, thickness: 2pt, dash: "dashed")))
    ]]
  en(bx, y + 320pt, 200pt, 30pt)[#align(center)[#dato("FONDO · NEGRO OPACO")]]
  en(bx + 230pt, y + 320pt, 200pt, 30pt)[#align(center)[#dato("FRENTE · PALABRA AL 56%")]]
  en(X0 + tw, y + 370pt, tw, 30pt)[#align(center)[#dato("ZONA SEGURA: 61% CENTRAL", color: verdeT)]]

  // C · recorte por el launcher
  tile(X0 + 2 * tw, tw, cajaC, "Recorte del launcher")
  let cx = X0 + 2 * tw + 40pt
  let d = 150pt
  let prev = (("vista-previa-ANTES-se-recorta.png", "ANTES · «astro»"), ("vista-previa-circulo.png", "CÍRCULO"),
              ("vista-previa-squircle.png", "SQUIRCLE"))
  for (i, (f, t)) in prev.enumerate() {
    en(cx + i * (d + 20pt), y + 140pt, d, d)[#image(A + f, width: 100%)]
    en(cx + i * (d + 20pt) - 10pt, y + 140pt + d + 14pt, d + 20pt, 30pt)[#align(center)[#dato(t, color: if i == 0 {tintaC} else {tenueC})]]
  }
  en(X0 + 2 * tw, y + 370pt, tw, 30pt)[#align(center)[#dato("CON EL ARTE DE iOS SE PIERDEN LA «r» Y EL PUNTO")]]

  // fila inferior · Google Play
  let y2 = y + th + 20pt
  let th2 = 370pt
  en(X0, y2, ANCHO, th2)[#box(width: ANCHO, height: th2, fill: negro)]
  en(X0, y2 + 30pt, ANCHO, 30pt)[#align(center)[#rotulo("Ficha de Google Play", color: tintaO)]]
  en(X0 + 260pt, y2 + 90pt, 200pt, 200pt)[#box(width: 200pt, height: 200pt, radius: 36pt, clip: true, stroke: 1pt + lineaO)[#image(A + "play-icono-512.png", width: 100%)]]
  en(X0 + 210pt, y2 + 305pt, 300pt, 30pt)[#align(center)[#dato("ÍCONO · 512 × 512", color: tenueO)]]
  en(X0 + 700pt, y2 + 90pt, 408pt, 200pt)[#box(width: 408pt, height: 200pt, stroke: 1pt + lineaO)[#image(A + "play-grafico-destacado-1024x500.png", width: 100%)]]
  en(X0 + 700pt, y2 + 305pt, 408pt, 30pt)[#align(center)[#dato("GRÁFICO DESTACADO · 1024 × 500", color: tenueO)]]
  en(X0 + 1240pt, y2 + 96pt, 420pt, 220pt)[
    #set par(leading: 8pt, justify: false)
    #text(font: f-mono, weight: 700, size: 15pt, fill: lima, tracking: 0.06em)[DESCRIPCIÓN CORTA]\
    #v(4pt)
    #text(font: f-cuerpo, size: 16pt, fill: tintaO)[«Una foto al día, a una hora sorpresa. Sin filtros, sin poses.»]\
    #v(10pt)
    #text(font: f-cuerpo, size: 13.5pt, fill: tenueO)[La ficha es pública: no menciona ubicación, metadatos, el estudio ni la universidad.]
  ]
  pie-lamina("Ícono de la aplicación: arte de iOS, capas adaptativas de Android y recursos de tienda",
             "Elaboración propia a partir de los archivos del ícono del proyecto (3 y 4 nov 2026).")
})

// ===========================================================================
// 8 · SISTEMA IMPLEMENTADO (oscura)
// ===========================================================================
#let lam-sistema() = pagina-lamina(osc: true, {
  en(X0, 100pt, ANCHO, 30pt)[#align(right)[#rotulo("Sistema implementado", color: tintaO)]]
  let zw = 500pt
  let zs = (X0, X0 + 610pt, X0 + 1220pt)
  let tits = (("Teléfono del participante", "Flutter · iPhone y Android"),
              ("Servidor", "Supabase · base + depósitos"),
              ("Computador de la investigadora", "panel web local"))
  for (i, (t, s)) in tits.enumerate() {
    en(zs.at(i), 160pt, zw, 60pt)[
      #text(font: f-mono, weight: 700, size: 17pt, fill: lima, tracking: 0.08em)[#upper(t)]\
      #text(font: f-mono, weight: 500, size: 13pt, fill: tenueO, tracking: 0.06em)[#upper(s)]
    ]
    linea((zs.at(i), 228pt), (zs.at(i) + zw, 228pt), color: lineaO, grosor: 1pt)
  }
  let mods(x, items, y0: 250pt, h: 88pt, g: 16pt) = {
    for (j, (t, s)) in items.enumerate() {
      nodo(x, y0 + j * (h + g), zw, h, t, sub: s, estilo: "queda")
    }
  }
  mods(zs.at(0), (
    ("Cámara dual", "Swift nativo · AVCaptureMultiCamSession"),
    ("Ubicación", "geolocator · en el instante de la foto"),
    ("Avisos", "flutter_local_notifications · agenda del servidor"),
    ("Galería", "photo_manager · escaneo y lugares en el teléfono"),
    ("Biometría", "Vision en iPhone · selfie en Android"),
    ("Alias", "sin correo · shared_preferences"),
  ), h: 84pt, g: 14pt)
  mods(zs.at(1), (
    ("Tablas", "perfiles · capturas · agenda · amistades · estado (latido) · comentarios · reacciones · recuerdos"),
    ("Depósitos", "capturas · galeria (privado)"),
    ("Reglas", "capturas: solo escribir y leer — la evidencia no se borra ni se altera"),
    ("Borrado", "función del servidor: elimina en cascada todo lo de un alias"),
  ), h: 118pt, g: 16pt)
  mods(zs.at(2), (
    ("Panel", "comuna por point-in-polygon · patrones de rutina · seguimiento"),
    ("Malla y match", "malla facial · descriptores de 128 dimensiones · confirmación humana"),
    ("Curaduría", "galería: 10 fotos llegan, 5 pasan al expediente"),
    ("Impresión", "puente local a Sewoo SLK-TS400 · ESC/POS por USB"),
  ), h: 118pt, g: 16pt)
  // flechas entre zonas
  let xa = zs.at(0) + zw
  let xb = zs.at(1)
  flecha-h(xa + 10pt, xb - 10pt, 330pt, color: lima)
  en(xa + 8pt, 290pt, 100pt, 40pt)[#align(center)[#dato("FOTOS + GPS", color: lima)]]
  flecha-h(xb - 10pt, xa + 10pt, 470pt, color: tenueO, dash: "dashed")
  en(xa + 4pt, 482pt, 102pt, 60pt)[#align(center)[#dato("AGENDA\ FEED", color: tenueO)]]
  let xc = zs.at(1) + zw
  let xd = zs.at(2)
  flecha-h(xc + 10pt, xd - 10pt, 330pt, color: lima)
  en(xc + 8pt, 290pt, 100pt, 40pt)[#align(center)[#dato("LECTURA", color: lima)]]
  en(zs.at(2), 820pt, zw, 60pt)[#dato("NINGUNA IMAGEN SALE DE ESTE COMPUTADOR PARA IDENTIFICAR A NADIE", color: tintaO)]
  pie-lamina("Sistema implementado: teléfono, servidor y computador de la investigadora",
             FUENTE-BIT + " (25 oct – 16 nov 2026).", osc: true)
})

// ===========================================================================
// 9 · DISTRIBUCIÓN
// ===========================================================================
#let lam-distribucion() = pagina-lamina({
  en(X0, 100pt, ANCHO, 30pt)[#align(right)[#rotulo("Distribución · cómo se compartió")]]
  // camino del participante
  let w = 236pt
  let h = 104pt
  let y = 260pt
  nodo(X0, y, w, h, "Convocatoria", sub: "Instagram, con la identidad de rastro")
  flecha-h(X0 + w + 6pt, X0 + w + 44pt, y + h / 2)
  nodo(X0 + w + 50pt, y, w, h, "Formulario", sub: "sin mencionar metadatos · cierre 3 nov, 18:00")
  flecha-h(X0 + 2 * w + 56pt, X0 + 2 * w + 94pt, y + h / 2)
  let xp = X0 + 2 * w + 100pt
  nodo(xp, y, w, h, "Planilla", sub: "casilla «Enviar instrucciones», que envía el correo", estilo: "lima")
  // bifurcación
  let xr = xp + w + 80pt
  linea((xp + w + 6pt, y + h / 2), (xp + w + 40pt, y + h / 2))
  linea((xp + w + 40pt, y - 40pt), (xp + w + 40pt, y + h + 40pt))
  flecha-h(xp + w + 40pt, xr - 4pt, y - 40pt)
  flecha-h(xp + w + 40pt, xr - 4pt, y + h + 40pt)
  let wr = 300pt
  nodo(xr, y - 90pt, wr, h, "iPhone · TestFlight", sub: "invitación desde la cuenta de un colaborador")
  nodo(xr, y + h - 10pt, wr, h, "Android · Play", sub: "prueba interna · lista de correos · 3 personas")
  // fricciones
  nodo(xr + wr + 20pt, y - 90pt, 300pt, h, "Fricción", sub: "la invitación llega a nombre de un desconocido", estilo: "vacio")
  nodo(xr + wr + 20pt, y + h - 10pt, 300pt, h, "Fricción", sub: "la cuenta de Google tiene que calzar con la lista", estilo: "vacio")
  // al terreno
  let xf = X0 + ANCHO - 250pt
  linea((xr + wr / 2, y - 90pt + h), (xr + wr / 2, y + h - 10pt), color: tenueC, dash: "dotted")
  flecha-v(xr + wr / 2, y + 2 * h - 10pt + 4pt, 490pt)
  nodo(xr - 160pt, 490pt, 620pt, 76pt, "Instalación: 7 días", sub: "la semana parte el día en que cada persona instala", estilo: "negro")

  // línea de tiempo 2–16 nov
  let ty = 760pt
  let x0 = X0 + 60pt
  let x1 = X0 + ANCHO - 60pt
  let dx(d) = x0 + (d - 2) * (x1 - x0) / 14
  marca(X0, 600pt, 600pt, "Noviembre de 2026", color: verdeT)
  // semana de capturas
  en(dx(4), ty - 64pt, dx(15) - dx(4), 26pt)[#box(width: dx(15) - dx(4), height: 26pt, fill: lima)[
    #align(center + horizon)[#text(font: f-mono, weight: 700, size: 12pt, fill: negro, tracking: 0.08em)[SEMANA DE CAPTURAS EN TERRENO · 4 – 15 NOV]]]]
  // bloqueo de Play
  en(dx(10), ty + 18pt, dx(13) - dx(10), 22pt)[#box(width: dx(13) - dx(10), height: 22pt,
    stroke: (paint: tintaC, thickness: 1pt, dash: "dashed"))[
    #align(center + horizon)[#text(font: f-mono, size: 11pt, fill: tintaC)[PLAY BLOQUEADO · LLAVE]]]]
  linea((x0, ty), (x1, ty), color: tintaC, grosor: 1.4pt)
  for d in range(2, 17) {
    linea((dx(d), ty - 6pt), (dx(d), ty + 6pt), color: tintaC, grosor: 1pt)
    en(dx(d) - 20pt, ty + 48pt, 40pt, 20pt)[#align(center)[#text(font: f-mono, size: 12pt, fill: tenueC)[#d]]]
  }
  let hitos = (
    (2, "Prueba interna de Play publicada", -1),
    (3, "Cierra la convocatoria · correo automático", 1),
    (8, "Apple rechaza el certificado de distribución", -1),
    (9.5, "Xcode Cloud: compila, no publica", 1),
    (11, "Versión 1.0.1+8 en TestFlight", -1),
    (16, "Sesión de revelación", 1),
  )
  for (d, t, lado) in hitos {
    let yy = if lado < 0 { ty - 136pt } else { ty + 86pt }
    if lado < 0 { linea((dx(d), yy + 40pt), (dx(d), ty - 8pt), color: tenueC, grosor: 1pt) }
    else {
      linea((dx(d), ty + 8pt), (dx(d), ty + 40pt), color: tenueC, grosor: 1pt)
      linea((dx(d), ty + 70pt), (dx(d), yy - 2pt), color: tenueC, grosor: 1pt)
    }
    place(top + left, dx: dx(d) - 6pt, dy: ty - 6pt, circle(radius: 6pt, fill: negro))
    en(dx(d) - 110pt, yy, 220pt, 46pt)[#align(center)[
      #set par(leading: 5pt)
      #text(font: f-cuerpo, size: 12.5pt, fill: tintaC)[#t]]]
  }
  pie-lamina("Distribución de la aplicación: el camino de un participante y la línea de tiempo del canal",
             "Elaboración propia a partir de la bitácora del proyecto (2 – 16 nov 2026).")
})


// ===========================================================================
// 0 · MAQUETA DE ALTA FIDELIDAD (21 oct 2026) — «momento»
// ===========================================================================
#let lam-maqueta() = pagina-lamina({
  en(X0, 100pt, ANCHO, 30pt)[#align(right)[#rotulo("Maqueta de alta fidelidad · «momento» · 21 oct 2026")]]
  let h = 540pt
  let w = h * 732 / 1514
  let g = (ANCHO - 6 * w) / 5
  let y = 200pt
  let tels = (
    ("maqueta-s1-0.jpg", "01 · Alta", "«Tu diario privado. Solo tuyo.»", false),
    ("maqueta-s2-0.jpg", "02 · Aviso", "«Tienes 2 minutos»", false),
    ("maqueta-s3-0.jpg", "03 · Captura", "foto doble, cuenta regresiva", false),
    ("maqueta-s3-1.jpg", "03 · Capa oculta", "lo que guarda mientras sacas la foto", true),
    ("maqueta-s4-1.jpg", "04 · Capa oculta", "la semana leída como rutina", true),
    ("maqueta-s5-0.jpg", "05 · Revelación", "el expediente, abierto con el rostro", false),
  )
  // agrupación
  en(X0, 156pt, 3 * w + 2 * g, 24pt)[#align(center)[#dato("LO QUE VE", color: tintaC)]]
  en(X0 + 3 * (w + g), 156pt, 2 * w + g, 24pt)[#box(width: 2 * w + g, height: 24pt, fill: negro)[#align(center + horizon)[#dato("«VER LO QUE CAPTURAMOS»", color: lima)]]]
  en(X0 + 5 * (w + g), 156pt, w, 24pt)[#align(center)[#dato("EL EVENTO", color: verdeT)]]
  for (i, (f, t, sub, osc)) in tels.enumerate() {
    let x = X0 + i * (w + g)
    en(x, y, w, h)[#image(A + f, width: w, height: h)]
    en(x, y + h + 14pt, w, 70pt)[
      #set par(leading: 6pt, justify: false)
      #text(font: f-mono, weight: 700, size: 14pt, fill: if osc {verdeT} else {tintaC}, tracking: 0.05em)[#upper(t)]\
      #text(font: f-cuerpo, size: 13pt, fill: tenueC)[#sub]
    ]
  }
  pie-lamina("Maqueta clickeable de la aplicación, presentada en la entrega del 21 de octubre, con su capa oculta",
             "Elaboración propia (21 oct 2026). Capturas de la maqueta interactiva.")
})

// ===========================================================================
// BEREAL → RASTRO · qué se toma, qué no entra, qué se agrega
// ===========================================================================
#let lam-bereal() = pagina-lamina({
  en(X0, 100pt, ANCHO, 30pt)[#align(right)[#rotulo("Referente directo · de BeReal a rastro")]]
  let xa = X0
  let wa = 640pt
  let xe = X0 + 670pt
  let we = 200pt
  let xb = X0 + 900pt
  let wb = 820pt
  let y0 = 160pt
  en(xa, y0, wa, 24pt)[#dato("BEREAL (BARREYAT Y PERREAU, 2020)", color: tintaC)]
  en(xe, y0, we, 24pt)[#align(center)[#dato("OPERACIÓN", color: tintaC)]]
  en(xb, y0, wb, 24pt)[#dato("RASTRO · VERSIÓN 1.0.1+8", color: tintaC)]
  linea((X0, y0 + 32pt), (X0 + ANCHO, y0 + 32pt), color: negro, grosor: 2pt)
  let filas = (
    ("Un aviso al día a una hora que nadie conoce de antemano, igual para todos.", "se toma", "Agenda en el servidor: la misma hora para todos, con una variación menor."),
    ("Foto con la cámara frontal y la trasera a la vez.", "se toma", "Cámara dual simultánea nativa (AVCaptureMultiCamSession)."),
    ("Sin filtros; la foto se puede repetir.", "se toma", "Vista previa con «Repetir» y «Publicar»."),
    ("No se ve lo de los demás sin publicar lo propio.", "se toma", "«Publica para ver». Nadie mira sin mostrar."),
    ("Ventana de dos minutos; lo publicado tarde queda marcado.", "no entra", "Sin ventana ni marca de atraso: se planificó y no se implementó."),
  )
  let rh = 62pt
  for (i, (a, op, b)) in filas.enumerate() {
    let y = y0 + 48pt + i * rh
    en(xa, y, wa, rh)[#text(font: f-cuerpo, size: 15pt, fill: tintaC)[#a]]
    en(xe, y - 2pt, we, 30pt)[#align(center)[
      #box(fill: if op == "se toma" {lima} else {none}, stroke: if op == "se toma" {none} else {(paint: tenueC, dash: "dashed", thickness: 1pt)},
           inset: (x: 10pt, y: 5pt))[#text(font: f-mono, weight: 700, size: 12.5pt, fill: if op == "se toma" {negro} else {tenueC}, tracking: 0.08em)[#upper(op)]]]]
    en(xb, y, wb, rh)[#text(font: f-cuerpo, size: 15pt, fill: if op == "se toma" {tintaC} else {tenueC})[#b]]
    linea((X0, y + rh - 12pt), (X0 + ANCHO, y + rh - 12pt), color: lineaC, grosor: 1pt)
  }
  // lo que se agrega: la capa oculta
  let yb = y0 + 48pt + 5 * rh + 10pt
  en(X0, yb, ANCHO, 900pt - yb)[#box(width: ANCHO, height: 900pt - yb, fill: negro)]
  en(X0 + 30pt, yb + 24pt, 560pt, 200pt)[
    #set par(leading: 8pt, justify: false)
    #text(font: f-mono, weight: 700, size: 17pt, fill: lima, tracking: 0.08em)[SE AGREGA · LA CAPA OCULTA]\
    #v(6pt)
    #text(font: f-cuerpo, size: 15pt, fill: tintaO)[Lo que BeReal no hace y rastro sí: cada gesto del juego deja un registro que el participante no ve.]
  ]
  let ag = (("Coordenadas", "latitud, longitud y precisión en cada captura"),
            ("Rostro", "registro biométrico en el alta, distinto del avatar"),
            ("Galería", "fecha y GPS de todo el carrete, en el teléfono"),
            ("Latido", "permisos, última conexión y capturas por teléfono"))
  let cw = (ANCHO - 640pt - 3 * 16pt - 30pt) / 4
  for (i, (t, sub)) in ag.enumerate() {
    nodo(X0 + 640pt + i * (cw + 16pt), yb + 24pt, cw, 900pt - yb - 48pt, t, sub: sub, estilo: "queda", tam: 16pt, tam-sub: 14.5pt)
  }
  pie-lamina("BeReal como referente directo: la mecánica que se toma, la que no entra y la capa que rastro agrega",
             "Elaboración propia a partir de la mecánica descrita de BeReal (Barreyat y Perreau, 2020) y del código de la aplicación.")
})

// --- despacho por id (memoria.typ: <!-- fig:app-ID -->) --------------------
#let lamina-app(id) = {
  if id == "app-maqueta" { lam-maqueta() }
  else if id == "app-bereal" { lam-bereal() }
  else if id == "app-arquitectura" { lam-arquitectura() }
  else if id == "app-onboarding" { lam-onboarding() }
  else if id == "app-captura" { lam-captura() }
  else if id == "app-recuerdos" { lam-recuerdos() }
  else if id == "app-esquemas" { lam-esquemas() }
  else if id == "app-pantallas" { lam-pantallas() }
  else if id == "app-icono" { lam-icono() }
  else if id == "app-sistema" { lam-sistema() }
  else if id == "app-distribucion" { lam-distribucion() }
}
