function [resultado,estado]=ae_modelo_16(entrada)
modo=entrada.modo;
posiciones=entrada.posiciones;
longitudes=entrada.longitudes;
areas=entrada.areas;
E=entrada.E;
errores=entrada.errores;
P=entrada.P;
xCarga=entrada.xCarga;
longitudUnion=entrada.longitudUnion;
ancho=entrada.ancho;
espesor=entrada.espesor;
moduloBanda=entrada.moduloBanda;
rigidezAdhesivo=entrada.rigidezAdhesivo;
fuerzaUnion=entrada.fuerzaUnion;
if modo=="compatibilidad"
    resultado=rm_tirantes_rigidos(posiciones,longitudes,areas,E,errores,P,xCarga);
    N=resultado.N;sigma=resultado.sigma;delta=resultado.delta;residuo=resultado.residuo;
    x=resultado.XY(:,1);
    disp(table((1:numel(N))',delta*1000,N/1000,sigma/1e6, ...
        'VariableNames',{'Varilla','delta_mm','N_kN','sigma_MPa'}));
    disp('Residuos de fuerza y primeros momentos:');disp(residuo);
else
    assert(modo=="adhesivo" && all([longitudUnion ancho espesor moduloBanda rigidezAdhesivo]>0),'Union invalida.');
    beta=sqrt(rigidezAdhesivo/(moduloBanda*espesor));
    x=linspace(0,longitudUnion,1001)'; den=-expm1(-2*beta*longitudUnion);
    e1=exp(beta*(x-longitudUnion)); e2=exp(-beta*(x+longitudUnion));
    N=fuerzaUnion*(e1-e2)/den;
    tau=fuerzaUnion*beta/ancho*(e1+e2)/den;
    delta=tau/rigidezAdhesivo;
    residuoTransferencia=trapz(x,tau*ancho)-fuerzaUnion;
    resultado=struct('beta',beta,'N',N,'tau',tau,'u',delta,'residuoTransferencia',residuoTransferencia);
    disp("Cortante maximo del adhesivo [MPa]: "+max(abs(tau))/1e6);
    disp("Residuo de transferencia integrado [N]: "+residuoTransferencia);
end

[figura,ejes]=rm_figura(3,'Compatibilidad y transferencia de carga');
if modo=="compatibilidad"
    plot(ejes(1),1:numel(delta),delta*1000,'k-o'); xlabel(ejes(1),'Varilla'); ylabel(ejes(1),'\delta [mm]');
    bar(ejes(2),N/1000); ylabel(ejes(2),'N [kN]'); xlabel(ejes(2),'Tirante');
    bar(ejes(3),sigma/1e6); ylabel(ejes(3),'\sigma [MPa]'); xlabel(ejes(3),'Tirante');
else
    rm_curva(ejes(1),x,N/1000,'N en la banda [kN]');
    rm_curva(ejes(2),x,tau/1e6,'\tau del adhesivo [MPa]');
    rm_curva(ejes(3),x,delta*1000,'u relativo [mm]'); xlabel(ejes(3),'x [m]');
end

if modo=="compatibilidad" && size(posiciones,2)==2 && size(posiciones,1)>1
    [figura,ejes]=rm_figura(1,'Plataforma 3D: posiciones de varillas y desplazamientos amplificados');hold(ejes(1),'on');
    xy=resultado.XY;escala=.2*max(longitudes)/max(max(abs(delta)),realmin);
    contorno=convhull(xy(:,1),xy(:,2));
    fill3(ejes(1),xy(contorno,1),xy(contorno,2),zeros(size(contorno)),[.85 .85 .85],'FaceAlpha',.4);
    plot3(ejes(1),xy(contorno,1),xy(contorno,2),-delta(contorno)*escala,'r-');
    for j=1:numel(N)
        plot3(ejes(1),[xy(j,1) xy(j,1)],[xy(j,2) xy(j,2)],[0 longitudes(j)],'k-');
        text(ejes(1),xy(j,1),xy(j,2),longitudes(j),sprintf(' %d: %.3g kN',j,N(j)/1000));
    end
    axis(ejes(1),'equal');view(ejes(1),35,24);grid(ejes(1),'on');
    xlabel(ejes(1),'X [m]');ylabel(ejes(1),'Y [m]');zlabel(ejes(1),'Z [m]');
end
estado=struct;
end
