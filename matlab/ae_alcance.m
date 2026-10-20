function s=ae_alcance(analisis)
switch string(analisis)
case "axial"
s='Barra recta axial, E y F constantes por tramo, pequeñas deformaciones, cargas y temperatura lineales por tramo, apoyos bilaterales y hasta ocho topes unilaterales. No comprueba pandeo.';
case "cercha"
s='Cerchas planas o espaciales, nudos articulados, cargas nodales, barras prismáticas y elasticidad lineal. No incluye flexión de barras, grandes desplazamientos ni verificación de pandeo.';
case "seccion"
s='Contornos poligonales con huecos sin solapamientos, o segmentos rectos de pared delgada. Las curvas se aproximan mediante vértices; la modalidad de pared delgada omite términos de espesor al cubo.';
case "torsion"
s='Torsión de Saint-Venant con J y W constantes por tramo. Secciones circulares exactas, pared delgada abierta o cerrada de una celda mediante sus aproximaciones. Sin alabeo restringido.';
case "viga"
s='Vigas rectas Euler-Bernoulli con E, F e I constantes por tramo, cargas repartidas lineales y apoyos de desplazamiento/rotación. La tensión mostrada usa una distancia extrema c y la aproximación de cortante corresponde a sección rectangular. No calcula el centro de cortante de perfiles abiertos.';
case "flexion_oblicua"
s='Verificación de una sección poligonal, también con huecos, en régimen elástico. Incluye acoplamiento de ejes no principales mediante Iyz. No obtiene la deformada espacial completa de una viga.';
case "sistema_barras"
s='Barras rectas prismáticas elásticas: marcos 3D con seis grados de libertad por nodo, barras axiales y marcos 2D. Flexión Euler-Bernoulli y torsión de Saint-Venant; no incluye alabeo restringido, deformación por cortante, grandes giros ni pandeo. Las curvas discretizadas con barras rectas requieren convergencia de malla y curvatura moderada respecto al tamaño de sección.';
case "tensor"
s='Estado homogéneo en un punto de un material elástico lineal isótropo. Las deformaciones fuera de la diagonal son tensoriales: epsilon_xy=gamma_xy/2. No calcula un campo espacial a partir de cargas de contorno.';
case "resistencia_combinada"
s='Marcos espaciales elásticos de barras rectas circulares, con flexión en dos planos, torsión y esfuerzo axial. El cortante transversal se controla mediante una envolvente conservadora de Jourawski, no mediante un campo exacto 3D de elasticidad. El dimensionamiento es uniforme y se limita al intervalo indicado. No incluye concentraciones locales en codos/uniones, alabeo restringido, pandeo ni plastificación.';
case "lamina"
s='Láminas delgadas, convexas, axisimétricas y sin momentos de borde. Admite presión uniforme o hidrostática y fuerza axial en el corte inicial. No predice flexión local de uniones, singularidades de ápices ni pandeo por presión externa.';
case "estabilidad"
s='Columna prismática de ejes principales, mismo tipo de apoyo en ambos planos, compresión conservativa constante y flexión de segundo orden linealizada. No incluye pandeo por torsión, flexotorsión, pospandeo ni plastificación. Las cargas interiores se aplican mediante funciones de forma; refina la malla para comprobar convergencia.';
case "dinamica"
s='Impacto sobre una estructura lineal sin amortiguamiento y con masa estructural despreciable frente al impactante; o barra radial prismática a velocidad angular constante. Se calcula el máximo energético o equilibrio de inercia, no una historia temporal de ondas o vibraciones.';
case "plasticidad"
s='Material ideal elastoplástico simétrico y carga monótona. Barras paralelas con desplazamiento común; flexión pura de una sección descrita por anchura frente a altura; torsión de sección circular. No representa descarga, endurecimiento, ciclos plásticos ni colapso general de un marco.';
case "fatiga"
s='Ciclos estacionarios caracterizados por sus extremos, límites de fatiga y coeficientes conocidos. Combina tensión normal y cortante mediante una relación empírica de seguridad. No estima daño acumulado, espectros variables ni vida finita sin datos experimentales.';
case "barra_curva"
s='Barras curvas de sección constante y material elástico lineal. La sección se describe mediante anchura frente a radio. El arco es circular y está empotrado en un extremo, con fuerza en el otro. No incluye alabeo, torsión espacial ni redistribución plástica.';
case "compatibilidad"
s='Dos familias de problemas avanzados: barra o plataforma rígida suspendida por varillas axiales paralelas y banda adherida a una base rígida mediante una ley de cortante lineal. No es un solucionador universal de todos los problemas avanzados.';
case "seccion_general"
s='Sección homogénea elástica, contorno poligonal o pared delgada. Obtiene área, centroide, inercias acopladas, tensiones por N, My y Mz y masa prismática. La torsión de una única celda delgada cerrada usa Bredt y Saint-Venant. No obtiene centro de cortante, cortante transversal, alabeo restringido, concentración en agujeros ni respuesta local de un sólido 3D. Si existen Qy, Qz o torsión no evaluada, el resultado se marca Parcial.';
case "uniones"
s='Comprobaciones nominales estáticas de un pasador o perno y sus láminas: tracción, corte, equivalente III, aplastamiento, sección neta y desgarro al borde. También soldadura a tope bajo fuerza y flexión en un plano, filetes bajo cortante directo centrado y adhesivo a cortante medio. Las demandas por fijación deben proceder del equilibrio del conjunto. No reparte automáticamente una carga excéntrica entre tornillos ni incluye precarga, fricción, palanca, fatiga, concentraciones o defectos de soldadura.';
case "placa_local"
s='Panel rectangular delgado idealizado, carga uniforme y coeficientes de borde declarados. Evalúa pandeo local por compresión y cortante por separado y compara con admisibles materiales. No resuelve placas con agujeros, flexión transversal, pospandeo, interacción compresión-cortante ni la rigidez de un soporte plegado. La validez elástica de compresión se contrasta con el límite proporcional.';
case "solido3d"
s='Elasticidad estática lineal isótropa de un único sólido material, tetraedros cuadráticos, caras fijas, tracciones o presiones uniformes por cara y carga volumétrica. Admite geometrías STEP/STL en m después del escalado. No representa contactos, deslizamiento, pretensado de tornillos, soldaduras explícitas, plasticidad, fatiga ni pandeo. Un ensamblaje no se convierte automáticamente en una pieza unida. Los resultados quedan Parcial si no se ha estudiado o no se ha alcanzado la convergencia de los indicadores; los máximos nodales deben interpretarse frente a singularidades y condiciones de contorno.';
otherwise
error('AE:Seleccion','Seleccion desconocida.');
end
end
