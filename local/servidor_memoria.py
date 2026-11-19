#!/usr/bin/env python3
"""
Servidor local del editor de la memoria de rastro.

Qué hace
  · sirve el editor (estudio-memoria.html) en http://127.0.0.1:8790
  · lee y guarda las reglas de diagramación (editor/reglas.json) validándolas
    contra editor/esquema.json, y solo las guarda si el documento compila
  · lee y guarda los capítulos de limpias/*.md, con huella para no pisar
    cambios hechos en otra parte, e historial de cada guardado
  · compila con Typst la página que se está mirando y las miniaturas
  · arma el catálogo de láminas (con miniatura de cada una)
  · administra el repositorio de imágenes (diagramacion/imagenes/)

Seguridad (ver ROAST.md §4): escucha solo en 127.0.0.1; toda ruta se resuelve y se
comprueba dentro del proyecto; solo ejecuta typst con argumentos fijos.

Uso:  python3 editor/servidor_memoria.py      (desde diagramacion/ o desde cualquier lado)
"""
import hashlib, io, json, os, re, shutil, subprocess, sys, threading, time, traceback
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs, unquote

# ── rutas ──────────────────────────────────────────────────────────────────────
EDITOR = os.path.dirname(os.path.abspath(__file__))
DIAG = os.path.dirname(EDITOR)                 # diagramacion/
PROY = os.path.dirname(DIAG)                   # memoria/  (raíz de Typst)
LIMPIAS = os.path.join(DIAG, "limpias")
IMAGENES = os.path.join(DIAG, "imagenes")
FOTOS_SESION = os.path.join(DIAG, "fotos-sesion")
HISTORIAL = os.path.join(EDITOR, "historial")
CATALOGO_TYP = os.path.join(EDITOR, "_catalogo")
ESQUEMA = os.path.join(EDITOR, "esquema.json")
REGLAS = os.path.join(EDITOR, "reglas.json")
CACHE = os.path.expanduser("~/Library/Caches/editor-memoria")   # fuera de iCloud
PDF_FINAL = os.path.join(DIAG, "memoria-full.pdf")
PUERTO = int(os.environ.get("PUERTO", "8790"))
TYPST = shutil.which("typst") or "/opt/homebrew/bin/typst"
LIMITE_PALABRAS = 20000
LIMITE_PDF = 10_000_000

for d in (IMAGENES, HISTORIAL, CATALOGO_TYP, CACHE):
    os.makedirs(d, exist_ok=True)

def dentro(base, ruta):
    """Ruta absoluta resuelta, solo si queda dentro de base (evita ../)."""
    r = os.path.realpath(os.path.join(base, ruta))
    if not (r == os.path.realpath(base) or r.startswith(os.path.realpath(base) + os.sep)):
        raise PermissionError("ruta fuera del proyecto")
    return r

def huella(texto):
    return hashlib.sha256(texto.encode("utf-8")).hexdigest()[:16]

def ahora():
    return time.strftime("%Y%m%d-%H%M%S")

# ── esquema y reglas ───────────────────────────────────────────────────────────
def esquema():
    with open(ESQUEMA, encoding="utf-8") as f:
        return json.load(f)

def asegurar_reglas():
    """reglas.json siempre existe y es JSON válido (Typst no puede capturar ese error)."""
    try:
        with open(REGLAS, encoding="utf-8") as f:
            d = json.load(f)
        if not isinstance(d, dict):
            raise ValueError
    except Exception:
        if os.path.exists(REGLAS):
            shutil.copy(REGLAS, os.path.join(HISTORIAL, f"reglas-corrupto-{ahora()}.json"))
        with open(REGLAS, "w", encoding="utf-8") as f:
            f.write("{}\n")

def leer_reglas():
    asegurar_reglas()
    with open(REGLAS, encoding="utf-8") as f:
        return json.load(f)

def validar_reglas(cand):
    """Deja solo reglas conocidas con valores válidos. Devuelve (limpias, errores)."""
    limpias, errores = {}, []
    for s in esquema()["secciones"]:
        sec = cand.get(s["id"], {}) if isinstance(cand.get(s["id"], {}), dict) else {}
        for g in s["reglas"]:
            if g["id"] not in sec:
                continue
            v = sec[g["id"]]
            t = g["tipo"]
            try:
                if t == "numero":
                    v = float(v)
                    if not (g["min"] <= v <= g["max"]):
                        raise ValueError(f"debe estar entre {g['min']} y {g['max']}")
                    if float(v).is_integer() and float(g.get("paso", 1)).is_integer():
                        v = int(v)
                elif t == "si_no":
                    if not isinstance(v, bool):
                        raise ValueError("debe ser sí o no")
                elif t == "color":
                    if not (isinstance(v, str) and re.fullmatch(r"#[0-9A-Fa-f]{6}", v)):
                        raise ValueError("debe ser un color #RRGGBB")
                elif t == "opcion":
                    if v not in g["opciones"]:
                        raise ValueError("opción no disponible")
            except (ValueError, TypeError) as e:
                errores.append(f"{g['nombre']}: {e}")
                continue
            if v == g["defecto"]:
                continue              # solo se guarda lo que difiere del valor por defecto
            limpias.setdefault(s["id"], {})[g["id"]] = v
    return limpias, errores

# ── compilación ────────────────────────────────────────────────────────────────
LOCK = threading.Lock()
ESTADO = {"generacion": 0, "paginas": 0, "advertencias": [], "error": None, "segundos": 0,
          "hora": None, "mapa": [], "palabras": 0, "pdf_bytes": None}

def typst(args, timeout=240):
    cmd = [TYPST] + args + ["--font-path", os.path.join(DIAG, "fonts"), "--root", PROY]
    p = subprocess.run(cmd, cwd=DIAG, capture_output=True, text=True, timeout=timeout)
    return p.returncode, p.stderr

def resumir_stderr(err):
    """Errores y advertencias en lenguaje claro: primera línea + ubicación."""
    out, lineas = [], err.splitlines()
    for i, l in enumerate(lineas):
        if l.startswith(("error:", "warning:")):
            donde = ""
            for k in range(i + 1, min(i + 4, len(lineas))):
                m = re.search(r"┌─ (\S+:\d+:\d+)", lineas[k])
                if m:
                    donde = m.group(1); break
            out.append({"tipo": "error" if l.startswith("error") else "aviso",
                        "texto": l.split(":", 1)[1].strip(), "donde": donde})
    # agrupa avisos repetidos de convergencia
    vistos, final = set(), []
    for o in out:
        k = (o["tipo"], o["texto"][:60])
        if k in vistos:
            continue
        vistos.add(k); final.append(o)
    return final[:12]

def contar_palabras():
    total = 0
    for f in os.listdir(LIMPIAS):
        if not f.endswith(".md") or f.startswith(("00-", "11-")):
            continue
        t = open(os.path.join(LIMPIAS, f), encoding="utf-8").read()
        t = re.sub(r"<!--.*?-->", "", t, flags=re.S)
        t = re.sub(r"[#*|`>_]", " ", t)
        total += len([w for w in t.split() if re.search(r"\w", w)])
    return total

def compilar_miniaturas():
    """Compila el documento entero a miniaturas (16 ppi). Devuelve (ok, stderr)."""
    gen = ESTADO["generacion"] + 1
    destino = os.path.join(CACHE, f"g{gen}")
    os.makedirs(destino, exist_ok=True)
    t0 = time.time()
    rc, err = typst(["compile", "memoria.typ", os.path.join(destino, "m-{p}.png"), "--ppi", "16"])
    if rc != 0:
        shutil.rmtree(destino, ignore_errors=True)
        return False, err
    n = len([f for f in os.listdir(destino) if f.startswith("m-")])
    try:
        mapa = json.loads(subprocess.run([TYPST, "query", "memoria.typ", "<mapa-paginas>", "--field", "value", "--one",
                                          "--font-path", os.path.join(DIAG, "fonts"), "--root", PROY],
                                         cwd=DIAG, capture_output=True, text=True, timeout=240).stdout)
    except Exception:
        mapa = ESTADO["mapa"]
    ESTADO.update(generacion=gen, paginas=n, advertencias=resumir_stderr(err), error=None,
                  segundos=round(time.time() - t0, 1), hora=time.strftime("%H:%M:%S"),
                  mapa=mapa, palabras=contar_palabras())
    # borra generaciones viejas (deja las dos últimas)
    for d in os.listdir(CACHE):
        if d.startswith("g") and d[1:].isdigit() and int(d[1:]) < gen - 1:
            shutil.rmtree(os.path.join(CACHE, d), ignore_errors=True)
    return True, err

def pagina_png(gen, p):
    """PNG de una página a 110 ppi, en caché por generación."""
    destino = os.path.join(CACHE, f"g{gen}")
    ruta = os.path.join(destino, f"p-{p}.png")
    if not os.path.exists(ruta):
        with LOCK:
            if not os.path.exists(ruta):
                rc, err = typst(["compile", "memoria.typ", os.path.join(destino, "p-{p}.png"),
                                 "--ppi", "110", "--pages", str(p)])
                if rc != 0:
                    return None
    return ruta if os.path.exists(ruta) else None

def recompilar():
    with LOCK:
        ok, err = compilar_miniaturas()
        if not ok:
            ESTADO["error"] = resumir_stderr(err) or [{"tipo": "error", "texto": err[-400:], "donde": ""}]
        return ok

# ── capítulos ──────────────────────────────────────────────────────────────────
def capitulos():
    src = open(os.path.join(DIAG, "memoria.typ"), encoding="utf-8").read()
    caps = [{"num": "00", "titulo": "Resumen y abstract", "archivo": "00-resumen.md"}]
    for num, tit, arch in re.findall(r'\("([0-9a-z]+)",\s*"([^"]+)",\s*"([^"]+\.md)"\)', src):
        caps.append({"num": num, "titulo": tit, "archivo": arch})
    for c in caps:
        ruta = os.path.join(LIMPIAS, c["archivo"])
        t = open(ruta, encoding="utf-8").read() if os.path.exists(ruta) else ""
        t2 = re.sub(r"<!--.*?-->", "", t, flags=re.S)
        c["palabras"] = len([w for w in re.sub(r"[#*|`>_]", " ", t2).split() if re.search(r"\w", w)])
    return caps

def marcadores_desconocidos(texto):
    cat = {l["id"] for l in catalogo_lista()}
    malos = []
    for m in re.finditer(r"<!-- (fig|lado|pagina|img|fotos)(?::\s*(.*?))? -->", texto):
        tipo, arg = m.group(1), (m.group(2) or "").strip()
        if tipo in ("fig", "lado") and arg not in cat:
            malos.append(m.group(0))
        if tipo in ("img", "fotos"):
            for a in arg.split("|")[0].split(","):
                a = a.strip()
                if not a:
                    continue
                ok = os.path.exists(os.path.join(IMAGENES, a)) if "." in a else os.path.exists(os.path.join(FOTOS_SESION, a + ".jpg"))
                if not ok:
                    malos.append(m.group(0)); break
    return malos

# ── catálogo de láminas ───────────────────────────────────────────────────────
NOMBRES_APP = {
    "app-bereal": "BeReal → rastro", "app-maqueta": "Maqueta de alta fidelidad", "app-arquitectura": "Arquitectura de información",
    "app-onboarding": "Flujo de alta", "app-captura": "Flujo de captura diaria", "app-recuerdos": "Flujo de Recuerdos",
    "app-esquemas": "Esquemas de pantalla", "app-pantallas": "Pantallas finales", "app-icono": "Ícono",
    "app-sistema": "Sistema implementado", "app-distribucion": "Distribución",
}

def catalogo_lista():
    lam = open(os.path.join(DIAG, "laminas.typ"), encoding="utf-8").read()
    fotos = open(os.path.join(DIAG, "fotos.typ"), encoding="utf-8").read()
    items = []
    for fid, tit in re.findall(r'^\s*"([a-z0-9-]+)":\s*\("([^"]+)"', lam, re.M):
        if fid == "arbol":      # el árbol vive como lámina Typst legible (arbol.typ)
            continue
        items.append({"id": fid, "nombre": tit, "grupo": "Diagramas", "lado": True})
    items.append({"id": "arbol", "nombre": "Árbol de problemas", "grupo": "Diagramas", "lado": False})
    items.append({"id": "identidad", "nombre": "Identidad visual (3 láminas)", "grupo": "Identidad", "lado": False})
    for aid, nom in NOMBRES_APP.items():
        items.append({"id": aid, "nombre": nom, "grupo": "Aplicación", "lado": False})
    for fid, rot in re.findall(r'^\s*"(foto-[a-z]+)":\s*\("([^"]+)"', fotos, re.M):
        items.append({"id": fid, "nombre": rot, "grupo": "Fotos del testeo", "lado": False})
    # dónde se usa cada una
    usos = {}
    for f in sorted(os.listdir(LIMPIAS)):
        if f.endswith(".md"):
            t = open(os.path.join(LIMPIAS, f), encoding="utf-8").read()
            for m in re.finditer(r"<!-- (?:fig|lado):\s*([a-z0-9-]+) -->", t):
                usos.setdefault(m.group(1), []).append(f[:3].rstrip("-"))
    for it in items:
        it["usos"] = sorted(set(usos.get(it["id"], [])))
    return items

CAT_LOCK = threading.Lock()

def miniatura_lamina(lid):
    """PNG de la primera página de una lámina, en caché según las fuentes .typ."""
    if not re.fullmatch(r"[a-z0-9-]+", lid):
        raise PermissionError("id inválido")
    fuentes = [os.path.join(DIAG, f) for f in os.listdir(DIAG) if f.endswith(".typ")] + [REGLAS]
    sello = hashlib.sha1("".join(f"{os.path.getmtime(f):.0f}" for f in sorted(fuentes)).encode()).hexdigest()[:10]
    ruta = os.path.join(CACHE, "catalogo", f"{lid}-{sello}.png")
    if os.path.exists(ruta):
        return ruta
    with CAT_LOCK:
        if os.path.exists(ruta):
            return ruta
        os.makedirs(os.path.dirname(ruta), exist_ok=True)
        src = os.path.join(CATALOGO_TYP, f"{lid}.typ")
        with open(src, "w", encoding="utf-8") as f:
            f.write('#import "/diagramacion/laminas.typ": *\n#show: conf\n#lamina-por-id("' + lid + '")\n')
        tmp = os.path.join(CACHE, "catalogo", f"_{lid}-{{p}}.png")
        rc, err = typst(["compile", os.path.relpath(src, DIAG), tmp, "--ppi", "34", "--pages", "1"])
        hecho = tmp.replace("{p}", "1")
        if rc == 0 and os.path.exists(hecho):
            os.replace(hecho, ruta)
            return ruta
    return None

# ── imágenes ───────────────────────────────────────────────────────────────────
def slug(nombre):
    base, ext = os.path.splitext(nombre)
    import unicodedata
    base = unicodedata.normalize("NFKD", base).encode("ascii", "ignore").decode()
    base = re.sub(r"[^A-Za-z0-9_-]+", "-", base).strip("-").lower() or "imagen"
    return base[:60]

def usos_imagen(nombre, grupo):
    usos = []
    clave = nombre if grupo == "repositorio" else os.path.splitext(nombre)[0]
    for f in sorted(os.listdir(LIMPIAS)):
        if f.endswith(".md"):
            t = open(os.path.join(LIMPIAS, f), encoding="utf-8").read()
            for m in re.finditer(r"<!-- (?:img|fotos):\s*(.*?) -->", t):
                arch = [a.strip() for a in m.group(1).split("|")[0].split(",")]
                if clave in arch:
                    usos.append(f[:3].rstrip("-"))
    if grupo == "testeo" and ('"' + clave + '"') in open(os.path.join(DIAG, "fotos.typ"), encoding="utf-8").read():
        usos.append("láminas")
    return sorted(set(usos))

def lista_imagenes():
    out = []
    for grupo, carpeta in (("repositorio", IMAGENES), ("testeo", FOTOS_SESION)):
        if not os.path.isdir(carpeta):
            continue
        for f in sorted(os.listdir(carpeta)):
            if f.lower().endswith((".jpg", ".jpeg", ".png", ".webp")):
                ruta = os.path.join(carpeta, f)
                try:
                    with Image.open(ruta) as im:
                        w, h = im.size
                except Exception:
                    w = h = 0
                out.append({"grupo": grupo, "nombre": f, "bytes": os.path.getsize(ruta), "ancho": w, "alto": h,
                            "usos": usos_imagen(f, grupo)})
    return out

try:
    from PIL import Image, ImageOps
except ImportError:
    Image = None

def guardar_imagen(nombre, datos):
    if Image is None:
        raise RuntimeError("falta Pillow (pip install pillow)")
    if len(datos) > 40_000_000:
        raise ValueError("la imagen pesa más de 40 MB")
    try:
        im = Image.open(io.BytesIO(datos)); im.load()
    except Exception:
        raise ValueError("el archivo no es una imagen válida")
    if im.format not in ("JPEG", "PNG", "WEBP", "MPO"):
        raise ValueError("solo se aceptan JPG, PNG o WebP")
    im = ImageOps.exif_transpose(im)
    alfa = im.mode in ("RGBA", "LA") or (im.mode == "P" and "transparency" in im.info)
    im.thumbnail((2000, 2000), Image.LANCZOS)
    base = slug(nombre)
    ext = ".png" if alfa else ".jpg"
    destino, n = os.path.join(IMAGENES, base + ext), 2
    while os.path.exists(destino):
        destino = os.path.join(IMAGENES, f"{base}-{n}{ext}"); n += 1
    if alfa:
        im.save(destino, "PNG", optimize=True)
    else:
        im.convert("RGB").save(destino, "JPEG", quality=85, optimize=True, progressive=True)
    return os.path.basename(destino)

def miniatura_imagen(grupo, nombre):
    carpeta = IMAGENES if grupo == "repositorio" else FOTOS_SESION
    src = dentro(carpeta, nombre)
    ruta = os.path.join(CACHE, "imgs", grupo, f"{nombre}-{os.path.getmtime(src):.0f}.jpg")
    if not os.path.exists(ruta):
        os.makedirs(os.path.dirname(ruta), exist_ok=True)
        with Image.open(src) as im:
            im = ImageOps.exif_transpose(im); im.thumbnail((360, 360))
            im.convert("RGB").save(ruta, "JPEG", quality=80)
    return ruta

def multipart(handler):
    """Lee un único archivo de un formulario multipart (sin el módulo cgi, retirado en 3.13)."""
    ctype = handler.headers.get("Content-Type", "")
    m = re.search(r"boundary=(.+)", ctype)
    if not m:
        raise ValueError("formulario inválido")
    limite = ("--" + m.group(1).strip('"')).encode()
    largo = int(handler.headers.get("Content-Length", "0"))
    if largo > 45_000_000:
        raise ValueError("demasiado grande")
    cuerpo = handler.rfile.read(largo)
    for parte in cuerpo.split(limite):
        if b"filename=" in parte:
            cab, _, dat = parte.partition(b"\r\n\r\n")
            fn = re.search(rb'filename="([^"]*)"', cab)
            return (fn.group(1).decode("utf-8", "ignore") if fn else "imagen"), dat.rstrip(b"\r\n-")
    raise ValueError("no venía ningún archivo")

# ── HTTP ───────────────────────────────────────────────────────────────────────
class H(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def responder(self, cod, cuerpo, tipo="application/json; charset=utf-8", cache=False):
        if isinstance(cuerpo, (dict, list)):
            cuerpo = json.dumps(cuerpo, ensure_ascii=False).encode()
        elif isinstance(cuerpo, str):
            cuerpo = cuerpo.encode()
        self.send_response(cod)
        self.send_header("Content-Type", tipo)
        self.send_header("Content-Length", str(len(cuerpo)))
        self.send_header("Cache-Control", "max-age=86400" if cache else "no-store")
        self.end_headers()
        self.wfile.write(cuerpo)

    def archivo(self, ruta, tipo, cache=False):
        if not ruta or not os.path.exists(ruta):
            return self.responder(404, {"error": "no existe"})
        with open(ruta, "rb") as f:
            self.responder(200, f.read(), tipo, cache)

    def json_body(self):
        n = int(self.headers.get("Content-Length", "0"))
        if n > 5_000_000:
            raise ValueError("demasiado grande")
        return json.loads(self.rfile.read(n) or b"{}")

    def do_GET(self):
        try:
            u = urlparse(self.path); q = {k: v[0] for k, v in parse_qs(u.query).items()}
            if u.path in ("/", "/index.html"):
                return self.archivo(os.path.join(EDITOR, "estudio-memoria.html"), "text/html; charset=utf-8")
            if u.path == "/api/estado":
                e = dict(ESTADO)
                e["pdf_bytes"] = os.path.getsize(PDF_FINAL) if os.path.exists(PDF_FINAL) else None
                e["limite_palabras"] = LIMITE_PALABRAS; e["limite_pdf"] = LIMITE_PDF
                e["historial"] = len([f for f in os.listdir(HISTORIAL) if f.startswith("reglas-")])
                return self.responder(200, e)
            if u.path == "/api/esquema":
                return self.responder(200, esquema())
            if u.path == "/api/reglas":
                return self.responder(200, leer_reglas())
            if u.path == "/api/capitulos":
                return self.responder(200, capitulos())
            if u.path == "/api/capitulo":
                ruta = dentro(LIMPIAS, q.get("archivo", ""))
                t = open(ruta, encoding="utf-8").read()
                return self.responder(200, {"texto": t, "huella": huella(t), "desconocidos": marcadores_desconocidos(t)})
            if u.path == "/api/catalogo":
                return self.responder(200, catalogo_lista())
            if u.path == "/api/imagenes":
                return self.responder(200, lista_imagenes())
            m = re.fullmatch(r"/vista/(\d+)/(\d+)\.png", u.path)
            if m:
                return self.archivo(pagina_png(int(m.group(1)), int(m.group(2))), "image/png", cache=True)
            m = re.fullmatch(r"/mini/(\d+)/(\d+)\.png", u.path)
            if m:
                return self.archivo(os.path.join(CACHE, f"g{int(m.group(1))}", f"m-{int(m.group(2))}.png"), "image/png", cache=True)
            m = re.fullmatch(r"/lamina/([a-z0-9-]+)\.png", u.path)
            if m:
                return self.archivo(miniatura_lamina(m.group(1)), "image/png")
            m = re.fullmatch(r"/img/(repositorio|testeo)/(.+)", u.path)
            if m:
                return self.archivo(miniatura_imagen(m.group(1), unquote(m.group(2))), "image/jpeg", cache=True)
            if u.path == "/pdf":
                return self.archivo(PDF_FINAL, "application/pdf")
            return self.responder(404, {"error": "no existe"})
        except PermissionError as e:
            self.responder(403, {"error": str(e)})
        except Exception as e:
            traceback.print_exc(); self.responder(500, {"error": str(e)})

    def do_PUT(self):
        try:
            u = urlparse(self.path); q = {k: v[0] for k, v in parse_qs(u.query).items()}
            if u.path == "/api/reglas":
                cand, errores = validar_reglas(self.json_body())
                if errores:
                    return self.responder(422, {"error": "Valores fuera de rango", "detalle": errores})
                with LOCK:
                    previo = open(REGLAS, encoding="utf-8").read()
                    with open(REGLAS, "w", encoding="utf-8") as f:
                        json.dump(cand, f, ensure_ascii=False, indent=2)
                    ok, err = compilar_miniaturas()
                    if not ok:   # no se guarda lo que no compila
                        with open(REGLAS, "w", encoding="utf-8") as f:
                            f.write(previo)
                        return self.responder(422, {"error": "Con esos valores el documento no compila. No se guardó.",
                                                    "detalle": [x["texto"] for x in resumir_stderr(err)]})
                    with open(os.path.join(HISTORIAL, f"reglas-{ahora()}.json"), "w", encoding="utf-8") as f:
                        f.write(previo)
                return self.responder(200, {"ok": True, "estado": ESTADO})
            if u.path == "/api/capitulo":
                b = self.json_body()
                ruta = dentro(LIMPIAS, b.get("archivo", ""))
                actual = open(ruta, encoding="utf-8").read()
                if huella(actual) != b.get("huella"):
                    return self.responder(409, {"error": "El archivo cambió fuera del editor desde que lo abriste. Recárgalo antes de guardar para no pisar esos cambios.",
                                                "huella": huella(actual)})
                nuevo = b.get("texto", "")
                shutil.copy(ruta, os.path.join(HISTORIAL, f"{os.path.basename(ruta)}-{ahora()}"))
                with open(ruta, "w", encoding="utf-8") as f:
                    f.write(nuevo)
                ok = recompilar()
                if not ok:
                    return self.responder(200, {"ok": True, "huella": huella(nuevo), "aviso": "Guardado, pero el documento no compila.",
                                                "estado": ESTADO, "desconocidos": marcadores_desconocidos(nuevo)})
                return self.responder(200, {"ok": True, "huella": huella(nuevo), "estado": ESTADO,
                                            "desconocidos": marcadores_desconocidos(nuevo)})
            return self.responder(404, {"error": "no existe"})
        except PermissionError as e:
            self.responder(403, {"error": str(e)})
        except Exception as e:
            traceback.print_exc(); self.responder(500, {"error": str(e)})

    def do_POST(self):
        try:
            u = urlparse(self.path)
            if u.path == "/api/compilar":
                ok = recompilar()
                return self.responder(200 if ok else 422, ESTADO)
            if u.path == "/api/deshacer-reglas":
                hs = sorted(f for f in os.listdir(HISTORIAL) if f.startswith("reglas-") and not f.startswith("reglas-corrupto"))
                if not hs:
                    return self.responder(409, {"error": "No hay cambios de reglas para deshacer."})
                with LOCK:
                    shutil.copy(os.path.join(HISTORIAL, hs[-1]), REGLAS)
                    os.remove(os.path.join(HISTORIAL, hs[-1]))
                    asegurar_reglas()
                    compilar_miniaturas()
                return self.responder(200, {"ok": True, "reglas": leer_reglas(), "estado": ESTADO})
            if u.path == "/api/exportar":
                with LOCK:
                    rc, err = typst(["compile", "memoria.typ", PDF_FINAL])
                if rc != 0:
                    return self.responder(422, {"error": "No se pudo exportar.", "detalle": [x["texto"] for x in resumir_stderr(err)]})
                return self.responder(200, {"ok": True, "bytes": os.path.getsize(PDF_FINAL)})
            if u.path == "/api/imagenes":
                nombre, datos = multipart(self)
                final = guardar_imagen(nombre, datos)
                return self.responder(200, {"ok": True, "nombre": final})
            return self.responder(404, {"error": "no existe"})
        except (ValueError, RuntimeError) as e:
            self.responder(422, {"error": str(e)})
        except Exception as e:
            traceback.print_exc(); self.responder(500, {"error": str(e)})

    def do_DELETE(self):
        try:
            u = urlparse(self.path); q = {k: v[0] for k, v in parse_qs(u.query).items()}
            if u.path == "/api/imagenes":
                nombre = q.get("nombre", "")
                ruta = dentro(IMAGENES, nombre)
                if usos_imagen(nombre, "repositorio"):
                    return self.responder(409, {"error": "La imagen está en uso. Saca primero su marcador del texto."})
                shutil.move(ruta, os.path.join(HISTORIAL, f"img-{ahora()}-{nombre}"))
                return self.responder(200, {"ok": True})
            return self.responder(404, {"error": "no existe"})
        except PermissionError as e:
            self.responder(403, {"error": str(e)})
        except Exception as e:
            traceback.print_exc(); self.responder(500, {"error": str(e)})

def revisar_entorno():
    problemas = []
    if not os.path.exists(TYPST):
        problemas.append("No encontré typst. Instálalo con: brew install typst")
    else:
        v = subprocess.run([TYPST, "--version"], capture_output=True, text=True).stdout.strip()
        print("·", v)
    if not os.path.isdir(os.path.expanduser("~/Library/Caches/typst/packages/preview/cmarker")):
        problemas.append("Falta el paquete cmarker de Typst (se descarga la primera vez con internet).")
    if Image is None:
        problemas.append("Falta Pillow: pip3 install pillow (sin esto no se pueden subir imágenes).")
    return problemas

if __name__ == "__main__":
    asegurar_reglas()
    for p in revisar_entorno():
        print("⚠", p)
    print("· compilando por primera vez…")
    recompilar()
    print(f"· {ESTADO['paginas']} páginas en {ESTADO['segundos']} s")
    try:
        srv = ThreadingHTTPServer(("127.0.0.1", PUERTO), H)
    except OSError:
        print(f"✗ El puerto {PUERTO} está ocupado. ¿Ya hay un editor abierto? Prueba: PUERTO=8791 python3 {sys.argv[0]}")
        sys.exit(1)
    print(f"✓ Editor en http://127.0.0.1:{PUERTO}  (Ctrl+C para cerrar)")
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        print("\n· cerrado")
