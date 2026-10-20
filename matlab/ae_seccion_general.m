function r=ae_seccion_general(d)
assert(ismember(string(d.geometria),["poligonos","pared_delgada"]),'AE:Seccion','Geometria no reconocida.');
assert(all(isfinite([d.N d.Qy d.Qz d.My d.Mz d.T]))&&isreal([d.N d.Qy d.Qz d.My d.Mz d.T]), ...
    'AE:Seccion','Los esfuerzos deben ser escalares reales finitos.');
assert(all(isfinite([d.G d.longitud d.densidad d.limiteTraccion d.limiteCompresion ...
    d.limiteCortante d.limiteEquivalente d.nRequerido]))&&all([d.G d.longitud d.densidad ...
    d.limiteTraccion d.limiteCompresion d.limiteCortante d.limiteEquivalente d.nRequerido]>0), ...
    'AE:Seccion','Propiedades, limites y factor requerido deben ser positivos y finitos.');
assert(ismember(d.teoria,[3 4])&&ismember(string(d.torsion),["no_evaluada","celda_unica"]), ...
    'AE:Seccion','Teoria 3 o 4; torsion no_evaluada o celda_unica.');
if d.geometria=="poligonos"
    g=rm_seccion(d.contornos,d.signos);p=g.vertices;
else
    g=rm_pared(d.segmentos);p=[d.segmentos(:,1:2);d.segmentos(:,3:4)];
end
A=[g.Iz g.Iyz;g.Iyz g.Iy];
assert(rcond(A)>1e-12,'AE:Seccion','La seccion no tiene dos inercias de flexion independientes.');
c=A\[-d.Mz;d.My];sigma=d.N/g.F+(p-g.centro)*c;
tau=zeros(size(sigma));J=NaN;Am=NaN;q=NaN;giro=NaN;torsionEvaluada=d.T==0;
if d.torsion=="celda_unica"
    assert(d.geometria=="pared_delgada",'AE:Seccion','Celda unica requiere segmentos de linea media.');
    S=d.segmentos;nb=size(S,1);escala=max(max(S(:,1:4))-min(S(:,1:4)));
    assert(nb>=3&&escala>0,'AE:Seccion','Se necesitan al menos tres paredes.');
    assert(all(vecnorm(S(:,3:4)-S([2:end 1],1:2),2,2)<=1e-9*escala), ...
        'AE:Seccion','Ordena las paredes consecutivamente y cierra el contorno.');
    validarCruces(S,escala);
    L=vecnorm(S(:,3:4)-S(:,1:2),2,2);Am=polyarea(S(:,1),S(:,2));
    assert(Am>1e-10*escala^2,'AE:Seccion','El area de la linea media es nula.');
    J=4*Am^2/sum(L./S(:,5));q=d.T/(2*Am);
    tau=[q./S(:,5);q./S(:,5)];giro=d.T*d.longitud/(d.G*J);torsionEvaluada=true;
end
sigmaT=max([sigma;0]);sigmaC=max([-sigma;0]);tauMax=max(abs(tau));
nNormal=min(razon(d.limiteTraccion,sigmaT),razon(d.limiteCompresion,sigmaC));
nTau=razon(d.limiteCortante,tauMax);
if d.teoria==3,equivalente=sqrt(sigma.^2+4*tau.^2);else,equivalente=sqrt(sigma.^2+3*tau.^2);end
nEq=razon(d.limiteEquivalente,max(equivalente));n=min([nNormal nTau nEq]);
completa=torsionEvaluada&&d.Qy==0&&d.Qz==0;
estado="Cumple";if n<d.nRequerido,estado="No cumple";elseif ~completa,estado="Parcial";end
r=struct('geometria',g,'puntos',p,'sigma',sigma,'tau',tau,'equivalente',equivalente, ...
    'coef',c,'sigmaMin',min(sigma),'sigmaMax',max(sigma),'F',g.F,'J',J,'areaMedia',Am,'flujoTorsion',q, ...
    'giro',giro,'masa',d.densidad*g.F*d.longitud,'factor',n,'nNormal',nNormal,'nCortante',nTau, ...
    'nEquivalente',nEq,'completa',completa,'estado',estado,'cumple',completa&&n>=d.nRequerido);
r.tabla=table(["Traccion";"Compresion";"Cortante torsional";"Equivalente"], ...
    [sigmaT;sigmaC;tauMax;max(equivalente)]/1e6, ...
    [d.limiteTraccion;d.limiteCompresion;d.limiteCortante;d.limiteEquivalente]/1e6, ...
    [razon(d.limiteTraccion,sigmaT);razon(d.limiteCompresion,sigmaC);nTau;nEq], ...
    'VariableNames',{'Comprobacion','Demanda_MPa','Limite_MPa','Factor'});
disp(r.tabla);disp("Estado: "+estado);disp("Masa prismatica [kg]: "+r.masa);
if ~completa,disp('No se ha evaluado el cortante transversal, el centro de cortante o la torsion de una seccion abierta.');end
[~,ax]=rm_figura(3,'Seccion general: geometria y tensiones');hold(ax(1),'on');
if d.geometria=="poligonos"
    tr=triangulation(g.region);v=tr.Points;ss=d.N/g.F+(v-g.centro)*c;
    patch(ax(1),'Faces',tr.ConnectivityList,'Vertices',v,'FaceVertexCData',ss/1e6, ...
        'FaceColor','interp','EdgeColor',[.3 .3 .3]);colorbar(ax(1));
    title(ax(1),'Seccion local y centroide; color = \sigma_x [MPa]');
else
    S=d.segmentos;
    for j=1:size(S,1)
        plot(ax(1),S(j,[1 3]),S(j,[2 4]),'k-','LineWidth',2);
        text(ax(1),mean(S(j,[1 3])),mean(S(j,[2 4])),sprintf(' %d',j));
    end
    title(ax(1),'Lineas medias, numeros de pared y centroide');
end
plot(ax(1),g.centro(1),g.centro(2),'r+','MarkerSize',9);axis(ax(1),'equal');
xlabel(ax(1),'y [m]');ylabel(ax(1),'z [m]');
rm_curva(ax(2),1:numel(sigma),sigma/1e6,'\sigma_x [MPa]',false);xlabel(ax(2),'Punto de contorno');
rm_curva(ax(3),1:numel(equivalente),equivalente/1e6,'\sigma_{eq} [MPa]',false);xlabel(ax(3),'Punto de contorno');
if d.torsion=="celda_unica"
    [~,ax]=rm_figura(2,'Celda cerrada: flujo de torsion y cortante');
    bar(ax(1),q+zeros(size(S,1),1));ylabel(ax(1),'q_T [N/m]');xlabel(ax(1),'Pared');
    bar(ax(2),q./S(:,5)/1e6);ylabel(ax(2),'\tau_T [MPa]');xlabel(ax(2),'Pared');
end
end
function n=razon(limite,demanda),if demanda==0,n=Inf;else,n=limite/demanda;end;end
function validarCruces(S,L)
n=size(S,1);tol=1e-12*L^2;
for i=1:n
    a=S(i,1:2);b=S(i,3:4);
    for j=i+1:n
        if j==i+1||(i==1&&j==n),continue;end
        c=S(j,1:2);d=S(j,3:4);
        o=[cruz(b-a,c-a),cruz(b-a,d-a),cruz(d-c,a-c),cruz(d-c,b-c)];
        caja=all(max(min([a;b]),min([c;d]))<=min(max([a;b]),max([c;d]))+1e-10*L);
        cruza=(o(1)*o(2)<=tol^2)&&(o(3)*o(4)<=tol^2)&&caja;
        assert(~cruza,'AE:Seccion','El contorno se cruza o contiene paredes superpuestas.');
    end
end
end
function v=cruz(a,b),v=a(1)*b(2)-a(2)*b(1);end
