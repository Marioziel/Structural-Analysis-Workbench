function [u,R,info]=rm_equilibrio3d(K,f,indices,valores)
% Elimina exclusivamente giros sin rigidez; no elimina mecanismos de traslacion.
try
    [u,R,info]=rm_lineal(K,f,indices,valores);info.girosReferencia=[];return
catch ex
    if ~strcmp(ex.identifier,'RM:Mecanismo'),rethrow(ex);end
end
libres=setdiff((1:numel(f))',indices(:));
libres=libres(full(max(abs(K(libres,:)),[],2))~=0);
A=K(libres,libres);diagA=full(diag(A));
if isempty(A)||any(diagA<=0),rethrow(ex);end
D=diag(1./sqrt(diagA));S=D*full(A)*D;
[V,L]=eig((S+S')/2);lambda=diag(L);tol=1e-10*max(abs(lambda));
if any(lambda < -tol),rethrow(ex);end
Z=D*V(:,abs(lambda)<=tol);
if isempty(Z),rethrow(ex);end
traslaciones=mod(libres-1,6)<3;
if norm(Z(traslaciones,:),'fro')>1e-8*norm(Z,'fro'),rethrow(ex);end
b=f(libres)-K(libres,indices)*valores(:);
assert(norm(Z'*b)<=1e-9*max(norm(Z,'fro')*norm(b),1), ...
    'RM:Mecanismo','Existe un par aplicado en un giro liberado sin rigidez.');
candidatos=find(~traslaciones);[~,~,perm]=qr(Z(candidatos,:)','vector');
giros=libres(candidatos(perm(1:size(Z,2))));
[u,R,info]=rm_lineal(K,f,[indices(:);giros(:)],[valores(:);zeros(numel(giros),1)]);
assert(norm(R(giros),inf)<=1e-7*max(norm(f,inf),1),'RM:Mecanismo','Un giro de referencia produce una reaccion no nula.');
info.girosReferencia=giros;
end
