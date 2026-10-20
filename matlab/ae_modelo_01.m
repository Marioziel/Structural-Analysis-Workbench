function [resultado,estado]=ae_modelo_01(entrada)
x=entrada.x;
F=entrada.F;
E=entrada.E;
puntuales=entrada.puntuales;
distribuidas=entrada.distribuidas;
apoyos=entrada.apoyos;
alpha=entrada.alpha;
deltaT=entrada.deltaT;
topes=entrada.topes;
resistencia=entrada.resistencia;
resultado=rm_axial(entrada);
disp(resultado.tablaNodos);disp(resultado.tablaTramos);
ae_graficar_axial(resultado);
estado=struct;
end
