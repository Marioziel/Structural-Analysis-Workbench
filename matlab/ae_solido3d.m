function r=ae_solido3d(d)
assert(exist('createpde','file')==2&&license('test','PDE_Toolbox'), ...
    'AE:PDE','solido3d requiere una licencia disponible de PDE Toolbox.');
assert(ismember(string(d.geometria),["caja","archivo"])&&ismember(string(d.modo),["geometria","resolver"]), ...
    'AE:Solido','Geometria caja o archivo; modo geometria o resolver.');
assert(all(isfinite([d.escalaGeometria d.E d.nu d.densidad d.Hmax d.factorCargaVolumen d.nRequerido d.toleranciaMalla]))&& ...
    all([d.escalaGeometria d.E d.densidad d.Hmax d.nRequerido d.toleranciaMalla]>0)&& ...
    d.nu>0&&d.nu<.5&&d.factorCargaVolumen>=0,'AE:Solido','Propiedades invalidas; esta interfaz de PDE Toolbox exige 0<nu<0.5.');
assert(isnumeric(d.limiteElastico)&&isscalar(d.limiteElastico)&&isreal(d.limiteElastico)&& ...
    (isnan(d.limiteElastico)||(isfinite(d.limiteElastico)&&d.limiteElastico>0)), ...
    'AE:Solido','Limite elastico positivo en Pa o NaN si se desconoce: no se comprobara resistencia.');
resistenciaEvaluada=~isnan(d.limiteElastico);
Hmin=[];Hgrad=1.5;
if isfield(d,'Hmin'),Hmin=d.Hmin;end
if isfield(d,'Hgrad'),Hgrad=d.Hgrad;end
assert(isempty(Hmin)||(isnumeric(Hmin)&&isscalar(Hmin)&&isfinite(Hmin)&&Hmin>0&&Hmin<=d.Hmax), ...
    'AE:Solido','Hmin debe estar vacio o ser positivo y no mayor que Hmax, en m.');
assert(isnumeric(Hgrad)&&isscalar(Hgrad)&&isfinite(Hgrad)&&Hgrad>=1&&Hgrad<=2, ...
    'AE:Solido','Hgrad debe estar entre 1 y 2.');
assert(isscalar(d.limiteDesplazamiento)&&isreal(d.limiteDesplazamiento)&&d.limiteDesplazamiento>0, ...
    'AE:Solido','El limite de desplazamiento debe ser positivo en m, o Inf.');
assert(isnumeric(d.aceleracionEfectiva)&&isreal(d.aceleracionEfectiva)&&numel(d.aceleracionEfectiva)==3 ...
    &&all(isfinite(d.aceleracionEfectiva)),'AE:Solido','Aceleracion efectiva: tres componentes en m/s2.');
m=createpde('structural','static-solid');
if d.geometria=="caja"
    assert(isnumeric(d.dimensiones)&&numel(d.dimensiones)==3&&all(isfinite(d.dimensiones))&&all(d.dimensiones>0), ...
        'AE:Solido','Dimensiones de la caja [Lx Ly Lz] positivas.');
    g=multicuboid(d.dimensiones(1),d.dimensiones(2),d.dimensiones(3));
else
    archivo=string(d.archivoGeometria);[~,~,ext]=fileparts(archivo);
    assert(isfile(archivo)&&ismember(lower(string(ext)),[".stl",".step",".stp"]), ...
        'AE:Solido','Selecciona un archivo STL o STEP existente; los archivos nativos de SolidWorks requieren exportacion.');
    g=importGeometry(archivo,'AllowSelfIntersections',false);
end
if d.escalaGeometria~=1,scale(g,d.escalaGeometria);end
assert(g.NumCells==1,'AE:Solido',['Este modulo admite un unico solido material conectado. ' ...
    'Un ensamblaje requiere definir las uniones o contactos; no se unen cuerpos automaticamente.']);
m.Geometry=g;limites=[min(g.Vertices,[],1);max(g.Vertices,[],1)];
[~,ax]=rm_figura(1,'Solido 3D: identificacion de caras');
pdegplot(ax(1),g,'FaceLabels','on','FaceAlpha',.4);view(ax(1),35,24);axis(ax(1),'equal');
xlabel(ax(1),'X [m]');ylabel(ax(1),'Y [m]');zlabel(ax(1),'Z [m]');
disp('Caja envolvente despues del escalado, en m:');disp(limites);
r=struct('modelo',m,'modo',string(d.modo),'estado',"Geometria sin resolver", ...
    'factor',NaN,'cumple',false,'completa',false,'limitesGeometricos',limites,'caras',g.NumFaces);
if d.modo=="geometria",return;end
fijas=d.carasFijas(:).';tr=d.traccionesCara;pr=d.presionesCara;ap=d.apoyosComponente;
assert(isnumeric(ap)&&isreal(ap)&&size(ap,2)==4&&all(isfinite(ap(:,1)))&&all(isfinite(ap(~isnan(ap)))), ...
    'AE:Solido','apoyosComponente: [cara ux uy uz], con NaN para componentes libres.');
assert(all(any(~isnan(ap(:,2:4)),2))&&numel(unique(ap(:,1)))==size(ap,1), ...
    'AE:Solido','Cada cara de apoyo debe restringir al menos una componente y aparecer una sola vez.');
assert(isnumeric(tr)&&size(tr,2)==4&&isreal(tr)&&all(isfinite(tr(:))), ...
    'AE:Solido','traccionesCara: [cara tx ty tz], con traccion superficial en Pa.');
assert(isnumeric(pr)&&size(pr,2)==2&&isreal(pr)&&all(isfinite(pr(:))), ...
    'AE:Solido','presionesCara: [cara presion], en Pa.');
if d.geometria=="caja"&&isempty(fijas)&&isempty(ap)&&isempty(tr)&&isempty(pr)
    dim=d.dimensiones*d.escalaGeometria;
    fijas=nearestFace(g,[-dim(1)/2 0 dim(3)/2]);
    cargada=nearestFace(g,[dim(1)/2 0 dim(3)/2]);
    assert(numel(d.traccionCaja)==3&&all(isfinite(d.traccionCaja)),'AE:Solido','traccionCaja necesita tres componentes en Pa.');
    tr=[cargada d.traccionCaja(:).'];
end
ids=[fijas(:);ap(:,1);tr(:,1);pr(:,1)];carasApoyo=unique([fijas(:);ap(:,1)]);
assert(~isempty(carasApoyo)&&all(isfinite(ids))&&all(ids==fix(ids)&ids>=1&ids<=g.NumFaces), ...
    'AE:Solido','Define caras fijas y numeros de cara validos. Usa primero modo geometria.');
assert(numel(unique([tr(:,1);pr(:,1)]))==size(tr,1)+size(pr,1), ...
    'AE:Solido','Una sola asignacion por cara cargada; combina previamente las tracciones que coincidan.');
assert(isempty(intersect(fijas,ap(:,1))),'AE:Solido','No repitas una cara entre fijas y apoyos por componente.');
assert(isempty(intersect(carasApoyo,[tr(:,1);pr(:,1)])),'AE:Solido','Separa las caras de apoyo de las caras cargadas.');
structuralProperties(m,'YoungsModulus',d.E,'PoissonsRatio',d.nu,'MassDensity',d.densidad);
if ~isempty(fijas),structuralBC(m,'Face',unique(fijas),'Constraint','fixed');end
nombres={'XDisplacement','YDisplacement','ZDisplacement'};
for j=1:size(ap,1)
    args={};for k=1:3,if ~isnan(ap(j,k+1)),args=[args {nombres{k},ap(j,k+1)}];end;end
    structuralBC(m,'Face',ap(j,1),args{:});
end
for j=1:size(tr,1),structuralBoundaryLoad(m,'Face',tr(j,1),'SurfaceTraction',tr(j,2:4));end
for j=1:size(pr,1),structuralBoundaryLoad(m,'Face',pr(j,1),'Pressure',pr(j,2));end
geff=d.factorCargaVolumen*d.aceleracionEfectiva(:).';
if any(geff~=0),structuralBodyLoad(m,'GravitationalAcceleration',geff);end
niveles=1;if d.refinarMalla
    assert(isscalar(d.nivelesMalla)&&ismember(d.nivelesMalla,2:4),'AE:Solido','nivelesMalla debe ser 2, 3 o 4.');
    niveles=d.nivelesMalla;
end
datos=zeros(niveles,6);
for j=1:niveles
    h=d.Hmax/1.5^(j-1);args={'Hmax',h,'Hgrad',Hgrad,'GeometricOrder','quadratic'};
    if ~isempty(Hmin),args=[args {'Hmin',Hmin/1.5^(j-1)}];end
    generateMesh(m,args{:});
    R=solve(m);u=[R.Displacement.ux R.Displacement.uy R.Displacement.uz];
    vmax=max(R.VonMisesStress);umax=max(vecnorm(u,2,2));
    assert(isfinite(vmax)&&isfinite(umax),'AE:Solido','La solucion contiene valores no finitos. Revisa apoyos y malla.');
    datos(j,:)=[h size(m.Mesh.Nodes,2) size(m.Mesh.Elements,2) umax vmax d.limiteElastico/max(vmax,realmin)];
end
errorU=NaN;errorS=NaN;
if niveles>1
    errorU=abs(datos(end,4)-datos(end-1,4))/max(datos(end,4),realmin);
    errorS=abs(datos(end,5)-datos(end-1,5))/max(datos(end,5),realmin);
end
convergente=niveles>1&&max(errorU,errorS)<=d.toleranciaMalla;
n=d.limiteElastico/max(vmax,realmin);cumpleCriterios=n>=d.nRequerido&&umax<=d.limiteDesplazamiento;
estado="Parcial: convergencia sin acreditar";
if convergente
    estado="Cumple criterios declarados";if ~cumpleCriterios,estado="No cumple criterios declarados";end
end
if ~resistenciaEvaluada
    estado="Parcial: resistencia sin comprobar";
    if ~convergente,estado="Parcial: resistencia y convergencia pendientes";end
end
reaccionTensiones=zeros(1,3);
for cara=carasApoyo(:).'
    q=evaluateReaction(R,'Face',cara);reaccionTensiones=reaccionTensiones+[sum([q.Fx]) sum([q.Fy]) sum([q.Fz])];
end
equilibrio=ae_equilibrio_solido(m,u);reaccion=equilibrio.reaccion;
r.resultadoFEM=R;r.u=u;r.sigmaVM=R.VonMisesStress;r.maxVM=vmax;r.maxDesplazamiento=umax;
r.factor=n;r.estado=estado;r.completa=convergente&&resistenciaEvaluada;r.cumple=r.completa&&cumpleCriterios;
r.resistenciaEvaluada=resistenciaEvaluada;r.convergenciaMalla=convergente;
r.cumpleCriterios=cumpleCriterios;r.errorRelativoU=errorU;r.errorRelativoSigma=errorS;
r.reaccion=reaccion;r.carasFijas=fijas;r.apoyosComponente=ap;r.traccionesCara=tr;r.presionesCara=pr;
r.equilibrio=equilibrio;r.reaccionTensiones=reaccionTensiones;
r.opcionesMalla=struct('HminInicial',Hmin,'Hgrad',Hgrad);
r.tablaMalla=array2table(datos,'VariableNames',{'Hmax_m','Nodos','Tetraedros','MaxU_m','MaxVM_Pa','FactorVM'});
disp(r.tablaMalla);disp("Estado: "+estado);disp('Resultante de reacciones nodales [N]:');disp(reaccion);
[~,ax]=rm_figura(1,'Solido 3D: malla de tetraedros');pdeplot3D(ax(1),m);axis(ax(1),'equal');view(ax(1),35,24);
[~,ax]=rm_figura(1,'Solido 3D: tension equivalente nodal [MPa]');
pdeplot3D(ax(1),m,'ColorMapData',R.VonMisesStress/1e6);axis(ax(1),'equal');view(ax(1),35,24);colorbar(ax(1));
[~,ax]=rm_figura(1,'Solido 3D: desplazamiento [mm], deformada amplificada');
span=max(limites(2,:)-limites(1,:));amplificacion=.1*span/max(umax,realmin);
pdeplot3D(ax(1),m,'ColorMapData',vecnorm(u,2,2)*1000, ...
    'Deformation',R.Displacement,'DeformationScaleFactor',amplificacion);
axis(ax(1),'equal');view(ax(1),35,24);colorbar(ax(1));
title(ax(1),sprintf('Amplificacion de deformada: %.4g',amplificacion));
end
