function [resultado,estado]=ae_modelo_06(entrada)
contornos=entrada.contornos;
signos=entrada.signos;
N=entrada.N;
My=entrada.My;
Mz=entrada.Mz;
usarExcentricidad=entrada.usarExcentricidad;
ey=entrada.ey;
ez=entrada.ez;
seccion=rm_seccion(contornos,signos);
if usarExcentricidad, My=-N*ez; Mz=-N*ey; end
coef=-[seccion.Iz seccion.Iyz;seccion.Iyz seccion.Iy]\[Mz;My];
vertices=seccion.vertices-seccion.centro;
sigmaVertices=N/seccion.F+vertices*coef;
resultado=struct('seccion',seccion,'coef',coef,'sigmaMin',min(sigmaVertices), ...
    'sigmaMax',max(sigmaVertices),'N',N,'My',My,'Mz',Mz);
disp(table(resultado.sigmaMin/1e6,resultado.sigmaMax/1e6, ...
    'VariableNames',{'sigmaMin_MPa','sigmaMax_MPa'}));

[figura,ejes]=rm_figura(2,'Flexion oblicua y excentricidad');
tr=triangulation(seccion.region); puntos=tr.Points;
sigma=N/seccion.F+(puntos-seccion.centro)*coef;
patch(ejes(1),'Faces',tr.ConnectivityList,'Vertices',puntos,'FaceVertexCData',sigma/1e6, ...
    'FaceColor','interp','EdgeColor','none');
axis(ejes(1),'equal'); colorbar(ejes(1)); title(ejes(1),'\sigma_x [MPa]');
hold(ejes(1),'on');
yy=linspace(min(puntos(:,1)),max(puntos(:,1)),100);
if abs(coef(2))>1e-12*max(abs(coef))
    zz=seccion.centro(2)-(N/seccion.F+coef(1)*(yy-seccion.centro(1)))/coef(2);
    plot(ejes(1),yy,zz,'k-','LineWidth',1.2);
elseif coef(1)~=0
    xline(ejes(1),seccion.centro(1)-N/seccion.F/coef(1),'k-');
end
xlim(ejes(1),[min(puntos(:,1)) max(puntos(:,1))]); ylim(ejes(1),[min(puntos(:,2)) max(puntos(:,2))]);
bar(ejes(2),sigmaVertices/1e6); ylabel(ejes(2),'\sigma [MPa]'); xlabel(ejes(2),'Vertice');
estado=struct;
if exist('coef','var'),estado.coef=coef;end
if exist('sigmaVertices','var'),estado.sigmaVertices=sigmaVertices;end
end
