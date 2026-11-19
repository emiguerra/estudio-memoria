// ===========================================================================
// reglas.typ — reglas de diagramación editables desde el editor
// Una sola fuente de verdad: editor/esquema.json define cada regla y su valor
// por defecto; editor/reglas.json guarda solo lo que se cambió. Una regla que
// falta en reglas.json toma su valor por defecto: nunca rompe la compilación.
// ===========================================================================
#let _esq = json("/diagramacion/editor/esquema.json")
#let _usr = json("/diagramacion/editor/reglas.json")
#let R = {
  let r = (:)
  for s in _esq.secciones {
    let u = if type(_usr) == dictionary { _usr.at(s.id, default: (:)) } else { (:) }
    let d = (:)
    for g in s.reglas { d.insert(g.id, u.at(g.id, default: g.defecto)) }
    r.insert(s.id, d)
  }
  r
}
#let RP(sec, id) = R.at(sec).at(id) * 1pt
