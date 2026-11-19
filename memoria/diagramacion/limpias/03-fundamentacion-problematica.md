# 3. Fundamentación y problemática

Saber que te extraen datos no cambia lo que haces. Esa paradoja es el problema del
proyecto, y aquí se mide con la encuesta propia, se ordena en un árbol de problemas y se
pone a prueba con el ensayo que mostró por qué el dato había que capturarlo en el origen.

## 3.1 Problemática

Cada vez que alguien desbloquea su teléfono, acepta unas condiciones que no leyó o camina
frente a una cámara conectada a internet, algo ocurre que esa persona no percibe: sus datos
son capturados, procesados y comercializados en fracciones de segundo. No hay sonido, no
hay vibración, no hay señal. El sistema está diseñado para que no haya ninguna.

A escala global, el 82% de los usuarios de internet declara alta preocupación por cómo se
recopila su información personal (DataStackHub, 2025). Sin embargo, el 62% considera
imposible transitar la vida diaria sin que las empresas accedan a sus datos, y solo el 3%
afirma comprender cómo funcionan las leyes de privacidad vigentes (Termly, 2025). Las
empresas saben y los usuarios no, y esa asimetría es el modelo de negocio, lejos de ser un
accidente. La
política de privacidad promedio tiene cerca de 6.500 palabras, más de 27 minutos de
lectura, pero los usuarios dedican en promedio 48 segundos a revisarla, alcanzando a leer
aproximadamente el 5% del documento (NordVPN, 2023; Linklaters, 2024). El consentimiento
existe en papel. La comprensión, no.

En Chile, el fenómeno tiene escala propia. Durante 2024 el país registró más de 6.400
millones de intentos de ciberataques y concentró el 7% de los ataques en Latinoamérica
(Entel Digital, 2025). La Ley N° 21.719, publicada en diciembre de 2024, moderniza la
regulación de datos personales, pero su entrada en vigencia está fijada para diciembre de
2026. Mientras la ley espera, la extracción opera. Según la primera Encuesta de Servicios
Digitales de la Alianza Chilena de Ciberseguridad, solo el 22,2% de los chilenos afirma
entender cómo se usan sus datos en plataformas digitales, y apenas el 18,6% siente tener
algún control sobre su información (Alianza Chilena de Ciberseguridad y Cybertrust, 2026).

Al desconocimiento se suma otra falla medible. El Instituto Nacional de Estándares y
Tecnología de Estados Unidos analizó cientos de algoritmos comerciales de reconocimiento
facial y encontró tasas de falso positivo significativamente más altas para personas
asiáticas, afroamericanas e indígenas americanas que para personas de piel clara (Grother
et al., 2019). Buolamwini y Gebru (2018) documentaron una tasa de error de 34,7% en mujeres
de piel oscura frente a 0,8% en hombres de piel clara en los mismos sistemas de
clasificación facial. En reconocimiento de voz, Koenecke et al. (2020) encontraron una tasa
de error de 0,35 en hablantes afroamericanos frente a 0,19 en hablantes blancos, casi el
doble, atribuible al modelo acústico y no al vocabulario.

Estas fallas
fueron medidas con rigor académico, publicadas y ampliamente cubiertas por prensa. Y sin
embargo, agencias gubernamentales como Immigration and Customs Enforcement en Estados
Unidos continúan desplegando estos mismos sistemas para decidir a quién detener, mientras
el margen de error documentado sigue sin corregirse. A diferencia del desconocimiento del
usuario, medido en Chile con datos nacionales precisos, no se encontró evidencia de
investigación de alcance nacional sobre sesgo algorítmico medido en sistemas chilenos. Lejos de
tranquilizar, esa ausencia indica que este segundo eje del problema recibe
mucha menos auditoría que el primero.

### Aristas del problema

<!-- fig:arbol -->

**Invisibilidad estructural de la extracción.** La preocupación coexiste con un
desconocimiento estructural. A nivel mundial, el 63% de los consumidores cree que las
empresas no son transparentes sobre el uso de su información (XtendedView, 2025). El 53% de
las aplicaciones gratuitas de iOS declara recopilar datos de privacidad, frente al 13,7% de
las de pago (Countly, 2025). La invisibilidad forma parte de la arquitectura
del sistema (Bridle, 2018).

**Resignación informada como respuesta dominante.** La gente sabe, pero saber no alcanza. La encuesta aplicada en esta investigación (N=49) lo
confirma, y se detalla más abajo.

**Impunidad del error medido.** Los sistemas de reconocimiento facial y de voz fallan de
forma medible, pública y verificada, y eso tampoco garantiza corrección. No es una falla
puntual de aplicación: es un vacío regulatorio generalizado. Nueva York exige por ley
auditorías independientes de sesgo para herramientas automatizadas de contratación, y aun
así un estudio sobre su implementación encontró que la norma no obliga a ninguna empresa a
corregir ni a dejar de usar un sistema que la propia auditoría revele sesgado: solo exige
publicar el resultado (Groves et al., 2024). De los miles de empleadores sujetos a la ley,
los investigadores hallaron apenas diecinueve auditorías publicadas. Saberlo, medirlo,
probarlo y hasta legislarlo tampoco basta.

**Ausencia de mediadores sensoriales.** Lo que conecta estas tres aristas son dos
condiciones entrelazadas. Cuando el sistema opera en secreto, la ausencia de estímulo
perceptible impide que el conocimiento se convierta en acción: leer una política de
privacidad no activa ninguna respuesta visceral (Ihde, 1990). Cuando el error se mide, se
publica y se demuestra con rigor, la ausencia de consecuencia revela un segundo umbral: ni
siquiera la evidencia pública garantiza corrección si nadie sostiene la presión sobre quien
la produce. Ambos umbrales comparten una misma raíz: sin una experiencia que el cuerpo
registre como propia, ni el desconocimiento ni el conocimiento verificado se traducen en
agencia real.

### La encuesta propia (N=49)

<!-- fig:encuesta -->

La encuesta de percepción y comportamiento digital aplicada en esta investigación es la
evidencia primaria de la problemática. Es chilena, es propia y es del año, a diferencia de
buena parte de las cifras internacionales disponibles.

| Dato | Cifra |
|---|---|
| Declara consciencia alta o máxima sobre la recopilación de sus datos (4–5/5) | 67% |
| Acepta términos y condiciones sin leerlos | 61% |
| Nombra la **resignación**, antes que la indiferencia o la confusión, como su emoción principal | 47% |
| Converge en tres variantes de la misma parálisis | 77% |
| · no sé por dónde empezar | 39% |
| · es muy complicado técnicamente | 22% |
| · creo que igual me van a rastrear | 16% |

El 67% declara consciencia alta o máxima sobre la recopilación de sus datos, y aun así el
61% acepta los términos sin leerlos. Casi la mitad nombra la resignación como su respuesta
emocional principal. El hallazgo más preciso es el 77%, porque muestra que lo que frena a las personas es la
desorientación, más que la indiferencia. No hay ningún punto de entrada al problema que la persona pueda habitar, y
ese es el lugar que este proyecto busca ocupar.

### La resignación en la literatura

La resignación informada tiene respaldo en la literatura sobre privacidad. Draper y Turow
(2019) describen la *resignación digital* y muestran que esa pasividad no surge sola: se
cultiva. Las corporaciones producen la sensación de inevitabilidad. Si la impotencia es un
producto de diseño, entonces es también un problema de diseño. Turow et al. (2015)
desmontan la «falacia del intercambio»: quien cede datos no calcula costos y beneficios, se
resigna. Hargittai y Marwick (2016) identifican apatía donde se suponía desconocimiento; Hoffmann et al.
(2016) describen el cinismo de la privacidad como mecanismo de afrontamiento; y Choi et al.
(2018) muestran que la fatiga de la privacidad predice la conducta mejor que la
preocupación, lo que explica directamente el 39% que no sabe por dónde empezar.

### Árbol de problemas

La causa del problema es estructural, experiencial y contextual a la vez.

**Causas estructurales (Nivel 1).** Las infraestructuras de extracción están diseñadas
deliberadamente para operar de forma imperceptible, porque la fricción sensorial reduciría
el volumen de datos capturados (Zuboff, 2019; Greenfield, 2006). La opacidad algorítmica es una decisión de arquitectura que impide auditar qué se extrae,
cómo se usa y con qué margen de error clasifica a quien mide (Bridle, 2018).

**Causas experienciales (Nivel 2).** Las tecnologías de captura de datos reconfiguran la
atención del usuario, reduciendo su capacidad de detenerse a cuestionar lo que un sistema
concluye sobre él (Stiegler, 2009). La comunicación sobre vigilancia y sesgo algorítmico,
cuando existe, se transmite en formatos textuales y estadísticos, un canal que no
compromete al cuerpo ni genera respuesta afectiva (Bilal y Lydersen, 2008).

**Causas contextuales (Nivel 3).** Regulación tardía en Chile, sin vigencia plena hasta
diciembre de 2026 (Ley N° 21.719), y ausencia de regulación equivalente para sesgo
algorítmico, salvo normas aisladas como la de Nueva York, que ni siquiera obliga a corregir
lo que audita (Groves et al., 2024).

**Problema central.** La extracción de datos y el error algorítmico que esa extracción
produce no generan ningún estímulo que el cuerpo del usuario pueda registrar como propio,
por lo que ambos permanecen fuera del umbral de lo que se puede confrontar, discutir o
exigir corregir (Ihde, 1990; Rogers e Ishii, 2017).

**Efectos.** Resignación informada: el usuario sabe pero no actúa. Entrega involuntaria y
naturalizada de datos personales. Vulnerabilidad sostenida ante sesgos algorítmicos y
discriminación automatizada, que persiste incluso después de ser medida, publicada y
confirmada académicamente (Buolamwini y Gebru, 2018; Cheney-Lippold, 2017).

El punto de intervención de esta investigación se sitúa en las causas experienciales del
Nivel 2. No es posible modificar la opacidad estructural del sistema ni forzar una
obligación legal de corrección donde no existe, pero sí es posible mejorar la respuesta que
hoy existe, dándole al usuario individual una experiencia que ni la resignación ni la
auditoría pública colectiva le ofrecen.

## 3.2 Fundamentación

### Justificación

El diseño tiene algo que decir aquí que otras disciplinas no pueden reemplazar. Informar ya no alcanza, incluso cuando la
información existe, se publica y se prueba con rigor académico. Por eso el diseño entra a
traducir: convierte tanto la extracción invisible como el
error ya medido en algo que el cuerpo registre como propio. El arte medial puede hacer la
crítica; la ingeniería puede construir el sensor; la auditoría técnica puede probar el sesgo
con rigor estadístico; ninguno de los tres está entrenado para diseñar la experiencia del
usuario no especializado en su entorno cotidiano. Esa intersección entre el argumento
político, el artefacto funcional y la experiencia habitable es el territorio específico del
diseño crítico.

Como muestran Dunne y Raby (2013), el diseño puede operar como medio para
hacer tangibles ideas que de otro modo permanecen abstractas; y como demuestra Fried
(2005), esa tangibilidad solo genera agencia cuando el artefacto funciona de verdad, más allá de
representar. La pertinencia disciplinar de este proyecto está en que el diseño es la única práctica que puede hacer cuatro
cosas al mismo tiempo: criticar, construir, probar con rigor técnico y hacer sentir, con un usuario real como destinatario y no como espectador. Agregar
información al problema no tendría ese efecto. Con el formato final del proyecto, eso
es todavía más literal: el usuario dejó de ser un visitante de sala y pasó a ser alguien en
su propia vida.

### Por qué ahora

La Ley 21.719 fue publicada en diciembre de 2024 y su entrada en vigencia está fijada para
diciembre de 2026. Entre ambas fechas se abre una ventana en que la norma existe pero la
Agencia de Protección de Datos Personales todavía no opera: la extracción avanza sin
fiscalización efectiva. El caso Anthropic-Chile, descrito en los Antecedentes, ocurrió
dentro de esa ventana, y también la semana de capturas de rastro: la obra extrajo
geolocalización y biometría de participantes chilenos en un tramo en que hacerlo no tenía
una autoridad de control que respondiera.

### Por qué capturar en el origen

La prueba de canal del 10 de octubre de 2026 (ver 7.3) mostró que prácticamente ningún
canal de subida de fotografías conserva hoy los metadatos de ubicación. Ese fracaso
reencuadró el proyecto. La fricción que hubo que sortear terminó siendo el fenómeno mismo, más que un obstáculo
anecdótico del desarrollo. La industria tomó el control del metadato en nombre de la
privacidad, y ahora es ella la que decide cuándo el dato viaja y cuándo no.

El hallazgo coincide con lo que Ignacio Ramos, oficial investigador de la PDI, había
señalado en la entrevista realizada durante el seminario, en junio de 2026: que la metadata es el dato más
invisible, y que una obra sobre extracción debía trabajar con datos de comportamiento y no
de contenido. La prueba de canal lo confirmó por la vía del fracaso, y la respuesta del
proyecto fue capturar el dato en el origen, dentro de la propia aplicación.

## Conclusiones

El problema no es la falta de información. Las personas saben, y ese saber no las mueve,
porque la extracción no deja nada que el cuerpo pueda registrar. Ahí el diseño ocupa un
lugar que la regulación y la alfabetización digital no ocupan: fabricar la experiencia
que el sistema evita.
