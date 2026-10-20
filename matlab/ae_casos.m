function estudio=ae_casos(analisis,base,casos,limiteDesplazamiento)
if nargin<4,limiteDesplazamiento=Inf;end
assert(isscalar(limiteDesplazamiento)&&isreal(limiteDesplazamiento)&&limiteDesplazamiento>0, ...
    'AE:Casos','Limite de desplazamiento positivo en m, o Inf.');
assert(isstruct(casos)&&~isempty(casos)&&all(isfield(casos,{'nombre','factorMecanico','cambios'})), ...
    'AE:Casos','Cada caso necesita nombre, factorMecanico y cambios.');
entradas=cell(numel(casos),1);nombres=strings(numel(casos),1);
for j=1:numel(casos)
    nombres(j)=string(casos(j).nombre);assert(strlength(nombres(j))>0,'AE:Casos','Nombra cada caso.');
    assert(isstruct(casos(j).cambios)&&isscalar(casos(j).cambios),'AE:Casos','cambios debe ser una estructura escalar.');
    nuevos=fieldnames(casos(j).cambios);
    assert(all(ismember(nuevos,fieldnames(base))),'AE:Casos','Hay un campo de cambios desconocido.');
    d=base;for k=1:numel(nuevos),d.(nuevos{k})=casos(j).cambios.(nuevos{k});end
    entradas{j}=ae_factor_mecanico(analisis,d,casos(j).factorMecanico);
end
assert(numel(unique(nombres))==numel(casos),'AE:Casos','Los nombres de los casos deben ser distintos.');
soluciones=cell(numel(casos),1);mov=NaN(numel(casos),1);factor=mov;estado=strings(numel(casos),1);
for j=1:numel(casos)
    disp("CASO: "+nombres(j));s=ae_resolver(analisis,entradas{j});s.caso=nombres(j);
    [mov(j),factor(j),estado(j)]=indicadores(s);
    if isfinite(limiteDesplazamiento)
        if isnan(mov(j)),estado(j)="Parcial: desplazamiento no disponible";
        elseif mov(j)>limiteDesplazamiento,estado(j)="No cumple desplazamiento";
        elseif isnan(factor(j)),estado(j)="Cumple desplazamiento; resistencia sin comprobar";end
    end
    soluciones{j}=s;
end
tabla=table(nombres,[casos.factorMecanico]',mov,factor,estado, ...
    'VariableNames',{'Caso','FactorMecanico','MaxDesplazamiento_m','FactorResistencia','Estado'});
[~,k]=max(mov,[],'omitnan');if all(isnan(mov)),k=[];end
[~,p]=min(factor,[],'omitnan');if all(isnan(factor)),p=[];end
estudio=struct('analisis',string(analisis),'soluciones',{soluciones},'tabla',tabla, ...
    'casoMaxDesplazamiento',k,'casoMinFactor',p,'limiteDesplazamiento',limiteDesplazamiento);
disp(tabla);
end
function [u,n,estado]=indicadores(s)
r=s.resultado;d=s.entrada;u=NaN;n=NaN;estado="Sin comprobar resistencia";
if isstruct(r)
    a=r;if isfield(r,'marco'),a=r.marco;end
    if isfield(a,'u')&&~isempty(a.u)&&s.analisis~="torsion"
        v=a.u;
        if isfield(a,'datos')&&isfield(a.datos,'nodos')
            dim=size(a.datos.nodos,2);v=v(:,1:dim);
            u=max(vecnorm(v,2,2));
        elseif isvector(v),u=max(abs(v));else,u=max(vecnorm(v,2,2));end
    elseif isfield(r,'deltaMax'),u=abs(r.deltaMax);
    elseif isfield(r,'delta'),u=max(abs(r.delta));end
    if isfield(r,'factor'),n=r.factor;end
    if isfield(r,'resistencia')&&r.resistencia.evaluada
        n=r.resistencia.factorSeguridad;
        if r.resistencia.cumple,estado="Cumple";else,estado="No cumple";end
    elseif isfield(r,'estado'),estado=r.estado;
    elseif isfield(r,'cumple')
        if r.cumple,estado="Cumple";else,estado="No cumple";end
    elseif isfield(r,'factor')&&s.analisis=="lamina"
        if n>=1,estado="Cumple criterio de membrana";else,estado="No cumple";end
    end
    if s.analisis=="tensor"
        n=d.limiteElastico/max(r.VM,realmin);if n>=1,estado="Cumple von Mises";else,estado="No cumple von Mises";end
    end
elseif istable(r)&&ismember('nCombinado',r.Properties.VariableNames)
    n=min(r.nCombinado);if all(r.Cumple),estado="Cumple";else,estado="No cumple";end
end
end
