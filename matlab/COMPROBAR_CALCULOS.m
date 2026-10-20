function COMPROBAR_CALCULOS
addpath(fileparts(mfilename('fullpath')));
global RM_PRUEBAS; RM_PRUEBAS={};
E=210e9; F=.002; L=2; I=8e-6; P=1000;
d=struct('nodos',[0 0;L 0],'barras',[1 2],'E',E,'F',F, ...
    'cargas',[2 P 0],'apoyos',[1 0 0;2 NaN 0]);
r=rm_cercha(d); cerca(r.u(2,1),P*L/(E*F),1e-12,'Cercha: alargamiento PL/EF');
cerca(r.N,P,1e-12,'Cercha: esfuerzo axial');
d.cargas=[2 0 0]; d.deformacionLibre=1e-4; r=rm_cercha(d);
cerca(r.u(2,1),1e-4*L,1e-12,'Cercha: expansion libre');
d.apoyos=[1 0 0;2 0 0]; r=rm_cercha(d);
cerca(r.N,-E*F*1e-4,1e-12,'Cercha: expansion impedida');
d.apoyos=[1 0 0]; falla(@()rm_cercha(d),'Cercha: mecanismo rechazado');
d=struct('nodos',[0 0 0;1 1 1],'barras',[1 2],'E',E,'F',F, ...
    'cargas',[2 P P P],'apoyos',[1 0 0 0;2 NaN 0 0]); r=rm_cercha(d);
cerca(r.N,sqrt(3)*P,1e-12,'Cercha espacial: equilibrio axial');
b=.12; h=.20; poly=[0 0;b 0;b h;0 h]; s=rm_seccion({poly},1);
cerca(s.F,b*h,1e-12,'Seccion: area rectangular');
cerca(s.Iy,b*h^3/12,1e-12,'Seccion: Iy rectangular');
cerca(s.Iz,h*b^3/12,1e-12,'Seccion: Iz rectangular');
ss=rm_seccion({flipud(poly)},1); cerca(ss.Iy,s.Iy,1e-12,'Seccion: orientacion de vertices');
ss=rm_seccion({poly,[.02 .02;.10 .02;.10 .18;.02 .18]},[1 -1]);
cerca(ss.F,.12*.20-.08*.16,1e-12,'Seccion: descuento de hueco');
falla(@()rm_seccion({poly,poly},[1 1]),'Seccion: solapamiento rechazado');
ss=rm_pared([0 0 b 0 .002]); cerca(ss.Iz,.002*b^3/12,1e-12,'Pared delgada: inercia de linea');
d=struct('nodos',[0 0;L 0],'barras',[1 2],'E',E,'F',F,'I',I, ...
    'cargas',[2 0 -P 0],'apoyos',[1 0 0 0]); r=rm_marco(d);
cerca(r.u(2,2),-P*L^3/(3*E*I),1e-12,'Voladizo: flecha PL3/3EI');
cerca(r.u(2,3),-P*L^2/(2*E*I),1e-12,'Voladizo: giro PL2/2EI');
cerca(polyval(r.campos{1}.M,0),-P*L,1e-12,'Voladizo: momento de raiz');
cerca(r.energia,-P*r.u(2,2)/2,5e-6,'Voladizo: energia de deformacion');
d.cargas=[2 0 0 0]; d.deformacionLibre=1e-4; d.curvaturaLibre=2e-4; r=rm_marco(d);
cerca(r.u(2,1),1e-4*L,1e-12,'Marco: deformacion axial libre');
cerca(r.u(2,2),2e-4*L^2/2,1e-12,'Marco: curvatura libre');
cerca(norm(r.campos{1}.acciones),0,1e-7,'Marco: libre sin fuerzas');
w=1500; d=struct('x',[0 L],'E',E,'F',F,'I',I,'puntuales',zeros(0,3), ...
    'distribuidas',[0 L -w -w],'apoyos',[0 0 NaN;L 0 NaN]); r=rm_viga(d);
cerca(polyval(r.campos{1}.v,L/2),-5*w*L^4/(384*E*I),1e-12,'Viga: flecha exacta con q uniforme');
cerca(r.R(:,2),[w*L/2;w*L/2],1e-12,'Viga: reacciones de carga uniforme');
d.puntuales=[.73 -P 0]; r=rm_viga(d);
assert(any(r.x==.73)); registrar('Viga: corte automatico para carga interior');
cerca(sum(r.R(:,2)),w*L+P,1e-12,'Viga: equilibrio de cargas superpuestas');
d2=struct('nodos',[0 0;L 0],'barras',[1 2],'E',E,'F',F,'I',I, ...
    'cargas',[2 0 0 0],'apoyos',[1 0 0 NaN;2 NaN 0 NaN],'q',[0 0 -w -w], ...
    'liberaciones',[1 1;1 2]); r=rm_marco(d2);
cerca(r.campos{1}.acciones([3 6]),[0;0],1e-7,'Marco: rotulas sin momento');
G=80e9; J=pi*.05^4/32; T=500;
r=rm_axial(struct('x',[0 L],'E',G,'F',J,'puntuales',[L T],'apoyos',[0 0]));
cerca(r.u(end),T*L/(G*J),1e-12,'Torsion: giro TL/GJ');
r=rm_tensor(diag([100e6 0 0]),E,.3);
cerca(r.VM,100e6,1e-12,'Tensor: von Mises uniaxial');
cerca(r.epsilon(2,2),-.3*100e6/E,1e-12,'Tensor: Poisson');
r=rm_tensor(100e6*eye(3),E,.3); cerca(r.VM,0,1e-8,'Tensor: estado hidrostatico');
r=rm_tensor([0 50e6 0;50e6 0 0;0 0 0],E,.3);
cerca(r.VM,sqrt(3)*50e6,1e-12,'Tensor: von Mises cortante puro');
cerca(r.Tresca,100e6,1e-12,'Tensor: Tresca cortante puro');
ee=r.epsilon; G=E/2/1.3; lambda=E*.3/(1.3*.4);
cerca(2*G*ee+lambda*trace(ee)*eye(3),r.S,1e-12,'Tensor: inversion de Hooke');
for tipo=["articulada_articulada","empotrada_libre","empotrada_empotrada","empotrada_articulada"]
    r=rm_columna(L,E,I,24,tipo,0,zeros(0,2));
    cerca(r.Pcritica,r.PEuler,1e-5,"Pandeo: Euler "+tipo);
end
r24=rm_columna(L,E,I,24,"articulada_articulada",0,zeros(0,2));
r48=rm_columna(L,E,I,48,"articulada_articulada",0,zeros(0,2));
cerca(r24.Pcritica,r48.Pcritica,1e-5,'Pandeo: convergencia 24/48 elementos');
falla(@()rm_columna(L,E,I,24,"articulada_articulada",1.01*r24.Pcritica,zeros(0,2)), ...
    'Pandeo: estado supercritico rechazado');
fprintf('\nSuperadas %d comprobaciones analiticas.\n',numel(RM_PRUEBAS));
end
function cerca(a,b,tol,nombre)
assert(isequal(size(a),size(b)) && all(isfinite(a(:))) && all(isfinite(b(:))) ...
    && norm(a(:)-b(:),inf)<=tol*max(1,norm(b(:),inf)), ...
    'Prueba fallida: %s. Error %g.',nombre,norm(a(:)-b(:),inf));
registrar(nombre);
end
function falla(f,nombre)
rechazo=false; try, f(); catch, rechazo=true; end
assert(rechazo,'Se aceptaron datos invalidos: %s',nombre); registrar(nombre);
end
function registrar(nombre)
global RM_PRUEBAS; RM_PRUEBAS{end+1}=char(nombre); fprintf('OK %s\n',nombre);
end
