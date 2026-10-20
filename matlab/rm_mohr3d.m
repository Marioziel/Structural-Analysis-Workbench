function r=rm_mohr3d(d,consulta)
assert(numel(consulta)==2 && consulta(1)>=1 && consulta(1)<=size(d.nodos,1) ...
    && consulta(1)==fix(consulta(1)) && ismember(consulta(2),1:6),'RM:Consulta','Consulta: [nodo componente 1..6].');
r=rm_marco3d(d);ud=d;nb=size(d.barras,1);
ud.qLocal=zeros(nb,8);ud.qGlobal=zeros(nb,6);ud.deformacionLibre=0;ud.giroLibre=0;ud.curvaturaLibre=zeros(nb,2);
ud.cargas=[consulta(1) zeros(1,6)];ud.cargas(consulta(2)+1)=1;
ud.apoyos(:,2:7)=0*ud.apoyos(:,2:7);v=rm_marco3d(ud);delta=0;
for i=1:nb
    a=r.campos{i};b=v.campos{i};L=a.L;
    contribucion=integrar(a.N,b.N,L)/(r.E(i)*r.F(i))+integrar(1,b.N,L)*r.deformacionLibre(i);
    if a.tipo=="viga"
        contribucion=contribucion+integrar(a.T,b.T,L)/(r.G(i)*r.J(i)) ...
            +integrar(a.My,b.My,L)/(r.E(i)*r.Iy(i)) ...
            +integrar(a.Mz,b.Mz,L)/(r.E(i)*r.Iz(i)) ...
            +integrar(1,b.My,L)*r.curvaturaLibre(i,1)+integrar(1,b.Mz,L)*r.curvaturaLibre(i,2) ...
            +integrar(1,b.T,L)*r.giroLibre(i);
    end
    delta=delta+contribucion;
end
function v=integrar(a,b,L)
v=polyval(polyint(conv(a,b)),L);
end
r.consulta=consulta;r.deltaNodal=r.u(consulta(1),consulta(2));
r.deltaMohr=delta-sum(v.R(:).*r.u(:));
end
