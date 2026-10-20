function carga=ae_carga_masa(masa,centroMasa,puntoTraslado,aceleracionBase,gravedad)
if nargin<5,gravedad=[0 0 -9.81];end
assert(isnumeric(masa)&&isreal(masa)&&isscalar(masa)&&isfinite(masa)&&masa>=0, ...
    'AE:Masa','Masa no negativa y finita en kg.');
vectores={centroMasa,puntoTraslado,aceleracionBase,gravedad};
for k=1:numel(vectores)
    v=vectores{k};assert(isnumeric(v)&&isreal(v)&&numel(v)==3&&all(isfinite(v(:))), ...
        'AE:Masa','Posiciones, aceleracion y gravedad necesitan tres componentes reales finitas.');
end
F=masa*(gravedad(:).'-aceleracionBase(:).');
M=cross(centroMasa(:).'-puntoTraslado(:).',F);
carga=[F M];
end
