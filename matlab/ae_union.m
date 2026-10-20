function r=ae_union(d)
assert(ismember(string(d.tipo),["pasador","soldadura_tope","soldadura_filete","adhesivo_simple"]), ...
    'AE:Union','Tipo de union no reconocido.');
assert(isscalar(d.nRequerido)&&isfinite(d.nRequerido)&&d.nRequerido>0,'AE:Union','Factor requerido positivo.');
if d.tipo=="pasador"
    positivo([d.diametro d.diametroAgujero d.areaTraccion d.limiteTraccionPerno d.limiteCortantePerno d.limiteEquivalente]);
    assert(d.diametroAgujero>=d.diametro,'AE:Union','El agujero no puede ser menor que el perno.');
    assert(isscalar(d.planosCorte)&&ismember(d.planosCorte,1:20),'AE:Union','Numero entero de planos de corte.');
    assert(all(isfinite([d.Paxial d.Pcortante]))&&isreal([d.Paxial d.Pcortante])&&d.Paxial>=0, ...
        'AE:Union','Paxial es traccion no negativa; Pcortante es real y finito.');
    A=pi*d.diametro^2/4;sigma=d.Paxial/d.areaTraccion;tau=abs(d.Pcortante)/(d.planosCorte*A);
    eq=sqrt(sigma^2+4*tau^2);
    L=d.laminas;assert(isnumeric(L)&&isreal(L)&&size(L,2)==4&&~isempty(L)&&all(isfinite(L(:))), ...
        'AE:Union','laminas: [espesor ancho distanciaCentroBorde fuerzaTransmitida].');
    assert(all(L(:,1)>0&L(:,2)>d.diametroAgujero&L(:,3)>d.diametroAgujero/2), ...
        'AE:Union','Espesor positivo, ancho mayor que d y centro a borde mayor que d/2.');
    assert(all(L(:,4)>=0),'AE:Union','La fuerza por lamina se introduce como magnitud positiva.');
    lim=d.limitesLamina;if size(lim,1)==1,lim=repmat(lim,size(L,1),1);end
    assert(isequal(size(lim),[size(L,1) 3]),'AE:Union','Un limite de traccion, aplastamiento y desgarro por lamina.');positivo(lim(:));
    apl=L(:,4)./(L(:,1)*d.diametro);net=L(:,4)./(L(:,1).*(L(:,2)-d.diametroAgujero));
    borde=L(:,4)./(2*L(:,1).*(L(:,3)-d.diametroAgujero/2));
    demanda=[sigma;tau;eq;reshape([net apl borde].',[],1)];
    limites=[d.limiteTraccionPerno;d.limiteCortantePerno;d.limiteEquivalente;reshape(lim.',[],1)];
    etiquetas=["Perno: traccion";"Perno: corte";"Perno: equivalente III"];
    for j=1:size(L,1),etiquetas=[etiquetas;"Lamina "+j+": neta";"Lamina "+j+": aplastamiento";"Lamina "+j+": desgarro"];end
    r=struct('sigmaPerno',sigma,'tauPerno',tau,'equivalentePerno',eq,'sigmaNeta',net, ...
        'sigmaAplastamiento',apl,'tauDesgarro',borde,'areaCorte',A, ...
        'diametroMinCorte',sqrt(4*abs(d.Pcortante)*d.nRequerido/(pi*d.planosCorte*d.limiteCortantePerno)));
elseif d.tipo=="soldadura_tope"
    positivo([d.longitudTope d.espesorTope d.limiteNormalSoldadura]);
    assert(all(isfinite([d.fuerzaSoldadura d.momentoSoldadura]))&&isreal([d.fuerzaSoldadura d.momentoSoldadura]), ...
        'AE:Union','Fuerza y momento reales finitos.');
    A=d.longitudTope*d.espesorTope;W=d.longitudTope*d.espesorTope^2/6;
    extremos=d.fuerzaSoldadura/A+[-1 1]*d.momentoSoldadura/W;
    demanda=max(abs(extremos));limites=d.limiteNormalSoldadura;etiquetas="Tope: tension normal extrema";
    r=struct('area',A,'moduloResistente',W,'sigmaExtremos',extremos);
elseif d.tipo=="soldadura_filete"
    assert(isvector(d.longitudesFilete)&&isvector(d.gargantas)&&numel(d.longitudesFilete)==numel(d.gargantas), ...
        'AE:Union','Una garganta efectiva por longitud de cordon.');
    positivo([d.longitudesFilete(:);d.gargantas(:);d.limiteCortanteSoldadura]);
    assert(isfinite(d.fuerzaSoldadura)&&isreal(d.fuerzaSoldadura)&&d.momentoSoldadura==0, ...
        'AE:Union','El modelo de filetes solo admite cortante directo sin momento ni excentricidad.');
    A=sum(d.longitudesFilete(:).*d.gargantas(:));demanda=abs(d.fuerzaSoldadura)/A;
    limites=d.limiteCortanteSoldadura;etiquetas="Filetes: cortante medio";r=struct('area',A,'tau',demanda);
else
    positivo([d.anchoAdhesivo d.solapeAdhesivo d.limiteAdhesivo]);
    assert(isfinite(d.fuerzaAdhesivo)&&isreal(d.fuerzaAdhesivo),'AE:Union','Fuerza real finita.');
    A=d.anchoAdhesivo*d.solapeAdhesivo;demanda=abs(d.fuerzaAdhesivo)/A;
    limites=d.limiteAdhesivo;etiquetas="Adhesivo: cortante medio";r=struct('area',A,'tau',demanda);
end
factores=limites./max(demanda,realmin);factores(demanda==0)=Inf;
r.factor=min(factores);r.cumple=r.factor>=d.nRequerido;r.estado="Cumple";
if ~r.cumple,r.estado="No cumple";end
r.demanda=demanda;r.limites=limites;r.etiquetas=etiquetas;
r.tabla=table((1:numel(etiquetas))',etiquetas,demanda(:)/1e6,limites(:)/1e6,factores(:), ...
    factores(:)/d.nRequerido-1,'VariableNames',{'Indice','Comprobacion','Demanda_MPa','Limite_MPa','Factor','Margen'});
disp(r.tabla);disp("Estado para el modelo de union: "+r.estado);
[~,ax]=rm_figura(2,'Union: demandas y margenes');
bar(ax(1),demanda(:)/1e6);ylabel(ax(1),'Tension [MPa]');xticks(ax(1),1:numel(etiquetas));
xlabel(ax(1),'Indice de comprobacion en la tabla');
bar(ax(2),d.nRequerido./factores(:));yline(ax(2),1,'r--');ylabel(ax(2),'Utilizacion [-]');xlabel(ax(2),'Comprobacion');
end
function positivo(v)
assert(isnumeric(v)&&isreal(v)&&all(isfinite(v))&&all(v>0),'AE:Union','Las dimensiones y los limites deben ser positivos y finitos.');
end
