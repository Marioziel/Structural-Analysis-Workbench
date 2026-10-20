function [resultado,estado]=ae_modelo_02(entrada)
nodos=entrada.nodos;
barras=entrada.barras;
E=entrada.E;
F=entrada.F;
cargas=entrada.cargas;
apoyos=entrada.apoyos;
deformacionLibre=entrada.deformacionLibre;
datos = struct('nodos',nodos,'barras',barras,'E',E,'F',F, ...
    'cargas',cargas,'apoyos',apoyos,'deformacionLibre',deformacionLibre);
resultado = rm_cercha(datos);
sigma = resultado.sigma;
disp(resultado.tabla);
disp('Desplazamientos nodales [mm]:'); disp(resultado.u*1000);
disp('Reacciones nodales [kN]:'); disp(resultado.R/1000);

[figura,ejes] = rm_figura(2,'Cercha: forma y esfuerzos');
amplitud = max(max(nodos)-min(nodos));
escalaDeformada = 0.12*amplitud/max(max(abs(resultado.u(:))),realmin);
hold(ejes(1),'on');
for i=1:size(barras,1)
    ix=barras(i,:); p=nodos(ix,:); pd=p+escalaDeformada*resultado.u(ix,:);
    if size(nodos,2)==2
        plot(ejes(1),p(:,1),p(:,2),'k-o');
        plot(ejes(1),pd(:,1),pd(:,2),'r--');
        text(ejes(1),mean(p(:,1)),mean(p(:,2)),sprintf(' %d',i));
    else
        plot3(ejes(1),p(:,1),p(:,2),p(:,3),'k-o');
        plot3(ejes(1),pd(:,1),pd(:,2),pd(:,3),'r--');
    end
end
axis(ejes(1),'equal'); title(ejes(1),'Negro: original; rojo: deformada amplificada');
if size(nodos,2)==3, view(ejes(1),35,24); grid(ejes(1),'on'); zlabel(ejes(1),'Z [m]'); end
xlabel(ejes(1),'X [m]');ylabel(ejes(1),'Y [m]');
bar(ejes(2),(1:size(barras,1))',resultado.N/1000);
yline(ejes(2),0,'Color',[.35 .35 .35]); ylabel(ejes(2),'N [kN]'); xlabel(ejes(2),'Barra');
estado=struct;
end
