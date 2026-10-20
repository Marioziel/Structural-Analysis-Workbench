function [resultado,estado]=ae_modelo_04(entrada)
x=entrada.x;
G=entrada.G;
tipoSeccion=entrada.tipoSeccion;
D=entrada.D;
di=entrada.di;
paredes=entrada.paredes;
areaMedia=entrada.areaMedia;
J=entrada.J;
W=entrada.W;
pares=entrada.pares;
distribuidos=entrada.distribuidos;
apoyos=entrada.apoyos;
if tipoSeccion=="circular"
    assert(all(D>di & di>=0),'Diametros incompatibles.');
    J=pi*(D.^4-di.^4)/32; W=J./(D/2);
elseif tipoSeccion=="abierta_delgada"
    assert(all(paredes(:,1)>0 & paredes(:,2)>0),'Paredes invalidas.');
    J=sum(paredes(:,1).*paredes(:,2).^3)/3; W=J/max(paredes(:,2));
elseif tipoSeccion=="cerrada_delgada"
    assert(areaMedia>0 && all(paredes(:)>0),'Datos invalidos.');
    J=4*areaMedia^2/sum(paredes(:,1)./paredes(:,2)); W=2*areaMedia*min(paredes(:,2));
else
    assert(tipoSeccion=="constantes" && all(J>0) && all(W>0),'Tipo de seccion invalido.');
end
datos=struct('x',x,'F',J,'E',G,'puntuales',pares,'distribuidas',distribuidos,'apoyos',apoyos);
resultado=rm_axial(datos);
if isscalar(W), W=repmat(W,numel(x)-1,1); end
W=W(:); assert(numel(W)==numel(x)-1 && all(W>0),'Un W por tramo.');
xx=[]; Mt=[]; tau=[]; giro=[];
for i=1:numel(resultado.tramos)
    t=resultado.tramos(i); s=linspace(0,t.L,101)'; j=resultado.modelo.indiceOriginal(i);
    xx=[xx;t.x0+s]; Mt=[Mt;polyval(t.N,s)];
    tau=[tau;polyval(t.N,s)/W(j)]; giro=[giro;polyval(t.delta,s)];
end
disp(table(resultado.modelo.x,resultado.u*180/pi,resultado.R, ...
    'VariableNames',{'x_m','giro_grados','Reaccion_Nm'}));

[figura,ejes]=rm_figura(3,'Torsion del eje');
rm_curva(ejes(1),xx,Mt,'M_t [N m]');
rm_curva(ejes(2),xx,tau/1e6,'\tau_{max} [MPa]');
rm_curva(ejes(3),xx,giro*180/pi,'\phi [grados]'); xlabel(ejes(3),'x [m]');
estado=struct;
if exist('J','var'),estado.J=J;end
if exist('W','var'),estado.W=W;end
end
