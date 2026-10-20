function [resultado,estado]=ae_modelo_10(entrada)
tipo=entrada.tipo;
radio=entrada.radio;
longitud=entrada.longitud;
anguloCono=entrada.anguloCono;
espesor=entrada.espesor;
presionInicial=entrada.presionInicial;
densidadLiquido=entrada.densidadLiquido;
gravedad=entrada.gravedad;
fuerzaAxialExtra=entrada.fuerzaAxialExtra;
E=entrada.E;
nu=entrada.nu;
limiteElastico=entrada.limiteElastico;
numeroPuntos=entrada.numeroPuntos;
assert(radio>0 && longitud>0 && espesor>0 && numeroPuntos>=20,'Geometria invalida.');
if tipo=="cilindro"
    z=linspace(0,longitud,numeroPuntos)'; r=radio+zeros(size(z));
    coseno=ones(size(z)); km=zeros(size(z)); kt=1./r;
elseif tipo=="esfera"
    phi=linspace(.025,pi/2,numeroPuntos)';
    z=radio*(1-cos(phi)); r=radio*sin(phi); coseno=sin(phi);
    km=ones(size(z))/radio; kt=km;
else
    assert(tipo=="cono" && anguloCono>0 && anguloCono<pi/2,'Tipo de lamina invalido.');
    z=linspace(0,longitud,numeroPuntos)'; r=radio+z*tan(anguloCono);
    coseno=cos(anguloCono)+zeros(size(z)); km=zeros(size(z)); kt=coseno./r;
end
p=presionInicial+densidadLiquido*gravedad*(z-z(1));
assert(all(p>=0) && limiteElastico>0,'Presion o limite invalido.');

fuerzaInicial=p(1)*pi*r(1)^2+fuerzaAxialExtra;
Fz=fuerzaInicial+cumtrapz(r,2*pi*p.*r);
Nm=Fz./(2*pi*r.*coseno);
Nt=(p-km.*Nm)./kt;
sigmaM=Nm/espesor; sigmaT=Nt/espesor;
equivalente=sqrt(sigmaM.^2+sigmaT.^2-sigmaM.*sigmaT);
factor=limiteElastico/max(max(equivalente),realmin);
errorLaplace=max(abs(km.*Nm+kt.*Nt-p));
resultado=struct('sigmaM',sigmaM,'sigmaT',sigmaT,'factor',factor,'errorLaplace',errorLaplace);
disp("Factor de seguridad von Mises: "+factor);
disp("Mayor razon espesor/radio de curvatura: "+max(espesor*max(abs(km),abs(kt))));
disp("Residuo de Laplace [Pa]: "+errorLaplace);

[figura,ejes]=rm_figura(3,'Lamina de revolucion');
rm_curva(ejes(1),z,sigmaM/1e6,'\sigma_m [MPa]');
rm_curva(ejes(2),z,sigmaT/1e6,'\sigma_\theta [MPa]');
rm_curva(ejes(3),z,equivalente/1e6,'\sigma_{VM} [MPa]'); xlabel(ejes(3),'z [m]');
azimut=linspace(0,2*pi,81);
X=r*cos(azimut);Y=r*sin(azimut);Z=z*ones(size(azimut));
[figura,ejes]=rm_figura(1,'Membrana 3D: color = tension equivalente [MPa]');
surf(ejes(1),X,Y,Z,(equivalente/1e6)*ones(size(azimut)),'EdgeColor','none');
axis(ejes(1),'equal');view(ejes(1),35,24);colorbar(ejes(1));
xlabel(ejes(1),'X [m]');ylabel(ejes(1),'Y [m]');zlabel(ejes(1),'Z [m]');
estado=struct;
if exist('z','var'),estado.z=z;end
if exist('r','var'),estado.r=r;end
if exist('p','var'),estado.p=p;end
if exist('Nm','var'),estado.Nm=Nm;end
if exist('Nt','var'),estado.Nt=Nt;end
if exist('km','var'),estado.km=km;end
if exist('kt','var'),estado.kt=kt;end
if exist('equivalente','var'),estado.equivalente=equivalente;end
if exist('Fz','var'),estado.Fz=Fz;end
end
