# ANÁLISIS ESTRUCTURAL INTEGRADO

Interfaz única para las familias de cálculo de los dieciséis capítulos y cuatro ampliaciones estructurales. Compatible con MATLAB R2024b. La memoria matemática se genera con el renderizador LaTeX de MATLAB; no requiere Symbolic Math Toolbox. Solo la familia `solido3d` requiere PDE Toolbox y una licencia disponible.

## Primera ejecución

1. Ejecuta `START_HERE.m` desde la raíz del repositorio o abre su subcarpeta `matlab` en MATLAB. `INICIAR_CURSO.m` incorpora sus funciones a la ruta; el integrado también hace esa preparación al ejecutar todo su contenido.
2. Abre `ANALISIS_ESTRUCTURAL_INTEGRADO.mlx`.
3. Conserva inicialmente `seleccion="directa"` y `analisis="axial"`.
4. Pulsa **Run**. Aparecen tablas, esquema, epiuras y desarrollo matemático por tramos.
5. Cambia una fuerza en el bloque **AXIAL** y vuelve a pulsar **Run**. Compara reacción, tensión y desplazamiento, y sus ecuaciones.

Utiliza **Run** para ejecutar todo después de cambiar de análisis o de datos. Ejecutar únicamente la sección de memoria reutiliza la última `solucion` calculada; no resuelve nuevos datos por sí sola. Para colocar los resultados debajo del código, selecciona la opción de salida **Inline** del Live Editor.

## Selección del modelo

La selección directa utiliza una clave. La selección guiada relaciona tres respuestas con una clave y, cuando corresponde, ajusta su modo. Las respuestas son opciones concretas; la guía no interpreta lenguaje libre ni verifica que la idealización describa la pieza real.

| Clave | Modelo y modos |
|---|---|
| `axial` | Barra recta: cargas, temperatura, apoyos y topes |
| `cercha` | Barras articuladas, nodos 2D o 3D |
| `seccion` | `poligonos` o `pared_delgada` |
| `torsion` | Sección `circular`, `abierta_delgada`, `cerrada_delgada` o `constantes` |
| `viga` | Flexión plana Euler-Bernoulli |
| `flexion_oblicua` | Sección poligonal bajo N, My y Mz, o carga excéntrica |
| `sistema_barras` | `espacial`, `plano` o `resorte` |
| `tensor` | Entrada de `tensiones` o `deformaciones` en un punto |
| `resistencia_combinada` | `estructura` o `seccion`; comprobar o dimensionar barras circulares |
| `lamina` | `cilindro`, `esfera` o `cono` axisimétricos |
| `estabilidad` | Columna en dos planos principales; no pandeo general de marcos |
| `dinamica` | `impacto` o `rotacion`; impacto axial, voladizo, marco 3D o rigidez dada |
| `plasticidad` | `axial`, `flexion` o `torsion`, carga monótona |
| `fatiga` | Extremos estacionarios de sigma y tau por punto |
| `barra_curva` | `arco` o `seccion`; arco plano orientable en 3D |
| `compatibilidad` | `compatibilidad` de plataforma/varillas o `adhesivo` |
| `seccion_general` | Contorno poligonal o pared delgada: N, My, Mz y torsión de una celda cerrada |
| `uniones` | Pasador/perno y láminas, soldadura a tope, filetes centrados o adhesivo simple |
| `placa_local` | Pandeo local de un panel rectangular por compresión o cortante |
| `solido3d` | Elasticidad estática 3D: caja o sólido importado STEP/STL, con PDE Toolbox |

La selección de resistencia no activa automáticamente fatiga, estabilidad o concentración de tensiones. Son fenómenos diferentes y necesitan datos específicos. La descripción de alcance del modelo se muestra antes de los datos.

Las cuatro ampliaciones figuran con `Capitulo=0` en el catálogo. No son capítulos nuevos ni requieren otros Live Scripts. La revisión de las lecciones y las fuentes de las fórmulas están en `REVISION_LECCIONES.md`.

## Ingreso de datos: procedimiento común

Esta guía corresponde únicamente al integrado. Los dieciséis Live Scripts docentes conservan su presentación y funcionamiento. No necesitas modificar un archivo auxiliar para cada ejercicio.

1. En **Selección del análisis**, usa `seleccion="directa"` y escribe la clave del capítulo en `analisis`.
2. En **Datos del caso**, completa la identificación y localiza el bloque con esa misma clave. Cada dato se escribe como `datos.nombre=valor;` **dentro** de su `if analisis=="…"`.
3. Sustituye geometría, material, cargas, apoyos y límites del bloque activo. No borres los campos de modos inactivos: la interfaz verifica la presencia de los campos de la familia, aunque solo use un grupo.
4. Al cambiar el número de nodos/barras/tramos, actualiza todas las tablas que dependan de ese número. Cambiar únicamente la coordenada o una fuerza no redefine las conexiones.
5. Para un solo caso deja `compararCasos=false`. Pulsa **Run** para ejecutar el documento completo y renovar datos, resultados, figuras y memoria.
6. Lee primero el alcance y estado del cálculo, luego unidades y signos. **Ejecución completada** no equivale a **resistencia comprobada**.

No edites `ae_datos.m` para alimentar el Live Script: sus valores sirven de catálogo y ejemplo para otras llamadas. La entrada efectiva del integrado es su bloque `datos`. Tampoco escribas datos solo en Workspace: un Run completo vuelve a construirlos desde el documento.

### Convenciones comunes de entrada

| Magnitud | Entrada |
|---|---|
| Longitudes, áreas, inercias | m, m², m⁴; 100 mm = 0.1 m; 400 mm² = 400e-6 m² |
| Fuerzas, momentos y tensiones | N, N m, Pa; 5 kN = 5000 N; 250 MPa = 250e6 Pa |
| Giros y ángulos | rad; 30 grados = 30*pi/180 |
| Masa y aceleración | kg y m/s²; kg no se introduce como fuerza |
| F | Área de sección en las familias de barras; no es una fuerza genérica |
| Filas de nodos | La fila 1 es nodo 1, la fila 2 nodo 2, etc. |
| Matrices | Espacio separa columnas; punto y coma separa filas |
| `[]` | Tabla vacía: ninguna carga/condición de ese tipo, si el campo lo permite |
| `NaN` en apoyos | Componente libre; 0 impide su movimiento; otro valor prescribe un movimiento |
| `Inf` en un límite permitido | Desactiva ese límite; no significa material infinitamente resistente |

Las plantillas siguientes muestran el bloque completo de cada familia con datos **de demostración**. Sustituye sus valores dentro del bloque que ya existe en el Live Script. No pegues las dieciséis plantillas al final del documento ni dupliques el bloque de una misma clave. Las filas con varios nombres en las tablas explican campos relacionados; cada campo sigue siendo una asignación independiente.

### Índice de las familias de los dieciséis capítulos


- [Capítulo 01: `axial`](#entrada-capitulo-01)
- [Capítulo 02: `cercha`](#entrada-capitulo-02)
- [Capítulo 03: `seccion`](#entrada-capitulo-03)
- [Capítulo 04: `torsion`](#entrada-capitulo-04)
- [Capítulo 05: `viga`](#entrada-capitulo-05)
- [Capítulo 06: `flexion_oblicua`](#entrada-capitulo-06)
- [Capítulo 07: `sistema_barras`](#entrada-capitulo-07)
- [Capítulo 08: `tensor`](#entrada-capitulo-08)
- [Capítulo 09: `resistencia_combinada`](#entrada-capitulo-09)
- [Capítulo 10: `lamina`](#entrada-capitulo-10)
- [Capítulo 11: `estabilidad`](#entrada-capitulo-11)
- [Capítulo 12: `dinamica`](#entrada-capitulo-12)
- [Capítulo 13: `plasticidad`](#entrada-capitulo-13)
- [Capítulo 14: `fatiga`](#entrada-capitulo-14)
- [Capítulo 15: `barra_curva`](#entrada-capitulo-15)
- [Capítulo 16: `compatibilidad`](#entrada-capitulo-16)

- [Entrada de un sólido 3D](#entrada-solido-3d)


<a id="entrada-capitulo-01"></a>

### Capítulo 01: Alargamiento, temperatura y contacto de una barra

Selección: `analisis="axial"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.x` | [x0 x1 … xn], m | Posiciones crecientes de todos los cambios de área, E, carga distribuida y condiciones que delimitan tramos. Incluye posiciones de cargas/apoyos para una partición clara. |
| `datos.F`, `datos.E` | Escalar o n valores; m² y Pa | Un valor común o uno por intervalo de x. No introducir diámetro donde se pide área. |
| `datos.puntuales` | [posición fuerza], m y N | Una fila por carga axial; positivo hacia +x. [] si no hay. |
| `datos.distribuidas` | [xInicio xFin qInicio qFin], m y N/m | Carga lineal entre sus extremos. [] si no hay. |
| `datos.apoyos` | [posición desplazamiento], m y m | El desplazamiento es prescrito, normalmente 0. El resto de la barra queda libre. |
| `datos.alpha`, `datos.deltaT` | 1/K y K | Dilatación térmica; pueden ser datos por tramo según la entrada axial. Sin temperatura usa deltaT=0. |
| `datos.topes` | [posición límite sentido] | Límite de desplazamiento en m y sentido +1 o −1. Es contacto unilateral, no un apoyo siempre activo. [] sin topes. |
| `datos.resistencia` | struct con limiteTraccion, limiteCompresion y nMin | Límites en Pa y factor mínimo sin unidades. No comprueba pandeo. |

Plantilla del bloque activo:

```matlab
if analisis=="axial"
datos.x=[0 1 3 4 5];
datos.F=[2 2 1 1]*1e-3; datos.E=210e9;
datos.puntuales=[1 7000;4 -3000;5 1000];
datos.distribuidas=[]; datos.apoyos=[0 0];
datos.alpha=12e-6; datos.deltaT=0; datos.topes=[];
datos.resistencia=struct('limiteTraccion',160e6,'limiteCompresion',160e6,'nMin',1.5);
end
```

Alcance: Barra recta axial, E y F constantes por tramo, pequeñas deformaciones, cargas y temperatura lineales por tramo, apoyos bilaterales y hasta ocho topes unilaterales. No comprueba pandeo.


<a id="entrada-capitulo-02"></a>

### Capítulo 02: Esfuerzos de barras unidas mediante articulaciones

Selección: `analisis="cercha"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.nodos` | Una fila [x y] o [x y z], m | El número de fila es el índice del nodo. No se añade una columna de numeración. |
| `datos.barras` | [nodoInicial nodoFinal] | Conecta índices de filas de nodos. El número de fila es el índice de barra. |
| `datos.E`, `datos.F` | Escalar o un valor por barra; Pa, m² | Rigidez axial del material y área resistente. |
| `datos.cargas` | [nodo FX FY] o [nodo FX FY FZ], N | Cargas aplicadas a nodos, no momentos ni cargas de flexión. |
| `datos.apoyos` | [nodo ux uy] o [nodo ux uy uz], m | 0 restringe; NaN deja libre. El conjunto debe impedir movimientos rígidos y mecanismos. |
| `datos.deformacionLibre` | Escalar o por barra, adimensional | Por ejemplo alpha·deltaT; una longitud de error debe dividirse entre la longitud de su barra. |

Plantilla del bloque activo:

```matlab
if analisis=="cercha"
datos.nodos = [0 0; 2 0; 1 1.5];
datos.barras = [1 2; 1 3; 2 3];
datos.E = 210e9;
datos.F = 400e-6;
datos.cargas = [3 0 -20000];
datos.apoyos = [1 0 0; 2 NaN 0];
datos.deformacionLibre = 0;
end
```

Alcance: Cerchas planas o espaciales, nudos articulados, cargas nodales, barras prismáticas y elasticidad lineal. No incluye flexión de barras, grandes desplazamientos ni verificación de pandeo.


<a id="entrada-capitulo-03"></a>

### Capítulo 03: Área, centroide e inercias de una sección

Selección: `analisis="seccion"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.modo` | "poligonos" o "pared_delgada" | Activa solo la descripción geométrica correspondiente. |
| `datos.contornos` | {[y z; …], [y z; …]}, m | Vértices ordenados en el contorno. Cada matriz representa material o hueco; no se escribe una nube desordenada. |
| `datos.signos` | [1 -1 …] | Una entrada por contorno: +1 material, −1 hueco. Evita solapes y huecos fuera del material. |
| `datos.segmentos` | [yi zi yf zf t], m | Una fila por pared definida por su línea media y espesor. En pared delgada se omiten términos de espesor al cubo. |

Plantilla del bloque activo:

```matlab
if analisis=="seccion"
datos.modo = "poligonos";
datos.contornos = {[-.06 -.10; .06 -.10; .06 .10; -.06 .10], ...
    [-.04 -.07; .04 -.07; .04 .07; -.04 .07]};
datos.signos = [1 -1];
datos.segmentos = [0 0 .12 0 .004; .12 0 .12 .20 .004; .12 .20 0 .20 .004];
end
```

Alcance: Contornos poligonales con huecos sin solapamientos, o segmentos rectos de pared delgada. Las curvas se aproximan mediante vértices; la modalidad de pared delgada omite términos de espesor al cubo.


<a id="entrada-capitulo-04"></a>

### Capítulo 04: Giro y tensiones de un eje recto

Selección: `analisis="torsion"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.x`, `datos.G` | Posiciones en m y módulo en Pa | x delimita tramos; G puede ser común o por tramo. |
| `datos.tipoSeccion` | "circular", "abierta_delgada", "cerrada_delgada" o "constantes" | Solo se usan las propiedades del tipo activo. |
| `datos.D`, `datos.di` | Diámetros exterior e interior, m | Solo circular; di=0 para macizo. Escalar o por tramo. |
| `datos.paredes` | [longitud espesor], m | Descripción de las paredes de la sección delgada; no son coordenadas del eje de la barra. |
| `datos.areaMedia` | m² | Área encerrada por la línea media de una celda cerrada; no el área de material. |
| `datos.J`, `datos.W` | m⁴ y m³ | Para constantes, introduce constante de torsión y módulo torsional; J no es siempre Iy+Iz. |
| `datos.pares` | [posición par], m y N m | Una fila por momento torsor concentrado. |
| `datos.distribuidos` | [xInicio xFin mInicio mFin] | Par distribuido por longitud, N m/m. |
| `datos.apoyos` | [posición giro], m y rad | Prescribe giros; 0 fija el giro torsional. |

Plantilla del bloque activo:

```matlab
if analisis=="torsion"
datos.x=[0 1 2.5];
datos.G=80e9;
datos.tipoSeccion="circular";
datos.D=[.05 .04]; datos.di=[0 .02];
datos.paredes=[.10 .003; .06 .003; .10 .003; .06 .003];
datos.areaMedia=.10*.06;
datos.J=1e-7; datos.W=4e-6;
datos.pares=[1 300; 2.5 -100];
datos.distribuidos=[];
datos.apoyos=[0 0];
end
```

Alcance: Torsión de Saint-Venant con J y W constantes por tramo. Secciones circulares exactas, pared delgada abierta o cerrada de una celda mediante sus aproximaciones. Sin alabeo restringido.


<a id="entrada-capitulo-05"></a>

### Capítulo 05: Flexión transversal de una viga plana

Selección: `analisis="viga"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.x` | Posiciones crecientes, m | Incluye los puntos de cambio del modelo. |
| `datos.E`, `datos.F`, `datos.I`, `datos.c` | Pa, m², m⁴, m | Material, área, inercia en el plano de flexión y distancia del eje neutro a la fibra extrema. Admite propiedades por tramo según el modelo de viga. |
| `datos.puntuales` | [posición fuerzaVertical momento], m, N, N m | Con +y hacia arriba, una fuerza hacia abajo es negativa; giro/momento positivos según el plano x-y. |
| `datos.distribuidas` | [xInicio xFin qInicio qFin], m y N/m | Carga vertical lineal; hacia abajo negativa. |
| `datos.apoyos` | [posición flecha giro], m, m, rad | [0 0 NaN] es flecha impedida con giro libre; [0 0 0] es empotramiento. |

Plantilla del bloque activo:

```matlab
if analisis=="viga"
datos.x=[0 2 4]; datos.E=210e9;
datos.F=.08*.16; datos.I=.08*.16^3/12; datos.c=.08;
datos.puntuales=[2 -10000 0];
datos.distribuidas=[0 4 -2000 -2000];
datos.apoyos=[0 0 NaN; 4 0 NaN];
end
```

Alcance: Vigas rectas Euler-Bernoulli con E, F e I constantes por tramo, cargas repartidas lineales y apoyos de desplazamiento/rotación. La tensión mostrada usa una distancia extrema c y la aproximación de cortante corresponde a sección rectangular. No calcula el centro de cortante de perfiles abiertos.


<a id="entrada-capitulo-06"></a>

### Capítulo 06: Tensiones por flexión biaxial o carga excéntrica

Selección: `analisis="flexion_oblicua"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.contornos`, `datos.signos` | Contornos [y z] en m y signo por contorno | Mismo formato geométrico del capítulo 3. |
| `datos.N`, `datos.My`, `datos.Mz` | N, N m, N m | N positivo en tracción. Esta familia mantiene las ecuaciones y convención de momentos del capítulo 6; comprueba su ecuación renderizada antes de transferir momentos desde otro modelo. |
| `datos.usarExcentricidad` | true o false | true sustituye los momentos por los obtenidos de la carga N excéntrica, no los suma a los que escribiste. |
| `datos.ey`, `datos.ez` | m | Excentricidades respecto al centroide; la implementación usa My=−N·ez y Mz=−N·ey. Para vectores físicos de mano derecha usa seccion_general y su convención explícita. |

Plantilla del bloque activo:

```matlab
if analisis=="flexion_oblicua"
datos.contornos={[-.05 -.08; .05 -.08; .05 .08; -.05 .08]}; datos.signos=1;
datos.N=-50000; datos.My=800; datos.Mz=1500;
datos.usarExcentricidad=false;
datos.ey=.015; datos.ez=.010;
end
```

Alcance: Verificación de una sección poligonal, también con huecos, en régimen elástico. Incluye acoplamiento de ejes no principales mediante Iyz. No obtiene la deformada espacial completa de una viga.


<a id="entrada-capitulo-07"></a>

### Capítulo 07: Esfuerzos y desplazamientos de un marco 2D o 3D

Selección: `analisis="sistema_barras"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.modo` | "espacial", "plano" o "resorte" | Conserva los campos de modos inactivos; no intervienen en el cálculo seleccionado. |
| `datos.nodos`, `datos.barras` | [X Y Z], m; [nodo1 nodo2] | Geometría del marco espacial mediante ejes de barras, no superficies CAD. |
| `datos.E`, `datos.G`, `datos.F`, `datos.Iy`, `datos.Iz`, `datos.J` | Pa, Pa, m², m⁴, m⁴, m⁴ | Escalar o por barra. Iy/Iz corresponden a ejes principales locales. J es la constante de torsión. |
| `datos.cargas` | [nodo FX FY FZ MX MY MZ] | Fuerzas en N y momentos en N m, en ejes globales. |
| `datos.apoyos` | [nodo ux uy uz rx ry rz] | Traslaciones en m y giros en rad; NaN libre, 0 impedido. |
| `datos.qGlobal` | [qx0 qx1 qy0 qy1 qz0 qz1], N/m | Una fila por barra; intensidades globales en sus extremos inicial y final. |
| `datos.qLocal` | [qx0 qx1 qy0 qy1 qz0 qz1 mx0 mx1] | Una fila por barra. Fuerzas por longitud en N/m y par por longitud en N m/m, en ejes locales. Se suma a qGlobal; evita duplicar cargas. |
| `datos.referenciaY` | [YX YY YZ], una fila por barra | Dirección de referencia para orientar el eje y local; no debe ser paralela al eje de barra. [0 0 0] deja orientación automática. |
| `datos.tipoBarra` | "viga" o "axial", común o por barra | Una barra axial no transmite flexión. No convierte un marco mal restringido en una estructura estable. |
| `datos.liberaciones` | [barra extremo giroLocal] | extremo=1 o 2; giroLocal=4,5,6 corresponde a giro local x,y,z. zeros(0,3) sin liberaciones. |
| `datos.deformacionLibre`, `datos.curvaturaLibre`, `datos.giroLibre` | Adimensional, [κy κz] en 1/m, giro/longitud en rad/m | Deformaciones iniciales por barra; 0 para omitir. |
| `datos.consulta` | [nodo componente] | Componente global: 1,2,3 traslaciones; 4,5,6 giros. Se contrasta con trabajo virtual. |
| `datos.vistaEpiuras`, `datos.mostrarCeros` | "locales", "espaciales", "ambas"; true/false | Opciones de representación. No cambian la física. |
| `datos.nodosPlano`, `datos.barrasPlano`, `datos.Iplano` | [x y], m; [nodo1 nodo2]; m⁴ | Geometría e inercia para modo plano; E y F son los campos comunes. |
| `datos.cargasPlano`, `datos.apoyosPlano` | [nodo FX FY MZ]; [nodo ux uy rz] | N/N m y m/rad; NaN deja libre el apoyo correspondiente. |
| `datos.qPlano` | [qx0 qx1 qy0 qy1], N/m | Una fila por barra plana. |
| `datos.liberacionesPlano`, `datos.consultaPlano` | [barra extremo]; [nodo componente] | Libera el giro del extremo; consulta plana: 1 x, 2 y, 3 giro. |
| `datos.deformacionLibrePlano`, `datos.curvaturaLibrePlano` | Adimensional y 1/m | Valores iniciales de barra para modo plano. |
| `datos.Dresorte`, `datos.dalambre`, `datos.vueltas` | m, m, número de vueltas | Diámetro medio del resorte, diámetro del alambre y vueltas activas. |
| `datos.Gresorte`, `datos.Eresorte`, `datos.fuerzaResorte`, `datos.parResorte` | Pa, Pa, N, N m | Propiedades y demandas del modo resorte. |

Plantilla del bloque activo:

```matlab
if analisis=="sistema_barras"
datos.modo="espacial";
datos.nodos=[0 0 0; 0 1 0; 2 1 0; 2 0 0];
datos.barras=[1 2; 2 3; 3 4];
datos.E=210e9; datos.G=80e9; datos.F=.005; datos.Iy=8e-6; datos.Iz=8e-6; datos.J=16e-6;
datos.cargas=[3 0 0 -1000 0 0 0];
datos.apoyos=[1 0 0 0 0 0 0; 4 0 0 0 0 0 0];
datos.qGlobal=[0 0 0 0 0 0; 0 0 0 0 -1000 -1000; 0 0 0 0 0 0];
datos.qLocal=zeros(size(datos.barras,1),8);
datos.referenciaY=zeros(size(datos.barras,1),3);
datos.tipoBarra="viga";
datos.liberaciones=zeros(0,3);
datos.deformacionLibre=0; datos.curvaturaLibre=[0 0]; datos.giroLibre=0;
datos.consulta=[3 3];
datos.vistaEpiuras="ambas"; datos.mostrarCeros=false;
datos.nodosPlano=[0 0;0 2;3 2;3 0];
datos.barrasPlano=[1 2;2 3;3 4]; datos.Iplano=8e-6;
datos.cargasPlano=[3 5000 -10000 0];
datos.apoyosPlano=[1 0 0 0;4 0 0 0];
datos.qPlano=[0 0 0 0;0 0 -1000 -1000;0 0 0 0];
datos.liberacionesPlano=zeros(0,2); datos.consultaPlano=[3 2];
datos.deformacionLibrePlano=0;datos.curvaturaLibrePlano=0;
datos.Dresorte=.10; datos.dalambre=.008; datos.vueltas=8; datos.Gresorte=80e9;
datos.Eresorte=210e9; datos.fuerzaResorte=200; datos.parResorte=2;
end
```

Alcance: Barras rectas prismáticas elásticas: marcos 3D con seis grados de libertad por nodo, barras axiales y marcos 2D. Flexión Euler-Bernoulli y torsión de Saint-Venant; no incluye alabeo restringido, deformación por cortante, grandes giros ni pandeo. Las curvas discretizadas con barras rectas requieren convergencia de malla y curvatura moderada respecto al tamaño de sección.


<a id="entrada-capitulo-08"></a>

### Capítulo 08: Tensiones principales y deformaciones en un punto

Selección: `analisis="tensor"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.tipo` | "tensiones" o "deformaciones" | Indica qué contiene la matriz de entrada. |
| `datos.matriz` | Matriz simétrica 3×3 | Tensiones: [σx τxy τxz; τxy σy τyz; τxz τyz σz] en Pa. Deformaciones: tensor adimensional, con εxy=γxy/2, no γxy. |
| `datos.E`, `datos.nu` | Pa y adimensional | Elasticidad isótropa; −1<nu<0.5 en esta familia. |
| `datos.alpha`, `datos.deltaT` | 1/K y K | Separa la deformación térmica isotrópica. |
| `datos.normalCara` | [nx ny nz] | Vector no nulo de la cara de consulta; el programa lo normaliza. |
| `datos.limiteElastico` | Pa | Se utiliza para los factores de von Mises y Tresca. No lo deduce del nombre del material. |

Plantilla del bloque activo:

```matlab
if analisis=="tensor"
datos.tipo="tensiones";
datos.matriz=[80 25 0; 25 -20 10; 0 10 5]*1e6;
datos.E=210e9; datos.nu=.3; datos.alpha=12e-6; datos.deltaT=0;
datos.normalCara=[1 1 0];
datos.limiteElastico=250e6;
end
```

Alcance: Estado homogéneo en un punto de un material elástico lineal isótropo. Las deformaciones fuera de la diagonal son tensoriales: epsilon_xy=gamma_xy/2. No calcula un campo espacial a partir de cargas de contorno.


<a id="entrada-capitulo-09"></a>

### Capítulo 09: Resistencia o diámetro de barras circulares en 3D

Selección: `analisis="resistencia_combinada"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.modo`, `datos.evaluacion` | "estructura" o "seccion"; "comprobar" o "dimensionar" | Dimensionar busca diámetros de barras circulares en el intervalo indicado; no rediseña una pieza CAD arbitraria. |
| `datos.nodos`, `datos.barras`, `datos.cargas`, `datos.apoyos`, `datos.qGlobal`, `datos.qLocal`, `datos.referenciaY`, `datos.liberaciones` | Formato espacial del capítulo 7 | Cargas y momentos globales; propiedades y esfuerzos referidos a los ejes locales correspondientes. |
| `datos.E`, `datos.nu`, `datos.G` | Pa, adimensional, Pa | En material isótropo G=E/[2(1+nu)]. Mantén consistencia entre ellos. |
| `datos.D`, `datos.di`, `datos.espesor` | m | Diámetros exterior/interior. Para tubo de espesor conocido usa espesor; [] permite la descripción mediante di. No son áreas. |
| `datos.limiteTraccion`, `datos.limiteCompresion` | Pa | Admisibles de cada signo, explícitos. |
| `datos.teoria`, `datos.nRequerido`, `datos.considerarCortante` | Entero 1–5, factor, true/false | Elige la teoría y comprueba su ecuación y alcance en la memoria. 3=III/Tresca y 4=IV/von Mises. No seleccionarlas sin atender al material. |
| `datos.intervaloDiametro`, `datos.puntosLongitud`, `datos.puntosAngulares` | [Dmin Dmax], m; números de puntos | Intervalo de búsqueda y resolución del muestreo de comprobación. |
| `datos.vistaEpiuras`, `datos.mostrarCeros` | "locales", "espaciales", "ambas"; true/false | Representación del modo estructura. |
| `datos.N`, `datos.Qy`, `datos.Qz`, `datos.My`, `datos.Mz`, `datos.T` | N, N, N, N m, N m, N m | Demandas directas del modo sección circular. No son coordenadas. |

Plantilla del bloque activo:

```matlab
if analisis=="resistencia_combinada"
datos.modo="estructura"; datos.evaluacion="comprobar";
datos.nodos=[0 0 0;.6 0 0;.6 0 .3]; datos.barras=[1 2;2 3];
datos.E=210e9; datos.nu=.3; datos.G=datos.E/(2*(1+datos.nu));
datos.cargas=[3 0 -450 -150 0 0 0]; datos.apoyos=[1 0 0 0 0 0 0];
datos.qGlobal=zeros(size(datos.barras,1),6); datos.qLocal=zeros(size(datos.barras,1),8);
datos.referenciaY=zeros(size(datos.barras,1),3);datos.liberaciones=zeros(0,3);
datos.D=.03; datos.di=0; datos.espesor=[];
datos.limiteTraccion=160e6;datos.limiteCompresion=160e6;
datos.teoria=4; datos.nRequerido=1; datos.considerarCortante=true;
datos.intervaloDiametro=[.015 .12]; datos.puntosLongitud=121; datos.puntosAngulares=360;
datos.vistaEpiuras="ambas"; datos.mostrarCeros=false;
datos.N=20000;datos.Qy=0;datos.Qz=0;datos.My=800;datos.Mz=1200;datos.T=600;
end
```

Alcance: Marcos espaciales elásticos de barras rectas circulares, con flexión en dos planos, torsión y esfuerzo axial. El cortante transversal se controla mediante una envolvente conservadora de Jourawski, no mediante un campo exacto 3D de elasticidad. El dimensionamiento es uniforme y se limita al intervalo indicado. No incluye concentraciones locales en codos/uniones, alabeo restringido, pandeo ni plastificación.


<a id="entrada-capitulo-10"></a>

### Capítulo 10: Tensiones de membrana en una superficie de revolución

Selección: `analisis="lamina"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.tipo` | "cilindro", "esfera" o "cono" | Superficie de revolución en régimen de membrana; no equivale a una chapa cualquiera. |
| `datos.radio`, `datos.longitud`, `datos.anguloCono`, `datos.espesor` | m, m, rad, m | Parámetros del modelo elegido. Introduce un ángulo en grados como grados*pi/180. |
| `datos.presionInicial`, `datos.densidadLiquido`, `datos.gravedad` | Pa, kg/m³, m/s² | Presión inicial más término hidrostático. Para presión uniforme usa densidadLiquido=0. |
| `datos.fuerzaAxialExtra` | N | Fuerza axial adicional; no volver a introducir aquí la fuerza de cierre ya considerada por la presión. |
| `datos.E`, `datos.nu`, `datos.limiteElastico` | Pa, adimensional, Pa | Propiedades y límite para el criterio resistente. |
| `datos.numeroPuntos` | Entero | Resolución de la representación e integración; no sustituye comprobar validez de membrana. |

Plantilla del bloque activo:

```matlab
if analisis=="lamina"
datos.tipo="cilindro";
datos.radio=.5; datos.longitud=1; datos.anguloCono=25*pi/180;
datos.espesor=.004;
datos.presionInicial=1e6; datos.densidadLiquido=0; datos.gravedad=9.81;
datos.fuerzaAxialExtra=0;
datos.E=210e9; datos.nu=.3; datos.limiteElastico=250e6;
datos.numeroPuntos=301;
end
```

Alcance: Láminas delgadas, convexas, axisimétricas y sin momentos de borde. Admite presión uniforme o hidrostática y fuerza axial en el corte inicial. No predice flexión local de uniones, singularidades de ápices ni pandeo por presión externa.


<a id="entrada-capitulo-11"></a>

### Capítulo 11: Pandeo y flexión de segundo orden de una columna

Selección: `analisis="estabilidad"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.L`, `datos.E`, `datos.I`, `datos.F` | m, Pa, m⁴, m² | I=[Iy Iz] para dos planos principales o un escalar para ambos. |
| `datos.extremos` | Nombre de condición | "articulada_articulada", "empotrada_libre", "empotrada_empotrada" o "empotrada_articulada". |
| `datos.elementos` | Entero ≥2 | Número de elementos de la columna; afecta aproximación numérica. |
| `datos.P` | N, magnitud positiva de compresión | Debe ser inferior a la crítica para resolver el equilibrio linealizado de segundo orden. |
| `datos.cargasLaterales` | [x FY FZ], m y N | Cargas transversales entre x=0 y L. [] sin ellas. |
| `datos.limiteProporcional` | Pa | Permite revisar si la tensión crítica elástica es compatible con el material; no calcula pandeo plástico ni estabilidad general de un marco. |

Plantilla del bloque activo:

```matlab
if analisis=="estabilidad"
datos.L=2;datos.E=210e9;datos.I=[8e-8 12e-8];datos.F=600e-6;
datos.extremos="articulada_articulada";datos.elementos=24;datos.P=10000;
datos.cargasLaterales=[.83 100 60];
datos.limiteProporcional=200e6;
end
```

Alcance: Columna prismática de ejes principales, mismo tipo de apoyo en ambos planos, compresión conservativa constante y flexión de segundo orden linealizada. No incluye pandeo por torsión, flexotorsión, pospandeo ni plastificación. Las cargas interiores se aplican mediante funciones de forma; refina la malla para comprobar convergencia.


<a id="entrada-capitulo-12"></a>

### Capítulo 12: Máximos de impacto o barra radial en rotación

Selección: `analisis="dinamica"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.modo`, `datos.estructura` | "impacto" o "rotacion"; tipo de estructura | En impacto: "axial", "voladizo", "marco_3d" o "rigidez_dada". |
| `datos.L`, `datos.E`, `datos.F`, `datos.I`, `datos.c` | m, Pa, m², m⁴, m | Geometría/material de barra axial o voladizo. |
| `datos.masa`, `datos.altura`, `datos.velocidadInicial`, `datos.gravedad` | kg, m, m/s, m/s² | Masa que impacta, altura de caída y velocidad inicial. Se obtiene un máximo por balance energético, no una historia temporal completa. |
| `datos.rigidezDada`, `datos.limiteElastico` | N/m y Pa | Rigidez equivalente en modo rigidez_dada; límite material cuando el modelo permite tensión. |
| `datos.densidad`, `datos.radioInicio`, `datos.omega` | kg/m³, m, rad/s | Barra radial en rotación: radioInicio desde el eje de giro al comienzo de la barra. |
| `datos.nodosImpacto`, `datos.barrasImpacto`, `datos.apoyosImpacto` | Formatos espaciales del capítulo 7 | Definen el marco para obtener su rigidez en la dirección del impacto. |
| `datos.nodoImpacto`, `datos.direccionImpacto` | Índice y [dx dy dz] | Nodo y vector no nulo de la fuerza de impacto. |
| `datos.Gimpacto`, `datos.IyImpacto`, `datos.IzImpacto`, `datos.Jimpacto` | Pa, m⁴, m⁴, m⁴ | Propiedades del marco de impacto. E y F son los campos comunes. |

Plantilla del bloque activo:

```matlab
if analisis=="dinamica"
datos.modo="impacto";
datos.estructura="axial";
datos.L=2; datos.E=210e9; datos.F=400e-6; datos.I=8e-6; datos.c=.08;
datos.masa=10; datos.altura=.02; datos.velocidadInicial=0; datos.gravedad=9.81;
datos.rigidezDada=1e6; datos.limiteElastico=250e6;
datos.densidad=7850; datos.radioInicio=.2; datos.omega=50;
datos.nodosImpacto=[0 0 0;0 1 0;2 1 0]; datos.barrasImpacto=[1 2;2 3];
datos.apoyosImpacto=[1 0 0 0 0 0 0]; datos.nodoImpacto=3; datos.direccionImpacto=[0 0 -1];
datos.Gimpacto=80e9; datos.IyImpacto=8e-6; datos.IzImpacto=8e-6; datos.Jimpacto=16e-6;
end
```

Alcance: Impacto sobre una estructura lineal sin amortiguamiento y con masa estructural despreciable frente al impactante; o barra radial prismática a velocidad angular constante. Se calcula el máximo energético o equilibrio de inercia, no una historia temporal de ondas o vibraciones.


<a id="entrada-capitulo-13"></a>

### Capítulo 13: Respuesta monótona de un material ideal elastoplástico

Selección: `analisis="plasticidad"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.modo` | "axial", "flexion" o "torsion" | Carga monótona y material ideal elastoplástico; no endurecimiento, descarga ni plasticidad del sólido CAD. |
| `datos.E`, `datos.G`, `datos.sigmaFluencia`, `datos.tauFluencia` | Pa | Módulos elásticos y límites de fluencia normal/cortante. |
| `datos.niveles`, `datos.anchuras`, `datos.curvaturaMax` | m, m, 1/m | Flexión: alturas crecientes y ancho de sección en cada altura, interpolado linealmente. Curvatura máxima impuesta. |
| `datos.Lb`, `datos.Fb`, `datos.desplazamientoMax` | m, m², m | Axial: longitudes y áreas de barras en paralelo que comparten desplazamiento, no una cadena de tramos en serie. |
| `datos.R`, `datos.ri`, `datos.longitudEje`, `datos.giroPorLongitudMax` | m, m, m, rad/m | Torsión: radios exterior/interior del eje y giro por longitud máximo. |
| `datos.pasos` | Entero ≥3 | Incrementos de representación de la respuesta monótona. |

Plantilla del bloque activo:

```matlab
if analisis=="plasticidad"
datos.modo="flexion";
datos.E=210e9; datos.G=80e9; datos.sigmaFluencia=250e6; datos.tauFluencia=145e6;
datos.niveles=[-.08 0 .08]; datos.anchuras=[.08 .08 .08];
datos.curvaturaMax=.10;
datos.Lb=[1 1.5 2]; datos.Fb=[200 300 250]*1e-6; datos.desplazamientoMax=.004;
datos.R=.025; datos.ri=0; datos.longitudEje=1; datos.giroPorLongitudMax=.5;
datos.pasos=101;
end
```

Alcance: Material ideal elastoplástico simétrico y carga monótona. Barras paralelas con desplazamiento común; flexión pura de una sección descrita por anchura frente a altura; torsión de sección circular. No representa descarga, endurecimiento, ciclos plásticos ni colapso general de un marco.


<a id="entrada-capitulo-14"></a>

### Capítulo 14: Seguridad frente a ciclos de tensión conocidos

Selección: `analisis="fatiga"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.ciclos` | [sigmaMax sigmaMin tauMax tauMin], Pa | Una fila por punto evaluado; máximo ≥ mínimo. La fila NO contiene un número de ciclos. |
| `datos.limiteFatigaNormal`, `datos.limiteFatigaCortante` | Pa | Límites de fatiga pertinentes al material y condiciones del caso. |
| `datos.limiteTraccion`, `datos.limiteCompresion`, `datos.limiteCortante` | Pa | Límites estáticos para contrastar los extremos del ciclo. |
| `datos.Knormal`, `datos.Kcortante` | Factores positivos | Correcciones/concentraciones que afectan a la amplitud en las ecuaciones implementadas; deben corresponder al caso. |
| `datos.psiNormal`, `datos.psiCortante` | Factores no negativos | Sensibilidad a tensión media del criterio implementado, con respaldo material. |
| `datos.nRequerido` | Factor positivo | Umbral del factor combinado. No estima vida mediante curva S–N ni acumula daño de un espectro variable. |

Plantilla del bloque activo:

```matlab
if analisis=="fatiga"
datos.ciclos=[120 -80 35 -35; 90 -50 50 -20]*1e6;
datos.limiteFatigaNormal=180e6; datos.limiteFatigaCortante=105e6;
datos.limiteTraccion=340e6; datos.limiteCompresion=340e6; datos.limiteCortante=195e6;
datos.Knormal=1.6; datos.Kcortante=1.4; datos.psiNormal=.15; datos.psiCortante=.10;
datos.nRequerido=1.5;
end
```

Alcance: Ciclos estacionarios caracterizados por sus extremos, límites de fatiga y coeficientes conocidos. Combina tensión normal y cortante mediante una relación empírica de seguridad. No estima daño acumulado, espectros variables ni vida finita sin datos experimentales.


<a id="entrada-capitulo-15"></a>

### Capítulo 15: Tensiones y desplazamiento de una barra de gran curvatura

Selección: `analisis="barra_curva"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.modo` | "arco" o "seccion" | Arco calcula un voladizo curvo; sección usa N y M ya conocidos. |
| `datos.radios`, `datos.anchuras` | m y m | Radios crecientes de la sección y ancho en cada radio. Se interpolan; no representan la polilínea del arco. |
| `datos.E`, `datos.nu` | Pa y adimensional | Propiedades elásticas; G se deriva cuando se incluye cortante. |
| `datos.anguloArco` | rad, 0<ángulo≤pi | Abertura del arco de referencia. |
| `datos.fuerza`, `datos.direccionConsulta` | [Fx Fy], N; [dx dy] | Vectores en el plano LOCAL del arco. La consulta se normaliza para obtener desplazamiento. |
| `datos.Nseccion`, `datos.Mseccion` | N y N m | Demandas directas del modo sección, según su ecuación renderizada. |
| `datos.origenArco`, `datos.direccionXArco`, `datos.normalPlanoArco` | [X Y Z], m; dos vectores | Ubicación y orientación espacial del arco; no convierten el problema en un arco con cargas fuera de su plano. |
| `datos.incluirCortante`, `datos.factorCortante` | true/false; factor positivo | Activa el término aproximado de energía por cortante. |

Plantilla del bloque activo:

```matlab
if analisis=="barra_curva"
datos.modo="arco";
datos.radios=[.08 .12]; datos.anchuras=[.03 .03];
datos.E=210e9; datos.nu=.3;
datos.anguloArco=pi/2; datos.fuerza=[0 -1000]; datos.direccionConsulta=[0 -1];
datos.Nseccion=1000; datos.Mseccion=200;
datos.origenArco=[0 0 0];datos.direccionXArco=[1 0 0];datos.normalPlanoArco=[0 1 1];
datos.incluirCortante=false; datos.factorCortante=1.2;
end
```

Alcance: Barras curvas de sección constante y material elástico lineal. La sección se describe mediante anchura frente a radio. El arco es circular y está empotrado en un extremo, con fuerza en el otro. No incluye alabeo, torsión espacial ni redistribución plástica.


<a id="entrada-capitulo-16"></a>

### Capítulo 16: Plataforma con varillas o transferencia adhesiva

Selección: `analisis="compatibilidad"`.

| Campo | Formato y unidad | Qué introducir |
|---|---|---|
| `datos.modo` | "compatibilidad" o "adhesivo" | Plataforma rígida sobre varillas o transferencia longitudinal en banda adherida. |
| `datos.posiciones` | [x y], m | Una fila por varilla de la plataforma. |
| `datos.longitudes`, `datos.areas`, `datos.E` | m, m², Pa | Un valor por varilla para longitudes y áreas; material común o compatible con el núcleo de varillas. |
| `datos.errores` | m | Errores de longitud/montaje por varilla; revisar signo con la ecuación de compatibilidad. |
| `datos.P`, `datos.xCarga` | N y [x y], m | Fuerza total y posición de aplicación sobre la plataforma. |
| `datos.longitudUnion`, `datos.ancho`, `datos.espesor` | m | Dimensiones de la banda adherida sobre base rígida. |
| `datos.moduloBanda`, `datos.rigidezAdhesivo`, `datos.fuerzaUnion` | Pa, Pa/m, N | Rigidez del adhesivo relaciona tensión cortante con deslizamiento, aproximadamente Gadh/espesorAdh; no es directamente Gadh. |

Plantilla del bloque activo:

```matlab
if analisis=="compatibilidad"
datos.modo="compatibilidad";
datos.posiciones=[0 0;1 0;1 1;0 1]; datos.longitudes=[1 1 1 1]; datos.areas=[200 200 200 200]*1e-6;
datos.E=210e9; datos.errores=[.0002 -.0001 0 .0001]; datos.P=20000; datos.xCarga=[.5 .5];
datos.longitudUnion=.12; datos.ancho=.03; datos.espesor=.002;
datos.moduloBanda=200e9; datos.rigidezAdhesivo=5e11; datos.fuerzaUnion=1000;
end
```

Alcance: Dos familias de problemas avanzados: barra o plataforma rígida suspendida por varillas axiales paralelas y banda adherida a una base rígida mediante una ley de cortante lineal. No es un solucionador universal de todos los problemas avanzados.

<a id="entrada-solido-3d"></a>
## Ingreso de datos de un sólido 3D

### Primera ejecución: geometría y unidades

En la selección escribe `analisis="solido3d"`. En su bloque activo cambia inicialmente:

```matlab
datos.geometria="archivo";
datos.modo="geometria";
datos.archivoGeometria="C:\ruta\pieza.step";
datos.escalaGeometria=1;
```

Usa una sola barra invertida en una ruta de MATLAB. Conserva los demás campos del bloque. El modo geometría revisa el CAD sin calcular tensiones: muestra caras y dimensiones. Si el importador recibe números en mm, la conversión a m es 0.001; si ya recibe m, es 1. Confirma una longitud conocida. La extensión STEP/STL no justifica por sí sola elegir una escala.

El módulo actual admite un único sólido material conectado. Un archivo STEP puede contener un ensamblaje de decenas de cuerpos y ser rechazado aunque abra en un programa CAD. Reexportar o unir cuerpos puede cambiar la idealización: no convierte contactos, tornillos o soldaduras en relaciones mecánicas verificadas.

### Segunda ejecución: problema físico

| Campo | Formato / unidad | Decisión necesaria |
|---|---|---|
| `datos.geometria`, `datos.modo` | "archivo" y "resolver" | Resolver solo después de revisar caras, escala y apoyos |
| `datos.archivoGeometria`, `datos.escalaGeometria` | Ruta STEP/STL; factor positivo | Archivo existente y conversión contrastada |
| `datos.dimensiones` | [Lx Ly Lz], m | Se usa solo con geometria="caja", no cambia el tamaño de un CAD importado |
| `datos.E`, `datos.nu`, `datos.densidad` | Pa; 0<ν<0.5; kg/m³ | Material elástico isótropo; no deducido por el importador |
| `datos.carasFijas` | [cara1 cara2 …] | Caras con ux=uy=uz=0; requiere justificación física |
| `datos.apoyosComponente` | [cara ux uy uz], m | NaN libre; 0 restringido. Una fila por cara, sin repetirla en carasFijas |
| `datos.traccionesCara` | [cara tx ty tz], Pa | Vector uniforme global por unidad de área, no una fuerza total |
| `datos.presionesCara` | [cara presión], Pa | Presión positiva hacia el interior |
| `datos.traccionCaja` | [tx ty tz], Pa | Solo demostración de la caja con todas las tablas vacías; no actúa sobre un archivo CAD |
| `datos.aceleracionEfectiva` | [ax ay az], m/s² | g−aBase; carga de volumen correspondiente a la masa del sólido |
| `datos.factorCargaVolumen` | Factor ≥0 | Multiplica esa carga de volumen; normalmente 1 |
| `datos.Hmax` | m | Tamaño máximo de elemento propuesto, no número de elementos |
| `datos.Hmin` (opcional) | m o [] | Tamaño mínimo solicitado; [] conserva el automático. Puede ser necesario en detalles delgados. Debe ser ≤Hmax |
| `datos.Hgrad` (opcional) | Entre 1 y 2 | Transición entre tamaños; por defecto 1.5. Reducirlo suaviza la transición y puede aumentar mucho el número de elementos |
| `datos.refinarMalla`, `datos.nivelesMalla` | true/false; 2–4 | Comparación de mallas, reduciendo Hmax por 1.5 por nivel |
| `datos.toleranciaMalla` | Fracción positiva | 0.05 = 5% entre los dos últimos indicadores; no error garantizado |
| `datos.limiteElastico`, `datos.nRequerido` | Pa o NaN; factor positivo | Límite positivo documentado para resistencia. NaN permite calcular tensiones/desplazamientos sin afirmar resistencia |
| `datos.limiteDesplazamiento` | m o Inf | Límite del desplazamiento máximo; Inf lo desactiva |

Para crear tablas sin filas usa `zeros(0,4)` en apoyos por componente/tracciones y `zeros(0,2)` en presiones. No asignes apoyo y carga a la misma cara en esta interfaz. Las caras pueden renumerarse al reexportar o cambiar geometría: vuelve a identificarlas.

Los controles opcionales de malla se pueden añadir únicamente al bloque SOLIDO3D como `datos.Hmin=.001; datos.Hgrad=1.3;`. Aquí se solicitan 1 mm mínimo y transición 1.3, como ejemplo de configuración; no son una receta universal. El integrado completa sus valores por defecto si no los escribes. Al refinar varios niveles se reducen Hmax y Hmin por el mismo factor; Hgrad se conserva. Una malla de mala calidad o un fallo del mallador exige revisar detalles y tamaños, no aceptar el resultado solo porque se pudo resolver.

Acero provisional para estudiar rigidez: E=210e9 Pa, nu=0.3 y densidad=7850 kg/m³. **Acero no identifica un límite elástico**: necesitas su grado o un valor documentado para emitir una comprobación resistente. Si se desconoce, escribe `datos.limiteElastico=NaN`; se calculan tensiones y desplazamientos, el factor queda sin evaluar y la memoria indica «pendiente». El límite de 160 MPa del ejemplo original no es una propiedad descubierta de tu pieza.

### Pasar de una masa a una carga superficial

500 kg producen un peso aproximado de 500·9.81=4905 N. Esto no indica dónde se aplican ni qué área los transmite. Si una fuerza total de 4905 N en −Z se reparte uniformemente sobre una cara plana de área **conocida** A=0.05 m², la entrada sería tz=−4905/0.05=−98100 Pa. El número de cara y esa área deben corresponder al CAD real. Este ejemplo no define por sí solo las cargas de tu soporte.

La aceleración volumétrica carga la masa del soporte modelado; no incorpora automáticamente 500 kg de equipo ausentes del sólido. Para el peso propio bajo −Z usa `[0 0 -9.81]`. Evita sumar otra vez una masa que ya está representada. Momentos por excentricidad y distribución entre fijaciones requieren equilibrio del conjunto; no basta dividir entre el número de tornillos.

### Qué aparecerá en la memoria y sobre el CAD

La memoria del sólido desarrolla equilibrio continuo, deformación, ley de Hooke, discretización K·u=f+R e indicadores del caso. No presenta una integral cerrada por cada detalle del CAD ni la matriz completa de miles de grados de libertad en una hoja.

Los mapas de tensión equivalente y desplazamiento y la deformada se muestran sobre el modelo 3D. Las ecuaciones permanecen en páginas separadas. Una sección o barra produce epiuras por su eje; un sólido produce campos espaciales. El integrado actual no inserta ecuaciones flotantes sobre las caras ni deriva automáticamente un modelo de vigas de una geometría importada.

Sin dos mallas comparadas o sin cumplir la tolerancia, el estado permanece Parcial. Aun con indicadores estables, interpreta máximos cercanos a aristas, cargas y apoyos idealizados. No se ejecutan automáticamente contactos, plasticidad, fatiga, estabilidad ni comprobación de soldaduras del conjunto.


## Ejemplo: una varilla simple

En el bloque AXIAL del Live Script:

```matlab
datos.x=[0 2];
datos.F=400e-6;
datos.E=200e9;
datos.puntuales=[2 10000];
datos.distribuidas=[];
datos.apoyos=[0 0];
datos.alpha=12e-6;
datos.deltaT=0;
datos.topes=[];
datos.resistencia=struct('limiteTraccion',160e6, ...
    'limiteCompresion',160e6,'nMin',1.5);
```

La reacción debe ser −10 kN; N=10 kN; sigma=25 MPa y el desplazamiento del extremo 0.25 mm. Las ecuaciones y las figuras se recalculan sin editar las rutinas. Un resultado axial no comprueba pandeo.

## Ejemplo: selección guiada de un marco

```matlab
seleccion="guiada";
guia.objeto="marco";
guia.accion="combinada";
guia.interes="deformaciones";
```

La guía selecciona `sistema_barras`. Rellena su bloque de datos: `modo="espacial"`, nodos `[X Y Z]`, conexiones, E, G, F, Iy, Iz, J, cargas y apoyos. Las filas de carga son `[nodo FX FY FZ MX MY MZ]`. En apoyos, una componente NaN es libre y una componente numérica prescribe su desplazamiento o giro. No se introducen coordenadas en la columna de índice de nodo.

Iy e Iz deben referirse a ejes principales locales de la sección; `referenciaY` orienta esos ejes. Una referencia nula deja que el programa elija una orientación geométrica, que debes revisar en el esquema. Para una sección con inercias diferentes no basta con conocer sus dimensiones: debes orientar correctamente la sección.

Si cambias el número de barras, adapta también las filas de `qGlobal`, `qLocal` y `referenciaY`, o vuelve a inicializarlas con el tamaño adecuado. E y las propiedades admiten escalares o valores por barra según el modelo. Cambiar de geometría exige actualizar todas las tablas relacionadas, no solo las coordenadas.

## Memoria matemática

Las expresiones se dibujan como ecuaciones dentro de la salida del Live Script. Se generan de nuevo a partir de `solucion`: no son capturas del libro ni fórmulas con números fijos. `memoria.paginas` conserva el título, la explicación y las expresiones LaTeX de cada página.

- Barra axial: equilibrio global y desarrollo de N(s), sigma(s), epsilon(s), delta(s) y desplazamiento final por tramo. Incluye temperatura y continuidad.
- Cerchas y marcos: sistema de rigidez, condiciones prescritas, extracto numérico de la matriz, resultados locales y trabajo virtual cuando corresponde. La matriz completa se conserva en el resultado.
- Otras familias: ecuaciones del modelo, criterio o integración aplicados y valores del caso. No se pretende producir una solución simbólica cerrada arbitraria para geometrías definidas numéricamente.

Para desarrollar solo determinadas barras o puntos:

```matlab
opcionesMemoria.elementos=[1 3];
opcionesMemoria.maxFilasMatriz=4;
```

`elementos=[]` desarrolla todos los elementos; en membranas muestra las estaciones inicial y final por defecto. Si deseas otras estaciones, indica sus índices. Las filas y columnas mostradas de K son un extracto de presentación; nunca sustituyen a K completa en el cálculo. El máximo de filas mostrado es cuatro para mantener la legibilidad.

El número de páginas depende del modelo y de los elementos seleccionados. En modelos extensos conviene escoger barras o puntos representativos. Las ecuaciones de memoria son una salida renderizada; para cambiarlas se modifican los datos y se recalcula, no se escribe sobre la imagen.

Cuando una barra axial combina carga mecánica y temperatura sin contactos unilaterales, las epiuras se desglosan automáticamente en componentes mecánicas, térmicas y totales. Con contactos se representa la solución total: el estado de contacto puede cambiar y no admite esa superposición en general.

## Conservar y comparar casos

`solucion.entrada` conserva los datos usados; `solucion.resultado` contiene los resultados de la familia y `solucion.comprobaciones` los controles disponibles. La estructura `memoria` conserva las ecuaciones utilizadas para el informe. Guarda un caso desde la consola, después de ejecutarlo:

```matlab
save('Caso_varilla.mat','solucion','memoria');
```

`save` guarda variables en un archivo MAT. Aquí conserva tanto los datos efectivos como el cálculo y las expresiones de la memoria; no sustituye a guardar el Live Script para conservar su presentación.

## Secciones y uniones

`seccion_general` admite perfiles definidos por vértices `[y z]`, huecos con signo negativo y paredes delgadas `[yi zi yf zf espesor]`. Calcula centroide, inercias acopladas y tensión normal por N, My y Mz. Los momentos físicos siguen la regla de la mano derecha. Un perfil curvo se aproxima mediante segmentos; la respuesta se refiere a la sección prismática idealizada.

La opción `torsion="celda_unica"` requiere paredes ordenadas y consecutivas que cierren una sola celda. Obtiene flujo de Bredt, tensión cortante, constante de torsión y giro. No obtiene el centro de cortante ni el alabeo restringido. Si introduces Qy/Qz o una torsión que ese modo no resuelve, el estado es **Parcial** aunque las tensiones normales sean admisibles.

En `uniones`, las cargas se refieren a **una fijación**. No se divide la fuerza del equipo entre tornillos sin estudiar su posición y la excentricidad. Cada fila de `laminas` contiene `[espesor ancho distanciaCentroAlBorde fuerzaTransmitida]`; la fuerza se introduce en N. `diametro` corresponde al pasador; `diametroAgujero` determina la pérdida de sección y el ligamento al borde. `areaTraccion` admite el área resistente de la rosca cuando corresponde. Los límites de tracción, corte, aplastamiento y equivalente se introducen por separado.

Las soldaduras a tope suponen penetración completa y flexión en el eje declarado por el ancho y espesor. Los filetes admiten cortante directo centrado mediante longitudes y gargantas efectivas. No se calcula un grupo de cordones excéntrico. El adhesivo simple comprueba cortante medio; no los máximos de borde ni el pelado.

`placa_local` compara por separado los límites de compresión y cortante, con los coeficientes y condiciones de borde indicados. Si ambos esfuerzos actúan simultáneamente, falta una comprobación de interacción y el resultado queda **Parcial**. El modelo no representa automáticamente un soporte plegado ni una placa perforada.

## Comparación de condiciones de carga

Activa `compararCasos=true` en el integrado. `cambios` sustituye campos completos de los datos base; después `factorMecanico` escala las fuerzas y momentos admitidos. No escala geometría, material, temperatura ni desplazamientos prescritos. Por ejemplo, para un modelo axial:

```matlab
compararCasos=true;
casos(1)=struct('nombre',"Servicio",'factorMecanico',1,'cambios',struct);
casos(2)=struct('nombre',"Carga aumentada",'factorMecanico',1.5,'cambios',struct);
casos(3)=struct('nombre',"Caliente",'factorMecanico',1, ...
    'cambios',struct('deltaT',50));
casoDetalle=2;
limiteDesplazamientoCasos=.002;
```

Aquí el límite adicional es 2 mm. `Inf` desactiva ese límite. Solo actúa en la comparación; el límite propio `datos.limiteDesplazamiento` del sólido funciona también al resolver un caso único. `casoDetalle` elige la solución que desarrolla la memoria. `estudio.soluciones` conserva todas y `estudio.tabla` identifica sus indicadores. Las figuras de cálculo llevan el nombre de su modelo; la memoria incluye el nombre del caso. No todos los modelos devuelven un factor resistente: la tabla lo declara cuando falta.

El factor 1.5 del ejemplo no es una exigencia normativa. Evita duplicar coeficientes ya incluidos en las cargas o admisibles al fijar también `nRequerido`.

`ae_carga_masa` obtiene una carga cuasiestática equivalente:

```matlab
carga=ae_carga_masa(masa,centroMasa,puntoTraslado,aceleracionBase,gravedad);
```

La función recibe kg, m y m/s² y devuelve `[FX FY FZ MX MY MZ]` en N y N m. Usa F=m(g−a) y M=(rG−rO)×F. Para un marco espacial añade delante el índice de nodo. No añade esa carga al modelo por sí sola; tampoco calcula vibración ni movimiento del contenido de un tanque. No dupliques el peso si ya está representado en otra carga.

## Sólidos 3D y geometría CAD

La disponibilidad de PDE Toolbox R2024b y su licencia se comprobó en este equipo. El núcleo usa elasticidad lineal isótropa y pequeños desplazamientos. `nu` debe estar entre 0 y 0.5, sin incluir extremos, en la interfaz utilizada. La primera demostración es una caja, no un soporte aprobado.

Para revisar una pieza exportada:

```matlab
analisis="solido3d";
```

En el bloque SOLIDO3D:

```matlab
datos.geometria="archivo";
datos.modo="geometria";
datos.archivoGeometria="C:\ruta\soporte.step";
datos.escalaGeometria=1;
```

En una cadena de MATLAB basta una sola barra invertida por separador de ruta. Ajusta la ruta al archivo real. La previsualización muestra números de cara y caja envolvente en metros. Contrasta una dimensión conocida. Usa escala 0.001 únicamente si las coordenadas que recibió el importador están en mm; no la apliques por la extensión del archivo.

Después cambia a `modo="resolver"` e introduce material, apoyos y cargas. `carasFijas` restringe las tres traslaciones de una cara. `apoyosComponente` permite `[cara ux uy uz]`, con NaN para componentes libres; por ejemplo `[3 0 NaN NaN]` impide solo el desplazamiento X de la cara 3. La elección debe representar el apoyo físico, no servir únicamente para evitar un error del solucionador.

`traccionesCara` usa `[cara tx ty tz]` en **Pa**, no fuerzas totales en N. Una fuerza uniforme normal sobre una superficie plana de área A se convierte en tracción mediante F/A con el signo y dirección correctos. `presionesCara` usa `[cara presión]`, positiva hacia el interior. La aceleración efectiva produce la fuerza de volumen de la masa del sólido; un equipo montado requiere sus cargas transmitidas adicionales.

Para estudiar sensibilidad a la malla, activa `refinarMalla=true` y define `nivelesMalla` entre 2 y 4. Cada nivel divide Hmax por 1.5. Se comparan desplazamiento máximo y tensión nodal máxima entre las dos últimas mallas; la tolerancia es editable y no garantiza por sí sola la precisión. Los picos singulares en esquinas, apoyos o cargas idealizadas requieren interpretación. Sin estudio, o sin cumplir la tolerancia, el resultado queda **Parcial**.

Se muestran identificación de caras, malla, tensión equivalente y deformada amplificada. En un sólido, los mapas de campo complementan la memoria; las epiuras por eje corresponden a los modelos de barras. No se extrae automáticamente un eje de viga de un CAD.

Se admite un único sólido material conectado. Importar un ensamblaje no define contactos ni uniones entre sus componentes. No están implementados contacto, precarga de tornillos, plasticidad 3D, fatiga del sólido, pandeo del sólido o dinámica vibratoria. La fatiga del capítulo correspondiente requiere sus propios datos y no se aplica automáticamente a este campo estático.

STEP/STL se importan desde MATLAB; los formatos nativos SLDPRT/SLDASM requieren exportación. Los ensamblajes necesitan una idealización compatible antes de importarlos como un único sólido conectado. Los modelos y resultados de componentes particulares no se distribuyen en este repositorio.

En `solucion.resultado.equilibrio` y `solucion.comprobaciones.Equilibrio3D` aparecen cargas ensambladas, reacciones nodales y residuos de fuerzas/momentos. Las reacciones proceden de K·u−f en los grados restringidos. `reaccionTensiones` conserva aparte la estimación por integración del campo de tensiones, que puede ser muy inexacta en una malla gruesa junto a un anclaje. Superar el equilibrio discreto no demuestra convergencia de tensiones ni validez de los apoyos físicos.

## Organización y mantenimiento

Conserva los 16 `Cap*.mlx`, los archivos `rm_*.m` y `ae_*.m` en esta carpeta. El integrador verifica la presencia de los capítulos. Los adaptadores `ae_modelo_02` a `ae_modelo_16` encapsulan las fórmulas y gráficas de los capítulos revisados; las rutinas `rm_*.m` se comparten directamente. No se ejecutan documentos dentro de otros documentos ni se comparten variables implícitas entre capítulos.

Modificar un Live Script docente no actualiza por sí solo su adaptador: una mejora debe trasladarse a la rutina compartida o al adaptador y verificarse también en la memoria. Así se evita asumir que dos textos de cálculo distintos están sincronizados sin comprobación.

`COMPROBAR_INTEGRADO.m` ejecuta controles de las familias, modos alternativos, casos analíticos, selección guiada y rechazo de entradas inválidas. `COMPROBAR_INTEGRADO_AXIAL.m` comprueba la presentación con temperatura, contactos y carga distribuida. No necesitan ejecutarse para resolver cada caso.

`COMPROBAR_LECCIONES.m` verifica las ampliaciones de secciones, uniones, paneles y casos de carga. `COMPROBAR_SOLIDO_INTEGRADO.m` comprueba la elasticidad 3D, reacciones, convergencia de un campo exacto, importación STEP/STL y memoria; requiere PDE Toolbox. El resultado de la revisión está registrado en `VALIDACION_INTEGRADO.md` y su manifiesto JSON.
