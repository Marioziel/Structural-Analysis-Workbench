function r=rm_dimensionar_marco3d(d,c,intervalo)
assert(numel(intervalo)==2&&intervalo(1)>0&&intervalo(2)>intervalo(1) ...
    && isscalar(c.D)&&isscalar(c.di),'RM:Dimensionar','Dimensionamiento uniforme: D y di escalares e intervalo [Dmin Dmax].');
g=@(D) margen(D,d,c);a=intervalo(1);b=intervalo(2);ga=g(a);gb=g(b);
assert(gb>=0,'RM:Dimensionar','Dmax no alcanza el factor requerido. Amplia el intervalo.');
if ga>=0,D=a;else,D=fzero(g,[a b]);end
c.D=D;r=rm_resistencia_marco3d(d,c);r.diametroElegido=D;
assert(r.cortanteValidado,'RM:Cortante','El cortante supera el 5%% del limite. Activa considerarCortante y repite el dimensionamiento.');
end
function y=margen(D,d,c)
c.D=D;r=rm_resistencia_marco3d(d,c);y=log(r.factor/c.nRequerido);
end
