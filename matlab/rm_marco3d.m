function r=rm_marco3d(d)
% Barras espaciales Euler-Bernoulli, torsion de Saint-Venant y barras axiales.
X=d.nodos; B=d.barras; nn=size(X,1); nb=size(B,1);
assert(size(X,2)==3 && isreal(X) && all(isfinite(X(:))) && size(B,2)==2 ...
    && nb>0 && all(B(:)>=1 & B(:)<=nn & B(:)==fix(B(:))),'RM:Geometria','Nodos [x y z] y barras [nodo1 nodo2].');
E=expandir(d.E,nb); F=expandir(d.F,nb); G=expandir(d.G,nb);
Iy=expandir(d.Iy,nb); Iz=expandir(d.Iz,nb); J=expandir(d.J,nb);
tipo=repmat("viga",nb,1); if isfield(d,'tipo'), tipo=string(d.tipo(:)); if isscalar(tipo),tipo=repmat(tipo,nb,1);end,end
assert(numel(tipo)==nb && all(ismember(tipo,["viga" "axial"])),'RM:Tipo','tipo: viga o axial por barra.');
vigas=tipo=="viga";
assert(all(E>0 & G>0 & F>0) && all(Iy>=0 & Iz>=0 & J>=0) ...
    && all(Iy(vigas)>0 & Iz(vigas)>0 & J(vigas)>0),'RM:Material','E, G, F positivos; Iy, Iz y J positivos en vigas.');
q=zeros(nb,8); if isfield(d,'qLocal'),q=d.qLocal;end
assert(isequal(size(q),[nb 8]) && all(isfinite(q(:))),'RM:Cargas','qLocal: [qx0 qx1 qy0 qy1 qz0 qz1 mx0 mx1] por barra.');
qg=zeros(nb,6); if isfield(d,'qGlobal'),qg=d.qGlobal;end
assert(isequal(size(qg),[nb 6]) && all(isfinite(qg(:))),'RM:Cargas','qGlobal: [qx0 qx1 qy0 qy1 qz0 qz1] por barra.');
ref=zeros(nb,3);if isfield(d,'referenciaY'),ref=d.referenciaY;end
assert(isequal(size(ref),[nb 3]) && all(isfinite(ref(:))),'RM:Ejes','referenciaY: una direccion por barra, o [0 0 0] para automatica.');
e0=zeros(nb,1);tw=e0;kap=zeros(nb,2);
if isfield(d,'deformacionLibre'),e0=expandir(d.deformacionLibre,nb);end
if isfield(d,'giroLibre'),tw=expandir(d.giroLibre,nb);end
if isfield(d,'curvaturaLibre'),kap=d.curvaturaLibre;if isequal(size(kap),[1 2]),kap=repmat(kap,nb,1);end,end
assert(isequal(size(kap),[nb 2])&&all(isfinite(kap(:))),'RM:Curvatura','curvaturaLibre: [kappa_y kappa_z] por barra.');
rel=zeros(0,3);if isfield(d,'liberaciones'),rel=d.liberaciones;end
assert(size(rel,2)==3 && all(rel(:,1)>=1 & rel(:,1)<=nb & rel(:,1)==fix(rel(:,1))) ...
    && all(ismember(rel(:,2),[1 2])) && all(ismember(rel(:,3),[4 5 6])),'RM:Rotulas','Liberaciones: [barra extremo giroLocal], giroLocal=4,5,6.');
P=d.cargas; A=d.apoyos;
if isempty(P),P=zeros(0,7);end
assert(size(P,2)==7 && all(isfinite(P(:))) && size(A,2)==7 ...
    && all(isfinite(A(:,1))) && all(~isinf(A(:))),'RM:Datos','Cargas y apoyos: nodo seguido de seis componentes.');
K=sparse(6*nn,6*nn); f=zeros(6*nn,1); elem=cell(nb,1);
for j=1:size(P,1)
    a=P(j,1); assert(a==fix(a)&&a>=1&&a<=nn,'RM:Nodo','Nodo de carga invalido.');
    ix=6*(a-1)+(1:6);f(ix)=f(ix)+P(j,2:7)';
end
for i=1:nb
    a=B(i,1);b=B(i,2);vec=X(b,:)-X(a,:);L=norm(vec);
    assert(L>0,'RM:Longitud','Barra de longitud nula.');ex=vec/L;ey=ref(i,:);
    if norm(ey)==0,[~,j]=min(abs(ex));ey=zeros(1,3);ey(j)=1;end
    ey=ey-dot(ey,ex)*ex;
    assert(norm(ey)>1e-10*max(norm(ref(i,:)),1),'RM:Ejes','referenciaY es paralela a la barra.');
    ey=ey/norm(ey);ez=cross(ex,ey);R=[ex;ey;ez];T=blkdiag(R,R,R,R);
    q(i,1:2:5)=q(i,1:2:5)+(R*qg(i,1:2:5)')';
    q(i,2:2:6)=q(i,2:2:6)+(R*qg(i,2:2:6)')';
    k=zeros(12);fl=zeros(12,1);k([1 7],[1 7])=E(i)*F(i)/L*[1 -1;-1 1];
    fl([1 7])=L/6*[2*q(i,1)+q(i,2);q(i,1)+2*q(i,2)]+E(i)*F(i)*e0(i)*[-1;1];
    if vigas(i)
        k([4 10],[4 10])=G(i)*J(i)/L*[1 -1;-1 1];
        fl([4 10])=L/6*[2*q(i,7)+q(i,8);q(i,7)+2*q(i,8)]+G(i)*J(i)*tw(i)*[-1;1];
        z=[2 6 8 12];y=[3 5 9 11];S=diag([1 -1 1 -1]);
        k(z,z)=flexion(E(i)*Iz(i),L);k(y,y)=S*flexion(E(i)*Iy(i),L)*S;
        fl(z)=carga(q(i,3),q(i,4),L)+E(i)*Iz(i)*kap(i,2)*[0;-1;0;1];
        fl(y)=S*carga(q(i,5),q(i,6),L)+E(i)*Iy(i)*kap(i,1)*[0;-1;0;1];
    else
        assert(all(abs(q(i,3:8))<1e-12),'RM:Axial','Una barra axial solo admite carga repartida axial.');
    end
    rr=rel(rel(:,1)==i,:);h=unique(6*(rr(:,2)-1)+rr(:,3))';g=setdiff(1:12,h);H=[];
    kc=k;fc=fl;
    if ~isempty(h)
        kh=k(h,h);scale=sqrt(max(diag(kh),realmin));D=diag(1./scale);
        H=D*pinv(D*kh*D,1e-12)*D;
        rhs=[fl(h) k(h,g)];
        assert(norm(kh*H*rhs-rhs,'fro')<=1e-8*max(norm(rhs,'fro'),1),'RM:Rotulas','Las liberaciones dejan una carga sin rigidez.');
        kc=zeros(12);fc=zeros(12,1);
        kc(g,g)=k(g,g)-k(g,h)*H*k(h,g);fc(g)=fl(g)-k(g,h)*H*fl(h);
        kc=(kc+kc')/2;
    end
    ix=[6*(a-1)+(1:6),6*(b-1)+(1:6)];K(ix,ix)=K(ix,ix)+T'*kc*T;f(ix)=f(ix)+T'*fc;
    elem{i}=struct('L',L,'R',R,'T',T,'k',k,'fl',fl,'ix',ix,'h',h,'g',g,'H',H);
end
indices=[];valores=[];
for j=1:size(A,1)
    a=A(j,1);assert(a>=1&&a<=nn&&a==fix(a),'RM:Nodo','Nodo de apoyo invalido.');
    for c=1:6
        if ~isnan(A(j,c+1)),indices(end+1)=6*(a-1)+c;valores(end+1)=A(j,c+1);end
    end
end
[u,Rnod,info]=rm_equilibrio3d(K,f,indices,valores);
assert(all(mod(info.nulos-1,6)>=3),'RM:Mecanismo','Hay una traslacion sin rigidez; revisa apoyos y conexiones.');
campos=cell(nb,1);U=0;
for i=1:nb
    e=elem{i};L=e.L;v=e.T*u(e.ix);
    if ~isempty(e.h),v(e.h)=e.H*(e.fl(e.h)-e.k(e.h,e.g)*v(e.g));end
    EA=E(i)*F(i);px=q(i,1);bp=(q(i,2)-px)/L;
    N0=EA*((v(7)-v(1))/L-e0(i))+L*(2*px+q(i,2))/6;
    N=[-bp/2 -px N0];pu=[-bp/(6*EA) -px/(2*EA) N0/EA+e0(i) v(1)];
    Mt=0;My=0;Mz=0;Vy=0;Vz=0;phi=[0 v(4)];
    pv=[(v(8)-v(2))/L v(2)];pw=[(v(9)-v(3))/L v(3)];
    if vigas(i)
        GJ=G(i)*J(i);mx=q(i,7);bm=(q(i,8)-mx)/L;
        M0=GJ*((v(10)-v(4))/L-tw(i))+L*(2*mx+q(i,8))/6;
        Mt=[-bm/2 -mx M0];phi=[-bm/(6*GJ) -mx/(2*GJ) M0/GJ+tw(i) v(4)];
        pv=polinomio(v(2),v(6),v(8),v(12),q(i,3),q(i,4),L,E(i)*Iz(i));
        pw=polinomio(v(3),-v(5),v(9),-v(11),q(i,5),q(i,6),L,E(i)*Iy(i));
        Mz=E(i)*Iz(i)*polyder(polyder(pv));Mz(end)=Mz(end)-E(i)*Iz(i)*kap(i,2);
        My=-E(i)*Iy(i)*polyder(polyder(pw));My(end)=My(end)-E(i)*Iy(i)*kap(i,1);
        Vy=-polyder(Mz);Vz=polyder(My);
    end
    acciones=e.k*v-e.fl;
    campos{i}=struct('N',N,'Vy',Vy,'Vz',Vz,'T',Mt,'My',My,'Mz',Mz,'u',pu,'v',pv,'w',pw, ...
        'phi',phi,'L',L,'R',e.R,'local',v,'acciones',acciones,'origen',X(B(i,1),:),'tipo',tipo(i));
    U=U+cuadrado(N,L)/(2*EA);
    if vigas(i),U=U+cuadrado(Mt,L)/(2*G(i)*J(i))+cuadrado(My,L)/(2*E(i)*Iy(i))+cuadrado(Mz,L)/(2*E(i)*Iz(i));end
end
r=struct('u',reshape(u,6,[])','R',reshape(Rnod,6,[])','K',K,'f',f,'campos',{campos}, ...
    'info',info,'energia',U,'datos',d,'E',E,'G',G,'F',F,'Iy',Iy,'Iz',Iz,'J',J, ...
    'qLocal',q,'deformacionLibre',e0,'curvaturaLibre',kap,'giroLibre',tw);
end
function v=cuadrado(p,L)
v=polyval(polyint(conv(p,p)),L);
end
function k=flexion(EI,L)
k=EI/L^3*[12 6*L -12 6*L;6*L 4*L^2 -6*L 2*L^2;-12 -6*L 12 -6*L;6*L 2*L^2 -6*L 4*L^2];
end
function f=carga(a,b,L)
f=[L*(7*a+3*b)/20;L^2*(3*a+2*b)/60;L*(3*a+7*b)/20;-L^2*(2*a+3*b)/60];
end
function p=polinomio(a,da,b,db,q0,q1,L,EI)
beta=(q1-q0)/L;
c=[L^2 L^3;2*L 3*L^2]\[b-a-da*L-q0*L^4/(24*EI)-beta*L^5/(120*EI);db-da-q0*L^3/(6*EI)-beta*L^4/(24*EI)];
p=[beta/(120*EI) q0/(24*EI) c(2) c(1) da a];
end
function v=expandir(v,n)
assert(isnumeric(v)&&isreal(v)&&all(isfinite(v(:))),'RM:Datos','Propiedad no valida.');
if isscalar(v),v=repmat(v,n,1);end
v=v(:);assert(numel(v)==n,'RM:Datos','Se necesita una propiedad por barra.');
end
