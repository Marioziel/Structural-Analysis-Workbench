function informe=COMPROBAR_SOLIDO_INTEGRADO
addpath(fileparts(mfilename('fullpath')));
assert(exist('createpde','file')==2&&license('test','PDE_Toolbox'),'AE:Pruebas','Estas pruebas requieren PDE Toolbox.');
v=get(groot,'defaultFigureVisible');set(groot,'defaultFigureVisible','off');limpieza=onCleanup(@()set(groot,'defaultFigureVisible',v));
informe=struct('prueba',{},'ok',{},'mensaje',{});
prueba('Solido 3D: campo uniaxial, Poisson y convergencia',@patch);
prueba('Solido 3D: reaccion del ensayo uniaxial',@reaccion);
prueba('Solido 3D: sin estudio de malla se marca parcial',@sinMalla);
prueba('STL: importacion, escala y previsualizacion',@stl);
prueba('STEP: geometria del ejemplo local de MATLAB',@step);
prueba('Solido 3D: escalado mecanico preserva material y apoyos',@escalado);
prueba('Solido 3D: datos incompatibles se rechazan',@rechazos);
prueba('Solido 3D: memoria y seleccion guiada',@memoria);
prueba('Solido 3D: material sin limite no declara resistencia',@sinLimite);
if nargout==0,disp(struct2table(informe));assert(all([informe.ok]),'AE:Pruebas','Hay pruebas fallidas.');end
    function prueba(nombre,fn)
        try,lastwarn('');fn();drawnow;[msg,id]=lastwarn;
            assert(~contains(id,'SceneNode')&&~contains(msg,'interpreter syntax'),'AE:Render','Error en ecuaciones: %s',msg);
            informe(end+1)=struct('prueba',string(nombre),'ok',true,'mensaje',"");
        catch ex,informe(end+1)=struct('prueba',string(nombre),'ok',false,'mensaje',string(getReport(ex,'extended','hyperlinks','off')));end
        fprintf('SOLIDO %s: %d\n',nombre,informe(end).ok);close all force;
    end
    function d=datosPatch
        d=ae_datos('solido3d');d.E=200e9;d.nu=.3;d.refinarMalla=true;
        g=multicuboid(d.dimensiones(1),d.dimensiones(2),d.dimensiones(3));
        fx=nearestFace(g,[-.1 0 .025]);fy=nearestFace(g,[0 -.04 .025]);fz=nearestFace(g,[0 0 0]);
        cargada=nearestFace(g,[.1 0 .025]);
        d.apoyosComponente=[fx 0 NaN NaN;fy NaN 0 NaN;fz NaN NaN 0];
        d.traccionesCara=[cargada 1e6 0 0];
    end
    function patch
        d=datosPatch;r=ae_solido3d(d);x=r.modelo.Mesh.Nodes';eps=1e6/d.E;
        esperado=[eps*(x(:,1)+.1),-d.nu*eps*(x(:,2)+.04),-d.nu*eps*x(:,3)];
        cerca(r.u,esperado,1e-6);cerca(r.maxVM,1e6,1e-6);assert(r.completa&&r.cumple);
    end
    function reaccion
        r=ae_solido3d(datosPatch);cerca(r.reaccion,[-4000 0 0],1e-6);
        assert(r.equilibrio.errorRelativoFuerzas<1e-8&&norm(r.equilibrio.residuoMomentos)<1e-6);
    end
    function sinMalla
        d=ae_datos('solido3d');d.Hmin=.02;d.Hgrad=1.5;s=ae_resolver('solido3d',d);r=s.resultado;
        assert(~r.completa&&~r.cumple&&startsWith(r.estado,'Parcial'));
        assert(r.opcionesMalla.HminInicial==d.Hmin&&r.opcionesMalla.Hgrad==d.Hgrad);
        cerca(r.reaccion,[-4000 0 0],1e-6);assert(r.equilibrio.errorRelativoFuerzas<1e-8);
    end
    function sinLimite
        d=datosPatch;d.limiteElastico=NaN;s=ae_resolver('solido3d',d);r=s.resultado;
        cerca(r.maxVM,1e6,1e-6);assert(r.convergenciaMalla&&~r.resistenciaEvaluada&&isnan(r.factor)&&~r.cumple&&~r.completa);
        m=ae_memoria(s);assert(contains(join(m.paginas(2).ecuaciones),'pendiente')&&~contains(join(m.paginas(2).ecuaciones),'NaN'));
    end
    function stl
        path=[tempname '.stl'];limpiar=onCleanup(@()delete(path));
        V=[0 0 0;200 0 0;200 80 0;0 80 0;0 0 50;200 0 50;200 80 50;0 80 50];
        F=[1 3 2;1 4 3;5 6 7;5 7 8;1 2 6;1 6 5;2 3 7;2 7 6;3 4 8;3 8 7;4 1 5;4 5 8];
        fid=fopen(path,'w');fprintf(fid,'solid control\n');
        for k=1:size(F,1)
            p=V(F(k,:),:);n=cross(p(2,:)-p(1,:),p(3,:)-p(1,:));n=n/norm(n);
            fprintf(fid,'facet normal %.9g %.9g %.9g\nouter loop\n',n);
            fprintf(fid,'vertex %.9g %.9g %.9g\n',p');fprintf(fid,'endloop\nendfacet\n');
        end
        fprintf(fid,'endsolid control\n');fclose(fid);
        d=ae_datos('solido3d');d.geometria="archivo";d.modo="geometria";d.archivoGeometria=path;d.escalaGeometria=.001;
        r=ae_solido3d(d);cerca(r.limitesGeometricos(2,:)-r.limitesGeometricos(1,:),[.2 .08 .05],1e-9);
        assert(r.estado=="Geometria sin resolver");
    end
    function step
        p=fullfile(matlabroot,'toolbox','pde','pde','pdedata','BlockWithHole.step');
        d=ae_datos('solido3d');d.geometria="archivo";d.modo="geometria";d.archivoGeometria=p;
        r=ae_solido3d(d);assert(r.caras>=6&&r.modelo.Geometry.NumCells==1);
    end
    function escalado
        d=datosPatch;d.aceleracionEfectiva=[0 0 -9.81];f=ae_factor_mecanico('solido3d',d,2);
        cerca(f.E,d.E,1e-12);cerca(f.apoyosComponente,d.apoyosComponente,1e-12);
        cerca(f.traccionesCara(:,2:4),2*d.traccionesCara(:,2:4),1e-12);
        cerca(f.traccionesCara(:,1),d.traccionesCara(:,1),1e-12);cerca(f.aceleracionEfectiva,d.aceleracionEfectiva,1e-12);
        assert(f.factorCargaVolumen==2);
    end
    function rechazos
        d=ae_datos('solido3d');d.nu=.5;rechazar(@()ae_solido3d(d));
        d=ae_datos('solido3d');d.Hmin=2*d.Hmax;rechazar(@()ae_resolver('solido3d',d));
        d=ae_datos('solido3d');d.geometria="archivo";d.archivoGeometria="sin_modelo.sldprt";rechazar(@()ae_solido3d(d));
        d=datosPatch;d.traccionesCara(1)=999;rechazar(@()ae_solido3d(d));
    end
    function memoria
        d=datosPatch;s=ae_resolver('solido3d',d);m=ae_memoria(s);assert(numel(m.paginas)==3);
        a=ae_orientar(struct('objeto',"solido",'accion',"combinada",'interes',"resistencia"));assert(a=="solido3d");
    end
end
function cerca(a,b,tol)
assert(isequal(size(a),size(b))&&all(isnan(a(:))==isnan(b(:))),'AE:Pruebas','Dimensiones incompatibles.');
q=~isnan(a);a=a(q);b=b(q);assert(norm(a(:)-b(:),inf)<=tol*max([norm(b(:),inf),1e-12]),'AE:Pruebas','Error frente a la solucion de control.');
end
function rechazar(fn)
ok=false;try,fn();catch ex,ok=startsWith(ex.identifier,'AE:');end
assert(ok,'AE:Pruebas','Un dato incompatible no fue rechazado.');
end
