function [resultado,estado]=ae_modelo_13(entrada)
modo=entrada.modo;
E=entrada.E;
G=entrada.G;
sigmaFluencia=entrada.sigmaFluencia;
tauFluencia=entrada.tauFluencia;
niveles=entrada.niveles;
anchuras=entrada.anchuras;
curvaturaMax=entrada.curvaturaMax;
Lb=entrada.Lb;
Fb=entrada.Fb;
desplazamientoMax=entrada.desplazamientoMax;
R=entrada.R;
ri=entrada.ri;
longitudEje=entrada.longitudEje;
giroPorLongitudMax=entrada.giroPorLongitudMax;
pasos=entrada.pasos;
assert(all([E G sigmaFluencia tauFluencia]>0) && pasos>=3,'Material invalido.');
if modo=="axial"
    assert(numel(Lb)==numel(Fb) && all(Lb>0 & Fb>0) && desplazamientoMax>0,'Barras invalidas.');
    parametro=linspace(0,desplazamientoMax,pasos)';
    tensiones=max(-sigmaFluencia,min(E*parametro./Lb,sigmaFluencia));
    respuesta=tensiones*Fb(:); limite=sum(Fb)*sigmaFluencia;
    resultado=struct('parametro',parametro,'respuesta',respuesta,'limite',limite,'tensiones',tensiones);
elseif modo=="flexion"
    assert(all(diff(niveles)>0) && all(anchuras>=0) && curvaturaMax>0,'Seccion invalida.');
    y=linspace(min(niveles),max(niveles),2001)'; b=interp1(niveles,anchuras,y);
    area=trapz(y,b); assert(area>0,'Area nula.'); yc=trapz(y,y.*b)/area;
    inercia=trapz(y,(y-yc).^2.*b); acumulada=cumtrapz(y,b);
    [unicos,ix]=unique(acumulada); yplastico=interp1(unicos,y(ix),area/2);
    limite=sigmaFluencia*trapz(y,abs(y-yplastico).*b);
    parametro=linspace(0,curvaturaMax,pasos)'; respuesta=zeros(size(parametro));
    for j=2:pasos
        k=parametro(j);
        equilibrio=@(y0) trapz(y,max(-sigmaFluencia,min(-E*k*(y-y0),sigmaFluencia)).*b);
        y0=fzero(equilibrio,[min(y)-(max(niveles)-min(niveles)) max(y)+(max(niveles)-min(niveles))]);
        sigma=max(-sigmaFluencia,min(-E*k*(y-y0),sigmaFluencia));
        respuesta(j)=-trapz(y,sigma.*(y-yc).*b);
    end
    resultado=struct('parametro',parametro,'respuesta',respuesta,'limite',limite, ...
        'sigma',sigma,'y',y,'inercia',inercia,'centro',yc);
else
    assert(modo=="torsion" && R>ri && ri>=0 && longitudEje>0 && giroPorLongitudMax>0,'Eje invalido.');
    rho=linspace(ri,R,2001)'; parametro=linspace(0,giroPorLongitudMax,pasos)';
    respuesta=zeros(size(parametro));
    for j=1:pasos
        tau=min(G*parametro(j)*rho,tauFluencia);
        respuesta(j)=2*pi*trapz(rho,tau.*rho.^2);
    end
    limite=2*pi*tauFluencia*(R^3-ri^3)/3;
    resultado=struct('parametro',parametro,'respuesta',respuesta,'limite',limite,'tau',tau,'rho',rho);
end
disp("Carga o momento limite: "+limite);
disp("Respuesta al ultimo incremento: "+respuesta(end));

[figura,ejes]=rm_figura(2,'Evolucion elastoplastica monotona');
plot(ejes(1),parametro,respuesta/1000,'k-','LineWidth',1.5);
yline(ejes(1),limite/1000,'--'); xlabel(ejes(1),'Desplazamiento, curvatura o giro/longitud');
ylabel(ejes(1),'Fuerza [kN] o momento [kN m]');
if modo=="flexion"
    plot(ejes(2),sigma/1e6,y,'k-','LineWidth',1.5); xlabel(ejes(2),'\sigma [MPa]'); ylabel(ejes(2),'y [m]');
elseif modo=="torsion"
    plot(ejes(2),rho,tau/1e6,'k-','LineWidth',1.5); xlabel(ejes(2),'Radio [m]'); ylabel(ejes(2),'\tau [MPa]');
else
    plot(ejes(2),parametro*1000,tensiones/1e6,'LineWidth',1.2); xlabel(ejes(2),'\delta [mm]'); ylabel(ejes(2),'\sigma [MPa]');
end
estado=struct;
if exist('area','var'),estado.area=area;end
if exist('inercia','var'),estado.inercia=inercia;end
if exist('yc','var'),estado.yc=yc;end
if exist('yplastico','var'),estado.yplastico=yplastico;end
if exist('limite','var'),estado.limite=limite;end
end
