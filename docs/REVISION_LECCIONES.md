# Revisión de las lecciones y ampliación estructural

Fecha: 19 de octubre de 2026. Destino: `ANALISIS_ESTRUCTURAL_INTEGRADO.mlx`. Se conservan los dieciséis documentos docentes y sus rutinas `rm_*.m`. No se crean otros diez Live Scripts. El integrado reúne ahora veinte familias de cálculo.

## Material encontrado

Se encontraron siete PDF, con 163 páginas en total. Sus títulos cubren las lecciones 1 y 2 juntas, 3, 4, 5, 6, 7 y 10. No se encontraron archivos identificados como lecciones 8 o 9. Las páginas de esta revisión son las del PDF, contadas desde 1.

| Documento | Páginas | Contenido estructural revisado |
|---|---:|---|
| Lecciones 1 y 2 (PDF no distribuido) | 21 | Fuerzas externas, inercia, estados de carga, seguridad |
| Lección 3 (PDF no distribuido) | 21 | Secciones, centroide, inercias, esfuerzos básicos |
| Lección 4 (PDF no distribuido) | 16 | Métodos de fabricación y restricciones tecnológicas |
| Lección 5 (PDF no distribuido) | 21 | Paneles, vigas delgadas, pandeo local, flujo de cortante |
| Lección 6 (PDF no distribuido) | 28 | Remaches/pasadores, láminas, soldaduras y adhesivos |
| Lección 7 (PDF no distribuido) | 22 | Pernos, orejetas, resistencia combinada, trayectoria de carga |
| Lección 10 (PDF no distribuido) | 34 | Descomposición estructural y distribución de esfuerzos |

Se extrajo el texto completo y se inspeccionaron visualmente las páginas relevantes con figuras o fórmulas. El objetivo es generalizar principios estructurales, sin trasladar factores ni recetas específicas de aeronaves a un soporte de vehículo.

## Decisiones sobre el integrado

| Tema | Situación y decisión |
|---|---|
| Barras, vigas, marcos 2D/3D, tensores, estabilidad, fatiga y otras teorías del libro | Se mantienen las dieciséis familias existentes con su alcance específico |
| Área, centroide e inercias de secciones complejas | Se reutiliza el núcleo de geometría existente; se añade `seccion_general` para combinarlo con esfuerzos y comprobaciones explícitas |
| Flexión biaxial de sección no simétrica | Se resuelve con Iy, Iz e Iyz y momentos físicos locales de mano derecha; se comprueba invariancia ante giro de ejes |
| Torsión de pared delgada cerrada | Se añade a sección general la celda única de Bredt, incluyendo J y giro; no multicelda ni alabeo restringido |
| Uniones | Se añade `uniones`: pasador/perno, láminas, soldadura a tope, filetes bajo cortante centrado y adhesivo simple |
| Pandeo local de placas | Se añade `placa_local`: mecanismos separados de compresión y cortante con condiciones y límites declarados |
| Fuerzas de equipos y distintos escenarios | Se añaden transformación masa/aceleración y traslado de momento, comparación de casos y conservación de sus entradas |
| Pieza real con geometría maciza | Se añade `solido3d`, elasticidad estática con PDE Toolbox e importación STEP/STL; esta ampliación numérica no procede de una supuesta fórmula CAD de las lecciones |
| Fabricación | Se conserva como información necesaria para seleccionar geometría, propiedades y admisibles; no se inventan límites universales de doblado, tolerancias o calidad de soldadura |

## Fórmulas y convenciones verificadas

- Lecciones 1 y 2, p. 6 y 11–12: fuerza de inercia, carga de cálculo y relación resistente. Se usa F=m(g−a) con vectores explícitos y M=(rG−rO)×F. Los factores de carga y de seguridad se introducen por el usuario; no se importa automáticamente un factor aeronáutico.
- Lección 3, p. 5–10: área, centroide, inercias y módulos resistentes. El centroide no sustituye al centro de cortante. La masa ρFL solo representa una pieza prismática con densidad uniforme.
- Lección 5, p. 8: σcr=kE(t/b)². Aquí k ya pertenece a esa expresión normalizada; no se añade otro factor π²/[12(1−ν²)]. El coeficiente depende de las restricciones de borde.
- Lección 5, p. 12: kτ=5.6+3.8/(a/b)² y τcr=0.9kτE(t/b)², para a≥b. Se ofrece la corrección empírica con ψ=τu/τcr y τcr,corr=τu(1+ψ)/(1+ψ+ψ²). La interacción compresión–cortante queda pendiente; no se crea una ley sin respaldo.
- Lección 5, p. 16: Bredt, q=T/(2Am) y τ=q/t. Se utiliza el área encerrada por la línea media. La constante J de celda delgada y su giro se obtienen con el núcleo de torsión existente.
- Lección 6, p. 6, 9–12: corte del pasador, aplastamiento, sección neta y desgarro. Se distinguen diámetro del pasador y diámetro del agujero. Las fórmulas empleadas son P/(iπd²/4), P/(td), P/[t(b−dh)] y P/[2t(e−dh/2)]. Se introducen las cargas reales transmitidas por cada lámina.
- Lección 6, p. 19–21: tope de penetración completa, A=lt y W=lt²/6 para el eje declarado; filetes con garganta efectiva y cortante directo. No se declara resuelta una unión excéntrica mediante P/A.
- Lección 6, p. 28: cortante medio en adhesivo P/(bL), sin pelado ni máximos locales.
- Lección 7, p. 9–10 y 13–16: combinación tracción–corte del perno mediante σeq,III=√(σ²+4τ²), con un admisible equivalente independiente; el diámetro mínimo del pasador se calcula solo por el mecanismo de corte declarado.
- Lección 10, p. 22–34: descomposición de la estructura y rutas de transferencia de esfuerzos. Se mantiene la distinción entre modelo global, sección y unión; los procedimientos empíricos exclusivos del fuselaje no se generalizan a una pieza cualquiera.

En algunas diapositivas los títulos o el símbolo del admisible son ambiguos: la expresión de la lección 6 p. 10 describe sección neta, aunque aparece asociada a aplastamiento; la lección 7 p. 10 no justifica reutilizar un admisible de cortante como admisible equivalente. El programa separa estos mecanismos y exige sus límites explícitos.

## Alcance pendiente para piezas reales

El integrado calcula modelos definidos mediante datos; no decide automáticamente contactos, uniones, materiales ni cargas a partir de la forma. Secciones abiertas con cortante transversal, centro de cortante, multiceldas, alabeo restringido, grupos excéntricos de tornillos o cordones y concentraciones de orejetas requieren modelos adicionales. En los módulos nuevos se identifica **Parcial** cuando una carga introducida incluye un mecanismo no resuelto.

El sólido 3D admite un único cuerpo material conectado, elasticidad lineal isótropa y cargas estáticas. La comprobación de malla compara indicadores, no certifica la fidelidad física. No incluye contactos, pretensado, plasticidad 3D, pandeo 3D ni fatiga por un historial de vehículo. Un mapa de tensión estático no sustituye esas comprobaciones.

Las pruebas y la preservación de los capítulos quedan documentadas en `VALIDACION_INTEGRADO.md`. Los valores que aparecen al abrir el integrado son ejemplos de funcionamiento, no propiedades ni cargas del soporte pendiente.
