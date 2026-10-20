function [resultado,estado]=ae_modelo_11(entrada)
L=entrada.L;
E=entrada.E;
I=entrada.I;
F=entrada.F;
extremos=entrada.extremos;
elementos=entrada.elementos;
P=entrada.P;
cargasLaterales=entrada.cargasLaterales;
limiteProporcional=entrada.limiteProporcional;
resultado=rm_columna3d(L,E,I,elementos,extremos,P,cargasLaterales);
primero=rm_columna3d(L,E,I,elementos,extremos,0,cargasLaterales);
sigmaCritica=resultado.Pcritica/F;EulerAplicable=sigmaCritica<=limiteProporcional;
disp(table(["Flexion hacia Y";"Flexion hacia Z"], ...
    [resultado.planoY.Pcritica;resultado.planoZ.Pcritica]/1000, ...
    'VariableNames',{'Plano','Pcr_kN'}));
disp(table(resultado.Pcritica/1000,resultado.margen,sigmaCritica/1e6,EulerAplicable, ...
    'VariableNames',{'Pcr_global_kN','Margen','sigmaCritica_MPa','Regimen_elastico_valido'}));

[figura,ejes]=rm_figura(3,'Estabilidad: dos planos principales');
plot(ejes(1),resultado.x,resultado.modo,'LineWidth',1.5);ylabel(ejes(1),'Modo normalizado');legend(ejes(1),{'Y','Z'});
plot(ejes(2),resultado.x,primero.u*1000,'--',resultado.x,resultado.u*1000,'LineWidth',1.3);
ylabel(ejes(2),'Desplazamientos [mm]');legend(ejes(2),{'Y primer orden','Z primer orden','Y segundo orden','Z segundo orden'},'Location','best');
pp=linspace(0,.9*resultado.Pcritica,25);vv=zeros(size(pp));
for j=1:numel(pp)
    a=rm_columna3d(L,E,I,elementos,extremos,pp(j),cargasLaterales);vv(j)=max(vecnorm(a.u,2,2))*1000;
end
plot(ejes(3),pp/1000,vv,'k-');xlabel(ejes(3),'P [kN]');ylabel(ejes(3),'max desplazamiento [mm]');
[figura,ejes]=rm_figura(1,'Columna: deformada espacial amplificada');hold(ejes(1),'on');
escala=.12*L/max(max(vecnorm(resultado.u,2,2)),realmin);
plot3(ejes(1),[0 L],[0 0],[0 0],'k-','LineWidth',2);
plot3(ejes(1),resultado.x,resultado.u(:,1)*escala,resultado.u(:,2)*escala,'r--','LineWidth',1.5);
view(ejes(1),35,24);axis(ejes(1),'equal');grid(ejes(1),'on');
xlabel(ejes(1),'X [m]');ylabel(ejes(1),'Y [m]');zlabel(ejes(1),'Z [m]');
title(ejes(1),sprintf('Deformada x %.3g',escala));
estado=struct;
if exist('sigmaCritica','var'),estado.sigmaCritica=sigmaCritica;end
if exist('EulerAplicable','var'),estado.EulerAplicable=EulerAplicable;end
end
