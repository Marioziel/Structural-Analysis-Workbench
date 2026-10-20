function informe=COMPROBAR_LECCIONES
addpath(fileparts(mfilename('fullpath')));v=get(groot,'defaultFigureVisible');set(groot,'defaultFigureVisible','off');
limpieza=onCleanup(@() set(groot,'defaultFigureVisible',v));
informe=struct('prueba',{},'ok',{},'mensaje',{});
prueba('Seccion rectangular: tension y masa analiticas',@rectangulo);
prueba('Seccion asimetrica: invariancia al girar los ejes',@rotacion);
prueba('Celda cerrada: Bredt, J y giro',@celda);
prueba('Celda cerrada: escalado de carga y rigidez',@escaladoCelda);
prueba('Seccion general: cortante transversal pendiente',@parcialSeccion);
prueba('Uniones: perno y laminas con agujero distinto',@pasador);
prueba('Uniones: numero de planos y escalado',@planos);
prueba('Soldadura a tope: traccion y flexion',@tope);
prueba('Soldadura de filetes: area efectiva',@filete);
prueba('Adhesivo: tension media y longitud',@adhesivo);
prueba('Placa: valores criticos independientes',@placa);
prueba('Placa: correccion de cortante acota ambos limites',@correccion);
prueba('Placa: interaccion pendiente y fallo separado',@interaccion);
prueba('Masa: gravedad y traslado de fuerzas',@masa);
prueba('Masa: aceleracion de base y signos',@aceleracion);
prueba('Casos: cargas mecanicas y temperatura independientes',@casos);
prueba('Casos: fuerzas y momentos conservan coordenadas',@factor);
prueba('Guia: seccion general, union y placa',@guia);
prueba('Entradas incompatibles y mecanismo no disponible',@rechazos);
prueba('Memorias matematicas de los modos nuevos',@memorias);
if nargout==0,disp(struct2table(informe));assert(all([informe.ok]),'AE:Pruebas','Hay pruebas fallidas.');end
    function prueba(nombre,fn)
        try,lastwarn('');fn();drawnow;[msg,id]=lastwarn;
            assert(~contains(id,'SceneNode')&&~contains(msg,'interpreter syntax'),'AE:Render','Error grafico: %s',msg);
            informe(end+1)=struct('prueba',string(nombre),'ok',true,'mensaje',"");
        catch ex,informe(end+1)=struct('prueba',string(nombre),'ok',false,'mensaje',string(getReport(ex,'extended','hyperlinks','off')));end
        fprintf('LECCION %s: %d\n',nombre,informe(end).ok);close all force;
    end
    function d=datosRect
        d=ae_datos('seccion_general');d.contornos={[-.05 -.10;.05 -.10;.05 .10;-.05 .10]};
        d.N=10000;d.My=100;d.Mz=200;d.longitud=2;d.densidad=7800;
    end
    function rectangulo
        d=datosRect;r=ae_seccion_general(d);A=.1*.2;Iy=.1*.2^3/12;Iz=.2*.1^3/12;
        cerca(r.F,A);cerca(r.sigmaMax,10000/A+100*.1/Iy+200*.05/Iz);
        cerca(r.sigmaMin,10000/A-100*.1/Iy-200*.05/Iz);cerca(r.masa,7800*A*2);
    end
    function rotacion
        d=ae_datos('seccion_general');a=ae_seccion_general(d);R=[0 -1;1 0];
        d.contornos=cellfun(@(p) p*R',d.contornos,'UniformOutput',false);m=R*[d.My;d.Mz];d.My=m(1);d.Mz=m(2);
        b=ae_seccion_general(d);cerca([a.sigmaMin a.sigmaMax a.masa],[b.sigmaMin b.sigmaMax b.masa]);
    end
    function d=datosCelda
        d=ae_datos('seccion_general');d.geometria="pared_delgada";d.torsion="celda_unica";
        d.segmentos=[0 0 .1 0 .002;.1 0 .1 .06 .002;.1 .06 0 .06 .002;0 .06 0 0 .002];
        d.N=0;d.My=0;d.Mz=0;d.T=100;d.G=80e9;d.longitud=2;
    end
    function celda
        d=datosCelda;r=ae_seccion_general(d);Am=.006;J=4*Am^2/(.32/.002);
        cerca(r.J,J);cerca(r.flujoTorsion,100/(2*Am));cerca(max(r.tau),100/(2*Am*.002));
        cerca(r.giro,100*2/(80e9*J));assert(r.completa);
    end
    function escaladoCelda
        d=datosCelda;a=ae_seccion_general(d);d.T=200;b=ae_seccion_general(d);
        cerca(b.giro,2*a.giro);cerca(b.factor,a.factor/2);d.G=160e9;c=ae_seccion_general(d);cerca(c.giro,b.giro/2);
    end
    function parcialSeccion
        d=datosRect;d.Qy=100;r=ae_seccion_general(d);assert(~r.cumple&&~r.completa&&r.estado=="Parcial");
        d.Qy=0;d.T=10;r=ae_seccion_general(d);assert(~r.completa);
    end
    function pasador
        d=ae_datos('uniones');r=ae_union(d);
        cerca(r.tauPerno,9000/(2*pi*.012^2/4));cerca(r.sigmaPerno,2000/84.3e-6);
        cerca(r.sigmaNeta(1),9000/(.006*(.04-.013)));cerca(r.sigmaAplastamiento(1),9000/(.006*.012));
        cerca(r.tauDesgarro(1),9000/(2*.006*(.02-.013/2)));
    end
    function planos
        d=ae_datos('uniones');a=ae_union(d);d.planosCorte=1;b=ae_union(d);cerca(b.tauPerno,2*a.tauPerno);
        d=ae_factor_mecanico('uniones',ae_datos('uniones'),2);c=ae_union(d);cerca(c.demanda,2*a.demanda);cerca(c.factor,a.factor/2);
    end
    function tope
        d=ae_datos('uniones');d.tipo="soldadura_tope";d.momentoSoldadura=8;r=ae_union(d);
        cerca(max(abs(r.sigmaExtremos)),9000/(.08*.006)+8/(.08*.006^2/6));
    end
    function filete
        d=ae_datos('uniones');d.tipo="soldadura_filete";r=ae_union(d);cerca(r.tau,9000/(2*.05*.0028));
    end
    function adhesivo
        d=ae_datos('uniones');d.tipo="adhesivo_simple";a=ae_union(d);cerca(a.tau,1000/(.04*.06));
        d.solapeAdhesivo=2*d.solapeAdhesivo;b=ae_union(d);cerca(b.factor,2*a.factor);
    end
    function placa
        d=ae_datos('placa_local');r=ae_placa_local(d);cerca(r.sigmaCritica,134.4e6);cerca(r.tauCriticaElastica,220.08e6);
        assert(r.completa&&r.cumple);
    end
    function correccion
        d=ae_datos('placa_local');d.corregirCortante=true;r=ae_placa_local(d);
        assert(r.tauCriticaUsada<min(r.tauCriticaElastica,d.tauUltima));
    end
    function interaccion
        d=ae_datos('placa_local');d.tau=10e6;r=ae_placa_local(d);assert(r.estado=="Parcial"&&~r.cumple);
        d.tau=300e6;r=ae_placa_local(d);assert(r.estado=="No cumple");
    end
    function masa
        c=ae_carga_masa(50,[.2 0 .3],[0 0 0],[0 0 0],[0 0 -9.81]);cerca(c,[0 0 -490.5 0 98.1 0]);
    end
    function aceleracion
        c=ae_carga_masa(50,[.2 0 .3],[0 0 0],[1 2 3],[0 0 -9.81]);cerca(c,[-50 -100 -640.5 30 113.1 -20]);
    end
    function casos
        d=ae_datos('axial');d.x=[0 2];d.F=400e-6;d.E=200e9;d.puntuales=[2 10000];d.deltaT=30;
        c(1)=struct('nombre',"A",'factorMecanico',1,'cambios',struct);
        c(2)=struct('nombre',"B",'factorMecanico',2,'cambios',struct);
        e=ae_casos('axial',d,c,.001);cerca(e.tabla.MaxDesplazamiento_m,[.00097;.00122]);
        assert(e.casoMaxDesplazamiento==2&&e.casoMinFactor==2&&e.tabla.Estado(2)=="No cumple desplazamiento");
        cerca(e.soluciones{2}.entrada.deltaT,30);cerca(e.soluciones{2}.entrada.puntuales(1),2);
    end
    function factor
        d=ae_datos('sistema_barras');f=ae_factor_mecanico('sistema_barras',d,3);
        cerca(f.cargas(:,1),d.cargas(:,1));cerca(f.cargas(:,2:end),3*d.cargas(:,2:end));
        cerca(f.apoyos,d.apoyos);cerca(f.E,d.E);cerca(f.qGlobal,3*d.qGlobal);
    end
    function guia
        a=ae_orientar(struct('objeto',"seccion",'accion',"combinada",'interes',"resistencia"));assert(a=="seccion_general");
        a=ae_orientar(struct('objeto',"union",'accion',"axial",'interes',"resistencia"));assert(a=="uniones");
        a=ae_orientar(struct('objeto',"placa",'accion',"compresion",'interes',"estabilidad"));assert(a=="placa_local");
    end
    function rechazos
        d=datosCelda;d.segmentos(end,3)=.01;rechazar(@()ae_seccion_general(d));
        d=ae_datos('uniones');d.diametroAgujero=.01;rechazar(@()ae_union(d));
        d.tipo="soldadura_filete";d.momentoSoldadura=1;rechazar(@()ae_union(d));
        d=ae_datos('placa_local');d.a=.1;rechazar(@()ae_placa_local(d));
        rechazar(@()ae_factor_mecanico('tensor',ae_datos('tensor'),2));
    end
    function memorias
        for a=["seccion_general","uniones","placa_local"]
            s=ae_resolver(a,ae_datos(a));m=ae_memoria(s,struct('elementos',1));assert(numel(m.paginas)>=2);close all force;
        end
        for tipo=["soldadura_tope","soldadura_filete","adhesivo_simple"]
            d=ae_datos('uniones');d.tipo=tipo;s=ae_resolver('uniones',d);m=ae_memoria(s);assert(numel(m.paginas)==2);close all force;
        end
        d=datosCelda;s=ae_resolver('seccion_general',d);m=ae_memoria(s);assert(numel(m.paginas)==4);
    end
end
function cerca(a,b)
assert(isequal(size(a),size(b))&&all(isnan(a(:))==isnan(b(:))),'AE:Pruebas','Dimensiones o valores no numericos incompatibles.');
q=~isnan(a);a=a(q);b=b(q);assert(norm(a(:)-b(:),inf)<=1e-8*max([norm(b(:),inf),1e-12]),'AE:Pruebas','Diferencia respecto al control.');
end
function rechazar(fn)
ok=false;try,fn();catch ex,ok=startsWith(ex.identifier,'AE:');end
assert(ok,'AE:Pruebas','El dato incompatible no fue rechazado.');
end
