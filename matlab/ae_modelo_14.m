function [resultado,estado]=ae_modelo_14(entrada)
ciclos=entrada.ciclos;
limiteFatigaNormal=entrada.limiteFatigaNormal;
limiteFatigaCortante=entrada.limiteFatigaCortante;
limiteTraccion=entrada.limiteTraccion;
limiteCompresion=entrada.limiteCompresion;
limiteCortante=entrada.limiteCortante;
Knormal=entrada.Knormal;
Kcortante=entrada.Kcortante;
psiNormal=entrada.psiNormal;
psiCortante=entrada.psiCortante;
nRequerido=entrada.nRequerido;
assert(size(ciclos,2)==4 && all(isfinite(ciclos(:))) && ...
    all(ciclos(:,1)>=ciclos(:,2) & ciclos(:,3)>=ciclos(:,4)),'Ciclos invalidos.');
assert(all([limiteFatigaNormal limiteFatigaCortante limiteTraccion limiteCompresion ...
    limiteCortante Knormal Kcortante nRequerido]>0) && psiNormal>=0 && psiCortante>=0,'Coeficientes invalidos.');
sa=(ciclos(:,1)-ciclos(:,2))/2; sm=(ciclos(:,1)+ciclos(:,2))/2;
ta=(ciclos(:,3)-ciclos(:,4))/2; tm=(ciclos(:,3)+ciclos(:,4))/2;
dn=Knormal.*sa+psiNormal.*sm; dt=Kcortante.*ta+psiCortante.*tm;
nFatN=limiteFatigaNormal./max(dn,realmin); nFatT=limiteFatigaCortante./max(dt,realmin);
nEstN=min(limiteTraccion./max(Knormal.*sa+sm,realmin), ...
    limiteCompresion./max(Knormal.*sa-sm,realmin));
nEstT=limiteCortante./max(Kcortante.*ta+abs(tm),realmin);
nNormal=min(nFatN,nEstN); nCortante=min(nFatT,nEstT);
nCombinado=1./sqrt(1./nNormal.^2+1./nCortante.^2);
resultado=table((1:size(ciclos,1))',sa/1e6,sm/1e6,ta/1e6,tm/1e6,nNormal,nCortante,nCombinado,nCombinado>=nRequerido, ...
    'VariableNames',{'Punto','sigmaA_MPa','sigmaM_MPa','tauA_MPa','tauM_MPa','nNormal','nCortante','nCombinado','Cumple'});
disp(resultado);

[figura,ejes]=rm_figura(3,'Fatiga: ciclo y margen');
fase=linspace(0,2*pi,301); plot(ejes(1),fase,(sm(1)+sa(1)*cos(fase))/1e6,'k-');
xlabel(ejes(1),'Fase [rad]'); ylabel(ejes(1),'\sigma, primer punto [MPa]');
medias=linspace(-limiteCompresion,limiteTraccion,401);
ampFat=(limiteFatigaNormal-psiNormal*medias)/Knormal;
ampEst=min((limiteTraccion-medias)/Knormal,(limiteCompresion+medias)/Knormal);
amplitudes=max(0,min(ampFat,ampEst));
plot(ejes(2),medias/1e6,amplitudes/1e6,'k-',sm/1e6,sa/1e6,'ro');
xlabel(ejes(2),'\sigma_m [MPa]'); ylabel(ejes(2),'\sigma_a [MPa]');
bar(ejes(3),nCombinado); yline(ejes(3),nRequerido,'r--');
xlabel(ejes(3),'Punto'); ylabel(ejes(3),'Factor de seguridad');
estado=struct;
if exist('sa','var'),estado.sa=sa;end
if exist('sm','var'),estado.sm=sm;end
if exist('ta','var'),estado.ta=ta;end
if exist('tm','var'),estado.tm=tm;end
if exist('nNormal','var'),estado.nNormal=nNormal;end
if exist('nCortante','var'),estado.nCortante=nCortante;end
if exist('nCombinado','var'),estado.nCombinado=nCombinado;end
end
