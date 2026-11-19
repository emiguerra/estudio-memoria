// motor.js — el servidor del editor de rastro, pero dentro del navegador.
//
// Responde las mismas rutas que servidor_memoria.py (/api/estado, /api/reglas…) para que la
// interfaz sea la misma. La memoria publicada (memoria/, con su manifiesto) es la base;
// lo que se edita aquí se guarda en este navegador como «cambios» encima de esa base,
// y se baja como .zip para llevarlo a la carpeta local.

const TYPST = '0.8.0-rc4';                 // typst.ts 0.8.0-rc4 = Typst 0.15.1, la misma versión que compila la memoria en local
const PDFJS = '4.10.38';
const CDN = 'https://cdn.jsdelivr.net/npm/@myriaddreamin';
const BASE = new URL('../memoria', import.meta.url).href;     // carpeta publicada
const PRINCIPAL = '/diagramacion/memoria.typ';
const LIMITE_PALABRAS = 20000, LIMITE_PDF = 10_000_000;
const RE_MARCADOR = /<!-- (fig|lado|pagina|img|fotos)(?::\s*(.*?))? -->/g;

// ── almacén de cambios (IndexedDB) ───────────────────────────────────────────
let bd;
function abrirBD() {
  if (bd) return Promise.resolve(bd);
  return new Promise((ok, mal) => {
    const r = indexedDB.open('rastro-memoria', 1);
    r.onupgradeneeded = () => r.result.createObjectStore('cambios');
    r.onsuccess = () => { bd = r.result; ok(bd); };
    r.onerror = () => mal(new Error('Este navegador no deja guardar datos (¿ventana privada?).'));
  });
}
async function tx(modo, f) {
  const d = await abrirBD();
  return new Promise((ok, mal) => { const t = d.transaction('cambios', modo), s = t.objectStore('cambios'); let res; const q = f(s); if (q) q.onsuccess = () => { res = q.result; }; t.oncomplete = () => ok(res); t.onerror = () => mal(t.error); });
}
async function todosCambios() {
  const d = await abrirBD();
  return new Promise((ok, mal) => { const out = {}, t = d.transaction('cambios'), c = t.objectStore('cambios').openCursor(); c.onsuccess = () => { const x = c.result; if (x) { out[x.key] = x.value; x.continue(); } }; t.oncomplete = () => ok(out); t.onerror = () => mal(t.error); });
}
const guardarCambio = (ruta, v) => tx('readwrite', s => s.put(v, ruta));
const borrarCambio = ruta => tx('readwrite', s => s.delete(ruta));

// ── estado en memoria ────────────────────────────────────────────────────────
const M = {
  manifiesto: null, base: new Map(),     // ruta → Uint8Array publicado
  cambios: {},                           // ruta → { dato: Uint8Array|null (null = borrado), base: huella, fecha }
  esquema: null, historialReglas: [],
  pdf: null, doc: null, gen: 0, estado: { generacion: 0, paginas: 0, advertencias: [], error: null, segundos: 0, hora: null, mapa: [], palabras: 0, pdf_bytes: null },
  alAvanzar: () => {},
};
const enc = new TextEncoder(), dec = new TextDecoder();
const huella = async u8 => [...new Uint8Array(await crypto.subtle.digest('SHA-1', u8))].slice(0, 6).map(b => b.toString(16).padStart(2, '0')).join('');

function leer(ruta) { const c = M.cambios[ruta]; if (c) return c.dato; return M.base.get(ruta) || null; }
const leerTexto = ruta => { const u = leer(ruta); return u ? dec.decode(u) : null; };
function existe(ruta) { return leer(ruta) != null; }
function rutas() { const s = new Set(M.base.keys()); for (const [r, c] of Object.entries(M.cambios)) { if (c.dato) s.add(r); else s.delete(r); } return [...s]; }

async function cambiar(ruta, u8) {
  const h = M.manifiesto.archivos.find(a => a.ruta === ruta)?.huella || null;
  // si vuelve a ser igual a lo publicado, deja de ser un cambio
  if (u8 && M.base.has(ruta) && (await huella(u8)).slice(0, 12) === h) { delete M.cambios[ruta]; await borrarCambio(ruta); }
  else { M.cambios[ruta] = { dato: u8, base: h, fecha: Date.now() }; await guardarCambio(ruta, M.cambios[ruta]); }
  avisarCambios();
}
let alCambios = () => {};
export function onCambios(f) { alCambios = f; }
function avisarCambios() { alCambios(Object.keys(M.cambios).length); }

// ── carga inicial ────────────────────────────────────────────────────────────
export async function iniciar(alAvanzar) {
  M.alAvanzar = alAvanzar || (() => {});
  M.alAvanzar('Leyendo la memoria publicada…');
  M.manifiesto = await (await fetch(BASE + '/manifiesto.json', { cache: 'no-cache' })).json();
  const total = M.manifiesto.archivos.reduce((a, x) => a + x.bytes, 0);
  let listos = 0;
  const cola = [...M.manifiesto.archivos];
  const trabajador = async () => {
    while (cola.length) {
      const a = cola.shift();
      const r = await fetch(BASE + encodeURI(a.ruta) + '?h=' + a.huella);
      if (!r.ok) throw new Error('No se pudo descargar ' + a.ruta);
      M.base.set(a.ruta, new Uint8Array(await r.arrayBuffer()));
      listos += a.bytes;
      M.alAvanzar(`Descargando la memoria · ${Math.round(listos / total * 100)} % de ${(total / 1e6).toFixed(1).replace('.', ',')} MB`);
    }
  };
  await Promise.all(Array.from({ length: 6 }, trabajador));
  M.cambios = await todosCambios().catch(() => ({}));
  // cambios hechos sobre una versión publicada que ya no es la misma
  M.desfasados = Object.entries(M.cambios).filter(([r, c]) => c.base && M.manifiesto.archivos.find(a => a.ruta === r)?.huella !== c.base).map(([r]) => r);
  M.esquema = JSON.parse(leerTexto('/diagramacion/editor/esquema.json'));
  avisarCambios();
  await prepararTypst();
  await compilarTodo();
  return { desfasados: M.desfasados, fotos: M.manifiesto.fotos_publicadas };
}

// ── Typst ────────────────────────────────────────────────────────────────────
let snippet, cargados = new Map();
async function prepararTypst() {
  M.alAvanzar('Descargando Typst (28 MB, solo la primera vez)…');
  await import(`${CDN}/typst.ts@${TYPST}/dist/esm/contrib/all-in-one-lite.bundle.js`);
  const s = new window.TypstSnippet();
  s.setCompilerInitOptions({ getModule: () => `${CDN}/typst-ts-web-compiler@${TYPST}/pkg/typst_ts_web_compiler_bg.wasm` });
  const fuentes = [...M.base.entries()].filter(([r]) => r.startsWith('/fuentes/')).map(([, u]) => u);
  // las fuentes de la memoria + las de Typst (Libertinus, New Computer Modern), como en tu computador
  s.use(window.TypstSnippet.preloadFontAssets({ assets: ['text'] }), window.TypstSnippet.preloadFonts(fuentes));
  M.alAvanzar('Preparando Typst y las fuentes…');
  await s.getCompiler();
  snippet = s;
}
async function sincronizarArchivos() {
  const vivos = new Set(rutas());
  for (const r of vivos) {
    if (r.startsWith('/fuentes/')) continue;
    const u = leer(r);
    if (cargados.get(r) === u) continue;
    await snippet.mapShadow(r, u); cargados.set(r, u);
  }
  for (const r of [...cargados.keys()]) if (!vivos.has(r)) { await snippet.unmapShadow(r); cargados.delete(r); }
}
function diagnosticos(ds) {
  const vistos = new Set(), out = [];
  for (const d of ds || []) {
    if (/variable fonts/.test(d.message)) continue;
    const k = d.severity + d.message.slice(0, 60); if (vistos.has(k)) continue; vistos.add(k);
    out.push({ tipo: d.severity === 'error' ? 'error' : 'aviso', texto: d.message, donde: d.path ? `${d.path}:${(+String(d.range || '0').split(':')[0]) + 1}` : '' });
  }
  return out.slice(0, 12);
}
// compila y, si funciona, deja el PDF como el vigente. Devuelve { ok, errores }
let enCurso = Promise.resolve();
function compilarTodo() { const p = enCurso.then(compilarYa, compilarYa); enCurso = p.catch(() => {}); return p; }
async function compilarYa() {
  const t0 = performance.now();
  await sincronizarArchivos();
  const cc = await snippet.getCompiler();
  // una sola compilación: el PDF y el mapa de capítulos salen del mismo documento
  const { r, mapa } = await cc.runWithWorld({ mainFilePath: PRINCIPAL }, async w => {
    const r = await w.pdf({ diagnostics: 'full' });
    let mapa = null;
    if (r?.result && !r.hasError) { try { mapa = await w.query({ selector: '<mapa-paginas>', field: 'value' }); } catch (e) { console.warn('mapa', e); } }
    return { r, mapa };
  });
  if (!r?.result || r.hasError) {
    const errores = diagnosticos(r?.diagnostics).filter(x => x.tipo === 'error');
    return { ok: false, errores: errores.length ? errores : [{ tipo: 'error', texto: 'Typst no pudo compilar el documento.', donde: '' }] };
  }
  M.pdf = r.result;
  const doc = await abrirPdf(r.result);
  const viejo = M.doc; M.doc = doc; viejo?.destroy?.();
  M.gen++;
  Object.assign(M.estado, {
    generacion: M.gen, paginas: doc.numPages, advertencias: diagnosticos(r.diagnostics).filter(x => x.tipo === 'aviso'),
    error: null, segundos: +((performance.now() - t0) / 1000).toFixed(1), hora: new Date().toTimeString().slice(0, 8),
    palabras: contarPalabras(), pdf_bytes: r.result.byteLength,
    mapa: Array.isArray(mapa) ? (Array.isArray(mapa[0]) ? mapa[0] : mapa) : M.estado.mapa,
  });
  return { ok: true };
}
export function onMapa() {}   // el mapa ya llega con cada compilación

// ── pdf.js ───────────────────────────────────────────────────────────────────
let pdfjs;
async function abrirPdf(bytes) {
  if (!pdfjs) {
    pdfjs = await import(`https://cdnjs.cloudflare.com/ajax/libs/pdf.js/${PDFJS}/pdf.min.mjs`);
    pdfjs.GlobalWorkerOptions.workerSrc = `https://cdnjs.cloudflare.com/ajax/libs/pdf.js/${PDFJS}/pdf.worker.min.mjs`;
  }
  return pdfjs.getDocument({ data: bytes.slice(0) }).promise;
}
export async function dibujar(n, canvas, ancho) {
  if (!M.doc) return;
  const doc = M.doc, pag = await doc.getPage(n);
  const v0 = pag.getViewport({ scale: 1 }), dpr = Math.min(window.devicePixelRatio || 1, 2);
  const v = pag.getViewport({ scale: ancho / v0.width * dpr });
  canvas.width = Math.round(v.width); canvas.height = Math.round(v.height);
  canvas._tarea?.cancel?.();
  const t = pag.render({ canvasContext: canvas.getContext('2d'), viewport: v }); canvas._tarea = t;
  try { await t.promise; } catch (e) { if (e?.name !== 'RenderingCancelledException') throw e; }
}
export const generacion = () => M.gen;

// ── palabras, capítulos, catálogo ────────────────────────────────────────────
const LIMPIAS = '/diagramacion/limpias/';
const palabrasDe = t => { t = t.replace(/<!--[\s\S]*?-->/g, '').replace(/[#*|`>_]/g, ' '); return t.split(/\s+/).filter(w => /[\p{L}\p{N}_]/u.test(w)).length; };
function contarPalabras() {
  return rutas().filter(r => r.startsWith(LIMPIAS) && r.endsWith('.md')).filter(r => !/\/(00|11)-/.test(r))
    .reduce((a, r) => a + palabrasDe(leerTexto(r)), 0);
}
function capitulos() {
  const src = leerTexto(PRINCIPAL);
  const caps = [{ num: '00', titulo: 'Resumen y abstract', archivo: '00-resumen.md' }];
  for (const m of src.matchAll(/\("([0-9a-z]+)",\s*"([^"]+)",\s*"([^"]+\.md)"\)/g)) caps.push({ num: m[1], titulo: m[2], archivo: m[3] });
  for (const c of caps) c.palabras = palabrasDe(leerTexto(LIMPIAS + c.archivo) || '');
  return caps;
}
let indice = null;
async function catalogo() {
  if (!indice) indice = await (await fetch(new URL('../catalogo/indice.json', import.meta.url))).json();
  const usos = {};
  for (const r of rutas().filter(r => r.startsWith(LIMPIAS) && r.endsWith('.md')).sort()) {
    for (const m of leerTexto(r).matchAll(/<!-- (?:fig|lado):\s*([a-z0-9-]+) -->/g)) (usos[m[1]] ||= []).push(r.slice(LIMPIAS.length, LIMPIAS.length + 3).replace(/-$/, ''));
  }
  return indice.map(x => ({ ...x, usos: [...new Set(usos[x.id] || [])].sort() }));
}
async function desconocidos(texto) {
  const ids = new Set((await catalogo()).map(x => x.id)), malos = [];
  for (const m of texto.matchAll(RE_MARCADOR)) {
    const tipo = m[1], arg = (m[2] || '').trim();
    if ((tipo === 'fig' || tipo === 'lado') && !ids.has(arg)) malos.push(m[0]);
    if (tipo === 'img' || tipo === 'fotos') for (let a of arg.split('|')[0].split(',')) { a = a.trim(); if (a && !existe(a.includes('.') ? '/diagramacion/imagenes/' + a : '/diagramacion/fotos-sesion/' + a + '.jpg')) { malos.push(m[0]); break; } }
  }
  return malos;
}

// ── imágenes ─────────────────────────────────────────────────────────────────
const IMG = '/diagramacion/imagenes/', FOTOS = '/diagramacion/fotos-sesion/';
const urls = new Map();
export function urlImagen(grupo, nombre) {
  const r = (grupo === 'repositorio' ? IMG : FOTOS) + nombre, u = leer(r);
  if (!u) return '';
  if (urls.get(r)?.u8 !== u) { if (urls.get(r)) URL.revokeObjectURL(urls.get(r).url); urls.set(r, { u8: u, url: URL.createObjectURL(new Blob([u])) }); }
  return urls.get(r).url;
}
async function medidas(u8) { try { const b = await createImageBitmap(new Blob([u8])); return [b.width, b.height]; } catch (e) { return [0, 0]; } }
async function listaImagenes() {
  const out = [], fotosTyp = leerTexto('/diagramacion/fotos.typ') || '';
  const textos = rutas().filter(r => r.startsWith(LIMPIAS) && r.endsWith('.md')).sort().map(r => [r.slice(LIMPIAS.length, LIMPIAS.length + 3).replace(/-$/, ''), leerTexto(r)]);
  for (const [grupo, pref] of [['repositorio', IMG], ['testeo', FOTOS]]) {
    for (const r of rutas().filter(r => r.startsWith(pref) && /\.(jpe?g|png|webp)$/i.test(r)).sort()) {
      const nombre = r.slice(pref.length), clave = grupo === 'repositorio' ? nombre : nombre.replace(/\.[^.]+$/, ''), u = leer(r);
      const usos = new Set();
      for (const [num, t] of textos) for (const m of t.matchAll(/<!-- (?:img|fotos):\s*(.*?) -->/g)) if (m[1].split('|')[0].split(',').map(x => x.trim()).includes(clave)) usos.add(num);
      if (grupo === 'testeo' && fotosTyp.includes('"' + clave + '"')) usos.add('láminas');
      const [ancho, alto] = await medidas(u);
      out.push({ grupo, nombre, bytes: u.byteLength, ancho, alto, usos: [...usos].sort() });
    }
  }
  return out;
}
function slug(n) { return n.normalize('NFKD').replace(/[̀-ͯ]/g, '').replace(/\.[^.]+$/, '').replace(/[^A-Za-z0-9_-]+/g, '-').replace(/^-|-$/g, '').toLowerCase().slice(0, 60) || 'imagen'; }
async function subirImagen(f) {
  if (!/^image\/(jpeg|png|webp)$/.test(f.type)) throw Object.assign(new Error('solo se aceptan JPG, PNG o WebP'), { codigo: 422 });
  let bm; try { bm = await createImageBitmap(f, { imageOrientation: 'from-image' }); } catch (e) { throw Object.assign(new Error('el archivo no es una imagen válida'), { codigo: 422 }); }
  const k = Math.min(1, 2000 / Math.max(bm.width, bm.height)), w = Math.round(bm.width * k), h = Math.round(bm.height * k);
  const c = document.createElement('canvas'); c.width = w; c.height = h; const x = c.getContext('2d'); x.drawImage(bm, 0, 0, w, h);
  let alfa = false;
  if (f.type !== 'image/jpeg') { const d = x.getImageData(0, 0, w, h).data; for (let i = 3; i < d.length; i += 64) if (d[i] < 250) { alfa = true; break; } }
  if (!alfa) { x.globalCompositeOperation = 'destination-over'; x.fillStyle = '#fff'; x.fillRect(0, 0, w, h); }
  const blob = await new Promise(ok => c.toBlob(ok, alfa ? 'image/png' : 'image/jpeg', 0.85));
  const ext = alfa ? '.png' : '.jpg', base = slug(f.name);
  let nombre = base + ext, n = 2; while (existe(IMG + nombre)) nombre = `${base}-${n++}${ext}`;
  await cambiar(IMG + nombre, new Uint8Array(await blob.arrayBuffer()));
  return nombre;
}

// ── reglas ───────────────────────────────────────────────────────────────────
const REGLAS = '/diagramacion/editor/reglas.json';
function validarReglas(cand) {
  const limpias = {}, errores = [];
  for (const s of M.esquema.secciones) {
    const sec = cand?.[s.id] && typeof cand[s.id] === 'object' ? cand[s.id] : {};
    for (const g of s.reglas) {
      if (!(g.id in sec)) continue;
      let v = sec[g.id];
      if (g.tipo === 'numero') { v = Number(v); if (!(v >= g.min && v <= g.max)) { errores.push(`${g.nombre}: debe estar entre ${g.min} y ${g.max}`); continue; } }
      else if (g.tipo === 'si_no') { if (typeof v !== 'boolean') { errores.push(`${g.nombre}: debe ser sí o no`); continue; } }
      else if (g.tipo === 'color') { if (!/^#[0-9A-Fa-f]{6}$/.test(v)) { errores.push(`${g.nombre}: debe ser un color #RRGGBB`); continue; } }
      else if (g.tipo === 'opcion') { if (!g.opciones.includes(v)) { errores.push(`${g.nombre}: opción no disponible`); continue; } }
      if (v === g.defecto) continue;
      (limpias[s.id] ||= {})[g.id] = v;
    }
  }
  return [limpias, errores];
}
const leerReglas = () => { try { const d = JSON.parse(leerTexto(REGLAS) || '{}'); return d && typeof d === 'object' ? d : {}; } catch (e) { return {}; } };
const jsonU8 = d => enc.encode(JSON.stringify(d, null, 2) + '\n');

// ── API: mismas rutas que servidor_memoria.py ────────────────────────────────
const err = (codigo, error, detalle) => Object.assign(new Error(error), { codigo, detalle, datos: { error, detalle } });
const estadoPublico = () => ({ ...M.estado, limite_palabras: LIMITE_PALABRAS, limite_pdf: LIMITE_PDF });

export async function api(ruta, opts = {}) {
  const u = new URL(ruta, location.href), p = u.pathname.replace(/^.*\/api\//, '/api/'), metodo = (opts.method || 'GET').toUpperCase();
  const cuerpo = () => JSON.parse(opts.body || '{}');
  if (metodo === 'GET') {
    if (p === '/api/estado') return estadoPublico();
    if (p === '/api/esquema') return M.esquema;
    if (p === '/api/reglas') return leerReglas();
    if (p === '/api/capitulos') return capitulos();
    if (p === '/api/capitulo') {
      const a = u.searchParams.get('archivo') || '';
      if (!/^[0-9a-z][\w.-]*\.md$/i.test(a)) throw err(403, 'ruta fuera del proyecto');
      const t = leerTexto(LIMPIAS + a) ?? '';
      return { archivo: a, texto: t, huella: (await huella(enc.encode(t))).slice(0, 16), desconocidos: await desconocidos(t) };
    }
    if (p === '/api/catalogo') return catalogo();
    if (p === '/api/imagenes') return listaImagenes();
  }
  if (metodo === 'PUT' && p === '/api/reglas') {
    const [limpias, errores] = validarReglas(cuerpo());
    if (errores.length) throw err(422, 'Hay reglas con valores no válidos', errores);
    const antes = leer(REGLAS);
    await cambiar(REGLAS, jsonU8(limpias));
    const r = await compilarTodo();
    if (!r.ok) {   // no compila: vuelve atrás y no guarda
      await cambiar(REGLAS, antes); await compilarTodo();
      throw err(422, 'Con ese valor el documento no compila; se mantuvo el anterior.', r.errores.map(e => e.texto + (e.donde ? ' · ' + e.donde : '')));
    }
    M.historialReglas.push(antes); if (M.historialReglas.length > 60) M.historialReglas.shift();
    return { reglas: limpias, estado: estadoPublico() };
  }
  if (metodo === 'POST' && p === '/api/deshacer-reglas') {
    if (!M.historialReglas.length) throw err(409, 'No hay cambios de reglas para deshacer');
    await cambiar(REGLAS, M.historialReglas.pop());
    await compilarTodo();
    return { reglas: leerReglas(), estado: estadoPublico() };
  }
  if (metodo === 'PUT' && p === '/api/capitulo') {
    const d = cuerpo();
    if (!/^[0-9a-z][\w.-]*\.md$/i.test(d.archivo || '')) throw err(403, 'ruta fuera del proyecto');
    const ruta = LIMPIAS + d.archivo, actual = leerTexto(ruta) ?? '';
    if (d.huella && (await huella(enc.encode(actual))).slice(0, 16) !== d.huella) throw err(409, 'Este capítulo cambió en otra pestaña desde que lo abriste. Vuelve a cargarlo antes de guardar.');
    await cambiar(ruta, enc.encode(d.texto));
    const r = await compilarTodo();
    const malos = await desconocidos(d.texto);
    const out = { huella: (await huella(enc.encode(d.texto))).slice(0, 16), desconocidos: malos, estado: estadoPublico() };
    if (!r.ok) { M.estado.error = r.errores; out.estado = estadoPublico(); out.aviso = 'Guardado, pero el documento no compila: revisa el detalle arriba.'; }
    return out;
  }
  if (metodo === 'POST' && p === '/api/compilar') { const r = await compilarTodo(); if (!r.ok) M.estado.error = r.errores; return estadoPublico(); }
  if (metodo === 'POST' && p === '/api/exportar') { if (!M.pdf) throw err(409, 'Todavía no hay un PDF compilado'); return { bytes: M.pdf.byteLength }; }
  if (metodo === 'POST' && p === '/api/imagenes') {
    const f = opts.body?.get?.('archivo'); if (!f) throw err(400, 'no venía ningún archivo');
    return { nombre: await subirImagen(f) };
  }
  if (metodo === 'DELETE' && p === '/api/imagenes') {
    const n = u.searchParams.get('nombre') || '';
    if (!/^[\w.-]+$/.test(n)) throw err(403, 'nombre no válido');
    const x = (await listaImagenes()).find(i => i.grupo === 'repositorio' && i.nombre === n);
    if (!x) throw err(404, 'no existe');
    if (x.usos.length) throw err(409, 'Está en uso: sácala del texto primero');
    await cambiar(IMG + n, null);
    return { ok: true };
  }
  throw err(404, 'ruta desconocida: ' + p);
}

// ── PDF y cambios ────────────────────────────────────────────────────────────
export const pdfActual = () => M.pdf;
export function listaCambios() {
  return Object.entries(M.cambios).map(([ruta, c]) => ({ ruta, borrado: !c.dato, fecha: c.fecha, desfasado: (M.desfasados || []).includes(ruta) })).sort((a, b) => a.ruta.localeCompare(b.ruta));
}
export async function zipCambios() {
  const z = new window.JSZip();
  const borrados = [];
  for (const [ruta, c] of Object.entries(M.cambios)) { if (c.dato) z.file(ruta.slice(1), c.dato); else borrados.push(ruta.slice(1)); }
  z.file('LEEME-cambios.txt', `Cambios hechos en el editor web de la memoria de rastro (${new Date().toLocaleString('es-CL')}).\n\n` +
    'Descomprime este .zip dentro de tu carpeta memoria/ y acepta reemplazar: cada archivo va a su misma ruta (diagramacion/…).\n' +
    (borrados.length ? '\nArchivos que borraste en el editor (bórralos a mano):\n' + borrados.map(b => '  ' + b).join('\n') + '\n' : '') +
    '\nDespués corre herramientas/sincronizar.py en el repo para publicar la versión nueva.\n');
  return z.generateAsync({ type: 'blob' });
}
export async function descartarCambios() {
  await tx('readwrite', s => s.clear()); M.cambios = {}; M.historialReglas = []; avisarCambios();
  await compilarTodo();
}
