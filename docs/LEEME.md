# Módulos de referencia: resistencia de materiales

Live Scripts para MATLAB R2024b. Cada archivo presenta datos editables, explicación, ecuaciones, cálculo y gráficas. Los valores iniciales permiten ejecutarlo sin preparar otro ejercicio.

## Empezar

1. Abre la subcarpeta `matlab` del repositorio en MATLAB.
2. Ejecuta `INICIAR_CURSO.m` una vez por sesión.
3. Abre el capítulo que deseas con el Live Editor.
4. Lee el alcance y modifica la sección **Datos / Input data**. Pulsa **Run** para recalcular todo.

Comparte la carpeta completa: los archivos `rm_*.m` contienen las operaciones reutilizadas. No es necesario ejecutar los capítulos anteriores ni conservar sus variables. El capítulo 1 conserva el Live Script que ya utilizabas.

## Archivos en orden

| Capítulo | Archivo |
|---|---|
| 01. Tracción y compresión axial | [Abrir](../matlab/Cap01_Traccion_Compresion.mlx) |
| 02. Cálculo de cerchas | [Abrir](../matlab/Cap02_Calculo_Cerchas.mlx) |
| 03. Características geométricas de áreas planas | [Abrir](../matlab/Cap03_Caracteristicas_Geometricas_Secciones.mlx) |
| 04. Torsión | [Abrir](../matlab/Cap04_Torsion.mlx) |
| 05. Flexión transversal | [Abrir](../matlab/Cap05_Flexion_Transversal.mlx) |
| 06. Flexión oblicua y tracción-compresión excéntrica | [Abrir](../matlab/Cap06_Flexion_Oblicua_Traccion_Excentrica.mlx) |
| 07. Desplazamientos y esfuerzos en sistemas de barras | [Abrir](../matlab/Cap07_Desplazamientos_Esfuerzos_Sistemas_Barras.mlx) |
| 08. Estado tensional, deformaciones y teorías de resistencia | [Abrir](../matlab/Cap08_Estado_Tensional_Deformaciones_Teorias_Resistencia.mlx) |
| 09. Resistencia en estados tensionales complejos | [Abrir](../matlab/Cap09_Resistencia_Estados_Tensionales_Complejos.mlx) |
| 10. Láminas de revolución | [Abrir](../matlab/Cap10_Laminas_Revolucion.mlx) |
| 11. Flexión longitudinal-transversal y estabilidad de barras | [Abrir](../matlab/Cap11_Flexion_Longitudinal_Transversal_Estabilidad.mlx) |
| 12. Carga dinámica de sistemas de barras | [Abrir](../matlab/Cap12_Cargas_Dinamicas_Sistemas_Barras.mlx) |
| 13. Sistemas de barras más allá del límite elástico | [Abrir](../matlab/Cap13_Sistemas_Barras_Fuera_Limite_Elastico.mlx) |
| 14. Cálculos de fatiga | [Abrir](../matlab/Cap14_Fatiga.mlx) |
| 15. Barras de gran curvatura | [Abrir](../matlab/Cap15_Barras_Gran_Curvatura.mlx) |
| 16. Problemas de mayor complejidad | [Abrir](../matlab/Cap16_Problemas_Mayor_Complejidad.mlx) |

## Cómo introducir otro problema

Sustituye geometría, material, cargas y apoyos; no cambies las ecuaciones para un problema dentro del alcance indicado. Las tablas de entrada pueden crecer o reducirse respetando sus columnas. En los capítulos con varias familias, selecciona `modo`, `tipo` o `tipoSeccion` y rellena los datos de esa opción.

Usa m, N, Pa, rad y s. Las tablas y figuras convierten a mm, kN o MPa cuando lo indica la etiqueta. `NaN` deja libre el desplazamiento o giro de un apoyo; un cero lo impide. Los índices de nodos comienzan en 1. En el capítulo 1 se explica también el uso de magnitudes relativas.

Las fórmulas escritas en las zonas de texto explican el cálculo. Las ecuaciones ejecutables están en las zonas de código. Los apartados «Funciones utilizadas» explican cada función en general y su papel concreto.

Las gráficas se generan según el modelo y el modo seleccionado: diagramas de esfuerzos para barras y vigas; distribuciones, ciclos, curvas de carga o márgenes cuando resultan pertinentes. No se crean diagramas que carezcan de significado en ese modelo.

## Alcance por capítulo

Consulta [REVISION_3D.md](REVISION_3D.md) para elegir el modelo, completar las tablas espaciales y leer sus ejes.

**02. Cálculo de cerchas.** Cerchas planas o espaciales, nudos articulados, cargas nodales, barras prismáticas y elasticidad lineal. No incluye flexión de barras, grandes desplazamientos ni verificación de pandeo.

**03. Características geométricas de áreas planas.** Contornos poligonales con huecos sin solapamientos, o segmentos rectos de pared delgada. Las curvas se aproximan mediante vértices; la modalidad de pared delgada omite términos de espesor al cubo.

**04. Torsión.** Torsión de Saint-Venant con J y W constantes por tramo. Secciones circulares exactas, pared delgada abierta o cerrada de una celda mediante sus aproximaciones. Sin alabeo restringido.

**05. Flexión transversal.** Vigas rectas Euler-Bernoulli con E, F e I constantes por tramo, cargas repartidas lineales y apoyos de desplazamiento/rotación. La tensión mostrada usa una distancia extrema c y la aproximación de cortante corresponde a sección rectangular. No calcula el centro de cortante de perfiles abiertos.

**06. Flexión oblicua y tracción-compresión excéntrica.** Verificación de una sección poligonal, también con huecos, en régimen elástico. Incluye acoplamiento de ejes no principales mediante Iyz. No obtiene la deformada espacial completa de una viga.

**07. Desplazamientos y esfuerzos en sistemas de barras.** Barras rectas prismáticas elásticas: marcos 3D con seis grados de libertad por nodo, barras axiales y marcos 2D. Flexión Euler-Bernoulli y torsión de Saint-Venant; no incluye alabeo restringido, deformación por cortante, grandes giros ni pandeo. Las curvas discretizadas con barras rectas requieren convergencia de malla y curvatura moderada respecto al tamaño de sección.

**08. Estado tensional, deformaciones y teorías de resistencia.** Estado homogéneo en un punto de un material elástico lineal isótropo. Las deformaciones fuera de la diagonal son tensoriales: epsilon_xy=gamma_xy/2. No calcula un campo espacial a partir de cargas de contorno.

**09. Resistencia en estados tensionales complejos.** Marcos espaciales elásticos de barras rectas circulares, con flexión en dos planos, torsión y esfuerzo axial. El cortante transversal se controla mediante una envolvente conservadora de Jourawski, no mediante un campo exacto 3D de elasticidad. El dimensionamiento es uniforme y se limita al intervalo indicado. No incluye concentraciones locales en codos/uniones, alabeo restringido, pandeo ni plastificación.

**10. Láminas de revolución.** Láminas delgadas, convexas, axisimétricas y sin momentos de borde. Admite presión uniforme o hidrostática y fuerza axial en el corte inicial. No predice flexión local de uniones, singularidades de ápices ni pandeo por presión externa.

**11. Flexión longitudinal-transversal y estabilidad de barras.** Columna prismática de ejes principales, mismo tipo de apoyo en ambos planos, compresión conservativa constante y flexión de segundo orden linealizada. No incluye pandeo por torsión, flexotorsión, pospandeo ni plastificación. Las cargas interiores se aplican mediante funciones de forma; refina la malla para comprobar convergencia.

**12. Carga dinámica de sistemas de barras.** Impacto sobre una estructura lineal sin amortiguamiento y con masa estructural despreciable frente al impactante; o barra radial prismática a velocidad angular constante. Se calcula el máximo energético o equilibrio de inercia, no una historia temporal de ondas o vibraciones.

**13. Sistemas de barras más allá del límite elástico.** Material ideal elastoplástico simétrico y carga monótona. Barras paralelas con desplazamiento común; flexión pura de una sección descrita por anchura frente a altura; torsión de sección circular. No representa descarga, endurecimiento, ciclos plásticos ni colapso general de un marco.

**14. Cálculos de fatiga.** Ciclos estacionarios caracterizados por sus extremos, límites de fatiga y coeficientes conocidos. Combina tensión normal y cortante mediante una relación empírica de seguridad. No estima daño acumulado, espectros variables ni vida finita sin datos experimentales.

**15. Barras de gran curvatura.** Barras curvas de sección constante y material elástico lineal. La sección se describe mediante anchura frente a radio. El arco es circular y está empotrado en un extremo, con fuerza en el otro. No incluye alabeo, torsión espacial ni redistribución plástica.

**16. Problemas de mayor complejidad.** Dos familias de problemas avanzados: barra o plataforma rígida suspendida por varillas axiales paralelas y banda adherida a una base rígida mediante una ley de cortante lineal. No es un solucionador universal de todos los problemas avanzados.

El archivo `GUIA_MATLAB.md` explica las operaciones básicas. Las capacidades son las familias descritas; una nueva ley de material o condición física requiere ampliar el modelo.

## Rutinas compartidas

| Archivo | Función |
|---|---|
| `rm_axial.m` | Barras axiales; se reutiliza para torsión y barra radial. |
| `rm_cercha.m` | Cerchas planas y espaciales. |
| `rm_seccion.m`, `rm_pared.m` | Propiedades geométricas. |
| `rm_marco.m`, `rm_viga.m`, `rm_marco3d.m` | Vigas, marcos planos y espaciales con seis componentes. |
| `rm_mohr3d.m`, `rm_mohr_plano.m`, `rm_equilibrio3d.m` | Trabajo virtual y tratamiento de giros liberados sin rigidez. |
| `rm_resistencia_marco3d.m`, `rm_dimensionar_marco3d.m` | Comprobación y dimensionamiento circular espacial. |
| `rm_tensor.m`, `rm_mohr.m` | Estado tensional y círculos de Mohr. |
| `rm_columna.m`, `rm_columna3d.m` | Pandeo y flexión con compresión en ambos planos. |
| `rm_tirantes_rigidos.m` | Barra/plataforma rígida con varillas axiales paralelas. |
| `rm_lineal.m` | Equilibrio con desplazamientos impuestos. |
| `rm_figura.m`, `rm_curva.m`, `rm_esquema_viga.m`, `rm_graficar_marco3d.m` | Presentación vertical, rayado y esquema de cargas. |

Se utilizan funciones de MATLAB; no se requiere Aerospace Toolbox ni Simulink.

## Comprobación

Consulta `VALIDACION.md` para conocer las comprobaciones realmente ejecutadas. Guarda una copia del capítulo antes de sustituir sus datos si deseas conservar un caso de referencia.
