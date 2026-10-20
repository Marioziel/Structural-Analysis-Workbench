function COMPROBAR_ESPACIAL
addpath(fileparts(mfilename('fullpath')));
global RM3D_TEST;RM3D_TEST={};
E=210e9;G=80e9;F=.003;Iy=5e-6;Iz=8e-6;J=12e-6;L=2;
d=struct('nodos',[0 0 0;L 0 0],'barras',[1 2],'E',E,'G',G,'F',F,'Iy',Iy,'Iz',Iz,'J',J, ...
    'cargas',[2 1000 2000 -3000 400 500 -600],'apoyos',[1 zeros(1,6)]);
r=rm_marco3d(d);P=d.cargas(2:end);
u=[P(1)*L/E/F,P(2)*L^3/(3*E*Iz)+P(6)*L^2/(2*E*Iz), ...
    P(3)*L^3/(3*E*Iy)-P(5)*L^2/(2*E*Iy),P(4)*L/G/J, ...
    -P(3)*L^2/(2*E*Iy)+P(5)*L/(E*Iy),P(2)*L^2/(2*E*Iz)+P(6)*L/(E*Iz)];
cerca(r.u(2,:),u,1e-12,'Voladizo: seis desplazamientos y giros');
a=r.campos{1};s=linspace(0,L,41);
cerca(polyval(a.N,s),P(1)*ones(size(s)),1e-10,'Voladizo: N');
cerca(polyval(a.Vy,s),P(2)*ones(size(s)),1e-10,'Voladizo: Qy');
cerca(polyval(a.Vz,s),P(3)*ones(size(s)),1e-10,'Voladizo: Qz');
cerca(polyval(a.T,s),P(4)*ones(size(s)),1e-10,'Voladizo: torsion');
cerca(polyval(a.My,s),P(5)-P(3)*(L-s),1e-10,'Voladizo: My');
cerca(polyval(a.Mz,s),P(6)+P(2)*(L-s),1e-10,'Voladizo: Mz');
cerca(r.energia,.5*P*r.u(2,:)',2e-6,'Voladizo: energia y trabajo');
Q=orth([1 2 3;3 -2 1;1 1 -1]);if det(Q)<0,Q(:,3)=-Q(:,3);end
dr=d;dr.nodos=d.nodos*Q';dr.cargas=[2 P(1:3)*Q' P(4:6)*Q'];dr.referenciaY=[0 1 0]*Q';rr=rm_marco3d(dr);
cerca(rr.u(2,:),[u(1:3)*Q' u(4:6)*Q'],1e-11,'Invariancia ante rotacion espacial');
cerca(rr.energia,r.energia,1e-9,'Energia invariante ante rotacion');
d.cargas=[2 zeros(1,6)];d.qGlobal=[100 200 -300 -500 -600 -900];r=rm_marco3d(d);
for j=1:3
    q0=d.qGlobal(2*j-1);q1=d.qGlobal(2*j);
    if j==1,cerca(r.u(2,j),L^2*(q0+2*q1)/(6*E*F),1e-12,'Carga axial lineal: desplazamiento');
    else
        if j==2,II=Iz;else,II=Iy;end
        cerca(r.u(2,j),L^4*(4*q0+11*q1)/(120*E*II),1e-12,"Carga lateral lineal: componente "+j);
    end
end
d.qGlobal=zeros(1,6);d.deformacionLibre=2e-4;d.giroLibre=1e-3;d.curvaturaLibre=[2e-3 -3e-3];r=rm_marco3d(d);
cerca(r.u(2,:),[2e-4*L -3e-3*L^2/2 -2e-3*L^2/2 1e-3*L 2e-3*L -3e-3*L],1e-12,'Deformaciones libres en cuatro modos');
cerca(norm(r.R),0,1e-6,'Deformaciones libres sin reacciones');
d=rmfield(d,{'deformacionLibre','giroLibre','curvaturaLibre'});
d.apoyos=[1 zeros(1,6);2 zeros(1,6)];d.deformacionLibre=1e-4;r=rm_marco3d(d);
cerca(polyval(r.campos{1}.N,0),-E*F*1e-4,1e-12,'Dilatacion impedida');
d=rmfield(d,'deformacionLibre');d.apoyos=[1 0 0 0 NaN NaN NaN;2 NaN 0 0 NaN NaN NaN];
d.liberaciones=[1 1 5;1 1 6;1 2 5;1 2 6];d.qGlobal=[0 0 -1000 -1000 0 0];
d.apoyos(1,5)=0;r=rm_marco3d(d);
cerca(polyval(r.campos{1}.v,L/2),-5*1000*L^4/(384*E*Iz),1e-12,'Rotulas: viga simplemente apoyada');
cerca(r.campos{1}.acciones([5 6 11 12]),zeros(4,1),1e-7,'Rotulas: momentos liberados nulos');
d.liberaciones=[d.liberaciones;1 1 4;1 2 4];r=rm_marco3d(d);cerca(polyval(r.campos{1}.T,0),0,1e-7,'Torsion liberada en ambos extremos');
dr=d;dr.nodos=d.nodos*Q';dr.referenciaY=[0 1 0]*Q';
dr.qGlobal=reshape(([0 -1000 0;0 -1000 0]*Q')',1,[]);
dr.qGlobal=[dr.qGlobal([1 4]) dr.qGlobal([2 5]) dr.qGlobal([3 6])];
dr.apoyos=[1 0 0 0 NaN NaN NaN;2 0 0 0 NaN NaN NaN];rr=rm_marco3d(dr);
cerca(polyval(rr.campos{1}.v,L/2),-5*1000*L^4/(384*E*Iz),1e-12,'Rotulas espaciales inclinadas: giros sin rigidez');
cerca(norm(rr.campos{1}.acciones([4:6 10:12])),0,1e-7,'Rotulas espaciales inclinadas: ningun momento espurio');
falla(@()rm_marco3d(rmfield(d,'apoyos')),'Faltan apoyos: datos rechazados');
d.liberaciones=zeros(0,3);d.qGlobal=zeros(1,6);d.tipo="axial";d.cargas=[2 1000 0 0 0 0 0];
d.apoyos=[1 0 0 0 NaN NaN NaN;2 NaN 0 0 NaN NaN NaN];r=rm_marco3d(d);
cerca(r.u(2,1),1000*L/(E*F),1e-12,'Elemento axial en estructura espacial');
d.apoyos=[1 0 0 0 NaN NaN NaN];falla(@()rm_marco3d(d),'Mecanismo traslacional rechazado');
d.tipo="viga";d.apoyos=[1 zeros(1,6)];d.cargas=[2 0 -1000 200 40 0 0];d.qGlobal=[0 0 20 30 -50 -100];
for c=1:6
    r=rm_mohr3d(d,[2 c]);cerca(r.deltaMohr,r.deltaNodal,2e-9,"Integral Mohr: componente "+c);
end
d.apoyos=[1 1e-4 -2e-4 3e-4 1e-4 2e-4 -1e-4];r=rm_mohr3d(d,[2 3]);
cerca(r.deltaMohr,r.deltaNodal,2e-9,'Mohr con movimientos de apoyo');
d.deformacionLibre=1e-4;d.giroLibre=2e-4;d.curvaturaLibre=[1e-4 -2e-4];r=rm_mohr3d(d,[2 2]);
cerca(r.deltaMohr,r.deltaNodal,2e-9,'Mohr con deformaciones libres');
E=210e9;nu=.3;G=E/(2*(1+nu));P=150;l=.3;
d=struct('nodos',[0 0 0;2*l 0 0;2*l 0 l],'barras',[1 2;2 3], ...
    'E',E,'G',G,'cargas',[3 0 -3*P -P 0 0 0],'apoyos',[1 zeros(1,6)]);
c=struct('D',.03,'di',0,'nu',nu,'limiteTraccion',160e6,'limiteCompresion',160e6, ...
    'teoria',4,'nRequerido',1,'puntosLongitud',241,'considerarCortante',false);
r=rm_resistencia_marco3d(d,c);a=r.marco.campos{1};
cerca(abs(polyval(a.My,0)),2*P*l,1e-10,'Control acodado: My=2Pl');
cerca(abs(polyval(a.Mz,0)),6*P*l,1e-10,'Control acodado: Mz=6Pl');
cerca(abs(polyval(a.T,0)),3*P*l,1e-10,'Control acodado: Mx=3Pl');
Meq=sqrt(6^2+2^2+.75*3^2)*P*l;W=pi*c.D^3/32;
cerca(max(r.maximos(:,4)),Meq/W,1e-10,'Control acodado: equivalente IV');
for teoria=2:4
    c.teoria=teoria;r=rm_dimensionar_marco3d(d,c,[.015 .08]);
    if teoria==2,coef=(1-nu)*sqrt(40)/2+(1+nu)*7/2;
    elseif teoria==3,coef=7;else,coef=sqrt(46.75);end
    esperado=(32*coef*P*l/(pi*c.limiteTraccion))^(1/3);
    cerca(r.diametroElegido,esperado,1e-10,"Dimensionamiento de control: teoria "+teoria);
    cerca(r.factor,1,1e-9,"Factor en diametro elegido: teoria "+teoria);
    assert(r.cumple);registrar("Criterio de cumplimiento: teoria "+teoria);
end
c.teoria=4;c.considerarCortante=true;rr=rm_dimensionar_marco3d(d,c,[.015 .08]);
assert(rr.diametroElegido>=esperado);registrar('Cota de cortante: diametro no menor que nominal');
c.espesor=.002;c.D=.04;r=rm_resistencia_marco3d(d,c);
cerca(r.di,.036*ones(2,1),1e-12,'Tubo: espesor constante');
c.di=.02;c.espesor=[];r=rm_resistencia_marco3d(d,c);
cerca(r.marco.F,pi*(c.D^2-c.di^2)/4*ones(2,1),1e-12,'Tubo: area e inercias en equilibrio');
b=rm_circular_combinada(0,1000,0,0,0,0,.04,0,.3,1);
cerca(b.tauQ,4*1000/(3*b.F),1e-12,'Cortante circular macizo: 4Q/3F');
cerca(b.envolvente(4),sqrt(3)*b.tauQ,1e-12,'Cota von Mises para cortante');
c.considerarCortante=false;c.D=.002;c.di=0;r=rm_resistencia_marco3d(d,c);
assert(~r.cortanteValidado&&~r.cumple);registrar('No se declara cumplimiento si se omite cortante importante');
% Mezcla de una viga y una varilla axial.
db=struct('nodos',[0 0 0;1 0 0;1 1 0],'barras',[1 2;2 3],'E',E,'G',G, ...
    'F',.003,'Iy',8e-6,'Iz',8e-6,'J',16e-6,'tipo',["viga";"axial"], ...
    'cargas',[2 0 -1000 0 0 0 0],'apoyos',[1 zeros(1,6);3 0 0 0 NaN NaN NaN]);
r=rm_marco3d(db);cerca(r.u(2,2),-1000/(3*E*8e-6+E*.003),1e-12,'Sistema mixto: viga y barra axial');
% Columna: fuerza fuera de nodo y estabilidad en los dos planos.
rc=rm_columna3d(2,E,[8e-8 12e-8],32,"articulada_articulada",1000,[.83 100 40]);
cerca(rc.Pcritica,pi^2*E*8e-8/4,1e-6,'Columna espacial: inercia minima');
ra=rm_columna(2,E,8e-8,48,"articulada_articulada",0,[.83 100]);
rb=rm_columna(2,E,8e-8,96,"articulada_articulada",0,[.83 100]);
cerca(min(ra.u),min(rb.u),5e-4,'Columna: convergencia de carga interior no nodal');
% Plataforma y geometria compatible.
xy=[0 0;1 0;1 1;0 1];r=rm_tirantes_rigidos(xy,ones(1,4),.001*ones(1,4),E,zeros(1,4),1000,[.5 .5]);
cerca(r.N,250*ones(4,1),1e-12,'Plataforma espacial: reparto simetrico');
cerca(r.residuo,zeros(3,1),1e-7,'Plataforma espacial: fuerza y dos momentos');
r=rm_tirantes_rigidos([0 1 2],[1 1 1],[.001 .001 .001],E,[.0002 0 -.0001],0,1);
cerca(r.residuo,zeros(2,1),1e-7,'Barra rigida plana: compatibilidad conservada');
dp=struct('nodos',[0 0;0 2;3 2;3 0],'barras',[1 2;2 3;3 4],'E',210e9, ...
    'F',.005,'I',8e-6,'cargas',[3 5000 -10000 0],'apoyos',[1 0 0 0;4 .0001 -.0002 .0001], ...
    'q',[0 0 0 0;0 0 -1000 -1000;0 0 0 0]);
rp=rm_mohr_plano(dp,[3 2]);cerca(rp.deltaMohr,rp.deltaNodal,1e-11,'Modo plano: trabajo virtual con asientos');
dp.deformacionLibre=[1e-4 2e-4 0];dp.curvaturaLibre=[1e-4 -2e-4 2e-4];
rp=rm_mohr_plano(dp,[3 3]);cerca(rp.deltaMohr,rp.deltaNodal,1e-11,'Modo plano: trabajo virtual con deformaciones libres');
fprintf('Superadas %d comprobaciones espaciales.\n',numel(RM3D_TEST));
end
function cerca(a,b,t,n)
assert(isequal(size(a),size(b))&&all(isfinite(a(:)))&&norm(a(:)-b(:),inf)<=t*max(norm(b(:),inf),1),'Error: %s, diferencia=%g',n,norm(a(:)-b(:),inf));
global RM3D_TEST;RM3D_TEST{end+1}=char(n);fprintf('OK %s\n',n);
end
function falla(f,n)
ok=false;try,f();catch,ok=true;end
assert(ok,'Se aceptaron datos invalidos: %s',n);global RM3D_TEST;RM3D_TEST{end+1}=char(n);fprintf('OK %s\n',n);
end

function registrar(n)
global RM3D_TEST;RM3D_TEST{end+1}=char(n);fprintf('OK %s\n',n);
end
