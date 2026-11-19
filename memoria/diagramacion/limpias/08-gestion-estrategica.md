# 8. Gestión estratégica

Un proyecto que extrae datos de personas reales no se sostiene solo con diseño. Necesitó
una cuenta de desarrollador ajena, una actriz, una sala y un plan para cuando algo
fallara, y cada una de esas piezas tuvo un costo que el proyecto tuvo que asumir.

## 8.1 Alianzas y colaboración

La aplicación se distribuyó mediante la **cuenta de desarrollador de un colaborador**,
Aarón, porque la cuenta de pago es requisito para publicar en TestFlight y en Google Play.
Esa alianza resolvió el problema de distribución y abrió tres costos.

**Costo de confianza.** La invitación de TestFlight llega a nombre de un desconocido. Un
correo de una aplicación que la persona no reconoce, firmado por alguien que no es la
investigadora, tiene exactamente la forma de un *phishing*, y eso en un estudio cuyo
encuadre ya es un engaño autorizado. Se mitigó con texto: el correo de selección declara
quién es el colaborador y por qué escribe.

**Costo de autonomía.** Cambiar código pasa por otra persona y por la revisión de la tienda.
De ahí la decisión de arquitectura descrita en 7.5: la lógica que puede necesitar ajustes
vive en la base de datos.

**Asimetría entre canales.** Publicar en Google Play obliga a una declaración pública de
seguridad de los datos (ubicación precisa, fotos); en TestFlight esa exposición no existe.
El diseño se sostiene, porque los términos dentro de la aplicación ya declaran la
recolección y el engaño recae sobre el uso y la revelación. Aun así, la misma obra,
distribuida por dos canales, declara cosas distintas en público.

**Una actriz para conducir la sesión.** Para la revelación se contrató a una actriz de la
compañía de teatro de la Universidad Diego Portales. Ella conducía cada sesión siguiendo un
guion: recibía a la persona, hacía las preguntas de ambientación, entregaba el expediente,
leía el desengaño y aplicaba los instrumentos. Separar los roles fue una decisión de
método: la investigadora quedaba libre para operar el panel, el escáner y la impresora, y
la persona frente al expediente no tenía delante a quien había construido la aplicación,
alguien a quien conocía y en quien confiaba.

**El lugar: KSA8.** El testeo se realizó el 16 de noviembre de 2026 en KSA8, un espacio
que se habilitó como sala de revelación por la jornada. La sala no tenía una conexión a
internet confiable, y esa condición fue la que obligó a construir la versión sin conexión
del sistema (7.7).

## 8.2 Plan operativo y de hitos

<!-- fig:hitos -->

| Hito | Fecha | Qué se entrega |
|---|---|---|
| Entrega conjunta G1+G2 | 21 oct 2026 | Cambio de formato argumentado + maqueta de alta fidelidad |
| Entrega G2 | 28 oct 2026 | Producto mínimo funcionando + diseño de experiencia cerrado |
| Memoria Final G2 | 11 nov 2026 | Aplicación funcionando + piloto |
| Pase G2 | 25 nov 2026 | Semana de capturas + evento de revelación |
| Memoria a Comisión | 2 dic 2026 | Desinstalación medida + análisis |
| Ensayo General | 9 dic 2026 | Afinado |

**Ruta crítica.** Todo dependía de que la aplicación estuviera distribuida alrededor del
11 al 14 de noviembre, y se cumplió: la convocatoria cerró el 3 de noviembre, con correo de
selección automatizado y distribución por TestFlight el mismo día. Entre el evento y la
Comisión, la ventana de seguimiento queda justa: probablemente cinco días en vez de siete,
con los números finales madurando después de la entrega.

El correo de selección se automatizó sobre la planilla de inscripción, con resguardos
contra el reenvío y contra el pegado masivo, y su lógica se probó en un simulador antes de
tocar la planilla real. El correo no lleva enlaces, porque los filtros de spam retienen los
enlaces a `script.google.com`, algo que se aprendió en octubre. La semana de siete días
parte el día en que cada persona instala la aplicación, sin una fecha fija común.

## 8.3 Riesgos y mitigaciones

Cada riesgo se registra con la mitigación que efectivamente se aplicó.

| Riesgo | Qué pasó y cómo se mitigó |
|---|---|
| Caducidad de la firma gratuita (7 días, un solo teléfono) | Obligó a distribuir por TestFlight con una cuenta de pago |
| Repositorios públicos con reglas de acceso permisivas | Llave fuera del repositorio y capturas de solo escritura; la lectura quedó abierta de forma deliberada durante la etapa de demostración |
| Exposición de material biométrico como foto de perfil | Error de una columna faltante, detectado antes de usar la aplicación con participantes |
| Dependencia externa que deja de ser gratuita | CARTO rompió los tres mapas en silencio; se reemplazó por OpenFreeMap con respaldo |
| Distribución por cuenta ajena | Costos de confianza, de autonomía y de asimetría entre canales (ver 8.1) |
| Confusión entre canales de prueba de Google Play | Se armó la cadena de firma de Android para un paquete innecesario: la versión ya estaba publicada en prueba interna desde el 2 de noviembre. La lección: revisar el estado real del canal antes de construir |
| Datos sensibles (biometría, geolocalización) | Minimización por arquitectura y cumplimiento de la Ley 21.719 |

## 8.4 Ámbitos de impacto

**Académico.** El proyecto documenta, con personas reales, que la experiencia corporal hace
sentir la extracción, pero no basta para cambiar la conducta cuando lo que sostiene la
entrega de datos es la confianza.

**Social.** Las participantes salieron sabiendo qué habían concedido, y varias pidieron
llevarse su expediente. El objeto que históricamente retuvo el Estado volvió a la persona.

**Disciplinar.** rastro muestra un lugar para el diseño frente a la vigilancia distinto de
la regulación y de la alfabetización: construir la consecuencia que el sistema no entrega.

**Ético.** El proyecto se sostiene en los estándares que exige: consentimiento, desengaño,
borrado de datos y curaduría antes de mostrar.

## 8.5 Proyección

La siguiente iteración ya tiene dirección. El cuerpo reaccionó y la conducta no cambió, así
que lo que hay que rediseñar es el cierre del expediente, la llamada a la acción. Quedan
tres caminos abiertos:

- **Sin confianza de por medio.** Repetir la semana con un grupo que no conozca a la
 autora, para observar qué pasa cuando el motivo de la entrega desaparece.
- **La mecánica completa.** Incorporar la ventana de dos minutos de BeReal, que no alcanzó
 a implementarse.
- **El sistema como herramienta.** Convertir el panel y el expediente en un kit que otros
 talleres o investigaciones puedan usar para mostrarle a una comunidad lo que su propio
 teléfono entrega.
