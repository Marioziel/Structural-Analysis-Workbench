function r=rm_columna3d(L,E,inercia,n,extremos,P,cargas)
if isscalar(inercia),inercia=[inercia inercia];end
assert(numel(inercia)==2 && all(inercia>0),'RM:Columna','inercia=[Iy Iz], o un escalar para ambas.');
if isempty(cargas),cargas=zeros(0,3);end
assert(size(cargas,2)==3,'RM:Columna','Cargas laterales: [x FY FZ].');
y=rm_columna(L,E,inercia(2),n,extremos,P,cargas(:,[1 2]));
z=rm_columna(L,E,inercia(1),n,extremos,P,cargas(:,[1 3]));
[pcr,eje]=min([y.Pcritica z.Pcritica]);modo=zeros(numel(y.x),2);
if eje==1,modo(:,1)=y.modo;else,modo(:,2)=z.modo;end
r=struct('x',y.x,'u',[y.u z.u],'modo',modo,'Pcritica',pcr,'PEuler',min(y.PEuler,z.PEuler), ...
    'margen',pcr/max(P,realmin),'ejeCritico',eje,'planoY',y,'planoZ',z);
end
