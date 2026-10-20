function r=ae_placa_local(d)
assert(all(isfinite([d.a d.b d.espesor d.E d.kCompresion d.limiteCompresion d.limiteCortante d.limiteProporcional d.nRequerido]))&& ...
    all([d.a d.b d.espesor d.E d.kCompresion d.limiteCompresion d.limiteCortante d.limiteProporcional d.nRequerido]>0), ...
    'AE:Placa','Geometria, propiedades, coeficientes y limites positivos finitos.');
assert(d.a>=d.b&&d.espesor/d.b<=.1,'AE:Placa','Modelo de placa delgada: a>=b y espesor/b<=0.1.');
assert(all(isfinite([d.sigmaCompresion d.tau]))&&d.sigmaCompresion>=0,'AE:Placa','Compresion no negativa y cortante finito.');
ks=5.6+3.8/(d.a/d.b)^2;sc=d.kCompresion*d.E*(d.espesor/d.b)^2;
tc=.9*ks*d.E*(d.espesor/d.b)^2;tcUsada=tc;
if d.corregirCortante
    assert(isscalar(d.tauUltima)&&isfinite(d.tauUltima)&&d.tauUltima>0,'AE:Placa','Introduce tauUltima positiva.');
    psi=d.tauUltima/tc;tcUsada=d.tauUltima*(1+psi)/(1+psi+psi^2);
end
lim=[min(sc,d.limiteCompresion);min(tcUsada,d.limiteCortante)];dem=[d.sigmaCompresion;abs(d.tau)];
n=lim./max(dem,realmin);n(dem==0)=Inf;
elasticidad=sc<=d.limiteProporcional||d.sigmaCompresion==0;
interaccion=d.sigmaCompresion>0&&d.tau~=0;
estado="Cumple por separado";if min(n)<d.nRequerido,estado="No cumple";
elseif ~elasticidad||interaccion,estado="Parcial";end
r=struct('kCortante',ks,'sigmaCritica',sc,'tauCriticaElastica',tc,'tauCriticaUsada',tcUsada, ...
    'factor',min(n),'estado',estado,'completa',elasticidad&&~interaccion, ...
    'cumple',min(n)>=d.nRequerido&&elasticidad&&~interaccion, ...
    'interaccionPendiente',interaccion,'elasticidadValida',elasticidad);
r.tabla=table(["Compresion";"Cortante"],dem/1e6,lim/1e6,n,n/d.nRequerido-1, ...
    'VariableNames',{'Comprobacion','Demanda_MPa','LimiteUtilizado_MPa','Factor','Margen'});
disp(r.tabla);disp("Estado: "+estado);
if interaccion,disp('Compresion y cortante simultaneos: falta una ley de interaccion de estabilidad.');end
if ~elasticidad,disp('La carga critica de compresion supera el limite proporcional; no se valida pandeo inelastico.');end
[~,ax]=rm_figura(2,'Placa: estabilidad local por separado');
rectangle(ax(1),'Position',[0 0 d.a d.b],'EdgeColor','k','LineWidth',1.4);axis(ax(1),'equal');
xlim(ax(1),[-.1*d.a 1.1*d.a]);ylim(ax(1),[-.2*d.b 1.2*d.b]);xlabel(ax(1),'a [m]');ylabel(ax(1),'b [m]');
title(ax(1),sprintf('Espesor %.4g m; k compresion %.4g',d.espesor,d.kCompresion));
bar(ax(2),[dem lim]/1e6);xticks(ax(2),[1 2]);xticklabels(ax(2),{'Compresion','Cortante'});
legend(ax(2),{'Demanda','Limite utilizado'},'Location','best');ylabel(ax(2),'Tension [MPa]');
end
