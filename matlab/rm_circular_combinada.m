function r=rm_circular_combinada(N,Qy,Qz,T,My,Mz,D,di,nu,k)
% Convencion vectorial: sigma=N/F+My*z/I-Mz*y/I.
assert(isscalar(D)&&isscalar(di)&&D>di&&di>=0&&nu>-1&&nu<.5&&k>0,'RM:Seccion','Diametros, nu o razon de limites invalidos.');
R=D/2;ri=di/2;F=pi*(D^2-di^2)/4;I=pi*(D^4-di^4)/64;J=2*I;
mb=hypot(My,Mz);mas=N/F+mb*R/I;menos=N/F-mb*R/I;tauT=abs(T)*R/J;
tauQ=hypot(Qy,Qz)*(2/3)*(R^3-ri^3)/(I*2*(R-ri));
nom=max(criterios(mas,tauT,nu,k),criterios(menos,tauT,nu,k));
envolvente=max(criterios(mas,tauT+tauQ,nu,k),criterios(menos,tauT+tauQ,nu,k));
r=struct('F',F,'I',I,'J',J,'nominal',nom,'envolvente',envolvente,'tauQ',tauQ,'tauT',tauT,'sigmaMas',mas,'sigmaMenos',menos);
end
function c=criterios(s,t,nu,k)
raiz=sqrt(s.^2+4*t.^2);
c=[(abs(s)+raiz)/2,((1-nu)*abs(s)+(1+nu)*raiz)/2,raiz,sqrt(s.^2+3*t.^2),((1-k)*s+(1+k)*raiz)/2];
end
