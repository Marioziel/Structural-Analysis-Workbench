function r=rm_resistencia_marco3d(d,c)
nb=size(d.barras,1);D=expandir(c.D,nb);di=expandir(c.di,nb);
if ~isfield(c,'considerarCortante'),c.considerarCortante=true;end
if isfield(c,'espesor') && ~isempty(c.espesor)
    t=expandir(c.espesor,nb);assert(all(t>0 & 2*t<D),'RM:Espesor','El espesor debe ser positivo y menor que D/2.');di=D-2*t;
end
assert(all(D>di & di>=0) && c.limiteTraccion>0 && c.limiteCompresion>0 ...
    && c.nu>-1 && c.nu<.5 && c.puntosLongitud>=3 && ismember(c.teoria,1:5) ...
    && c.nRequerido>0,'RM:Resistencia','Datos de seccion, criterio o muestreo invalidos.');
F=pi*(D.^2-di.^2)/4;I=pi*(D.^4-di.^4)/64;
d.F=F;d.Iy=I;d.Iz=I;d.J=2*I;r=struct('marco',rm_marco3d(d),'D',D,'di',di);
maximos=zeros(nb,5);nominal=maximos;crit=zeros(nb,5);tauQ=zeros(nb,1);campos=cell(nb,1);razon=c.limiteTraccion/c.limiteCompresion;
for i=1:nb
    a=r.marco.campos{i};s=linspace(0,a.L,c.puntosLongitud)';
    vals=cell(1,6);nombres={'N','Vy','Vz','T','My','Mz'};
    for j=1:6,vals{j}=polyval(a.(nombres{j}),s);end
    eq=zeros(numel(s),5);base=eq;tq=zeros(numel(s),1);
    for j=1:numel(s)
        b=rm_circular_combinada(vals{1}(j),vals{2}(j),vals{3}(j),vals{4}(j),vals{5}(j),vals{6}(j),D(i),di(i),c.nu,razon);
        eq(j,:)=b.envolvente;if ~c.considerarCortante,eq(j,:)=b.nominal;end
        base(j,:)=b.nominal;tq(j)=b.tauQ;
    end
    for j=1:5,[maximos(i,j),ix]=max(eq(:,j));crit(i,j)=s(ix);end
    nominal(i,:)=max(base,[],1);tauQ(i)=max(tq);
    campos{i}=struct('s',s,'equivalentes',eq,'nominal',base,'tauQ',tq);
end
[peor,barra]=max(maximos(:,c.teoria));r.factor=c.limiteTraccion/max(peor,realmin);r.cumple=r.factor>=c.nRequerido*(1-1e-8);
r.cortanteValidado=c.considerarCortante || max(tauQ)<=.05*c.limiteTraccion;
r.cumple=r.cumple&&r.cortanteValidado;
r.barraCritica=barra;r.sCritica=crit(barra,c.teoria);r.maximos=maximos;r.nominal=nominal;r.campos=campos;r.config=c;
r.tabla=table((1:nb)',D,di,maximos(:,c.teoria)/1e6,c.limiteTraccion./max(maximos(:,c.teoria),realmin), ...
    crit(:,c.teoria),tauQ/1e6,100*tauQ/c.limiteTraccion,'VariableNames', ...
    {'Barra','D_m','di_m','Equivalente_cota_MPa','Factor_seguridad','s_critica_m','tauQ_cota_MPa','tauQ_porcentaje_limite'});
end
function v=expandir(v,n)
if isscalar(v),v=repmat(v,n,1);end
v=v(:);assert(numel(v)==n&&all(isfinite(v)),'RM:Seccion','Una dimension por barra o un escalar.');
end
