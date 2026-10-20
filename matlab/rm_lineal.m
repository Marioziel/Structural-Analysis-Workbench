function [u,R,info]=rm_lineal(K,f,indices,valores)
% Equilibrio lineal con desplazamientos prescritos. No añade apoyos fisicos.
n=numel(f); f=f(:); indices=indices(:); valores=valores(:);
assert(isequal(size(K),[n n]) && all(isfinite(nonzeros(K))) && all(isfinite(f)), ...
    'RM:Sistema','Dimensiones o valores no validos en el sistema.');
assert(numel(indices)==numel(valores) && numel(unique(indices))==numel(indices) ...
    && all(indices>=1 & indices<=n & indices==fix(indices)) && all(isfinite(valores)), ...
    'RM:Apoyos','Restricciones repetidas o invalidas.');
libres=setdiff((1:n)',indices); u=zeros(n,1); u(indices)=valores;
% Rotaciones sin ninguna rigidez, por ejemplo en extremos liberados.
nulos=libres(full(max(abs(K(libres,:)),[],2))==0);
assert(all(abs(f(nulos))==0),'RM:Mecanismo','Hay una carga en un grado sin rigidez.');
libres=setdiff(libres,nulos);
if ~isempty(libres)
    A=K(libres,libres); b=f(libres)-K(libres,indices)*valores;
    assert(all(diag(A)>0),'RM:Inestable','Rigidez no positiva: sistema inestable.');
    s=1./sqrt(diag(A)); D=spdiags(s,0,numel(s),numel(s)); B=D*A*D;
    assert(rcond(full(B))>1e-12,'RM:Mecanismo', ...
        'La estructura tiene un mecanismo o restricciones insuficientes.');
    u(libres)=s.*(B\(s.*b));
end
R=K*u-f;
esc=max([norm(f,inf),norm(K*u,inf),realmin]);
assert(norm(R(libres),inf)<=1e-7*esc,'RM:Equilibrio','Residuo excesivo en nodos libres.');
info=struct('libres',libres,'prescritos',indices,'nulos',nulos, ...
    'residuo',norm(R(libres),inf),'energia',.5*u'*K*u);
end
