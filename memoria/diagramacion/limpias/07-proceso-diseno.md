# 7. Proceso de diseño

En investigación por diseño, el recorrido es parte del argumento (Gaver, 2012). Por eso
este capítulo cuenta los errores y los cambios de rumbo con el mismo detalle que los
aciertos.

## 7.0 Las tres arquitecturas

<!-- fig:arquitecturas -->

El proyecto llegó a su forma actual después de abandonar dos arquitecturas completas. Las
tres versiones no fueron titubeos: convergieron en la misma conclusión, que el dato hay que
capturarlo en el origen.

1. **Entregable 1.** Análisis de voz (Web Speech API y BERT) y de rostro (ml5.faceMesh)
 en tres tramos. Se abandonó.
2. **Semestre 2.** Instalación museográfica de cuatro fases, con cuatro nodos ESP32,
 proyección por capas y una Raspberry Pi. El motor de metadatos quedaba atrapado en el
 problema del canal: las fotos de la semana anterior llegaban sin GPS. Se redujo al
 cierre simbólico dentro del evento.
3. **Versión vigente.** Capturar el dato dentro de la aplicación, en el momento. El
 formato social como caballo de Troya.

## 7.1 Naming

La aplicación se distribuyó en noviembre de 2026 bajo el nombre `rastrapp`. Ese nombre deja
ver el del proyecto, y el camuflaje dependía en parte de que la aplicación no anunciara lo
que era. Que no haya cambiado es un dato del estudio: forma parte de las condiciones en
que los participantes la aceptaron.

## 7.2 Logotipo e identidad

La identidad de rastro **no va en la aplicación**: se reserva para la revelación, es decir,
para el panel de la investigadora, el expediente y el montaje del evento. La decisión se
tomó el 1 de noviembre de 2026. El tema de la aplicación se repintó a una paleta neutra: el
verde del sistema pasó a blanco, y todas las pantallas heredaron el camuflaje desde un solo
archivo.

En la revelación, el lenguaje gráfico se construye sobre la **malla biométrica facial**: la
misma estructura de puntos con que el sistema lee un rostro se vuelve la imagen del
proyecto.

Por eso el sistema tiene dos pieles. La piel de rastro se arma sobre negro, papel y un lima
de alto contraste, con un verde de señal como acento. Su tipografía es monoespaciada, la
letra de las terminales y de los registros: Martian Mono y JetBrains Mono en esta memoria,
Space Mono en la convocatoria e IBM Plex Mono en el panel y la proyección. A eso la
convocatoria suma una versión bitmap del nombre, construida con puntos en rombo, grano y un
destello, que remite a una imagen degradada por la captura.

La piel de camuflaje, en cambio,
es la de la aplicación: negro puro, una superficie gris oscura, blanco y el gris secundario
de iOS, todo en Inter y sin verde, pixel ni grano. Entre una piel y otra solo cruza el
logotipo, la palabra en minúscula con punto final. Como aparece en el ícono y en el
encabezado de la aplicación, tiene que poder pasar por la marca de cualquier red social.

<!-- fig:identidad -->

## 7.3 Sistema de metadatos

La **prueba de canal** del 10 de octubre de 2026 midió qué canal de subida conserva los
metadatos de una fotografía. El resultado fue que prácticamente ninguno lo hace. Ese
fracaso fundamenta el proyecto: si el dato no viaja, hay que capturarlo donde nace.

La respuesta fue la **extracción en el origen**: el GPS se registra en el instante de la
foto, dentro de la aplicación. La ubicación se traduce a **comuna** mediante
*point-in-polygon* sobre los límites oficiales de la Región Metropolitana, en reemplazo de
la geocodificación inversa (Nominatim), que solo podía adivinar. Fue una decisión de
privacidad y no solo de precisión: la coordenada se descarta una vez asignada la comuna.

El **expediente térmico** se imprime en una Sewoo SLK-TS400 conectada por USB, con comandos
ESC/POS enviados mediante pyusb. Contiene el rostro, el registro completo de capturas y un
mapa con las comunas etiquetadas.

El pipeline de impresión solo funcionaba bien con piel clara: los rostros de piel oscura y
los tomados a contraluz salían negros. La **corrección de contraste por gamma** que lo
resolvió termina siendo un argumento del proyecto sobre sesgo biométrico, porque el aparato
de la obra reprodujo, sin que nadie lo programara, el sesgo que la obra denuncia.

La **primera captura real confirmada** fue la del alias `nadie-9924`: dos fotos y
coordenadas reales de Santiago. Es el primer registro completo del paso del gesto al dato.

## 7.4 Desarrollo de la aplicación

### La aplicación como fachada

La aplicación es el lugar donde la extracción ocurre, y tenía que cumplir dos funciones
opuestas a la vez: hacia el participante, ser una red social de una foto al día, mundana;
hacia el sistema, registrar en silencio el rostro, la ubicación y la galería de quien la
usa. Cada pantalla tiene una lectura para quien la mira y otra para lo que queda guardado.

### BeReal, referente directo de la aplicación

El referente directo es **BeReal**, la red social francesa de Alexis Barreyat y Kévin
Perreau lanzada en 2020 (Barreyat y Perreau, 2020): un aviso al día a una hora que nadie
conoce de antemano, igual para todos; una foto con la cámara frontal y la trasera a la
vez, sin filtros; y lo de los demás bloqueado hasta publicar lo propio. rastro toma esa
mecánica casi entera y le agrega lo que BeReal no hace: una capa de registro que el
participante no ve. Un patrón familiar no se interroga, y lo que no se interroga se
entrega sin fricción. Solo quedó fuera la ventana de dos minutos con marca de atraso: se
planificó y no se llegó a implementar.

<!-- fig:app-bereal -->

### De la maqueta a la versión de campo

La primera forma de la aplicación, antes del pivote del 20 de octubre, fue un lector de
metadatos EXIF, y la prueba de canal (7.3) mostró que ese camino estaba cerrado. El
desarrollo avanzó después en seis etapas:

0. **Maqueta clickeable (21 de octubre).** Cinco pantallas con el nombre provisional
 *momento* y un interruptor, «Ver lo que capturamos», que destapaba la capa oculta.
1. **Prototipo funcional (24 de octubre).** Feed, modo desarrollador oculto, avisos
 locales y captura con GPS guardada en el teléfono.
2. **Circuito completo (25 de octubre).** Cámara dual, subida a la nube, sistema social
 real, registro biométrico y términos y condiciones.
3. **Camuflaje (1 de noviembre).** La identidad de rastro salió de la aplicación (7.2).
4. **Recuerdos (8 de noviembre).** Lectura de la galería bajo la apariencia de recuerdos.
5. **Versión de campo (11 de noviembre).** La compilación 1.0.1+8, con GPS obligatorio,
 subida atómica y galería operativa.

De la maqueta a la aplicación cambiaron tres cosas: la identidad cálida de *momento* dio
paso al camuflaje; el pretexto biométrico pasó de «proteger tu diario» a «crear tu
avatar»; y la capa oculta salió de la aplicación para quedar solo en el panel y en el
expediente. Desde ahí el diseño siguió en código, sobre el teléfono, porque qué permiso se
pide, cuándo y con qué palabras solo se podía probar con la cámara y el GPS reales.

### Arquitectura de información

<!-- fig:app-arquitectura -->

La aplicación tiene dos zonas visibles: el alta, que se recorre una vez, y el uso diario,
en tres pestañas (Feed, Amigos y Perfil). Una tercera zona, la trastienda del modo
desarrollador, queda a una pulsación larga y el participante nunca la ve. La arquitectura
reproduce la del fenómeno que estudia: una interfaz pública y una capa de registro a la
que solo accede quien opera el sistema.

### Flujo de alta

<!-- fig:app-onboarding -->

El alta reproduce el trámite de cualquier aplicación social, y en él ocurren las tres
entregas que sostienen la revelación. Los **términos y condiciones** abren con cuatro
apartados simples y siguen con trece cláusulas jurídicas: todo lo recogido está declarado
y casi nadie lo lee. El **registro biométrico** se presenta como la creación de un avatar:
en iPhone, la persona sigue un punto con la nariz hasta completar un anillo, un gesto
parecido al de Face ID; en Android, una selfie de frente. Ese rostro es el que, en el
evento, abre el expediente. El **perfil** pide una foto elegida, distinta del rostro
biométrico, de modo que la cara pública y la retenida quedan en archivos separados. No se
pide correo, y los permisos se piden con textos neutros.

### Flujo de captura diaria

<!-- fig:app-captura -->

Una vez al día llega el aviso, «¡Es tu momento! ✨», a una hora que sale de una agenda en
el servidor. La cámara dual dispara trasera y frontal en el mismo instante; la persona ve
una foto doble y el sistema guarda, en ese mismo segundo, latitud, longitud, precisión,
hora y alias. Publicar desbloquea lo de los demás: nadie mira sin mostrar. Ninguna
pantalla muestra la ubicación al participante: la asimetría que el proyecto denuncia está
implementada en la interfaz.

### Flujo de Recuerdos

<!-- fig:app-recuerdos -->

Recuerdos es la función que hace más visible el engaño autorizado. Se presenta como
**«Un día como hoy»**, el patrón conocido de las galerías del teléfono, mientras la
aplicación lee en el propio teléfono la fecha y el GPS de todo el carrete y agrupa las
coordenadas en lugares de 80 metros: casa, trabajo o estudio, tercer lugar. Al servidor
suben el resumen y diez fotos elegidas a ciegas por ubicación; la investigadora cura
cinco y descarta lo que podría exponer algo íntimo. El aviso de activación tiene una sola
opción, «Activar», y se repite hasta que la persona escanea su galería.

### Esquemas, pantallas e ícono

<!-- fig:app-esquemas -->

Los esquemas muestran una interfaz casi vacía a propósito: cada pantalla pide una sola cosa
sin dar motivos para detenerse.

<!-- fig:app-pantallas -->

Las pantallas finales visten esa estructura con la piel de camuflaje. El único rastro de
la marca es la palabra «rastro.» en el encabezado, como cualquier otra red social.

<!-- fig:app-icono -->

El ícono es esa misma palabra en blanco sobre negro. En Android hubo que separarlo en dos
capas, porque la máscara del sistema solo garantiza el 61% central y con el arte de iOS se
leía «astro». La ficha de Google Play describe una aplicación de una foto al día y no
menciona ubicación, metadatos ni el estudio.

### Sistema implementado

<!-- fig:app-sistema -->

La aplicación está escrita en Flutter, con la cámara dual de iPhone en código nativo
(`AVCaptureMultiCamSession`). El servidor es Supabase: guarda perfiles, capturas, agenda,
amistades, comentarios, reacciones, Recuerdos y un «latido» por teléfono que permite
seguir la conducta después de la revelación. Las capturas son de solo escritura y lectura,
y el borrado de un participante elimina en cascada todo lo asociado a su alias. Del otro
lado está el panel de la investigadora (7.7).

### Distribución: cómo se compartió

<!-- fig:app-distribucion -->

La aplicación se distribuyó por los canales de prueba de cada plataforma, TestFlight en
iPhone y la prueba interna de Google Play en Android, bajo la cuenta de un colaborador.
La convocatoria se difundió por Instagram y llevaba a un formulario sin mención a
metadatos; en la planilla, una casilla enviaba a cada persona el correo con sus
instrucciones de instalación, y su semana de siete días partía el día en que instalaba.
Cada canal filtró la muestra a su manera: en iPhone la invitación llegaba a nombre de un
desconocido, y en Android el enlace solo funcionaba con la cuenta exacta de la lista
(8.1). La distribución tampoco fue estable: Apple bloqueó el certificado el 8 de
noviembre, Play rechazó el paquete nuevo hasta el 13, y la versión 1.0.1+8 llegó a
TestFlight el 11.

### Implementación en terreno

La aplicación operó entre el 4 y el 15 de noviembre de 2026 en los teléfonos de las nueve
personas inscritas (10.5), además de teléfonos de prueba. Al 8 de noviembre había 54
capturas, 49 con coordenadas, y la primera semana dejó ver fallas que ninguna prueba
previa había mostrado (7.5). También mostró que la exposición es una elección: **Mon fue
la única participante que no concedió los permisos que la extracción necesitaba**. Negó
la ubicación y no activó la galería, y sus capturas llegaron sin GPS ni foto frontal. La
aplicación funcionó igual para ella; lo que cambió fue lo que el sistema pudo saber
(10.7).

## 7.5 Implementación de código (Flutter)

En esta etapa el recorrido técnico se vuelve argumento.

**Del computador al teléfono (20 al 25 de octubre).** El entorno se montó desde cero, con
incompatibilidades entre versiones y el disco casi lleno, y la aplicación se instaló en un
iPhone físico compilando por fuera de Flutter. Tres errores del código nativo de la cámara
se resolvieron con los registros del propio teléfono: el simulador no tiene cámara y su
GPS es simulado, así que no servía.

**El esquema versionado y la base de datos no coincidían (3 de noviembre).** Una columna
que existía en el archivo de esquema nunca se había creado en la base. La subida de la
foto de perfil fallaba en silencio y la aplicación usaba como respaldo el rostro del
registro biométrico: **a los demás se les mostraba ese rostro como foto de perfil**. Fue
el error más grave del proyecto, exactamente donde la obra prometía separar la cara
pública de la identidad retenida, y se detectó antes de abrir la aplicación a
participantes.

**El fallo silencioso.** La misma forma de error reapareció en terreno: la subida de
capturas no era atómica y la galería nunca había subido nada en producción, porque el
código tragaba los errores. Se corrigió haciendo el fallo ruidoso y verificando contra
los registros del servidor, no contra lo que la aplicación decía.

**La base de datos como único grado de libertad.** Con la aplicación en la cuenta de un
tercero, cambiar código dependía de otra persona y de la revisión de Apple. Las correcciones
de comportamiento se resolvieron en la base y entraron sin publicar una versión nueva:
cuando la distribución depende de otros, la arquitectura define cuánto se puede corregir a
mitad de un estudio.

**El reconocimiento en el panel: de la escena al mecanismo.** La identificación pasó de una
selección manual a una comparación real de descriptores faciales de 128 dimensiones: el
sistema propone y la investigadora confirma, sin que ninguna imagen salga de su
computador. Eso obligó a corregir lo que la documentación declaraba («match manual, nunca
automático»). Si una memoria declara una postura ética, el código tiene que poder
sostenerla; aquí lo que se ajustó fue la declaración. La seguridad de los repositorios y
de los mapas se detalla en 8.3.

## 7.6 Metodología de trabajo

El registro del proceso forma parte del método: la bitácora del proyecto, un registro datado
de cada decisión, cada falla y cada pivote, es la fuente primaria de este capítulo.

## 7.7 El evento: la revelación en vivo (16 de noviembre de 2026)

El montaje convirtió la arquitectura en una sala operando. Tres servidores corrían en el
computador de la investigadora: archivos, el puente que conecta el iPad escáner con el
monitor, e impresión térmica. El iPad reconoce el rostro con comparación facial local
(ninguna imagen sale del equipo), la investigadora confirma con un toque, y recién ahí la
identidad aparece proyectada. La máquina propone; la persona decide cuándo mostrar.

### El panel de rastro: desde ahí se manejaba todo

<!-- fig:foto-panel -->

La sesión entera se operaba desde el **panel de rastro**, una página web que corre en el
computador de la investigadora y lee la base del estudio; durante la semana fue también
el lugar desde donde se siguió el estudio. Sus diez pestañas van de lo crudo a lo
inferido: el resumen, el mapa con todos los puntos, cada captura con su ubicación, el
rostro de registro de cada persona, la identificación en vivo, los patrones de rutina, el
seguimiento posterior a la revelación, el expediente con su impresión y su borrado, la
curaduría de la galería y las pantallas de proyección.

En la sala, el panel coordinaba los tres aparatos de la revelación: el **iPad** que escanea
el rostro, el **monitor vertical** que muestra la malla, la identidad confirmada y después
la galería, y la **impresora térmica**, que recibe el expediente con un botón, sin el
diálogo del navegador que habría dejado ver la tramoya frente a la persona.

### La versión sin conexión

La sala probablemente no tendría internet, y en vez de buscar mejor señal se decidió no
necesitarla. El 12 de noviembre se construyó una **versión sin conexión**: un script
copia a un disco externo las tablas, las fotos y rostros, la galería, los modelos de
reconocimiento facial y el mapa de cada expediente, unos 203 MB. El panel y la impresión
leen esa copia y pasan a ella solos si la red no responde en ocho segundos. Se probó con
la red cortada, y el riesgo apareció solo ese mismo día, cuando el servidor dejó de
responder unos minutos. Tiene dos costos declarados: sin red no se puede marcar
«revelado» ni borrar datos en el momento, y la copia es un segundo depósito de datos
sensibles que se borra al cerrar el estudio.

### En la sala

<!-- fig:foto-escaner -->

<!-- fig:foto-impresion -->

**La impresora como recurso disputado.** El expediente térmico fallaba por permisos: dos
procesos se disputaban el puerto USB. Liberarlo antes de imprimir quedó en el protocolo de
montaje.

**El expediente falso, en vivo.** Sobre una cara real capturada en el momento se imprimió
una ficha a nombre de otra persona, con domicilio y carrera inventados. No es un accidente
de la obra: es su tesis ejecutada, lo fácil que es fabricar un expediente convincente sobre
un cuerpo que no eligió estar ahí.

## Conclusiones

El proceso dejó una lección que se repitió en cada etapa: lo que falla en silencio no se
corrige. La galería que nunca subió nada, el rostro que aparecía como foto de perfil, los
mapas que devolvían la misma imagen. rastro trata sobre sistemas que operan sin ser
vistos, y su propio desarrollo lo comprobó, porque cada corrección empezó por hacer visible
la falla antes de arreglarla.
