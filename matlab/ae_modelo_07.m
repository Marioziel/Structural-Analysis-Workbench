function [resultado,estado]=ae_modelo_07(entrada)
modo=entrada.modo;
nodos=entrada.nodos;
barras=entrada.barras;
E=entrada.E;
G=entrada.G;
F=entrada.F;
Iy=entrada.Iy;
Iz=entrada.Iz;
J=entrada.J;
cargas=entrada.cargas;
apoyos=entrada.apoyos;
qGlobal=entrada.qGlobal;
qLocal=entrada.qLocal;
referenciaY=entrada.referenciaY;
tipoBarra=entrada.tipoBarra;
liberaciones=entrada.liberaciones;
deformacionLibre=entrada.deformacionLibre;
curvaturaLibre=entrada.curvaturaLibre;
giroLibre=entrada.giroLibre;
consulta=entrada.consulta;
vistaEpiuras=entrada.vistaEpiuras;
mostrarCeros=entrada.mostrarCeros;
nodosPlano=entrada.nodosPlano;
barrasPlano=entrada.barrasPlano;
Iplano=entrada.Iplano;
cargasPlano=entrada.cargasPlano;
apoyosPlano=entrada.apoyosPlano;
qPlano=entrada.qPlano;
liberacionesPlano=entrada.liberacionesPlano;
consultaPlano=entrada.consultaPlano;
deformacionLibrePlano=entrada.deformacionLibrePlano;
curvaturaLibrePlano=entrada.curvaturaLibrePlano;
Dresorte=entrada.Dresorte;
dalambre=entrada.dalambre;
vueltas=entrada.vueltas;
Gresorte=entrada.Gresorte;
Eresorte=entrada.Eresorte;
fuerzaResorte=entrada.fuerzaResorte;
parResorte=entrada.parResorte;
if modo=="espacial"
    datos=struct('nodos',nodos,'barras',barras,'E',E,'G',G,'F',F,'Iy',Iy,'Iz',Iz,'J',J, ...
        'cargas',cargas,'apoyos',apoyos,'qGlobal',qGlobal,'qLocal',qLocal, ...
        'referenciaY',referenciaY,'tipo',tipoBarra,'liberaciones',liberaciones, ...
        'deformacionLibre',deformacionLibre,'curvaturaLibre',curvaturaLibre,'giroLibre',giroLibre);
    resultado=rm_mohr3d(datos,consulta);
    disp(table(resultado.deltaNodal,resultado.deltaMohr, ...
        'VariableNames',{'Respuesta_nodal','Integral_Mohr'}));
    disp('Desplazamientos [m] y giros [rad], columnas X Y Z giroX giroY giroZ:'); disp(resultado.u);
    disp('Reacciones [N] y momentos [N m], columnas FX FY FZ MX MY MZ:'); disp(resultado.R);
elseif modo=="plano"
    datos=struct('nodos',nodosPlano,'barras',barrasPlano,'E',E,'F',F,'I',Iplano, ...
        'cargas',cargasPlano,'apoyos',apoyosPlano,'q',qPlano,'liberaciones',liberacionesPlano, ...
        'deformacionLibre',deformacionLibrePlano,'curvaturaLibre',curvaturaLibrePlano);
    resultado=rm_mohr_plano(datos,consultaPlano);disp(resultado.u);disp(resultado.R);
    disp(table(resultado.deltaNodal,resultado.deltaMohr, ...
        'VariableNames',{'Respuesta_nodal','Integral_Mohr'}));
else
    assert(modo=="resorte" && all([Dresorte dalambre vueltas Gresorte Eresorte]>0),'Datos invalidos.');
    flexibilidad=8*Dresorte^3*vueltas/(Gresorte*dalambre^4);
    flexibilidadAngular=64*Dresorte*vueltas/(Eresorte*dalambre^4);
    deltaResorte=fuerzaResorte*flexibilidad; giroResorte=parResorte*flexibilidadAngular;
    resultado=struct('delta',deltaResorte,'giro',giroResorte);
    disp(resultado);
end

if modo=="espacial"
    figuras=rm_graficar_marco3d(resultado,vistaEpiuras,mostrarCeros);
elseif modo=="plano"
    [figura,ejes]=rm_figura(1,'Marco plano: numeracion'); hold(ejes(1),'on');
    for i=1:size(barrasPlano,1)
        xy=nodosPlano(barrasPlano(i,:),:);plot(ejes(1),xy(:,1),xy(:,2),'k-o');
        text(ejes(1),mean(xy(:,1)),mean(xy(:,2)),sprintf(' B%d',i));
    end
    axis(ejes(1),'equal');
    for i=1:numel(resultado.campos)
        a=resultado.campos{i};s=linspace(0,a.L,101);
        [figura,ejes]=rm_figura(3,sprintf('Barra plana %d',i));
        rm_curva(ejes(1),s,polyval(a.N,s)/1000,'N [kN]');
        rm_curva(ejes(2),s,polyval(a.V,s)/1000,'V [kN]');
        rm_curva(ejes(3),s,polyval(a.M,s)/1000,'M [kN m]');xlabel(ejes(3),'s [m]');
    end
else
    [figura,ejes]=rm_figura(2,'Resorte: respuesta lineal');
    pp=linspace(0,max(1,abs(fuerzaResorte)),101);
    rm_curva(ejes(1),pp,pp*flexibilidad*1000,'\delta [mm]',false);xlabel(ejes(1),'P [N]');
    mm=linspace(0,max(1,abs(parResorte)),101);
    rm_curva(ejes(2),mm,mm*flexibilidadAngular*180/pi,'\phi [grados]',false);xlabel(ejes(2),'M [N m]');
end
estado=struct;
if exist('flexibilidad','var'),estado.flexibilidad=flexibilidad;end
if exist('flexibilidadAngular','var'),estado.flexibilidadAngular=flexibilidadAngular;end
end
