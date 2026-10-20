function e=ae_equilibrio_solido(modelo,u)
A=assembleFEMatrices(modelo,'KFGH');
n=size(modelo.Mesh.Nodes,2);
assert(isequal(size(u),[n 3]),'AE:Equilibrio','Desplazamientos: una fila [ux uy uz] por nodo.');
f=A.F+A.G;residuo=A.K*u(:)-f;
restringidos=full(any(A.H~=0,1))';
nodales=zeros(3*n,1);nodales(restringidos)=residuo(restringidos);
rn=reshape(nodales,n,3);fn=reshape(full(f),n,3);x=modelo.Mesh.Nodes';
reaccion=sum(rn,1);fuerza=sum(fn,1);
momentoR=sum(cross(x,rn,2),1);momentoF=sum(cross(x,fn,2),1);
e=struct('metodo',"Reacciones nodales: K*u-f en grados restringidos", ...
    'reaccion',reaccion,'fuerzaAplicada',fuerza,'residuoFuerzas',reaccion+fuerza, ...
    'momentoReacciones',momentoR,'momentoAplicado',momentoF, ...
    'residuoMomentos',momentoR+momentoF, ...
    'residuoLibreMax',norm(residuo(~restringidos),inf), ...
    'errorRelativoFuerzas',norm(reaccion+fuerza)/max(norm(fuerza),1));
end
