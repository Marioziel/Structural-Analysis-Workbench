function r=rm_viga(d)
% Viga recta con cortes automaticos para fuerzas, pares, q y apoyos.
x=d.x(:); assert(numel(x)>=2 && all(diff(x)>0),'RM:Viga','x debe ser creciente.');
n=numel(x)-1; E=expandir(d.E,n); I=expandir(d.I,n); F=expandir(d.F,n);
P=d.puntuales; Q=d.distribuidas; A=d.apoyos;
if isempty(P), P=zeros(0,3); end
if isempty(Q), Q=zeros(0,4); end
assert(size(P,2)==3 && size(Q,2)==4 && size(A,2)==3, ...
    'RM:Viga','P: [x Fy M], q: [xi xf qi qf], apoyos: [x v theta].');
assert(all(Q(:,2)>Q(:,1)),'RM:Viga','Una carga distribuida tiene limites invalidos.');
pos=[P(:,1);Q(:,1);Q(:,2);A(:,1)];
assert(all(pos>=x(1)&pos<=x(end)),'RM:Viga','Dato fuera de la viga.');
xx=unique([x;pos]); ne=numel(xx)-1;
g=struct('nodos',[xx zeros(size(xx))],'barras',[(1:ne)' (2:ne+1)'], ...
    'E',zeros(ne,1),'F',zeros(ne,1),'I',zeros(ne,1),'q',zeros(ne,4), ...
    'cargas',zeros(size(P,1),4),'apoyos',[(1:ne+1)' zeros(ne+1,1) nan(ne+1,2)]);
for i=1:ne
    mid=mean(xx(i:i+1)); j=find(x<=mid,1,'last');
    g.E(i)=E(j); g.F(i)=F(j); g.I(i)=I(j);
    for k=1:size(Q,1)
        if mid>Q(k,1) && mid<Q(k,2)
            q=Q(k,3)+(Q(k,4)-Q(k,3))*([xx(i) xx(i+1)]-Q(k,1))/(Q(k,2)-Q(k,1));
            g.q(i,3:4)=g.q(i,3:4)+q;
        end
    end
end
for j=1:size(P,1), g.cargas(j,:)=[find(xx==P(j,1),1) 0 P(j,2:3)]; end
for j=1:size(A,1)
    k=find(xx==A(j,1),1);
    assert(all(isnan(g.apoyos(k,3:4))),'RM:Viga','No repitas apoyos en x.');
    g.apoyos(k,3:4)=A(j,2:3);
end
r=rm_marco(g); r.x=xx;
end
function v=expandir(v,n)
if isscalar(v), v=repmat(v,n,1); end
v=v(:); assert(numel(v)==n && all(isfinite(v)&v>0),'RM:Viga','Propiedad invalida.');
end
