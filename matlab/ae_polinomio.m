function t=ae_polinomio(p,variable)
if nargin<2,variable='s';end
assert(isnumeric(p)&&isvector(p)&&all(isfinite(p)),'AE:Memoria','Polinomio invalido.');
p=p(:).';t='';grado=numel(p)-1;
for j=1:numel(p)
    v=p(j);if v==0,continue;end
    k=grado-j+1;
    termino=ae_numero(abs(v));
    if k>0
        if abs(v)==1,termino='';end
        if k==1,termino=[termino variable];else,termino=[termino variable '^{' num2str(k) '}'];end
    end
    if v<0,signo='-';elseif isempty(t),signo='';else,signo='+';end
    t=[t signo termino];
end
if isempty(t),t='0';end
end
