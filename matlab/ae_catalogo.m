function t=ae_catalogo
Clave=[...
"axial";
"cercha";
"seccion";
"torsion";
"viga";
"flexion_oblicua";
"sistema_barras";
"tensor";
"resistencia_combinada";
"lamina";
"estabilidad";
"dinamica";
"plasticidad";
"fatiga";
"barra_curva";
"compatibilidad";
"seccion_general";
"uniones";
"placa_local";
"solido3d"];
Necesidad=[...
"Alargamiento, temperatura y contacto de una barra";
"Esfuerzos de barras unidas mediante articulaciones";
"Área, centroide e inercias de una sección";
"Giro y tensiones de un eje recto";
"Flexión transversal de una viga plana";
"Tensiones por flexión biaxial o carga excéntrica";
"Esfuerzos y desplazamientos de un marco 2D o 3D";
"Tensiones principales y deformaciones en un punto";
"Resistencia o diámetro de barras circulares en 3D";
"Tensiones de membrana en una superficie de revolución";
"Pandeo y flexión de segundo orden de una columna";
"Máximos de impacto o barra radial en rotación";
"Respuesta monótona de un material ideal elastoplástico";
"Seguridad frente a ciclos de tensión conocidos";
"Tensiones y desplazamiento de una barra de gran curvatura";
"Plataforma con varillas o transferencia adhesiva";
"Seccion arbitraria: flexion biaxial y celda cerrada";
"Pasadores, laminas y uniones soldadas o adhesivas simples";
"Estabilidad local de una placa delgada";
"Elasticidad estatica de un solido 3D y geometria STEP/STL"];
Capitulo=[(1:16)';zeros(4,1)];
t=table(Clave,Necesidad,Capitulo);
end
