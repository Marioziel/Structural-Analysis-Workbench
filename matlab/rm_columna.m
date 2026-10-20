function r=rm_columna(L,E,I,n,apoyos,P,cargas)
% Discretizacion energetica Euler-Bernoulli y rigidez geometrica para P constante.
assert(isscalar(L)&&L>0 && E>0 && I>0 && n>=2 && n==fix(n) && P>=0, ...
    'RM:Columna','Geometria, material, malla o compresion no validos.');
nn=n+1; x=linspace(0,L,nn)'; h=L/n; K=sparse(2*nn,2*nn); G=K;
k=E*I/h^3*[12 6*h -12 6*h;6*h 4*h^2 -6*h 2*h^2; ...
    -12 -6*h 12 -6*h;6*h 2*h^2 -6*h 4*h^2];
g=1/(30*h)*[36 3*h -36 3*h;3*h 4*h^2 -3*h -h^2; ...
    -36 -3*h 36 -3*h;3*h -h^2 -3*h 4*h^2];
for j=1:n
    ix=2*(j-1)+(1:4); K(ix,ix)=K(ix,ix)+k; G(ix,ix)=G(ix,ix)+g;
end
switch string(apoyos)
    case "articulada_articulada", fijos=[1 2*nn-1]; mu=1;
    case "empotrada_libre", fijos=[1 2]; mu=2;
    case "empotrada_empotrada", fijos=[1 2 2*nn-1 2*nn]; mu=.5;
    case "empotrada_articulada", fijos=[1 2 2*nn-1]; mu=.69915566;
    otherwise, error('RM:Columna','Condiciones de extremo desconocidas.');
end
libres=setdiff(1:2*nn,fijos);
[V,D]=eig(full(K(libres,libres)),full(G(libres,libres)));
val=real(diag(D)); valid=isfinite(val)&val>0; ids=find(valid); [pcr,j]=min(val(valid));
modo=zeros(2*nn,1); modo(libres)=real(V(:,ids(j)));
modo=modo/max(abs(modo(1:2:end)));
f=zeros(2*nn,1);
assert(isempty(cargas)||(size(cargas,2)==2&&all(isfinite(cargas(:)))&&all(cargas(:,1)>=0&cargas(:,1)<=L)), ...
    'RM:Columna','Cargas [posicion fuerza], con posicion entre 0 y L.');
for j=1:size(cargas,1)
    i=min(floor(cargas(j,1)/h)+1,n);xi=(cargas(j,1)-x(i))/h;
    forma=[1-3*xi^2+2*xi^3;h*(xi-2*xi^2+xi^3);3*xi^2-2*xi^3;h*(-xi^2+xi^3)];
    ix=2*(i-1)+(1:4);f(ix)=f(ix)+forma*cargas(j,2);
end
assert(P<pcr*(1-1e-8),'RM:Inestable','P alcanza la carga critica; no hay solucion estable linealizada.');
[u,~,info]=rm_lineal(K-P*G,f,fijos,zeros(size(fijos)));
r=struct('x',x,'u',u(1:2:end),'theta',u(2:2:end),'modo',modo(1:2:end), ...
    'Pcritica',pcr,'PEuler',pi^2*E*I/(mu*L)^2,'margen',pcr/max(P,realmin), ...
    'info',info,'K',K,'G',G);
end
