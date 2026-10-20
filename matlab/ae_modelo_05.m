function [resultado,estado]=ae_modelo_05(entrada)
x=entrada.x;
E=entrada.E;
F=entrada.F;
I=entrada.I;
c=entrada.c;
puntuales=entrada.puntuales;
distribuidas=entrada.distribuidas;
apoyos=entrada.apoyos;
datos=struct('x',x,'E',E,'F',F,'I',I,'puntuales',puntuales, ...
    'distribuidas',distribuidas,'apoyos',apoyos);
resultado=rm_viga(datos);
xx=[]; V=[]; M=[]; v=[]; theta=[]; sigma=[]; tau=[];
for i=1:numel(resultado.campos)
    t=resultado.campos{i}; s=linspace(0,t.L,121)';
    xx=[xx;t.origen(1)+s]; V=[V;polyval(t.V,s)]; M=[M;polyval(t.M,s)];
    v=[v;polyval(t.v,s)]; theta=[theta;polyval(t.theta,s)];
    if isscalar(c), ci=c; else, ci=c(find(x<=mean(t.origen(1)+[0 t.L]),1,'last')); end
    sigma=[sigma;abs(polyval(t.M,s))*ci/resultado.datos.I(i)];
    tau=[tau;1.5*abs(polyval(t.V,s))/resultado.datos.F(i)];
end
disp(table(resultado.x,resultado.u(:,2)*1000,resultado.u(:,3), ...
    'VariableNames',{'x_m','flecha_mm','giro_rad'}));
disp('Reacciones [N, N, N m]:'); disp(resultado.R);
disp("Tension extrema de flexion [MPa]: "+max(sigma)/1e6);
disp("Cortante maximo si seccion rectangular [MPa]: "+max(tau)/1e6);

[figura,ejes]=rm_figura(5,'Viga: esfuerzos y deformacion');
rm_esquema_viga(ejes(1),datos);
rm_curva(ejes(2),xx,V/1000,'V [kN]');
rm_curva(ejes(3),xx,M/1000,'M [kN m]');
rm_curva(ejes(4),xx,theta*180/pi,'\theta [grados]');
rm_curva(ejes(5),xx,v*1000,'v [mm]'); xlabel(ejes(5),'x [m]');
estado=struct;
if exist('V','var'),estado.V=V;end
if exist('M','var'),estado.M=M;end
if exist('v','var'),estado.v=v;end
if exist('theta','var'),estado.theta=theta;end
if exist('sigma','var'),estado.sigma=sigma;end
if exist('tau','var'),estado.tau=tau;end
end
