function r=rm_cercha(d)
% Cercha plana o espacial: nodos, barras, E, F, cargas y apoyos.
X=d.nodos; B=d.barras; dim=size(X,2); nn=size(X,1); nb=size(B,1);
assert(ismember(dim,[2 3]) && all(isfinite(X(:))) && size(B,2)==2 ...
    && all(B(:)>=1 & B(:)<=nn & B(:)==fix(B(:))), 'RM:Datos','Nodos o barras invalidos.');
E=expandir(d.E,nb); F=expandir(d.F,nb);
assert(all(E>0 & F>0),'RM:Material','E y F deben ser positivos.');
e0=zeros(nb,1); if isfield(d,'deformacionLibre'), e0=expandir(d.deformacionLibre,nb); end
K=sparse(dim*nn,dim*nn); f=zeros(dim*nn,1); L=zeros(nb,1); dir=zeros(nb,dim);
assert(size(d.cargas,2)==dim+1 && size(d.apoyos,2)==dim+1, ...
    'RM:Datos','Cargas y apoyos necesitan nodo seguido de componentes.');
for j=1:size(d.cargas,1)
    i=d.cargas(j,1); assert(i>=1 && i<=nn && i==fix(i),'RM:Nodo','Nodo de carga invalido.');
    ix=dim*(i-1)+(1:dim); f(ix)=f(ix)+d.cargas(j,2:end)';
end
for i=1:nb
    a=B(i,1); b=B(i,2); v=X(b,:)-X(a,:); L(i)=norm(v);
    assert(L(i)>0,'RM:Longitud','Una barra tiene longitud nula.');
    dir(i,:)=v/L(i); c=[-dir(i,:) dir(i,:)];
    ix=[dim*(a-1)+(1:dim),dim*(b-1)+(1:dim)];
    K(ix,ix)=K(ix,ix)+(E(i)*F(i)/L(i))*(c'*c);
    f(ix)=f(ix)+E(i)*F(i)*e0(i)*c';
end
indices=[]; valores=[];
for j=1:size(d.apoyos,1)
    a=d.apoyos(j,1); assert(a>=1 && a<=nn && a==fix(a),'RM:Nodo','Nodo de apoyo invalido.');
    for k=1:dim
        if ~isnan(d.apoyos(j,k+1))
            indices(end+1)=dim*(a-1)+k; valores(end+1)=d.apoyos(j,k+1);
        end
    end
end
[u,R,info]=rm_lineal(K,f,indices,valores);
assert(isempty(info.nulos),'RM:Mecanismo','Hay una traslacion libre sin rigidez; revisa conexiones y apoyos.');
N=zeros(nb,1);
for i=1:nb
    a=B(i,1); b=B(i,2); ix=[dim*(a-1)+(1:dim),dim*(b-1)+(1:dim)];
    N(i)=E(i)*F(i)*(([-dir(i,:) dir(i,:)]*u(ix))/L(i)-e0(i));
end
r=struct('u',reshape(u,dim,[])','R',reshape(R,dim,[])','N',N, ...
    'sigma',N./F,'L',L,'K',K,'f',f,'info',info,'datos',d);
r.tabla=table((1:nb)',L,N/1000,r.sigma/1e6, ...
    'VariableNames',{'Barra','Longitud_m','N_kN','sigma_MPa'});
end
function v=expandir(v,n)
assert(isnumeric(v) && isreal(v) && all(isfinite(v(:))),'RM:Datos','Propiedad no valida.');
if isscalar(v), v=repmat(v,n,1); end
v=v(:); assert(numel(v)==n,'RM:Datos','Se necesita un valor por barra.');
end
