function r=rm_marco(d)
% Marco plano Euler-Bernoulli: desplazamientos pequenos, sin cortante flexible.
X=d.nodos; B=d.barras; nn=size(X,1); nb=size(B,1);
assert(size(X,2)==2 && all(isfinite(X(:))) && size(B,2)==2 ...
    && all(B(:)>=1 & B(:)<=nn & B(:)==fix(B(:))), 'RM:Datos','Geometria invalida.');
E=expandir(d.E,nb); F=expandir(d.F,nb); I=expandir(d.I,nb);
assert(all(E>0 & F>0 & I>0),'RM:Material','E, F e I deben ser positivos.');
q=zeros(nb,4); if isfield(d,'q'), q=d.q; end
assert(isequal(size(q),[nb 4]) && all(isfinite(q(:))), ...
    'RM:Cargas','q: una fila [px0 px1 qy0 qy1] por barra, en ejes locales.');
e0=zeros(nb,1); kappa=e0;
if isfield(d,'deformacionLibre'), e0=expandir(d.deformacionLibre,nb); end
if isfield(d,'curvaturaLibre'), kappa=expandir(d.curvaturaLibre,nb); end
liberadas=false(nb,2);
if isfield(d,'liberaciones')
    a=d.liberaciones;
    assert(size(a,2)==2 && all(a(:,1)>=1 & a(:,1)<=nb & a(:,1)==fix(a(:,1))) ...
        && all(ismember(a(:,2),[1 2])),'RM:Rotulas','Liberaciones: [barra extremo].');
    for j=1:size(a,1), liberadas(a(j,1),a(j,2))=true; end
end
K=sparse(3*nn,3*nn); f=zeros(3*nn,1); elem=cell(nb,1);
assert(size(d.cargas,2)==4 && size(d.apoyos,2)==4,'RM:Datos','Cargas/apoyos: nodo y tres componentes.');
for j=1:size(d.cargas,1)
    a=d.cargas(j,1); assert(a>=1 && a<=nn && a==fix(a),'RM:Nodo','Nodo invalido.');
    ix=3*(a-1)+(1:3); f(ix)=f(ix)+d.cargas(j,2:4)';
end
for i=1:nb
    a=B(i,1); b=B(i,2); v=X(b,:)-X(a,:); L=norm(v);
    assert(L>0,'RM:Longitud','Barra de longitud nula.'); c=v(1)/L; s=v(2)/L;
    Q=[c s 0;-s c 0;0 0 1]; T=blkdiag(Q,Q);
    k=zeros(6); k([1 4],[1 4])=E(i)*F(i)/L*[1 -1;-1 1];
    iz=[2 3 5 6];
    k(iz,iz)=E(i)*I(i)/L^3*[12 6*L -12 6*L;6*L 4*L^2 -6*L 2*L^2; ...
        -12 -6*L 12 -6*L;6*L 2*L^2 -6*L 4*L^2];
    fl=zeros(6,1); p0=q(i,1); p1=q(i,2); q0=q(i,3); q1=q(i,4);
    fl([1 4])=L/6*[2*p0+p1;p0+2*p1]+E(i)*F(i)*e0(i)*[-1;1];
    fl(iz)=[L*(7*q0+3*q1)/20;L^2*(3*q0+2*q1)/60; ...
        L*(3*q0+7*q1)/20;-L^2*(2*q0+3*q1)/60]+E(i)*I(i)*kappa(i)*[0;-1;0;1];
    h=[3 6]; h=h(liberadas(i,:)); g=setdiff(1:6,h);
    kc=k; fc=fl;
    if ~isempty(h)
        kc=zeros(6); fc=zeros(6,1);
        kc(g,g)=k(g,g)-k(g,h)*(k(h,h)\k(h,g));
        fc(g)=fl(g)-k(g,h)*(k(h,h)\fl(h));
    end
    ix=[3*(a-1)+(1:3),3*(b-1)+(1:3)];
    K(ix,ix)=K(ix,ix)+T'*kc*T; f(ix)=f(ix)+T'*fc;
    elem{i}=struct('L',L,'T',T,'k',k,'fl',fl,'ix',ix,'h',h,'g',g,'c',c,'s',s);
end
indices=[]; valores=[];
for j=1:size(d.apoyos,1)
    a=d.apoyos(j,1); assert(a>=1 && a<=nn && a==fix(a),'RM:Nodo','Apoyo invalido.');
    for k=1:3
        if ~isnan(d.apoyos(j,k+1))
            indices(end+1)=3*(a-1)+k; valores(end+1)=d.apoyos(j,k+1);
        end
    end
end
[u,R,info]=rm_lineal(K,f,indices,valores);
assert(all(mod(info.nulos,3)==0),'RM:Mecanismo','Hay una traslacion libre sin rigidez.');
campos=cell(nb,1); energia=0;
for i=1:nb
    e=elem{i}; L=e.L; v=e.T*u(e.ix);
    if ~isempty(e.h), v(e.h)=e.k(e.h,e.h)\(e.fl(e.h)-e.k(e.h,e.g)*v(e.g)); end
    px=q(i,1); bp=(q(i,2)-px)/L; qy=q(i,3); bq=(q(i,4)-qy)/L;
    EA=E(i)*F(i); EI=E(i)*I(i);
    N0=EA*((v(4)-v(1))/L-e0(i))+L*(2*px+q(i,2))/6;
    N=[-bp/2 -px N0]; pu=[-bp/(6*EA) -px/(2*EA) N0/EA+e0(i) v(1)];
    rhs=[v(5)-v(2)-v(3)*L-qy*L^4/(24*EI)-bq*L^5/(120*EI); ...
        v(6)-v(3)-qy*L^3/(6*EI)-bq*L^4/(24*EI)];
    cc=[L^2 L^3;2*L 3*L^2]\rhs;
    pv=[bq/(120*EI) qy/(24*EI) cc(2) cc(1) v(3) v(2)];
    M=EI*polyder(polyder(pv)); M(end)=M(end)-EI*kappa(i);
    V=polyder(M); acciones=e.k*v-e.fl;
    campos{i}=struct('N',N,'V',V,'M',M,'u',pu,'v',pv,'theta',polyder(pv), ...
        'L',L,'local',v,'acciones',acciones,'origen',X(B(i,1),:),'c',e.c,'s',e.s);
    ss=linspace(0,L,401);
    energia=energia+trapz(ss,polyval(N,ss).^2/(2*EA)+polyval(M,ss).^2/(2*EI));
end
r=struct('u',reshape(u,3,[])','R',reshape(R,3,[])','K',K,'f',f, ...
    'campos',{campos},'info',info,'energia',energia,'datos',d);
end
function v=expandir(v,n)
assert(isnumeric(v) && isreal(v) && all(isfinite(v(:))),'RM:Datos','Propiedad invalida.');
if isscalar(v), v=repmat(v,n,1); end
v=v(:); assert(numel(v)==n,'RM:Datos','Se necesita una propiedad por barra.');
end
