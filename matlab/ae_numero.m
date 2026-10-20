function t=ae_numero(v)
assert(isnumeric(v)&&isscalar(v)&&isreal(v),'AE:Memoria','Se esperaba un numero real.');
if isnan(v),t='\mathrm{NaN}';return;end
if isinf(v),t='\infty';if v<0,t=['-' t];end;return;end
if v==0,t='0';return;end
if abs(v)>=1e5||abs(v)<1e-3
    e=floor(log10(abs(v)));t=[sprintf('%.5g',v/10^e) '\times10^{' num2str(e) '}'];
else,t=sprintf('%.6g',v);end
end
