function s=rm_pared(segmentos)
% Propiedades de lineas medias de pared delgada. Omite terminos de orden t^3.
assert(size(segmentos,2)==5 && all(isfinite(segmentos(:))) && all(segmentos(:,5)>0), ...
    'RM:Pared','Cada fila: [yi zi yf zf espesor].');
v=segmentos(:,3:4)-segmentos(:,1:2); L=sqrt(sum(v.^2,2));
assert(all(L>0),'RM:Pared','Un segmento tiene longitud nula.');
a=L.*segmentos(:,5); centros=(segmentos(:,1:2)+segmentos(:,3:4))/2;
A=sum(a); c=sum(a.*centros,1)/A; dc=centros-c;
Iz=sum(a.*(dc(:,1).^2+v(:,1).^2/12));
Iy=sum(a.*(dc(:,2).^2+v(:,2).^2/12));
Iyz=sum(a.*(dc(:,1).*dc(:,2)+v(:,1).*v(:,2)/12));
[V,D]=eig([Iy -Iyz;-Iyz Iz]); [p,j]=sort(diag(D),'descend');
s=struct('F',A,'centro',c,'Iy',Iy,'Iz',Iz,'Iyz',Iyz,'Jp',Iy+Iz, ...
    'principales',p,'direcciones',V(:,j),'radios',sqrt(p/A));
end
