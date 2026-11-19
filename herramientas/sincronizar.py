#!/usr/bin/env python3
"""
sincronizar.py — copia la memoria de rastro (tu carpeta local) al sitio web.

Copia solo los archivos que memoria.typ usa de verdad (según `typst --deps`), deja el
paquete cmarker dentro del proyecto, junta las fuentes, arma las miniaturas de las láminas
y escribe el manifiesto que el editor web carga. Al final compila la copia con el mismo
Typst que corre en el navegador (0.14) y sin fuentes del sistema, para asegurar que el
sitio vea lo mismo que tu computador.

Uso:
  python3 herramientas/sincronizar.py              fotos del testeo reemplazadas por recuadros
  python3 herramientas/sincronizar.py --con-fotos  publica las fotos del testeo
  --fuentes-fijas   convierte las fuentes variables en fijas (solo si el editor web vuelve a un Typst < 0.15)
  TYPST_WEB=/ruta/a/typst  Typst de la misma versión que el navegador, para la verificación final
"""
import hashlib, json, os, re, shutil, subprocess, sys, tempfile

AQUI = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(AQUI)
SRC = os.path.expanduser(os.environ.get("MEMORIA", "~/Desktop/memoria"))
DIAG = os.path.join(SRC, "diagramacion")
DST = os.path.join(REPO, "memoria")
CON_FOTOS = "--con-fotos" in sys.argv
TYPST = shutil.which("typst") or "/opt/homebrew/bin/typst"
TYPST_WEB = os.environ.get("TYPST_WEB", TYPST)
FIJAS = "--fuentes-fijas" in sys.argv
CMARKER = os.path.expanduser("~/Library/Caches/typst/packages/preview/cmarker/0.1.6")
LIB = os.path.expanduser("~/Library/Fonts")
# fuentes que la memoria toma del sistema en tu Mac; en la web van incluidas
FUENTES_SISTEMA = ["Inter_24pt-Regular.ttf", "Inter_24pt-Bold.ttf", "InterTight-VariableFont_wght.ttf"]

def paso(t): print("·", t, flush=True)

# 1. qué archivos usa la memoria
paso("Calculando dependencias con Typst…")
deps = os.path.join(tempfile.mkdtemp(), "deps.json")
subprocess.run([TYPST, "compile", "memoria.typ", os.path.join(tempfile.mkdtemp(), "x.pdf"), "--font-path", "fonts",
                "--root", "..", "--deps", deps, "--deps-format", "json"], cwd=DIAG, check=True, capture_output=True)
entradas = []
for f in json.load(open(deps))["inputs"]:
    a = os.path.normpath(os.path.join(DIAG, f))
    if a.startswith(SRC + os.sep):
        entradas.append(os.path.relpath(a, SRC))
# además: todos los capítulos, las reglas y las imágenes del repositorio (se pueden insertar desde el editor)
for d, ext in (("diagramacion/limpias", ".md"), ("diagramacion/imagenes", "")):
    p = os.path.join(SRC, d)
    if os.path.isdir(p):
        entradas += [os.path.join(d, f) for f in os.listdir(p) if f.endswith(ext) and not f.startswith(".")]
entradas += ["diagramacion/editor/esquema.json", "diagramacion/editor/reglas.json"]
entradas = sorted(set(entradas))

# 2. copia limpia
paso(f"Copiando {len(entradas)} archivos…")
if os.path.isdir(DST): shutil.rmtree(DST)
for r in entradas:
    os.makedirs(os.path.dirname(os.path.join(DST, r)), exist_ok=True)
    shutil.copy2(os.path.join(SRC, r), os.path.join(DST, r))

# cmarker dentro del proyecto: el import apunta a la copia local
os.makedirs(os.path.join(DST, "vendor/cmarker"), exist_ok=True)
for f in ("lib.typ", "plugin.wasm", "typst.toml", "LICENSE"):
    if os.path.exists(os.path.join(CMARKER, f)): shutil.copy2(os.path.join(CMARKER, f), os.path.join(DST, "vendor/cmarker", f))
for r in entradas:
    if r.endswith(".typ"):
        p = os.path.join(DST, r); t = open(p, encoding="utf-8").read()
        t2 = t.replace('#import "@preview/cmarker:0.1.6"', '#import "/vendor/cmarker/lib.typ" as cmarker')
        if t2 != t: open(p, "w", encoding="utf-8").write(t2)

# 3. fuentes
# Typst 0.15 (el del navegador y el local) usa las fuentes variables tal cual. Con
# --fuentes-fijas, para un Typst anterior que no sabe usarlas, cada fuente variable se
# publica como fuentes fijas, una por grosor, con el resto de los ejes por defecto.
paso("Juntando fuentes" + (" (y fijando las variables)…" if FIJAS else "…"))
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
fdst = os.path.join(DST, "fuentes"); os.makedirs(fdst, exist_ok=True)
NOMBRE_PESO = {100: "Thin", 200: "ExtraLight", 300: "Light", 400: "Regular", 500: "Medium", 600: "SemiBold", 700: "Bold", 800: "ExtraBold", 900: "Black"}
def fijar(ruta):
    t = TTFont(ruta)
    if "fvar" not in t or not FIJAS:
        shutil.copy2(ruta, fdst); return
    familia = t["name"].getDebugName(16) or t["name"].getDebugName(1)
    italica = bool(t["OS/2"].fsSelection & 1) or "Italic" in os.path.basename(ruta)
    eje = {a.axisTag: a for a in t["fvar"].axes}
    for w in range(300, 900, 100):
        if not (eje["wght"].minValue <= w <= eje["wght"].maxValue): continue
        f = TTFont(ruta)
        pos = {k: (w if k == "wght" else a.defaultValue) for k, a in eje.items()}
        inst = instantiateVariableFont(f, pos)
        estilo = NOMBRE_PESO[w] + (" Italic" if italica else "")
        estilo = "Italic" if estilo == "Regular Italic" else estilo
        n = inst["name"]
        for rec in list(n.names):
            if rec.nameID in (1, 16): n.setName(familia, rec.nameID, rec.platformID, rec.platEncID, rec.langID)
            elif rec.nameID in (2, 17): n.setName(estilo, rec.nameID, rec.platformID, rec.platEncID, rec.langID)
            elif rec.nameID == 4: n.setName(f"{familia} {estilo}", 4, rec.platformID, rec.platEncID, rec.langID)
            elif rec.nameID == 6: n.setName((familia + "-" + estilo).replace(" ", ""), 6, rec.platformID, rec.platEncID, rec.langID)
        inst["OS/2"].usWeightClass = w
        inst.save(os.path.join(fdst, (familia + "-" + estilo).replace(" ", "") + ".ttf"))
for f in os.listdir(os.path.join(DIAG, "fonts")):
    if f.lower().endswith((".ttf", ".otf")): fijar(os.path.join(DIAG, "fonts", f))
for f in FUENTES_SISTEMA:
    if os.path.exists(os.path.join(LIB, f)): fijar(os.path.join(LIB, f))
    else: print("  ! falta", f)
print(f"  {len(os.listdir(fdst))} archivos de fuente")
emoji = os.path.join(REPO, "herramientas/NotoEmoji-Regular.ttf")
if os.path.exists(emoji): shutil.copy2(emoji, fdst)

# 4. fotos del testeo
fotos = os.path.join(DST, "diagramacion/fotos-sesion")
if not CON_FOTOS and os.path.isdir(fotos):
    paso("Reemplazando las fotos del testeo por recuadros (usa --con-fotos para publicarlas)…")
    from PIL import Image, ImageDraw
    for f in os.listdir(fotos):
        p = os.path.join(fotos, f)
        with Image.open(p) as im: w, h = im.size
        im = Image.new("L", (w, h), 70); d = ImageDraw.Draw(im)
        d.rectangle([0, 0, w - 1, h - 1], outline=110, width=max(2, w // 300))
        d.line([0, 0, w, h], fill=90, width=max(1, w // 600)); d.line([0, h, w, 0], fill=90, width=max(1, w // 600))
        im.save(p, "JPEG", quality=70)

# 4b. el editor local, para que el repo guarde ambas versiones
loc = os.path.join(REPO, "local"); os.makedirs(loc, exist_ok=True)
for f in ("estudio-memoria.html", "servidor_memoria.py", "abrir-editor.command", "ROAST.md"):
    if os.path.exists(os.path.join(DIAG, "editor", f)): shutil.copy2(os.path.join(DIAG, "editor", f), loc)

# 5. manifiesto
paso("Escribiendo el manifiesto…")
archivos = []
for raiz, _, fs in os.walk(DST):
    for f in fs:
        if f.startswith(".") or f == "manifiesto.json": continue
        p = os.path.join(raiz, f); r = os.path.relpath(p, DST)
        archivos.append({"ruta": "/" + r, "bytes": os.path.getsize(p),
                         "huella": hashlib.sha1(open(p, "rb").read()).hexdigest()[:12]})
archivos.sort(key=lambda x: x["ruta"])
json.dump({"fotos_publicadas": CON_FOTOS, "archivos": archivos}, open(os.path.join(DST, "manifiesto.json"), "w"), ensure_ascii=False, indent=0)

# 6. miniaturas de las láminas, compiladas desde la copia
paso("Dibujando miniaturas de las láminas…")
sys.path.insert(0, os.path.join(DIAG, "editor"))
lam = open(os.path.join(DST, "diagramacion/laminas.typ"), encoding="utf-8").read()
fot = open(os.path.join(DST, "diagramacion/fotos.typ"), encoding="utf-8").read()
ids = [i for i in re.findall(r'^\s*"([a-z0-9-]+)":\s*\("', lam, re.M) if i != "arbol"] + ["arbol", "identidad"]
ids += re.findall(r'"(app-[a-z]+)"', open(os.path.join(DST, "diagramacion/app.typ"), encoding="utf-8").read())
ids += re.findall(r'^\s*"(foto-[a-z]+)":\s*\("', fot, re.M)
ids = list(dict.fromkeys(ids))
cat = os.path.join(REPO, "catalogo"); shutil.rmtree(cat, ignore_errors=True); os.makedirs(cat)
tmpd = os.path.join(DST, "diagramacion/_cat"); os.makedirs(tmpd, exist_ok=True)
hechas = []
for i in ids:
    src = os.path.join(tmpd, i + ".typ")
    open(src, "w").write('#import "/diagramacion/laminas.typ": *\n#show: conf\n#lamina-por-id("' + i + '")\n')
    r = subprocess.run([TYPST, "compile", src, os.path.join(cat, i + "-{p}.png"), "--ppi", "34", "--pages", "1",
                        "--root", DST, "--font-path", fdst, "--ignore-system-fonts"], capture_output=True, text=True)
    if r.returncode == 0 and os.path.exists(os.path.join(cat, i + "-1.png")):
        os.replace(os.path.join(cat, i + "-1.png"), os.path.join(cat, i + ".png")); hechas.append(i)
shutil.rmtree(tmpd)
# índice del catálogo: solo las láminas que existen (las borradas de la memoria no compilan y quedan fuera)
sys.path.insert(0, os.path.join(DIAG, "editor"))
from servidor_memoria import NOMBRES_APP
titulos = dict(re.findall(r'^\s*"([a-z0-9-]+)":\s*\("([^"]+)"', lam, re.M))
rotulos = dict(re.findall(r'^\s*"(foto-[a-z]+)":\s*\("([^"]+)"', fot, re.M))
indice = []
for i in hechas:
    if i in rotulos: indice.append({"id": i, "nombre": rotulos[i], "grupo": "Fotos del testeo", "lado": False})
    elif i in NOMBRES_APP: indice.append({"id": i, "nombre": NOMBRES_APP[i], "grupo": "Aplicación", "lado": False})
    elif i == "arbol": indice.append({"id": i, "nombre": "Árbol de problemas", "grupo": "Diagramas", "lado": False})
    elif i == "identidad": indice.append({"id": i, "nombre": "Identidad visual (3 láminas)", "grupo": "Identidad", "lado": False})
    else: indice.append({"id": i, "nombre": titulos.get(i, i), "grupo": "Diagramas", "lado": True})
orden = ["Diagramas", "Identidad", "Aplicación", "Fotos del testeo"]
indice.sort(key=lambda x: orden.index(x["grupo"]))
json.dump(indice, open(os.path.join(cat, "indice.json"), "w"), ensure_ascii=False, indent=1)
print(f"  {len(hechas)} láminas en el catálogo (las {len(ids) - len(hechas)} restantes ya no están en la memoria)")

# 7. verificación con el Typst del navegador y sin fuentes del sistema
paso(f"Verificando con {subprocess.run([TYPST_WEB, '--version'], capture_output=True, text=True).stdout.strip()}…")
out = os.path.join(tempfile.mkdtemp(), "web.pdf")
r = subprocess.run([TYPST_WEB, "compile", "diagramacion/memoria.typ", out, "--root", ".", "--font-path", "fuentes", "--ignore-system-fonts"],
                   cwd=DST, capture_output=True, text=True)
avisos = sorted(set(l for l in r.stderr.splitlines() if l.startswith(("error", "warning"))))
for a in avisos: print("  ", a)
if r.returncode != 0: sys.exit("La copia no compila: revisa los errores de arriba.")
paginas = subprocess.run(["pdfinfo", out], capture_output=True, text=True).stdout
print("  ok ·", re.search(r"Pages:\s+(\d+)", paginas).group(1), "páginas ·",
      round(sum(a["bytes"] for a in archivos) / 1e6, 1), "MB publicados ·", "con fotos" if CON_FOTOS else "fotos reservadas")
