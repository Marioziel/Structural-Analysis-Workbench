function s=ae_resolver(analisis,datos)
ae_verificar;
analisis=string(analisis);t=ae_catalogo;
assert(isscalar(analisis)&&any(t.Clave==analisis),'AE:Seleccion','Analisis no reconocido.');
assert(isstruct(datos)&&isscalar(datos),'AE:Datos','datos debe ser una estructura escalar.');
base=ae_datos(analisis);
if analisis=="solido3d"
    base.Hmin=[];base.Hgrad=1.5;
    for opcional={'Hmin','Hgrad'}
        if ~isfield(datos,opcional{1}),datos.(opcional{1})=base.(opcional{1});end
    end
end
esperados=fieldnames(base);recibidos=fieldnames(datos);
faltan=setdiff(esperados,recibidos);sobran=setdiff(recibidos,esperados);
assert(isempty(faltan),'AE:Datos','Faltan campos: %s.',strjoin(faltan,', '));
assert(isempty(sobran),'AE:Datos','Campos desconocidos: %s.',strjoin(sobran,', '));
n=t.Capitulo(t.Clave==analisis);
if n>0
    calculo=str2func(sprintf('ae_modelo_%02d',n));
    [r,estado]=calculo(datos);
else
    estado=struct;
    switch analisis
        case "seccion_general",r=ae_seccion_general(datos);
        case "uniones",r=ae_union(datos);
        case "placa_local",r=ae_placa_local(datos);
        case "solido3d",r=ae_solido3d(datos);
        otherwise,error('AE:Seleccion','Ampliacion desconocida.');
    end
end
c=struct('Ejecucion',"Completada",'Alcance',ae_alcance(analisis), ...
    'Interpretacion',"Los controles verifican el modelo; revisa por separado su aplicabilidad fisica.");
if isstruct(r)
    if isfield(r,'validacion'),c.ControlAxial=r.validacion;end
    if isfield(r,'deltaMohr'),c.ErrorTrabajoVirtual=abs(r.deltaMohr-r.deltaNodal);end
    if isfield(r,'info'),c.SistemaLineal=r.info;end
    if isfield(r,'resistencia'),c.Resistencia=r.resistencia;end
    if isfield(r,'cumple'),c.CumpleResistencia=r.cumple;end
    if isfield(r,'errorLaplace'),c.ResiduoLaplace_Pa=r.errorLaplace;end
    if isfield(r,'residuoEnergia'),c.ResiduoEnergia_J=r.residuoEnergia;end
    if isfield(r,'estado'),c.EstadoModelo=r.estado;end
    if isfield(r,'equilibrio'),c.Equilibrio3D=r.equilibrio;end
    if isfield(r,'completa'),c.ComprobacionCompleta=r.completa;end
end
s=struct('analisis',analisis,'capitulo',n,'entrada',datos,'resultado',r, ...
    'estado',estado,'comprobaciones',c,'fecha',datetime('now'),'unidades',"SI: m N Pa rad kg s K");
end
