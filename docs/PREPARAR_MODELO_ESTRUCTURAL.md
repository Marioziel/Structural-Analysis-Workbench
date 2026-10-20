# Preparación de un componente para el estudio estructural

Antes de evaluar un componente, define su geometría, material, cargas, fijaciones y criterios de aceptación. El CAD por sí solo no determina esas condiciones. Los archivos CAD y resultados particulares se conservan fuera de la distribución pública.

## Geometría

Para inspeccionar el diseño sirve el archivo nativo de SolidWorks. Un ensamblaje SLDASM necesita sus piezas referenciadas; un archivo de ensamblaje aislado puede no contener toda la geometría. STEP permite transferir geometría sólida a MATLAB. STL es una superficie triangulada, debe cerrar un volumen y puede perder detalles según su tolerancia de exportación. Se prefiere STEP cuando esté disponible.

El integrado no abre directamente SLDPRT o SLDASM. Para el análisis sólido se necesita PDE Toolbox y una geometría compatible que represente un único sólido conectado. Si la preparación geométrica une piezas en contacto, esa continuidad representa una idealización rígida; no comprueba contactos, tornillos ni soldaduras. Conserva el CAD original y documenta cualquier simplificación de la copia de cálculo.

Se contrastará una dimensión conocida antes de calcular. Un factor de 1000 en longitudes altera áreas, inercias y tensiones de forma importante. Se revisarán cuerpos separados, agujeros, espesores, radios y superficies de apoyo. Una pieza importada no informa por sí sola de cómo está unida a la estructura que la sostiene o al equipo que recibe.

## Datos que definen el problema físico

| Dato | Utilidad |
|---|---|
| Material, estado y espesor real | E, ν, densidad, límite elástico y admisibles pertinentes; temperatura si modifica sus propiedades |
| Masa del equipo en servicio y centro de masa | Fuerzas y momentos transmitidos; incluir contenidos, accesorios y otras masas sostenidas |
| Fijaciones a la estructura y al equipo | Ubicaciones, componentes restringidas, dimensiones de tornillos y cordones, contacto o libertad de movimiento |
| Condiciones de carga | Gravedad y aceleraciones por caso, fuerzas externas, temperatura y condiciones de operación; no se asignarán aceleraciones de vehículo sin fuente |
| Criterio de aceptación | Desplazamiento admisible, resistencia y coeficientes aplicables con su justificación |
| Uso repetido y entorno | Espectro de cargas/ciclos y corrosión u otros factores si se requiere fatiga o vida útil |

## Secuencia prevista

1. Revisar geometría, unidades, material y trayectoria de cargas.
2. Estimar por equilibrio las fuerzas y momentos y contrastar un modelo sencillo de barras o secciones cuando sea representativo.
3. Elegir el modelo de sólido si interesa el campo local en una pieza de geometría compleja. Identificar caras antes de aplicar restricciones y cargas.
4. Revisar desplazamientos, tensiones, reacciones y sensibilidad a la malla. Distinguir concentraciones físicas de singularidades por idealización.
5. Comprobar por separado fijaciones, soldaduras, estabilidad y fatiga si el caso las requiere. La fuerza por fijación no se obtiene dividiendo la carga entre el número de tornillos cuando existe excentricidad.

Un conjunto de chapas soldadas o piezas atornilladas puede requerir contactos, conectores, elementos de lámina o un programa de elementos finitos con esas capacidades. El módulo actual no sustituye esas relaciones por una unión automática entre cuerpos. El resultado se documentará con las hipótesis realmente empleadas y las comprobaciones pendientes.
