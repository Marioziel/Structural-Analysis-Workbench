function r=rm_tirantes_rigidos(posiciones,L,F,E,d0,P,posicionCarga)
if isvector(posiciones),x=posiciones(:);XY=[x zeros(size(x))];B=[ones(size(x)) x];pc=posicionCarga(1);
else
    assert(size(posiciones,2)==2,'RM:Tirantes','Posiciones: vector x o filas [x y].');
    XY=posiciones;x=XY(:,1);B=[ones(size(x)) XY];pc=posicionCarga(:);
    assert(numel(pc)==2,'RM:Tirantes','Una plataforma requiere posicionCarga=[x y].');
end
n=numel(x);L=L(:);F=F(:);d0=d0(:);if isscalar(E),E=repmat(E,n,1);end;E=E(:);
assert(numel(L)==n&&numel(F)==n&&numel(d0)==n&&numel(E)==n ...
    && all(L>0&F>0&E>0)&&all(isfinite([XY(:);L;F;E;d0;P;pc(:)])) ...
    && rank(B)==size(B,2),'RM:Tirantes','Datos incompatibles o apoyos geometricamente insuficientes.');
k=E.*F./L;f=P*[1;pc(:)]+B'*(k.*d0);K=B'*(k.*B);
[u,~,info]=rm_lineal(K,f,[],[]);delta=B*u;N=k.*(delta-d0);res=B'*N-P*[1;pc(:)];
r=struct('movimientos',u,'delta',delta,'N',N,'sigma',N./F,'residuo',res,'XY',XY,'L',L,'info',info);
end
