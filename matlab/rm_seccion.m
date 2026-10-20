function s=rm_seccion(contornos,signos)
% Propiedades exactas de contornos poligonales sin solapamientos.
assert(iscell(contornos) && numel(contornos)==numel(signos) && all(abs(signos)==1), ...
    'RM:Seccion','Contornos: celda de poligonos; signos: +1 material, -1 hueco.');
A=0; Qy=0; Qz=0; Iy0=0; Iz0=0; Iyz0=0; region=polyshape; vertices=[];
for i=1:numel(contornos)
    p=contornos{i};
    assert(size(p,2)==2 && size(p,1)>=3 && isreal(p) && all(isfinite(p(:))), ...
        'RM:Seccion','Cada contorno necesita vertices [y z].');
    if isequal(p(1,:),p(end,:)), p=p(1:end-1,:); end
    y=p(:,1); z=p(:,2); j=[2:numel(y) 1]; c=y.*z(j)-y(j).*z;
    if sum(c)<0, p=flipud(p); y=p(:,1); z=p(:,2); c=y.*z(j)-y(j).*z; end
    a=sum(c)/2; assert(a>0,'RM:Seccion','Contorno degenerado.');
    sg=signos(i); A=A+sg*a;
    Qy=Qy+sg*sum((y+y(j)).*c)/6; Qz=Qz+sg*sum((z+z(j)).*c)/6;
    Iz0=Iz0+sg*sum((y.^2+y.*y(j)+y(j).^2).*c)/12;
    Iy0=Iy0+sg*sum((z.^2+z.*z(j)+z(j).^2).*c)/12;
    Iyz0=Iyz0+sg*sum((2*y.*z+y.*z(j)+y(j).*z+2*y(j).*z(j)).*c)/24;
    vertices=[vertices;p];
    if sg>0, region=union(region,polyshape(p(:,1),p(:,2),'Simplify',false)); end
end
for i=reshape(find(signos<0),1,[])
    p=contornos{i}; region=subtract(region,polyshape(p(:,1),p(:,2),'Simplify',false));
end
assert(A>0 && abs(area(region)-A)<1e-8*A,'RM:Seccion', ...
    'Hay solapamientos, huecos fuera del material o contornos invalidos.');
yc=Qy/A; zc=Qz/A; Iy=Iy0-A*zc^2; Iz=Iz0-A*yc^2; Iyz=Iyz0-A*yc*zc;
J=[Iy -Iyz;-Iyz Iz]; [V,D]=eig(J); [principales,ix]=sort(diag(D),'descend');
assert(all(principales>0),'RM:Seccion','La seccion no tiene inercia positiva.');
s=struct('F',A,'centro',[yc zc],'Iy',Iy,'Iz',Iz,'Iyz',Iyz, ...
    'Jp',Iy+Iz,'principales',principales,'direcciones',V(:,ix), ...
    'radios',sqrt(principales/A),'region',region,'vertices',vertices);
end
