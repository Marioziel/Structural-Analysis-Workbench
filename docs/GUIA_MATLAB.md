# Guía breve de MATLAB

Cada fila distingue qué hace una operación en general y cómo se usa aquí. Los Live Scripts explican además las funciones principales de su capítulo.

| Operación | Qué significa | Uso concreto |
|---|---|---|
| `numel(x)` | Cuenta todos los elementos de un arreglo. | numel(x)-1 da el número de tramos entre posiciones. |
| `size(A,1), size(A,2)` | Da el número de filas o columnas. | size(barras,1) cuenta las barras que se deben recorrer. |
| `assert(condicion,mensaje)` | Detiene el cálculo si la condición es falsa. | Rechaza áreas negativas o apoyos incompatibles antes de usar las ecuaciones. |
| `isrow, isscalar, isnan, isfinite` | Comprueban forma o tipo de valor. | isscalar(E) permite usar el mismo módulo en todas las barras; isnan reconoce componentes libres de apoyos. |
| `all, any` | Reducen condiciones lógicas: todas o alguna. | all(E>0) exige un módulo positivo en cada barra. |
| `exist(nombre,'file')` | Comprueba si MATLAB encuentra un archivo. | La primera línea confirma que las rutinas del curso están disponibles. |
| `struct` | Agrupa datos mediante campos con nombre. | datos.E, datos.F y datos.apoyos viajan juntos al solucionador. |
| `table, disp` | Organizan columnas y muestran información. | Presentan fuerzas, tensiones y desplazamientos con encabezados y unidades. |
| `zeros, ones, eye, NaN` | Crean arreglos de ceros, unos, la identidad o valores ausentes. | eye(3) representa la parte esférica de un tensor; NaN indica un apoyo libre según la convención de estos archivos. |
| `linspace(a,b,n)` | Genera n puntos igualmente espaciados. | Muestrea cada tramo para dibujar su diagrama. |
| `repmat` | Repite un arreglo. | Extiende una propiedad escalar a todas las barras. |
| `reshape, (:), transpose (')` | Cambian la forma o la orientación de un arreglo. | x(:) asegura una columna para integrar o construir una tabla. |
| `min, max, abs` | Obtienen extremos y valores absolutos. | max(abs(sigma)) localiza la mayor magnitud de tensión. |
| `sum, mean` | Suman valores o calculan su promedio. | sum(N) verifica la resultante; mean(xy) sitúa una etiqueta en el centro de una barra. |
| `diff, find, unique` | Calculan diferencias, buscan índices o eliminan duplicados. | diff(x)>0 comprueba posiciones crecientes; unique reúne cortes y cargas coincidentes. |
| `norm, sqrt, hypot` | Calculan magnitudes o raíces. | norm(normalCara) permite transformar una dirección en un vector unitario. |
| `polyval, polyder` | Evalúan o derivan polinomios escritos con sus coeficientes. | polyval(t.M,s) obtiene el momento en una posición interior de una barra. |
| `interp1` | Interpola valores entre puntos de una tabla. | Convierte una tabla de anchuras frente a altura o radio en una sección continua por tramos. |
| `trapz, cumtrapz` | Integran por trapecios; la segunda acumula la integral. | trapz calcula energía y trabajo virtual; cumtrapz integra la presión o el área acumulada. |
| `integral` | Integra una función de forma adaptativa. | Obtiene el radio neutro de una barra curva con cambios de anchura. |
| `fzero` | Busca una raíz de una función escalar. | Encuentra el eje neutro que deja nula la fuerza normal en flexión elastoplástica pura. |
| `eig, diag, trace` | Calculan valores propios, manejan diagonales y suman la diagonal. | eig obtiene tensiones principales; trace aparece en la ley de Hooke tridimensional. |
| `A\b` | Resuelve el sistema lineal A·x=b. | Obtiene coeficientes de flexión oblicua a partir de los momentos y las inercias. |
| `sin, cos, tan, pi` | Funciones trigonométricas en radianes y constante pi. | Describen geometrías circulares, orientaciones y puntos del contorno. |
| `exp, expm1` | Calculan la exponencial y exp(x)-1. | Describen transferencia por adhesivo sin perder precisión para parámetros pequeños. |
| `plot, plot3, bar, patch` | Dibujan curvas, líneas espaciales, barras o superficies por caras. | Muestran deformadas, esfuerzos de barras y mapas de tensión. |
| `hold, axis, xlim, ylim` | Controlan superposición, proporciones y límites de ejes. | axis equal conserva la forma real de una sección. |
| `title, xlabel, ylabel, legend, colorbar, text` | Añaden títulos, etiquetas, leyendas, escala de color o texto. | Las unidades de cada gráfica se escriben con estas funciones. |
| `yline, xline, quiver` | Dibujan referencias constantes o flechas. | yline marca el cero o un límite; quiver representa cargas en el esquema. |
| `lines, sprintf` | Generan colores y texto con valores insertados. | Asignan un color a cada barra y escriben su número en el esquema. |
| `polyshape, triangulation` | Representan áreas poligonales y las dividen en triángulos. | Definen material y huecos y permiten colorear el campo de tensión. |
| `rm_...` | Son funciones del curso guardadas en esta carpeta, no comandos incorporados. | rm_viga aplica el modelo de viga a tus datos; rm_figura organiza las gráficas verticales. |

## Símbolos de código

- `=` asigna un valor; `==` compara valores.
- `;` evita imprimir una asignación y separa filas dentro de una matriz.
- `[]` construye matrices; `{}` construye celdas, por ejemplo una lista de contornos.
- `A(i,j)` selecciona una entrada. `A(:,j)` selecciona toda la columna j.
- `.*`, `./` y `.^` operan elemento por elemento; `*`, `/` y `^` tienen significado matricial.
- `if / elseif / else / end` selecciona una opción de cálculo.
- `for / end` repite el bloque para cada barra, tramo o punto.
- `@(x)` define una función anónima, por ejemplo `@(r) 1./r`.
- `%` inicia un comentario; `...` continúa una instrucción en la línea siguiente.

Las letras griegas de una figura se escriben con comandos TeX, por ejemplo `\sigma`, `\epsilon`, `\delta`, `\theta` y `\tau`. En las ecuaciones del texto se utiliza LaTeX. Los nombres del código usan letras habituales como `sigma` y `delta`.

## Operaciones de la ampliación espacial

| Operación | Significado general | Uso concreto |
|---|---|---|
| `cross(a,b)` | Producto vectorial perpendicular a a y b. | Completa la base local de una barra y orienta el plano de un arco. |
| `dot(a,b)` | Producto escalar. | Proyecta una dirección sobre otra y obtiene la flexibilidad del impacto. |
| `vecnorm(A,2,2)` | Norma de cada fila. | Mide desplazamientos espaciales para elegir una amplificación visual. |
| `quiver3` | Dibuja flechas con tres componentes. | Representa fuerzas globales y ejes locales en el esquema. |
| `surf` | Dibuja una superficie mediante mallas. | Representa la membrana de revolución en 3D con color de tensión. |
| `polyint`, `conv` | Integran polinomios y multiplican sus coeficientes. | Integran exactamente los productos de esfuerzos del trabajo virtual. |
| `blkdiag` | Crea una matriz por bloques diagonales. | Aplica la misma transformación espacial a fuerzas y giros de ambos nodos. |
| `rank` | Cuenta direcciones linealmente independientes. | Rechaza una plataforma con apoyos alineados que no impiden ambas inclinaciones. |

Las funciones `rm_...` son rutinas incluidas en la carpeta. El capítulo 7 puede ejecutar su modelo plano, espacial o resorte sin cambiar sus ecuaciones.
