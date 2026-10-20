function r = rm_axial(modelo)
%RESOLVER_BARRA_AXIAL Equilibrio y compatibilidad de una barra recta.
% F y E constantes por tramo; q y DeltaT lineales por tramo.
% Unidades coherentes: se recomienda m, N, Pa, grados C y 1/grado C.
% Fuente mecanica: capitulo 1 del libro local, ecs. 1.20--1.22.
% N positivo en traccion; cargas, reacciones y delta positivos a la derecha.

m = preparar(modelo);
[r, K, f] = calcular(m);
r.modelo = m;
r.componentes = struct;
hayTemperatura = any(m.alpha .* max(abs(m.deltaT), [], 2) ~= 0);
hayMecanica = any(m.P ~= 0) || any(m.q(:) ~= 0) || any(m.apoyos(:,2) ~= 0);
% La superposicion solo se presenta sin contactos unilaterales.
if hayTemperatura && hayMecanica && isempty(m.topes)
    mp = m; mp.deltaT(:) = 0;
    mt = m; mt.P(:) = 0; mt.q(:) = 0; mt.apoyos(:,2) = 0;
    r.componentes.mecanica = calcular(mp);
    r.componentes.termica = calcular(mt);
    escala = max([norm(r.u,inf), norm(r.componentes.mecanica.u,inf), ...
        norm(r.componentes.termica.u,inf), realmin]);
    assert(norm(r.u-r.componentes.mecanica.u-r.componentes.termica.u,inf) ...
        <= 1e-8*escala, 'Axial:Superposicion', 'Fallo de superposicion.');
end
r.hayTemperatura = hayTemperatura;
r.hayMecanica = hayMecanica;
r.validacion = comprobar(r, m, K, f);
r.resistencia = resistencia(r, m);
r.tablaNodos = table(m.x, r.u, m.P, r.R, ...
    'VariableNames', {'x','delta','P_aplicada','Reaccion'});
ini = arrayfun(@(t) polyval(t.N,0), r.tramos); ini=ini(:);
fin = arrayfun(@(t) polyval(t.N,t.L), r.tramos); fin=fin(:);
r.tablaTramos = table(m.x(1:end-1), m.x(2:end), m.F, m.E, ini, fin, ...
    'VariableNames', {'xInicial','xFinal','F','E','N_inicial','N_final'});
end

function m = preparar(d)
assert(isstruct(d) && isscalar(d), 'Axial:Datos', 'modelo debe ser una estructura.');
permitidos = {'nombre','nota','x','F','E','alpha','deltaT','puntuales', ...
    'distribuidas','apoyos','topes','referencias','opciones','resistencia'};
assert(all(ismember(fieldnames(d), permitidos)), 'Axial:Campo', ...
    'Hay un campo desconocido en modelo. Revisa los campos de entrada.');
for campo = {'x','F','E'}
    assert(isfield(d,campo{1}), 'Axial:Datos', 'Falta modelo.%s.',campo{1});
end
assert(isnumeric(d.x) && isvector(d.x), 'Axial:Geometria', 'x debe ser un vector numerico.');
x = double(d.x(:));
assert(numel(x)>=2 && isreal(x) && all(isfinite(x)) && all(diff(x)>0), ...
    'Axial:Geometria', 'x debe contener posiciones reales crecientes.');
ng = numel(x)-1;
F = vector(d.F, ng, 'F', true);
E = vector(d.E, ng, 'E', true);
alpha = vector(valor(d,'alpha',0), ng, 'alpha', false);
T = valor(d,'deltaT',zeros(ng,2));
if isscalar(T)
    T = repmat(T,ng,2);
elseif isvector(T) && numel(T)==ng && ~isequal(size(T),[ng 2])
    T = repmat(T(:),1,2);
end
assert(isnumeric(T) && isreal(T) && isequal(size(T),[ng 2]) && all(isfinite(T(:))), ...
    'Axial:Temperatura', 'deltaT: escalar, un valor por tramo o matriz [nTramos x 2].');
P = matriz(valor(d,'puntuales',zeros(0,2)),2,'puntuales');
Q = matriz(valor(d,'distribuidas',zeros(0,4)),4,'distribuidas');
A = matriz(valor(d,'apoyos',[x(1) 0]),2,'apoyos');
C = matriz(valor(d,'topes',zeros(0,3)),3,'topes');
assert(~isempty(A), 'Axial:Apoyos', 'Se necesita al menos un apoyo bilateral.');
assert(numel(unique(A(:,1)))==size(A,1), 'Axial:Apoyos', 'No repitas apoyos en una posicion.');
assert(size(C,1)<=8 && numel(unique(C(:,1)))==size(C,1), 'Axial:Topes', ...
    'Se admiten hasta 8 topes, uno por posicion.');
assert(all(abs(C(:,3))==1), 'Axial:Topes', 'El sentido del tope debe ser +1 o -1.');
assert(~any(ismember(C(:,1),A(:,1))), 'Axial:Topes', 'Un nodo no puede ser apoyo y tope a la vez.');
assert(all(Q(:,2)>Q(:,1)), 'Axial:Carga', 'Cada distribuida necesita xFinal > xInicial.');
posiciones = [P(:,1); Q(:,1); Q(:,2); A(:,1); C(:,1)];
assert(all(posiciones>=x(1) & posiciones<=x(end)), 'Axial:Rango', ...
    'Hay una carga, apoyo o tope fuera de la barra.');
xn = unique([x; posiciones]);
assert(all(diff(xn)>1e-12*(x(end)-x(1))), 'Axial:Geometria', ...
    'Existen posiciones casi coincidentes: unificalas en Datos.');
n = numel(xn)-1;
m = struct('nombre',string(valor(d,'nombre','Barra axial')), ...
    'nota',string(valor(d,'nota','')), 'x',xn, 'F',zeros(n,1), ...
    'E',zeros(n,1),'alpha',zeros(n,1),'deltaT',zeros(n,2), ...
    'q',zeros(n,2),'P',zeros(n+1,1),'apoyos',A,'topes',C);
m.original = d;
m.indiceOriginal = zeros(n,1);
for i=1:n
    centro = (xn(i)+xn(i+1))/2;
    g = find(x<=centro,1,'last');
    m.indiceOriginal(i)=g;
    m.F(i)=F(g); m.E(i)=E(g); m.alpha(i)=alpha(g);
    fraccion = ([xn(i),xn(i+1)]-x(g))/(x(g+1)-x(g));
    m.deltaT(i,:) = T(g,1)+(T(g,2)-T(g,1))*fraccion;
    for j=1:size(Q,1)
        if centro>Q(j,1) && centro<Q(j,2)
            f = ([xn(i),xn(i+1)]-Q(j,1))/(Q(j,2)-Q(j,1));
            m.q(i,:) = m.q(i,:)+Q(j,3)+(Q(j,4)-Q(j,3))*f;
        end
    end
end
for j=1:size(P,1)
    k=find(xn==P(j,1),1); m.P(k)=m.P(k)+P(j,2);
end
ref = valor(d,'referencias',struct);
m.referencias = struct('a',valor(ref,'a',1),'P',valor(ref,'P',1), ...
    'F',valor(ref,'F',1),'E',valor(ref,'E',1));
rv=[m.referencias.a m.referencias.P m.referencias.F m.referencias.E];
assert(isnumeric(rv) && isreal(rv) && numel(rv)==4 && all(isfinite(rv)&rv>0), ...
    'Axial:Referencias', 'Las referencias a, P, F y E deben ser escalares positivos.');
op = valor(d,'opciones',struct);
m.opciones = struct('desglose',string(valor(op,'desglose','auto')), ...
    'normalizar',valor(op,'normalizar',false),'rayado',valor(op,'rayado',true), ...
    'visible',char(valor(op,'visible','on')));
assert(ismember(m.opciones.desglose,["auto","total","completo"]), ...
    'Axial:Opciones','desglose debe ser auto, total o completo.');
assert(ismember(string(m.opciones.visible),["on","off"]), 'Axial:Opciones','visible: on u off.');
for k={'normalizar','rayado'}
    v=m.opciones.(k{1});
    assert(isscalar(v) && (islogical(v) || (isnumeric(v) && ismember(v,[0 1]))), ...
        'Axial:Opciones','normalizar y rayado deben ser true o false.');
end
res = valor(d,'resistencia',struct);
lt=vectorLimite(valor(res,'limiteTraccion',Inf),ng);
lc=vectorLimite(valor(res,'limiteCompresion',Inf),ng);
m.resistencia = struct('limiteTraccion',lt(m.indiceOriginal), ...
    'limiteCompresion',lc(m.indiceOriginal),'nMin',valor(res,'nMin',1));
assert(isnumeric(m.resistencia.nMin) && isscalar(m.resistencia.nMin) ...
    && isfinite(m.resistencia.nMin) && m.resistencia.nMin>0, ...
    'Axial:Resistencia','nMin debe ser positivo.');
end

function [r,K,f] = calcular(m)
n = numel(m.x); K=sparse(n,n); f=m.P;
for i=1:n-1
    L=m.x(i+1)-m.x(i); EA=m.E(i)*m.F(i); ix=[i i+1];
    K(ix,ix)=K(ix,ix)+(EA/L)*[1 -1;-1 1];
    fq=L/6*[2*m.q(i,1)+m.q(i,2);m.q(i,1)+2*m.q(i,2)];
    ft=EA*m.alpha(i)*mean(m.deltaT(i,:))*[-1;1];
    f(ix)=f(ix)+fq+ft;
end
[~,ia]=ismember(m.apoyos(:,1),m.x);
[~,ic]=ismember(m.topes(:,1),m.x);
nc=numel(ic); valido=false;
for estado=0:2^nc-1
    if nc==0, activos=false(0,1); else, activos=logical(bitget(estado,1:nc)).'; end
    fijos=[ia;ic(activos)]; valores=[m.apoyos(:,2);m.topes(activos,2)];
    libres=setdiff((1:n).',fijos); u=zeros(n,1); u(fijos)=valores;
    if ~isempty(libres)
        A=K(libres,libres); b=f(libres)-K(libres,fijos)*valores;
        % Escalar las ecuaciones mejora el calculo con rigideces muy distintas.
        s=1./sqrt(diag(A)); As=spdiags(s,0,numel(s),numel(s));
        u(libres)=s.*((As*A*As)\(s.*b));
    end
    R=K*u-f;
    escalaF=max([norm(f,1),norm(K*u,1),realmin]);
    tolF=1e-8*escalaF;
    escalaU=max([norm(u,inf),norm(valores,inf),norm(f,inf)/max(diag(K)),realmin]);
    tolU=1e-8*escalaU;
    penetracion=m.topes(:,3).*(u(ic)-m.topes(:,2));
    reaccionProhibida=m.topes(:,3).*R(ic);
    if all(penetracion<=tolU) && all(reaccionProhibida(activos)<=tolF)
        valido=true; break
    end
end
assert(valido,'Axial:Contacto','No se encontro un estado de contacto compatible.');
r=struct('u',u,'R',R,'contactosActivos',activos);
prototipo=struct('x0',0,'L',0,'N',zeros(1,3),'sigma',zeros(1,3), ...
    'epsilon',zeros(1,3),'delta',zeros(1,4),'q',zeros(1,2),'deltaT',zeros(1,2));
r.tramos=repmat(prototipo,n-1,1);
for i=1:n-1
    L=m.x(i+1)-m.x(i); EA=m.E(i)*m.F(i);
    q0=m.q(i,1); mq=(m.q(i,2)-q0)/L;
    T0=m.deltaT(i,1); mT=(m.deltaT(i,2)-T0)/L;
    N0=EA*((u(i+1)-u(i))/L-m.alpha(i)*mean(m.deltaT(i,:))) ...
        + L*(2*q0+m.q(i,2))/6;
    polN=[-mq/2 -q0 N0]; polS=polN/m.F(i);
    polE=polN/EA+[0 m.alpha(i)*mT m.alpha(i)*T0];
    polU=[polE(1)/3 polE(2)/2 polE(3) u(i)];
    r.tramos(i)=struct('x0',m.x(i),'L',L,'N',polN,'sigma',polS, ...
        'epsilon',polE,'delta',polU,'q',[mq q0],'deltaT',[mT T0]);
end
filas=cell(4,1); campos={'N','sigma','epsilon','delta'};
for k=1:4
    xmin=NaN; xmax=NaN; vmin=Inf; vmax=-Inf;
    for i=1:n-1
        t=r.tramos(i); s=puntosCriticos(t.(campos{k}),t.L);
        v=polyval(t.(campos{k}),s);
        [lo,j]=min(v); if lo<vmin, vmin=lo; xmin=t.x0+s(j); end
        [hi,j]=max(v); if hi>vmax, vmax=hi; xmax=t.x0+s(j); end
    end
    filas{k}={string(campos{k}),vmin,xmin,vmax,xmax};
end
r.extremos=cell2table(vertcat(filas{:}), ...
    'VariableNames',{'Magnitud','Minimo','xMinimo','Maximo','xMaximo'});
end

function v = comprobar(r,m,K,f)
escala=max([norm(f,1),norm(K*r.u,1),realmin]);
tol=1e-8*escala;
qTotal=sum(diff(m.x).*mean(m.q,2));
errorGlobal=abs(sum(m.P)+qTotal+sum(r.R));
errorSalto=0; errorCompatibilidad=0;
for i=1:numel(r.tramos)
    t=r.tramos(i);
    errorCompatibilidad=max(errorCompatibilidad,abs(polyval(t.delta,t.L)-r.u(i+1)));
    if i<numel(r.tramos)
        salto=polyval(r.tramos(i+1).N,0)-polyval(t.N,t.L)+m.P(i+1)+r.R(i+1);
        errorSalto=max(errorSalto,abs(salto));
    end
end
uEscala=max([norm(r.u,inf),norm(f,inf)/max(diag(K)),realmin]);
[~,ap]=ismember(m.apoyos(:,1),m.x);
errorApoyo=max(abs(r.u(ap)-m.apoyos(:,2)));
fijos=ap; if ~isempty(m.topes)
    [~,ic]=ismember(m.topes(:,1),m.x); fijos=[fijos;ic(r.contactosActivos)];
end
libres=setdiff((1:numel(m.x)).',fijos);
errorLibres=norm(r.R(libres),inf); if isempty(errorLibres), errorLibres=0; end
errorExtremos=max(abs([polyval(r.tramos(1).N,0)+m.P(1)+r.R(1), ...
    polyval(r.tramos(end).N,r.tramos(end).L)-m.P(end)-r.R(end)]));
assert(max([errorGlobal,errorSalto,errorLibres,errorExtremos])<=tol, ...
    'Axial:Equilibrio','No se supera la comprobacion de equilibrio.');
assert(max(errorCompatibilidad,errorApoyo)<=1e-8*uEscala, ...
    'Axial:Compatibilidad','No se supera la comprobacion de desplazamientos.');
v=struct('superadas',true,'errorEquilibrio',errorGlobal,'errorSaltos',errorSalto, ...
    'errorExtremos',errorExtremos,'errorNodosLibres',errorLibres, ...
    'errorCompatibilidad',errorCompatibilidad,'errorApoyos',errorApoyo);
end

function v=resistencia(r,m)
n=Inf; sT=0; sC=0;
for i=1:numel(r.tramos)
    t=r.tramos(i); s=puntosCriticos(t.sigma,t.L); valores=polyval(t.sigma,s);
    tr=max([0 valores]); co=max([0 -valores]); sT=max(sT,tr); sC=max(sC,co);
    if tr>0, n=min(n,m.resistencia.limiteTraccion(i)/tr); end
    if co>0, n=min(n,m.resistencia.limiteCompresion(i)/co); end
end
definida=any(isfinite(m.resistencia.limiteTraccion) | isfinite(m.resistencia.limiteCompresion));
v=struct('evaluada',definida,'sigmaTraccionMax',sT,'sigmaCompresionMax',sC, ...
    'factorSeguridad',n,'nMin',m.resistencia.nMin,'cumple',n>=m.resistencia.nMin);
end

function s=puntosCriticos(p,L)
d=polyder(p); primero=find(d~=0,1);
if isempty(primero), d=[]; else, d=d(primero:end); end
if isempty(d), z=[]; else, z=roots(d); end
z=real(z(abs(imag(z))<1e-9*max(1,L)));
s=unique([0;L;z(z>0 & z<L)]).';
end
function v=valor(s,c,predeterminado)
if isfield(s,c), v=s.(c); else, v=predeterminado; end
end
function a=matriz(a,n,nombre)
if isempty(a), a=zeros(0,n); end
assert(isnumeric(a) && isreal(a) && ismatrix(a) && size(a,2)==n && all(isfinite(a(:))), ...
    'Axial:Datos','%s necesita %d columnas numericas finitas.',nombre,n);
a=double(a);
end
function a=vector(a,n,nombre,positivo)
assert(isnumeric(a) && isreal(a) && isvector(a) && all(isfinite(a(:))), ...
    'Axial:Datos','%s debe ser un vector numerico finito.',nombre);
if isscalar(a), a=repmat(a,n,1); end
a=double(a(:));
assert(numel(a)==n,'Axial:Datos','%s necesita un valor por tramo original.',nombre);
if positivo, assert(all(a>0),'Axial:Datos','%s debe ser positivo.',nombre); end
end
function a=vectorLimite(a,n)
assert(isnumeric(a) && isreal(a) && isvector(a) && all(a(:)>0), ...
    'Axial:Resistencia','Los limites deben ser positivos, o Inf si no se comprueban.');
if isscalar(a), a=repmat(a,n,1); end
a=a(:); assert(numel(a)==n,'Axial:Resistencia','Se necesita un limite por tramo original.');
end
