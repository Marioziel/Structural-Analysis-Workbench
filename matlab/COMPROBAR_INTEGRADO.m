function informe=COMPROBAR_INTEGRADO
% Pruebas del integrador, independientes de los documentos docentes.
carpeta=fileparts(mfilename('fullpath'));addpath(carpeta);
anterior=get(groot,'defaultFigureVisible');set(groot,'defaultFigureVisible','off');
limpieza=onCleanup(@() set(groot,'defaultFigureVisible',anterior));
informe=struct('prueba',{},'ok',{},'mensaje',{},'paginas',{});
t=ae_catalogo;
for j=1:height(t)
    probar("Familia: "+t.Clave(j),t.Clave(j),ae_datos(t.Clave(j)));
end
variantes={"seccion","modo","pared_delgada"; ...
    "torsion","tipoSeccion","abierta_delgada";"torsion","tipoSeccion","cerrada_delgada"; ...
    "torsion","tipoSeccion","constantes"; ...
    "sistema_barras","modo","plano";"sistema_barras","modo","resorte"; ...
    "tensor","tipo","deformaciones"; ...
    "resistencia_combinada","modo","seccion"; ...
    "resistencia_combinada","evaluacion","dimensionar"; ...
    "lamina","tipo","esfera";"lamina","tipo","cono"; ...
    "dinamica","modo","rotacion";"dinamica","estructura","voladizo"; ...
    "dinamica","estructura","rigidez_dada";"dinamica","estructura","marco_3d"; ...
    "plasticidad","modo","axial";"plasticidad","modo","torsion"; ...
    "barra_curva","modo","seccion";"compatibilidad","modo","adhesivo"};
for j=1:size(variantes,1)
    a=variantes{j,1};d=ae_datos(a);d.(variantes{j,2})=variantes{j,3};
    if a=="tensor",d.matriz=d.matriz/1e11;end
    probar(a+": "+variantes{j,3},a,d);
end
try
    d=ae_datos('axial');d.x=[0 2];d.F=400e-6;d.E=200e9;
    d.puntuales=[2 10000];s=ae_resolver('axial',d);r=s.resultado;
    cerca(r.u(end),10000*2/(200e9*400e-6));
    cerca(polyval(r.tramos(1).sigma,1),10000/400e-6);cerca(r.R(1),-10000);
    registrar('Barra simple: solucion analitica, sigma y reaccion',true,'',0);
    d.puntuales=[2 20000];s2=ae_resolver('axial',d);cerca(s2.resultado.u,2*r.u);
    m=ae_memoria(s,struct('elementos',1));m2=ae_memoria(s2,struct('elementos',1));
    assert(~isequal(m.paginas(2).ecuaciones,m2.paginas(2).ecuaciones));
    registrar('Cambiar datos actualiza resultados y ecuaciones',true,'',0);
    d.puntuales=[];d.deltaT=30;d.alpha=12e-6;s=ae_resolver('axial',d);
    cerca(s.resultado.u(end),12e-6*30*2);cerca(s.resultado.R,zeros(2,1));
    registrar('Dilatacion libre: desplazamiento sin esfuerzo',true,'',0);
    d.apoyos=[0 0;2 0];s=ae_resolver('axial',d);
    cerca(polyval(s.resultado.tramos(1).sigma,1),-200e9*12e-6*30);
    registrar('Dilatacion impedida: tension termica',true,'',0);
catch ex,registrar('Controles analiticos axiales',false,getReport(ex,'extended','hyperlinks','off'),0);end
close all force;
try
    d=ae_datos('sistema_barras');d.nodos=[0 0 0;2 0 0];d.barras=[1 2];
    d.cargas=[2 0 0 -1000 0 0 0];d.apoyos=[1 0 0 0 0 0 0];
    d.qGlobal=zeros(1,6);d.qLocal=zeros(1,8);d.referenciaY=[0 1 0];
    d.consulta=[2 3];d.vistaEpiuras="locales";
    s=ae_resolver('sistema_barras',d);cerca(s.resultado.u(2,3),-1000*2^3/(3*d.E*d.Iy));
    cerca(s.resultado.deltaNodal,s.resultado.deltaMohr);
    ae_memoria(s,struct('elementos',1));
    registrar('Voladizo 3D: flecha analitica y trabajo virtual',true,'',0);
catch ex,registrar('Voladizo 3D',false,getReport(ex,'extended','hyperlinks','off'),0);end
close all force;
try
    d=ae_datos('tensor');d.matriz=40e6*eye(3);s=ae_resolver('tensor',d);
    cerca(s.resultado.VM,0);cerca(s.resultado.Tresca,0);
    registrar('Estado hidrostatico: von Mises y Tresca nulos',true,'',0);
catch ex,registrar('Tensor hidrostatico',false,getReport(ex,'extended','hyperlinks','off'),0);end
close all force;
guias={"barra_recta","axial","deformaciones","axial"; ...
    "barras_articuladas","combinada","esfuerzos","cercha"; ...
    "seccion","geometria","propiedades","seccion"; ...
    "barra_recta","torsion","deformaciones","torsion"; ...
    "barra_recta","flexion","deformaciones","viga"; ...
    "seccion","flexion","resistencia","seccion_general"; ...
    "marco","combinada","deformaciones","sistema_barras"; ...
    "punto","combinada","resistencia","tensor"; ...
    "marco","combinada","resistencia","resistencia_combinada"; ...
    "superficie_revolucion","presion","resistencia","lamina"; ...
    "barra_recta","compresion","estabilidad","estabilidad"; ...
    "marco","impacto","esfuerzos","dinamica"; ...
    "seccion","plastificacion","resistencia","plasticidad"; ...
    "punto","ciclos","resistencia","fatiga"; ...
    "barra_curva","combinada","deformaciones","barra_curva"; ...
    "union_adhesiva","axial","esfuerzos","compatibilidad"};
for j=1:size(guias,1)
    try
        g=struct('objeto',guias{j,1},'accion',guias{j,2},'interes',guias{j,3});
        [a,~,aj]=ae_orientar(g);assert(a==guias{j,4});
        if g.objeto=="union_adhesiva",assert(aj.modo=="adhesivo");end
        if g.objeto=="marco"&&g.accion=="impacto",assert(aj.estructura=="marco_3d");end
        registrar('Guia: '+string(j),true,'',0);
    catch ex,registrar('Guia: '+string(j),false,ex.message,0);end
end
try
    rechazado=false;d=ae_datos('axial');d.area=1;
    try,ae_resolver('axial',d);catch ex,rechazado=strcmp(ex.identifier,'AE:Datos');end
    assert(rechazado);registrar('Rechazo de campo desconocido',true,'',0);
    rechazado=false;d=rmfield(ae_datos('axial'),'E');
    try,ae_resolver('axial',d);catch ex,rechazado=strcmp(ex.identifier,'AE:Datos');end
    assert(rechazado);registrar('Rechazo de campo requerido ausente',true,'',0);
    rechazado=false;
    try,ae_orientar(struct('objeto',"marco",'accion',"compresion",'interes',"estabilidad"));
    catch ex,rechazado=strcmp(ex.identifier,'AE:Guia');end
    assert(rechazado);registrar('Guia rechaza pandeo general de marcos no implementado',true,'',0);
catch ex,registrar('Control de entradas invalidas',false,ex.message,0);end
if nargout==0
    disp(struct2table(informe));
    assert(all([informe.ok]),'AE:Pruebas','Hay pruebas fallidas.');
end
    function probar(nombre,a,d)
        try
            lastwarn('');
            s=ae_resolver(a,d);m=ae_memoria(s,struct('elementos',1,'maxFilasMatriz',3));
            drawnow;assert(~isempty(m.paginas));
            [aviso,identificador]=lastwarn;
            assert(~contains(identificador,'SceneNode')&&~contains(aviso,'interpreter syntax'), ...
                'AE:Render','Una ecuacion no pudo renderizarse: %s',aviso);
            registrar(nombre,true,'',numel(m.paginas));
        catch ex,registrar(nombre,false,getReport(ex,'extended','hyperlinks','off'),0);end
        close all force;
    end
    function registrar(nombre,ok,msg,np)
        informe(end+1)=struct('prueba',string(nombre),'ok',ok,'mensaje',string(msg),'paginas',np);
        fprintf('CONTROL %s: %d\n',nombre,ok);
    end
end
function cerca(a,b)
assert(norm(a(:)-b(:),inf)<=1e-8*max([norm(b(:),inf),1e-12]),'AE:Pruebas','Diferencia analitica fuera de tolerancia.');
end
