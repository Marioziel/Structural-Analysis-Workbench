# Revisión de dimensiones: los 16 capítulos

## Qué significa cambiar solo los datos

Sí, para un problema dentro del modelo indicado en el capítulo. Cambiar los datos incluye elegir el modo y completar geometría, material, cargas, apoyos y sección. Un dibujo en perspectiva no basta para decidir el modelo: una figura plana puede tener una fuerza fuera del plano y necesitar el capítulo 7 espacial.

| Capítulo | Modelo y representación | Entrada o decisión |
|---|---|---|
| 01 | Barra axial, 1D | Conservar x, fuerzas axiales y apoyos. Un marco acodado va en 7. |
| 02 | Cerchas 2D/3D | nodos con dos o tres columnas. Nudos articulados; las barras solo transmiten N. |
| 03 | Área de sección, 2D | La sección plana suministra propiedades a un modelo espacial; no es un sólido de volumen. |
| 04 | Torsión de barra, 1D | Una barra recta alrededor de su eje. Para torsión combinada en un marco, 7/9. |
| 05 | Viga plana | Fuerzas y flexión en un plano. Cargas fuera del plano o torsión: 7. |
| 06 | Sección con flexión biaxial | El mapa es 2D porque muestra la sección. Sus momentos pueden proceder de un marco 3D. |
| 07 | Marcos 3D, planos y resortes | modo="espacial" admite seis componentes nodales, barras axiales y liberaciones locales. |
| 08 | Tensor 3D | Se añaden direcciones principales espaciales. Mohr sigue siendo una representación plana. |
| 09 | Marco 3D o sección circular | Geometría, esfuerzos, sección crítica, cortante transversal y dimensionamiento uniforme. |
| 10 | Superficie de revolución 3D | Vista de cilindro, esfera o cono. El cálculo mantiene la hipótesis axisimétrica. |
| 11 | Columna en dos planos | I=[Iy Iz], cargas [x FY FZ]. La menor carga crítica controla; se muestra deformada 3D. |
| 12 | Impacto con flexibilidad 3D opcional | estructura="marco_3d" obtiene k por carga unitaria. Conserva axial, voladizo y giro radial. |
| 13 | Plasticidad de barras o sección | Carga monótona axial, flexión o torsión pura. No es un cálculo de colapso de marco espacial. |
| 14 | Ciclos de tensión por punto | La geometría puede venir de 7/9; este módulo recibe extremos de tensión y coeficientes. |
| 15 | Arco plano orientable en 3D | El dibujo se orienta mediante una base; las fuerzas se introducen en ese plano local. |
| 16 | Barra plana o plataforma espacial | posiciones=[x y] activa tres movimientos compatibles; conserva la unión adhesiva 1D. |

## Marcos: de los datos a los resultados

En el capítulo 7 usa `modo="espacial"`. En el 9 usa `modo="estructura"`. No necesitas ejecutar un capítulo antes del otro. Comparten el mismo cálculo de barras espaciales.

- Nodos: `[X Y Z]`, en m.
- Barras: `[nodoInicial nodoFinal]`. Para una carga interior añade un nodo en esa posición y divide la barra en la tabla.
- Cargas nodales: `[nodo FX FY FZ MX MY MZ]`, en N y N m. Fuerzas y momentos son globales; los momentos son vectores de mano derecha.
- Apoyos: `[nodo uX uY uZ giroX giroY giroZ]`. Cero impide la componente; `NaN` la deja libre; otro número impone un asiento o giro.
- Cargas repartidas globales: una fila por barra, `[qX_inicio qX_final qY_inicio qY_final qZ_inicio qZ_final]`, en N/m.
- Las filas de `qLocal`, `qGlobal` y `referenciaY` deben seguir las barras. Una tabla de ceros mantiene desactivada esa opción.
- Las propiedades pueden ser escalares o un valor por barra. En el 7 se dan F, Iy, Iz y J; en el 9 circular se deducen de los diámetros.

La rutina convierte las cargas a ejes locales, monta el equilibrio, aplica compatibilidad y devuelve desplazamientos, giros y reacciones globales. Después obtiene N, Qy, Qz, Mx, My y Mz a lo largo de cada barra.

## Cómo leer las figuras

`vistaEpiuras="ambas"` muestra geometría/deformada 3D, epiuras verticales por barra y epiuras sobre la estructura. `"locales"` conserva las curvas verticales; `"espaciales"` muestra su orientación; `"geometria"` reduce las figuras al esquema y la deformada. `mostrarCeros=true` incluye componentes nulas.

El eje local x va del primer nodo al segundo. y se construye con `referenciaY`; z completa el triedro de mano derecha. En el esquema x es rojo, y verde y z azul. Iy e Iz deben ser inercias de los ejes principales, con Iyz=0. Utiliza los ejes del capítulo 3 y fija referenciaY en esa dirección; no introduzcas inercias de ejes no principales sin transformarlas. Al comparar signos con otro esquema debes usar los mismos ejes, orden de nodos y lado del corte.

La curva negra indica geometría original o el cero; la deformada roja está amplificada. En las epiuras espaciales la separación también es una escala visual del esfuerzo. Las curvas verticales conservan los valores y unidades. Bajo torsión pura el eje original y la deformada pueden coincidir: los giros se consultan en la tabla y en la epiura de Mx.

Al ejecutar en MATLAB, abre la figura en una ventana y usa la herramienta Rotate 3D para girar la vista. Las miniaturas guardadas muestran una perspectiva fija.

## Comprobar o dimensionar en el capítulo 9

`evaluacion="comprobar"` evalúa los diámetros introducidos. `"dimensionar"` busca un diámetro uniforme en `intervaloDiametro`; recalcula rigideces y esfuerzos en cada evaluación. El intervalo debe contener una solución admisible. Si `espesor=[]` se conserva `di`; con un espesor positivo se usa `di=D-2·espesor`.

`teoria=3` selecciona Tresca; `teoria=4`, von Mises; `teoria=5`, Mohr con diferentes límites resistentes. Los criterios 1–4 se presentan para límites simétricos.

La comprobación con Q usa una envolvente conservadora de Jourawski: suma las mayores magnitudes de cortante, aunque no coincidan en el mismo punto. El mapa de sección muestra por separado la distribución nominal de N, My, Mz y torsión. Si desactivas `considerarCortante`, solo se acepta la comprobación cuando su contribución es como máximo el 5% del límite resistente. La tabla indica ese porcentaje.

Estas comprobaciones corresponden a barras circulares macizas o tubulares y elasticidad lineal. Las concentraciones en esquinas/soldaduras y el pandeo requieren su propio modelo; no quedan resueltos por dibujar la estructura en 3D.

## Curvas representadas por tramos rectos

En el capítulo 7 se pueden definir nodos sobre una curva y unirlos consecutivamente. Es una aproximación de barras rectas para elementos esbeltos: duplica el número de tramos y comprueba convergencia. La tensión de una sección con gran curvatura inicial necesita la formulación del capítulo 15; no se sustituye por la ley de tensión de una barra recta.

## Control reproducible

Ejecuta `COMPROBAR_CALCULOS.m` para los controles anteriores y `COMPROBAR_ESPACIAL.m` para los controles del cálculo espacial y sus ampliaciones. Consulta `VALIDACION.md` para los resultados realmente ejecutados.
