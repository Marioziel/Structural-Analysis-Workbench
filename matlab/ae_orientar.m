function [analisis,explicacion,ajustes]=ae_orientar(g)
campos={'objeto','accion','interes'};
assert(isstruct(g)&&all(isfield(g,campos)),'AE:Guia','Completa objeto, accion e interes.');
o=string(g.objeto);a=string(g.accion);i=string(g.interes);
assert(isscalar(o)&&isscalar(a)&&isscalar(i),'AE:Guia','Una respuesta por pregunta.');
objetos=["barra_recta","barras_articuladas","marco","seccion","punto", ...
    "superficie_revolucion","barra_curva","plataforma","union_adhesiva","union","placa","solido"];
acciones=["axial","torsion","flexion","combinada","temperatura","compresion", ...
    "impacto","rotacion","ciclos","plastificacion","presion","geometria"];
intereses=["esfuerzos","deformaciones","resistencia","estabilidad","propiedades"];
assert(ismember(o,objetos)&&ismember(a,acciones)&&ismember(i,intereses), ...
    'AE:Guia','Respuesta desconocida. Consulta las opciones escritas en el Live Script.');
analisis="";ajustes=struct;
if o=="seccion" && a=="geometria" && i=="propiedades"
    analisis="seccion";
elseif o=="seccion" && ismember(a,["axial","flexion","combinada","torsion"]) && i=="resistencia"
    analisis="seccion_general";
elseif o=="union" && ismember(a,["axial","combinada"]) && i=="resistencia"
    analisis="uniones";
elseif o=="placa" && ismember(a,["compresion","combinada"]) && i=="estabilidad"
    analisis="placa_local";
elseif o=="solido" && ismember(a,["axial","flexion","combinada","presion"]) && ismember(i,["esfuerzos","deformaciones","resistencia"])
    analisis="solido3d";
elseif a=="ciclos" && i=="resistencia"
    analisis="fatiga";
elseif a=="plastificacion" && ismember(o,["barra_recta","seccion"])
    analisis="plasticidad";
elseif o=="barra_recta" && a=="compresion" && i=="estabilidad"
    analisis="estabilidad";
elseif a=="impacto" && ismember(o,["barra_recta","marco"])
    analisis="dinamica";
elseif o=="barra_recta" && a=="rotacion"
    analisis="dinamica";
elseif o=="barra_recta" && ismember(a,["axial","temperatura","compresion"]) && i~="estabilidad"
    analisis="axial";
elseif o=="barra_recta" && a=="torsion"
    analisis="torsion";
elseif o=="barra_recta" && a=="flexion"
    analisis="viga";
elseif o=="barras_articuladas" && ismember(a,["axial","combinada","temperatura"]) && i~="estabilidad"
    analisis="cercha";
elseif o=="marco" && ismember(a,["axial","torsion","flexion","combinada","temperatura"])
    if i=="resistencia",analisis="resistencia_combinada";
    elseif ismember(i,["esfuerzos","deformaciones"]),analisis="sistema_barras";end
elseif o=="seccion" && ismember(a,["flexion","axial"])
    analisis="flexion_oblicua";
elseif o=="seccion" && a=="combinada" && i=="resistencia"
    analisis="resistencia_combinada";
elseif o=="punto" && ismember(i,["esfuerzos","deformaciones","resistencia"])
    analisis="tensor";
elseif o=="superficie_revolucion" && a=="presion"
    analisis="lamina";
elseif o=="barra_curva" && ismember(a,["axial","flexion","combinada"])
    analisis="barra_curva";
elseif o=="plataforma" && ismember(a,["axial","combinada","temperatura"])
    analisis="compatibilidad";
elseif o=="union_adhesiva" && a=="axial"
    analisis="compatibilidad";
end
assert(strlength(analisis)>0,'AE:Guia', ...
    ['La combinacion no identifica un modelo implementado. Consulta ae_catalogo y precisa la idealizacion. ' ...
    'Un marco transmite momentos; una cercha solo N. Una seccion aislada no proporciona la deformada de toda la estructura.']);
t=ae_catalogo;fila=find(t.Clave==analisis);
explicacion=t(fila,:);
if analisis=="compatibilidad" && o=="union_adhesiva",ajustes.modo="adhesivo";end
if analisis=="dinamica" && a=="rotacion",ajustes.modo="rotacion";end
if analisis=="dinamica" && o=="marco",ajustes.estructura="marco_3d";end
end
