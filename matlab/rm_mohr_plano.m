function r=rm_mohr_plano(d,consulta)
assert(numel(consulta)==2&&consulta(1)>=1&&consulta(1)<=size(d.nodos,1) ...
    && consulta(1)==fix(consulta(1))&&ismember(consulta(2),1:3),'RM:Consulta','Consulta plana: [nodo componente 1..3].');
r=rm_marco(d);ud=d;nb=size(d.barras,1);
ud.q=zeros(nb,4);ud.cargas=[consulta(1) 0 0 0];ud.cargas(consulta(2)+1)=1;
ud.deformacionLibre=0;ud.curvaturaLibre=0;ud.apoyos(:,2:4)=0*ud.apoyos(:,2:4);
v=rm_marco(ud);delta=0;
E=expandir(d.E,nb);F=expandir(d.F,nb);I=expandir(d.I,nb);e0=zeros(nb,1);kap=e0;
if isfield(d,'deformacionLibre'),e0=expandir(d.deformacionLibre,nb);end
if isfield(d,'curvaturaLibre'),kap=expandir(d.curvaturaLibre,nb);end
for i=1:nb
    a=r.campos{i};b=v.campos{i};L=a.L;
    delta=delta+integrar(a.N,b.N,L)/(E(i)*F(i))+integrar(a.M,b.M,L)/(E(i)*I(i)) ...
        +integrar(1,b.N,L)*e0(i)+integrar(1,b.M,L)*kap(i);
end
r.deltaNodal=r.u(consulta(1),consulta(2));r.deltaMohr=delta-sum(v.R(:).*r.u(:));
end
function v=integrar(a,b,L)
v=polyval(polyint(conv(a,b)),L);
end
function v=expandir(v,n)
if isscalar(v),v=repmat(v,n,1);end
v=v(:);assert(numel(v)==n,'RM:Datos','Una propiedad por barra.');
end
