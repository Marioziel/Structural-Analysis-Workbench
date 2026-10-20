function [resultado,estado]=ae_modelo_08(entrada)
tipo=entrada.tipo;
matriz=entrada.matriz;
E=entrada.E;
nu=entrada.nu;
alpha=entrada.alpha;
deltaT=entrada.deltaT;
normalCara=entrada.normalCara;
limiteElastico=entrada.limiteElastico;
if tipo=="tensiones"
    S=matriz;
else
    assert(tipo=="deformaciones" && E>0 && nu>-1 && nu<.5,'Datos invalidos.');
    ee=matriz-alpha*deltaT*eye(3);
    G=E/(2*(1+nu)); lambda=E*nu/((1+nu)*(1-2*nu));
    S=2*G*ee+lambda*trace(ee)*eye(3);
end
resultado=rm_tensor(S,E,nu);
deformaciones=resultado.epsilon+alpha*deltaT*eye(3);
assert(norm(normalCara)>0,'La normal no puede ser nula.');
n=normalCara(:)/norm(normalCara);
traccion=S*n; sigmaNormal=n'*traccion;
tauCara=norm(traccion-sigmaNormal*n);
disp(table(resultado.principales/1e6,'VariableNames',{'Tensiones_principales_MPa'}));
disp('Deformaciones tensoriales:'); disp(deformaciones);
disp(table(sigmaNormal/1e6,tauCara/1e6,resultado.VM/1e6,resultado.Tresca/1e6, ...
    'VariableNames',{'Normal_MPa','Cortante_cara_MPa','Von_Mises_MPa','Tresca_MPa'}));

assert(limiteElastico>0,'Limite resistente positivo.');
nVM=limiteElastico/max(resultado.VM,realmin);
nTresca=limiteElastico/max(resultado.Tresca,realmin);
disp(table(nVM,nTresca));
[figura,ejes]=rm_figura(2,'Tensiones principales y Mohr');
bar(ejes(1),resultado.principales/1e6); yline(ejes(1),0,'Color',[.35 .35 .35]);
ylabel(ejes(1),'\sigma [MPa]'); xlabel(ejes(1),'Principal');
rm_mohr(ejes(2),resultado);
[figura,ejes]=rm_figura(1,'Tensor 3D: direcciones principales y normal de consulta');hold(ejes(1),'on');
colores=lines(3);
for j=1:3
    v=resultado.direcciones(:,j);
    quiver3(ejes(1),0,0,0,v(1),v(2),v(3),0,'Color',colores(j,:),'LineWidth',2);
    text(ejes(1),v(1),v(2),v(3),sprintf(' σ_%d = %.3g MPa',j,resultado.principales(j)/1e6));
end
quiver3(ejes(1),0,0,0,n(1),n(2),n(3),0,'k--','LineWidth',1.2);
text(ejes(1),n(1),n(2),n(3),' normal');
axis(ejes(1),'equal');grid(ejes(1),'on');view(ejes(1),35,24);
xlabel(ejes(1),'X');ylabel(ejes(1),'Y');zlabel(ejes(1),'Z');
estado=struct;
if exist('S','var'),estado.S=S;end
if exist('deformaciones','var'),estado.deformaciones=deformaciones;end
if exist('sigmaNormal','var'),estado.sigmaNormal=sigmaNormal;end
if exist('tauCara','var'),estado.tauCara=tauCara;end
if exist('nVM','var'),estado.nVM=nVM;end
if exist('nTresca','var'),estado.nTresca=nTresca;end
end
