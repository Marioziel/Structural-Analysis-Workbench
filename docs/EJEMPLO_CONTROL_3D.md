# Control de un marco acodado espacial

El ejemplo 9.1, páginas impresas 305–307, se puede comprobar con los datos iniciales del capítulo 9: tramos de 0.6 m y 0.3 m, fuerzas de -450 N en Y y -150 N en Z en el extremo, y empotramiento en el nodo 1. La orientación global puede diferir del dibujo, pero las magnitudes de los momentos son las mismas.

En la sección del empotramiento deben aparecer:

- |My| = 90 N m.
- |Mz| = 270 N m.
- |Mx| = 135 N m.

Para contrastar el dimensionamiento de referencia utiliza:

```matlab
evaluacion="dimensionar";
considerarCortante=false;
nRequerido=1;
limiteTraccion=160e6;
limiteCompresion=160e6;
di=0; espesor=[];
```

La comprobación solo acepta omitir Q si permanece dentro del umbral del 5%. Ejecuta con teoría 2, 3 y 4 por separado:

| Teoría | Diámetro calculado [mm] | Valor impreso [mm] |
|---|---:|---:|
| 2 | 26.8590 | 26.8 |
| 3 | 27.1684 | 27.2 |
| 4 | 26.9564 | 26.9 |

Las cifras impresas son aproximadas; la columna calculada conserva el resultado de las fórmulas sin truncar.

Con `considerarCortante=true` el programa incluye su envolvente conservadora; el diámetro resultante puede aumentar. Ese cambio se debe al modelo de comprobación, no a un error de la vista 3D.
