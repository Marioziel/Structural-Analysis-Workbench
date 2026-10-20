function d=ae_factor_mecanico(analisis,d,f)
assert(isnumeric(f)&&isreal(f)&&isscalar(f)&&isfinite(f)&&f>=0,'AE:Casos','Factor mecanico real, finito y no negativo.');
if f==1,return;end
switch string(analisis)
case "axial"
    d.puntuales=cols(d.puntuales,2,f);d.distribuidas=cols(d.distribuidas,3:4,f);
case "cercha",d.cargas=cols(d.cargas,2:size(d.cargas,2),f);
case "torsion"
    d.pares=cols(d.pares,2,f);d.distribuidos=cols(d.distribuidos,3:4,f);
case "viga"
    d.puntuales=cols(d.puntuales,2:3,f);d.distribuidas=cols(d.distribuidas,3:4,f);
case "flexion_oblicua"
    d.N=f*d.N;d.My=f*d.My;d.Mz=f*d.Mz;
case "sistema_barras"
    if d.modo=="espacial"
        d.cargas=cols(d.cargas,2:7,f);d.qGlobal=f*d.qGlobal;d.qLocal=f*d.qLocal;
    elseif d.modo=="plano"
        d.cargasPlano=cols(d.cargasPlano,2:4,f);d.qPlano=f*d.qPlano;
    else,d.fuerzaResorte=f*d.fuerzaResorte;d.parResorte=f*d.parResorte;end
case "resistencia_combinada"
    if d.modo=="estructura"
        d.cargas=cols(d.cargas,2:7,f);d.qGlobal=f*d.qGlobal;d.qLocal=f*d.qLocal;
    else
        for k={'N','Qy','Qz','My','Mz','T'},d.(k{1})=f*d.(k{1});end
    end
case "seccion_general"
    for k={'N','Qy','Qz','My','Mz','T'},d.(k{1})=f*d.(k{1});end
case "uniones"
    if d.tipo=="pasador"
        d.Paxial=f*d.Paxial;d.Pcortante=f*d.Pcortante;d.laminas=cols(d.laminas,4,f);
    elseif d.tipo=="adhesivo_simple",d.fuerzaAdhesivo=f*d.fuerzaAdhesivo;
    else,d.fuerzaSoldadura=f*d.fuerzaSoldadura;d.momentoSoldadura=f*d.momentoSoldadura;end
case "placa_local",d.sigmaCompresion=f*d.sigmaCompresion;d.tau=f*d.tau;
case "solido3d"
    d.traccionCaja=f*d.traccionCaja;d.traccionesCara=cols(d.traccionesCara,2:4,f);
    d.presionesCara=cols(d.presionesCara,2,f);d.factorCargaVolumen=f*d.factorCargaVolumen;
otherwise
    error('AE:Casos',['El escalado automatico no se define para esta familia. ' ...
        'Usa factorMecanico=1 y especifica las modificaciones en cambios.']);
end
end
function v=cols(v,indices,f),if ~isempty(v),v(:,indices)=f*v(:,indices);end;end
