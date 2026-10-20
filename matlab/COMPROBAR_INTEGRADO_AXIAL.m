function informe=COMPROBAR_INTEGRADO_AXIAL
addpath(fileparts(mfilename('fullpath')));
v=get(groot,'defaultFigureVisible');set(groot,'defaultFigureVisible','off');
limpieza=onCleanup(@() set(groot,'defaultFigureVisible',v));
informe=struct('prueba',{},'ok',{});
d=ae_datos('axial');d.x=[0 2];d.F=400e-6;d.E=200e9;
d.puntuales=[2 10000];d.alpha=12e-6;d.deltaT=30;
lastwarn('');s=ae_resolver('axial',d);r=s.resultado;
cerca(r.u(end),10000*2/(d.E*d.F)+d.alpha*d.deltaT*2);
cerca(r.u,r.componentes.mecanica.u+r.componentes.termica.u);
assert(numel(findall(groot,'Type','figure'))==3);
ae_memoria(s);drawnow;sinErrorGrafico;
informe(end+1)=struct('prueba',"Carga y temperatura: superposicion y graficas",'ok',true);
close all force;
d.deltaT=0;d.topes=[2 .0001 1];lastwarn('');s=ae_resolver('axial',d);r=s.resultado;
assert(r.contactosActivos);cerca(r.u(end),.0001);cerca(r.R(end),-6000);
ae_memoria(s);drawnow;sinErrorGrafico;
informe(end+1)=struct('prueba',"Tope activo: compatibilidad y reaccion",'ok',true);
close all force;
d.topes=[];d.puntuales=[];d.distribuidas=[0 2 1000 1000];lastwarn('');
s=ae_resolver('axial',d);r=s.resultado;cerca(r.u(end),1000*2^2/(2*d.E*d.F));
cerca(polyval(r.tramos(1).N,2),0);cerca(polyval(r.tramos(1).N,0),2000);
ae_memoria(s);drawnow;sinErrorGrafico;
informe(end+1)=struct('prueba',"Carga distribuida: solucion continua y esquema",'ok',true);
close all force;
if nargout==0,disp(struct2table(informe));end
end
function cerca(a,b)
assert(norm(a(:)-b(:),inf)<=1e-8*max([norm(b(:),inf),1e-10]),'AE:Pruebas','Diferencia analitica fuera de tolerancia.');
end
function sinErrorGrafico
[msg,id]=lastwarn;assert(~contains(id,'SceneNode')&&~contains(msg,'interpreter syntax'), ...
    'AE:Render','Error al representar ecuaciones: %s',msg);
end
