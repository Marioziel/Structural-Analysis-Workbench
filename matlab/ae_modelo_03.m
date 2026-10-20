function [resultado,estado]=ae_modelo_03(entrada)
modo=entrada.modo;
contornos=entrada.contornos;
signos=entrada.signos;
segmentos=entrada.segmentos;
if modo=="poligonos"
    resultado=rm_seccion(contornos,signos);
else
    assert(modo=="pared_delgada",'Modo no reconocido.');
    resultado=rm_pared(segmentos);
end
F=resultado.F;
centro=resultado.centro;
Iy=resultado.Iy; Iz=resultado.Iz; Iyz=resultado.Iyz;
disp(table(F,centro(1),centro(2),Iy,Iz,Iyz, ...
    'VariableNames',{'F_m2','yc_m','zc_m','Iy_m4','Iz_m4','Iyz_m4'}));

disp(table(resultado.principales,resultado.radios, ...
    'VariableNames',{'Inercia_principal_m4','Radio_giro_m'}));
[figura,ejes]=rm_figura(2,'Seccion y propiedades'); hold(ejes(1),'on');
if modo=="poligonos"
    plot(ejes(1),resultado.region,'FaceColor',[.8 .85 .9]);
else
    for i=1:size(segmentos,1)
        plot(ejes(1),segmentos(i,[1 3]),segmentos(i,[2 4]),'k-','LineWidth',2);
    end
end
plot(ejes(1),centro(1),centro(2),'ro');
for k=1:2
    v=resultado.direcciones(:,k)*3*max(resultado.radios);
    plot(ejes(1),centro(1)+[-v(1) v(1)],centro(2)+[-v(2) v(2)],'--');
end
axis(ejes(1),'equal'); xlabel(ejes(1),'y [m]'); ylabel(ejes(1),'z [m]');
title(ejes(1),'Centroide y ejes principales');
bar(ejes(2),resultado.principales); ylabel(ejes(2),'I [m^4]'); xlabel(ejes(2),'Eje principal');
estado=struct;
if exist('F','var'),estado.F=F;end
if exist('centro','var'),estado.centro=centro;end
if exist('Iy','var'),estado.Iy=Iy;end
if exist('Iz','var'),estado.Iz=Iz;end
if exist('Iyz','var'),estado.Iyz=Iyz;end
end
