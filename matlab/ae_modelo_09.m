function [resultado,estado]=ae_modelo_09(entrada)
modo=entrada.modo;
evaluacion=entrada.evaluacion;
nodos=entrada.nodos;
barras=entrada.barras;
E=entrada.E;
nu=entrada.nu;
G=entrada.G;
cargas=entrada.cargas;
apoyos=entrada.apoyos;
qGlobal=entrada.qGlobal;
qLocal=entrada.qLocal;
referenciaY=entrada.referenciaY;
liberaciones=entrada.liberaciones;
D=entrada.D;
di=entrada.di;
espesor=entrada.espesor;
limiteTraccion=entrada.limiteTraccion;
limiteCompresion=entrada.limiteCompresion;
teoria=entrada.teoria;
nRequerido=entrada.nRequerido;
considerarCortante=entrada.considerarCortante;
intervaloDiametro=entrada.intervaloDiametro;
puntosLongitud=entrada.puntosLongitud;
puntosAngulares=entrada.puntosAngulares;
vistaEpiuras=entrada.vistaEpiuras;
mostrarCeros=entrada.mostrarCeros;
N=entrada.N;
Qy=entrada.Qy;
Qz=entrada.Qz;
My=entrada.My;
Mz=entrada.Mz;
T=entrada.T;
config=struct('D',D,'di',di,'espesor',espesor,'nu',nu,'limiteTraccion',limiteTraccion, ...
    'limiteCompresion',limiteCompresion,'teoria',teoria,'nRequerido',nRequerido, ...
    'puntosLongitud',puntosLongitud,'considerarCortante',considerarCortante);
if modo=="estructura"
    datos=struct('nodos',nodos,'barras',barras,'E',E,'G',G,'cargas',cargas,'apoyos',apoyos, ...
        'qGlobal',qGlobal,'qLocal',qLocal,'referenciaY',referenciaY,'liberaciones',liberaciones);
    if evaluacion=="dimensionar"
        resultado=rm_dimensionar_marco3d(datos,config,intervaloDiametro);
    else
        assert(evaluacion=="comprobar",'Evaluacion no reconocida.');
        resultado=rm_resistencia_marco3d(datos,config);
    end
    disp(resultado.tabla);
    disp(table(resultado.factor,resultado.cumple,resultado.cortanteValidado, ...
        'VariableNames',{'Factor_global','Cumple','Cortante_validado'}));
    disp('Reacciones [FX FY FZ MX MY MZ]:');disp(resultado.marco.R);
    i=resultado.barraCritica;sCritica=resultado.sCritica;a=resultado.marco.campos{i};
    N=polyval(a.N,sCritica);Qy=polyval(a.Vy,sCritica);Qz=polyval(a.Vz,sCritica);
    T=polyval(a.T,sCritica);MyVector=polyval(a.My,sCritica);Mz=polyval(a.Mz,sCritica);
    Dcrit=resultado.D(i);dicrit=resultado.di(i);
else
    assert(modo=="seccion" && isscalar(D)&&isscalar(di),'En seccion usa diametros escalares.');
    Dcrit=D;dicrit=di;if ~isempty(espesor),dicrit=D-2*espesor;end
    MyVector=-My;sCritica=0;
    resultado=rm_circular_combinada(N,Qy,Qz,T,MyVector,Mz,Dcrit,dicrit,nu,limiteTraccion/limiteCompresion);
    valores=resultado.envolvente;
    if ~considerarCortante
        assert(resultado.tauQ<=.05*limiteTraccion,'El cortante supera el umbral del 5%%. Activa considerarCortante.');
        valores=resultado.nominal;
    end
    disp(table((1:5)',valores'/1e6,limiteTraccion./max(valores',realmin), ...
        'VariableNames',{'Teoria','Equivalente_MPa','Factor'}));
end

if modo=="estructura"
    figuras=rm_graficar_marco3d(resultado.marco,vistaEpiuras,mostrarCeros);
    [figura,ejes]=rm_figura(1,'Tension equivalente por barra: envolvente de comprobacion');hold(ejes(1),'on');
    for j=1:numel(resultado.campos)
        b=resultado.campos{j};plot(ejes(1),b.s,b.equivalentes(:,teoria)/1e6,'DisplayName',sprintf('Barra %d',j),'LineWidth',1.5);
    end
    yline(ejes(1),limiteTraccion/nRequerido/1e6,'r--','HandleVisibility','off');
    legend(ejes(1),'show','Location','best');xlabel(ejes(1),'s local [m]');ylabel(ejes(1),'Equivalente [MPa]');
end
Fcrit=pi*(Dcrit^2-dicrit^2)/4;Icrit=pi*(Dcrit^4-dicrit^4)/64;Jcrit=2*Icrit;
ang=linspace(0,2*pi,puntosAngulares+1)';y=Dcrit*cos(ang)/2;z=Dcrit*sin(ang)/2;
sigma=N/Fcrit+(MyVector*z-Mz*y)/Icrit;tauT=abs(T)*Dcrit/(2*Jcrit);
eqNominal=sqrt(sigma.^2+3*tauT^2);
[figura,ejes]=rm_figura(2,'Seccion critica: distribucion nominal N, M y T');
rm_curva(ejes(1),ang*180/pi,sigma/1e6,'\sigma_x [MPa]',false);
rm_curva(ejes(2),ang*180/pi,eqNominal/1e6,'\sigma_{VM}, sin Q [MPa]',false);xlabel(ejes(2),'Angulo local [grados]');
[figura,ejes]=rm_figura(1,'Contorno de la seccion critica: color = tension normal');
surface(ejes(1),[y';y'],[z';z'],zeros(2,numel(y)),[sigma';sigma']/1e6, ...
    'FaceColor','none','EdgeColor','interp','LineWidth',3);
view(ejes(1),2);axis(ejes(1),'equal');colorbar(ejes(1));xlabel(ejes(1),'y local [m]');ylabel(ejes(1),'z local [m]');
estado=struct;
if exist('N','var'),estado.N=N;end
if exist('Qy','var'),estado.Qy=Qy;end
if exist('Qz','var'),estado.Qz=Qz;end
if exist('T','var'),estado.T=T;end
if exist('MyVector','var'),estado.MyVector=MyVector;end
if exist('Mz','var'),estado.Mz=Mz;end
if exist('Dcrit','var'),estado.Dcrit=Dcrit;end
if exist('dicrit','var'),estado.dicrit=dicrit;end
if exist('Fcrit','var'),estado.Fcrit=Fcrit;end
if exist('Icrit','var'),estado.Icrit=Icrit;end
if exist('Jcrit','var'),estado.Jcrit=Jcrit;end
if exist('valores','var'),estado.valores=valores;end
end
