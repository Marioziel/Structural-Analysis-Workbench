function [resultado,estado]=ae_modelo_12(entrada)
modo=entrada.modo;
estructura=entrada.estructura;
L=entrada.L;
E=entrada.E;
F=entrada.F;
I=entrada.I;
c=entrada.c;
masa=entrada.masa;
altura=entrada.altura;
velocidadInicial=entrada.velocidadInicial;
gravedad=entrada.gravedad;
rigidezDada=entrada.rigidezDada;
limiteElastico=entrada.limiteElastico;
densidad=entrada.densidad;
radioInicio=entrada.radioInicio;
omega=entrada.omega;
nodosImpacto=entrada.nodosImpacto;
barrasImpacto=entrada.barrasImpacto;
apoyosImpacto=entrada.apoyosImpacto;
nodoImpacto=entrada.nodoImpacto;
direccionImpacto=entrada.direccionImpacto;
Gimpacto=entrada.Gimpacto;
IyImpacto=entrada.IyImpacto;
IzImpacto=entrada.IzImpacto;
Jimpacto=entrada.Jimpacto;
assert(all([L E F masa gravedad limiteElastico]>0) && altura>=0 && velocidadInicial>=0,'Datos invalidos.');
if modo=="impacto"
    if estructura=="axial", k=E*F/L;
    elseif estructura=="voladizo", k=3*E*I/L^3;
    elseif estructura=="marco_3d"
        assert(norm(direccionImpacto)>0,'Direccion de impacto nula.');
        direccionImpacto=direccionImpacto/norm(direccionImpacto);
        datosImpacto=struct('nodos',nodosImpacto,'barras',barrasImpacto,'E',E,'G',Gimpacto,'F',F, ...
            'Iy',IyImpacto,'Iz',IzImpacto,'J',Jimpacto,'apoyos',apoyosImpacto, ...
            'cargas',[nodoImpacto direccionImpacto 0 0 0]);
        unitario=rm_marco3d(datosImpacto);
        flexibilidad=dot(direccionImpacto,unitario.u(nodoImpacto,1:3));
        assert(flexibilidad>0,'La direccion de impacto esta impedida.');k=1/flexibilidad;
    else, assert(estructura=="rigidez_dada" && rigidezDada>0,'Rigidez invalida.'); k=rigidezDada; end
    velocidadImpacto=sqrt(velocidadInicial^2+2*gravedad*altura);
    deltaEstatica=masa*gravedad/k;
    deltaMax=(masa*gravedad+sqrt((masa*gravedad)^2+k*masa*velocidadImpacto^2))/k;
    fuerzaMax=k*deltaMax; factorDinamico=deltaMax/deltaEstatica;
    if estructura=="axial", sigmaMax=fuerzaMax/F;
    elseif estructura=="voladizo", sigmaMax=fuerzaMax*L*c/I;
    else, sigmaMax=NaN; end
    residuoEnergia=.5*k*deltaMax^2-.5*masa*velocidadImpacto^2-masa*gravedad*deltaMax;
    resultado=struct('rigidez',k,'deltaMax',deltaMax,'fuerzaMax',fuerzaMax, ...
        'factorDinamico',factorDinamico,'sigmaMax',sigmaMax,'residuoEnergia',residuoEnergia);
    disp(resultado);
else
    assert(modo=="rotacion" && densidad>0 && radioInicio>=0 && omega>=0,'Datos de giro invalidos.');
    q0=densidad*F*omega^2*radioInicio; q1=densidad*F*omega^2*(radioInicio+L);
    datos=struct('x',[0 L],'E',E,'F',F,'distribuidas',[0 L q0 q1],'apoyos',[0 0]);
    resultado=rm_axial(datos);
    disp(resultado.extremos);
end

if modo=="impacto"
    [figura,ejes]=rm_figura(2,'Impacto: maximos energeticos');
    hh=linspace(0,max(.01,2*altura),101);
    dd=(masa*gravedad+sqrt((masa*gravedad)^2+k*masa*(velocidadInicial^2+2*gravedad*hh)))/k;
    plot(ejes(1),hh,dd*1000,'k-','LineWidth',1.5); xlabel(ejes(1),'Altura [m]'); ylabel(ejes(1),'\delta_{max} [mm]');
    uu=linspace(0,deltaMax,101); plot(ejes(2),uu*1000,k*uu/1000,'k-','LineWidth',1.5);
    xlabel(ejes(2),'\delta [mm]'); ylabel(ejes(2),'Fuerza elastica [kN]');
else
    t=resultado.tramos(1); xx=linspace(0,L,151);
    [figura,ejes]=rm_figura(3,'Barra radial en rotacion');
    rm_curva(ejes(1),xx,polyval(t.N,xx)/1000,'N [kN]');
    rm_curva(ejes(2),xx,polyval(t.sigma,xx)/1e6,'\sigma [MPa]');
    rm_curva(ejes(3),xx,polyval(t.delta,xx)*1000,'\delta [mm]'); xlabel(ejes(3),'x [m]');
end

if modo=="impacto" && estructura=="marco_3d"
    datosImpacto.cargas=[nodoImpacto fuerzaMax*direccionImpacto 0 0 0];
    marcoImpacto=rm_marco3d(datosImpacto);
    figuras=rm_graficar_marco3d(marcoImpacto,"locales",false);
end
estado=struct;
if exist('k','var'),estado.k=k;end
if exist('velocidadImpacto','var'),estado.velocidadImpacto=velocidadImpacto;end
if exist('marcoImpacto','var'),estado.marcoImpacto=marcoImpacto;end
end
