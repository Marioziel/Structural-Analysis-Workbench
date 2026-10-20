function [resultado,estado]=ae_modelo_15(entrada)
modo=entrada.modo;
radios=entrada.radios;
anchuras=entrada.anchuras;
E=entrada.E;
nu=entrada.nu;
anguloArco=entrada.anguloArco;
fuerza=entrada.fuerza;
direccionConsulta=entrada.direccionConsulta;
Nseccion=entrada.Nseccion;
Mseccion=entrada.Mseccion;
origenArco=entrada.origenArco;
direccionXArco=entrada.direccionXArco;
normalPlanoArco=entrada.normalPlanoArco;
incluirCortante=entrada.incluirCortante;
factorCortante=entrada.factorCortante;
assert(all(radios>0) && all(diff(radios)>0) && all(anchuras>=0) && E>0 && nu>-1 && nu<.5,'Seccion invalida.');
b=@(r) interp1(radios,anchuras,r,'linear');
F=integral(b,min(radios),max(radios),'Waypoints',radios(2:end-1));
assert(F>0,'Area nula.');
R=integral(@(r) r.*b(r),min(radios),max(radios),'Waypoints',radios(2:end-1))/F;
rn=F/integral(@(r) b(r)./r,min(radios),max(radios),'Waypoints',radios(2:end-1));
e=R-rn; assert(e>0,'Curvatura no resoluble con estos datos.');
rr=linspace(min(radios),max(radios),1001)';
if modo=="seccion"
    N=Nseccion; M=Mseccion;
    sigma=N/F+M/(F*e)*(1-rn./rr);
    resultado=struct('F',F,'R',R,'rn',rn,'e',e,'sigma',sigma);
else
    assert(modo=="arco" && anguloArco>0 && anguloArco<=pi && norm(direccionConsulta)>0 ...
        && numel(fuerza)==2 && numel(direccionConsulta)==2,'Usa fuerza y consulta con dos componentes en el plano local.');
    th=linspace(0,anguloArco,1001)'; ss=R*th;
    xx=R*sin(th); yy=R*(1-cos(th));
    N=fuerza(1)*cos(th)+fuerza(2)*sin(th);
    Q=fuerza(1)*sin(th)-fuerza(2)*cos(th);
    M=(xx(end)-xx)*fuerza(2)-(yy(end)-yy)*fuerza(1);
    unit=direccionConsulta/norm(direccionConsulta);
    n=unit(1)*cos(th)+unit(2)*sin(th); q=unit(1)*sin(th)-unit(2)*cos(th);
    m=(xx(end)-xx)*unit(2)-(yy(end)-yy)*unit(1);
    integrando=M.*m/(E*F*e*R)+N.*n/(E*F)+(M.*n+N.*m)/(E*F*R);
    energia=M.^2/(2*E*F*e*R)+N.^2/(2*E*F)+M.*N/(E*F*R);
    if incluirCortante
        G=E/(2*(1+nu)); integrando=integrando+factorCortante*Q.*q/(G*F);
        energia=energia+factorCortante*Q.^2/(2*G*F);
    end
    desplazamiento=trapz(ss,integrando); U=trapz(ss,energia);
    sigmaInterior=N/F+M/(F*e)*(1-rn/min(radios));
    sigmaExterior=N/F+M/(F*e)*(1-rn/max(radios));
    [~,critico]=max(max(abs([sigmaInterior sigmaExterior]),[],2));
    sigma=N(critico)/F+M(critico)/(F*e)*(1-rn./rr);
    resultado=struct('F',F,'R',R,'rn',rn,'e',e,'delta',desplazamiento,'energia',U, ...
        'sigmaInterior',sigmaInterior,'sigmaExterior',sigmaExterior);
    disp("Desplazamiento en la direccion indicada [mm]: "+1000*desplazamiento);
end
disp(table(F,R,rn,e));

[figura,ejes]=rm_figura(2,'Barra curva: seccion y tensiones');
plot(ejes(1),sigma/1e6,rr,'k-','LineWidth',1.5); xlabel(ejes(1),'\sigma [MPa]'); ylabel(ejes(1),'r [m]');
if modo=="arco"
    plot(ejes(2),ss,sigmaInterior/1e6,'k-',ss,sigmaExterior/1e6,'--','LineWidth',1.2);
    legend(ejes(2),{'Interior','Exterior'},'Location','best'); xlabel(ejes(2),'s [m]'); ylabel(ejes(2),'\sigma [MPa]');
else
    rm_curva(ejes(2),rr,1-rn./rr,'Factor 1-r_n/r',false); xlabel(ejes(2),'r [m]');
end
if modo=="arco"
    [figura,ejes]=rm_figura(3,'Arco: epiuras a lo largo de la directriz');
    rm_curva(ejes(1),ss,N/1000,'N [kN]');
    rm_curva(ejes(2),ss,Q/1000,'Q [kN]');
    rm_curva(ejes(3),ss,M/1000,'M [kN m]'); xlabel(ejes(3),'s [m]');
end

if modo=="arco"
    ex=direccionXArco/norm(direccionXArco);normal=normalPlanoArco/norm(normalPlanoArco);
    assert(abs(dot(ex,normal))<1e-8,'La direccion X debe ser perpendicular a la normal del plano.');
    ey=cross(normal,ex);
    puntos=origenArco+xx*ex+yy*ey;
    [figura,ejes]=rm_figura(1,'Arco orientado en el espacio: color = tension interior [MPa]');
    surface(ejes(1),[puntos(:,1)';puntos(:,1)'],[puntos(:,2)';puntos(:,2)'], ...
        [puntos(:,3)';puntos(:,3)'],[sigmaInterior';sigmaInterior']/1e6, ...
        'FaceColor','none','EdgeColor','interp','LineWidth',3);
    view(ejes(1),35,24);axis(ejes(1),'equal');grid(ejes(1),'on');colorbar(ejes(1));
    xlabel(ejes(1),'X [m]');ylabel(ejes(1),'Y [m]');zlabel(ejes(1),'Z [m]');
end
estado=struct;
if exist('N','var'),estado.N=N;end
if exist('M','var'),estado.M=M;end
if exist('Q','var'),estado.Q=Q;end
if exist('ss','var'),estado.ss=ss;end
if exist('critico','var'),estado.critico=critico;end
if exist('U','var'),estado.U=U;end
end
