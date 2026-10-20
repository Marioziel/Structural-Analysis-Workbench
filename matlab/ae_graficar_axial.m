function figuras = ae_graficar_axial(r)
m=r.modelo; ref=m.referencias;
if m.opciones.desglose=="auto",m.opciones.desglose="completo";end
base=[1000 1e6 1e-6 1e-3]; etiquetas={'N [kN]','\sigma [MPa]','\epsilon [10^{-6}]','\delta [mm]'};
termica=base; etiquetasT=etiquetas;
if m.opciones.normalizar
    base=[ref.P, ref.P/ref.F, ref.P/(ref.E*ref.F), ref.P*ref.a/(ref.E*ref.F)];
    etiquetas={'N / P','\sigma / (P/F)','\epsilon / (P/(EF))','\delta / (Pa/(EF))'};
    et=max(abs(m.alpha.*m.deltaT),[],'all');
    if et>0
        termica=[et*ref.E*ref.F,et*ref.E,et,et*ref.a];
        etiquetasT={'N / (\epsilon_T EF)','\sigma / (\epsilon_T E)', ...
            '\epsilon / \epsilon_T','\delta / (\epsilon_T a)'};
    end
end
series=struct('r',{},'campo',{},'escala',{},'titulo',{});
desglose=isfield(r.componentes,'mecanica') && m.opciones.desglose~="total";
if desglose
    for k=1:4, agregar(r.componentes.mecanica,k,base(k),etiquetas{k},'p'); end
    for k=1:3, agregar(r.componentes.termica,k,termica(k),etiquetasT{k},'t'); end
    if m.opciones.desglose=="completo"
        agregar(r.componentes.termica,4,termica(4),etiquetasT{4},'t');
        for k=1:4, agregar(r,k,base(k),etiquetas{k},'total'); end
    else
        agregar(r,2,base(2),etiquetas{2},'total');
    end
else
    for k=1:4, agregar(r,k,base(k),etiquetas{k},'total'); end
end
porPagina=4; nPaginas=ceil(numel(series)/porPagina);
figuras=gobjects(nPaginas,1);
for pagina=1:nPaginas
    indices=(pagina-1)*porPagina+1:min(pagina*porPagina,numel(series));
    figuras(pagina)=figure('Color','w',...
        'Name',char(m.nombre+" - "+pagina+"/"+nPaginas), ...
        'Position',[80+25*(pagina-1) 45 850 min(780,190+150*numel(indices))]);
    annotation(figuras(pagina),'textbox',[.09 .96 .86 .035], ...
        'String',char(m.nombre+" | "+pagina+"/"+nPaginas),'Interpreter','none', ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',11);
    pesos=[1.3 ones(1,numel(indices))]; separacion=.055;
    alturas=(.86-separacion*numel(indices))*pesos/sum(pesos);
    borde=.925; ejes=gobjects(numel(pesos),1);
    for j=1:numel(pesos)
        borde=borde-alturas(j);
        ejes(j)=axes(figuras(pagina),'Position',[.09 borde .86 alturas(j)],'FontSize',9);
        borde=borde-separacion;
    end
    esquema(ejes(1),r);
    for j=1:numel(indices)
        curva(ejes(j+1),series(indices(j)),m);
    end
    etiquetaX='x [m]'; if m.opciones.normalizar, etiquetaX='x/a'; end
    xlabel(ejes(end),etiquetaX);
    drawnow;
end

    function agregar(sol,k,escala,etiqueta,sufijo)
        campos={'N','sigma','epsilon','delta'};
        series(end+1)=struct('r',sol,'campo',campos{k},'escala',escala, ...
            'titulo',[etiqueta '   (' sufijo ')']);
    end
end

function esquema(ax,r)
m=r.modelo; hold(ax,'on'); L=m.x(end)-m.x(1);
sx=1; if m.opciones.normalizar, sx=m.referencias.a; end
xx=m.x/sx; margen=0.15*L/sx;
h=0.4*m.F/max(m.F);
stairs(ax,xx,[h;h(end)],'k-','LineWidth',1.5);
stairs(ax,xx,-[h;h(end)],'k-','LineWidth',1.5);
plot(ax,[xx(1) xx(1)],[-h(1) h(1)],'k-','LineWidth',1.5);
plot(ax,[xx(end) xx(end)],[-h(end) h(end)],'k-','LineWidth',1.5);
plot(ax,[xx(1) xx(end)],[0 0],'k--','LineWidth',0.8);
for i=1:numel(h)
    centro=mean(xx(i:i+1));
    if m.opciones.normalizar
        area=mult(m.F(i)/m.referencias.F,'F');
        long=mult((m.x(i+1)-m.x(i))/sx,'a');
    else
        area=sprintf('F=%.5g mm^2',m.F(i)*1e6);
        long=sprintf('%.3g m',m.x(i+1)-m.x(i));
    end
    text(ax,centro,h(i)+0.13,area,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',9);
    text(ax,centro,-0.72,long,'HorizontalAlignment','center','FontSize',10);
    if any(m.alpha(i)*m.deltaT(i,:)~=0)
        patch(ax,xx([i i+1 i+1 i]),[-h(i) -h(i) h(i) h(i)], ...
            [1 0.65 0.3],'FaceAlpha',0.15,'EdgeColor','none');
    end
end
escalaP=1000; unidad=' kN';
if m.opciones.normalizar, escalaP=m.referencias.P; unidad='P'; end
for j=1:numel(m.P)
    if m.P(j)~=0
        flecha(ax,xx(j),0,sign(m.P(j))*0.07*L/sx);
        text(ax,xx(j),1.45,sprintf('%+.3g%s',m.P(j)/escalaP,unidad), ...
            'HorizontalAlignment','center','FontSize',9);
    end
end
ap=m.apoyos(:,1);
for j=1:size(m.topes,1)
    [~,i]=min(abs(m.x-m.topes(j,1)));
    pared(ax,m.topes(j,1)/sx,m.topes(j,3),0.035*L/sx);
    if r.contactosActivos(j), estado='cerrado'; ap=[ap;m.topes(j,1)];
    else, estado='abierto'; end
    text(ax,m.topes(j,1)/sx,-1.03,sprintf('tope %s; \\Delta=%.3g m', ...
        estado,abs(m.topes(j,2))),'HorizontalAlignment','center','FontSize',8);
    if ~r.contactosActivos(j), text(ax,xx(i),0.95,'R=0','FontSize',8); end
end
for j=1:size(m.apoyos,1)
    sentido=-1; if m.apoyos(j,1)==m.x(end), sentido=1; end
    pared(ax,m.apoyos(j,1)/sx,sentido,0);
    if m.apoyos(j,2)~=0
        text(ax,m.apoyos(j,1)/sx,-1.03,sprintf('\\delta=%.3g m',m.apoyos(j,2)), ...
            'HorizontalAlignment','center','FontSize',8);
    end
end
for j=1:numel(ap)
    i=find(m.x==ap(j),1);
    if abs(r.R(i))>1e-10*max([abs(r.R);realmin])
        flecha(ax,xx(i),0.76,sign(r.R(i))*0.07*L/sx);
        text(ax,xx(i),1.35,sprintf('R_{total}=%+.3g%s',r.R(i)/escalaP,unidad), ...
            'HorizontalAlignment','center','FontSize',8);
    end
end
qmax=max(abs(m.q),[],'all');
if qmax>0
    for i=1:numel(h)
        if ~any(m.q(i,:)~=0), continue; end
        pos=linspace(xx(i),xx(i+1),5);
        valores=linspace(m.q(i,1),m.q(i,2),5);
        for j=1:5
            flecha(ax,pos(j),1.95,0.055*L/sx*valores(j)/qmax);
        end
        if m.opciones.normalizar
            qlabel=sprintf('q: %+.3g a %+.3g P/a',m.q(i,:)*sx/escalaP);
        else
            qlabel=sprintf('q: %+.3g a %+.3g kN/m',m.q(i,:)/1000);
        end
        text(ax,mean(xx(i:i+1)),2.25,qlabel,'HorizontalAlignment','center','FontSize',8);
    end
end
if r.hayTemperatura
    text(ax,mean([xx(1) xx(end)]),2.65,'Sombreado: tramo con deformacion termica', ...
        'HorizontalAlignment','center','FontSize',8);
end
xlim(ax,[xx(1)-margen xx(end)+margen]); ylim(ax,[-1.25 2.95]);
set(ax,'YTick',[],'Box','on');
title(ax,'Barra: areas, longitudes, cargas y apoyos','Units','normalized', ...
    'Position',[.5 1.03 0],'FontSize',10);
end

function curva(ax,s,m)
hold(ax,'on'); sx=1; if m.opciones.normalizar, sx=m.referencias.a; end
L=m.x(end)-m.x(1); margen=0.15*L/sx;
plot(ax,[m.x(1) m.x(end)]/sx,[0 0],'-','Color',[.35 .35 .35],'LineWidth',1);
vx=[]; vy=[];
for i=1:numel(s.r.tramos)
    t=s.r.tramos(i); p=t.(s.campo);
    dp=polyder(p); k=find(dp~=0,1);
    if isempty(k), z=[]; else, z=roots(dp(k:end)); end
    z=real(z(abs(imag(z))<1e-9*max(1,t.L))); z=z(z>0 & z<t.L);
    a=unique([linspace(0,t.L,81).';z(:)]);
    v=polyval(p,a)/s.escala;
    vx=[vx;(t.x0+a)/sx]; vy=[vy;v];
    if m.opciones.rayado
        count=max(4,round(70*t.L/L)); paso=t.L/count;
        a=((0:count-1)+.5)*paso; v=polyval(p,a)/s.escala;
        plot(ax,[(t.x0+a)/sx;(t.x0+a)/sx],[zeros(size(v));v], ...
            '-','Color',[.5 .5 .5],'LineWidth',.5);
    end
end
plot(ax,vx,vy,'k-','LineWidth',1.5);
lo=min([0;vy]); hi=max([0;vy]); rango=hi-lo;
if rango==0, rango=1; end
ylim(ax,[lo-.16*rango hi+.20*rango]);
xlim(ax,[m.x(1)/sx-margen m.x(end)/sx+margen]);
title(ax,s.titulo,'Interpreter','tex','Units','normalized','Position',[.5 1.03 0],'FontSize',10);
set(ax,'Box','on');
if s.campo=="delta"
    plot(ax,m.x/sx,s.r.u/s.escala,'ko','MarkerSize',4,'LineWidth',1);
end
k=find(s.r.extremos.Magnitud==string(s.campo),1); e=s.r.extremos(k,:);
pares=[e.xMinimo e.Minimo;e.xMaximo e.Maximo];
if abs(e.Maximo-e.Minimo)<1e-10*max([abs(e.Maximo),abs(e.Minimo),realmin]), pares=pares(1,:); end
for par=pares.'
    if abs(par(2)/s.escala)>1e-12*max([abs(vy);realmin])
        plot(ax,par(1)/sx,par(2)/s.escala,'ko','MarkerSize',3);
        alineacion='bottom'; if par(2)<0, alineacion='top'; end
        horizontal='left'; if par(1)>m.x(end)-.05*L, horizontal='right'; end
        text(ax,par(1)/sx,par(2)/s.escala,sprintf(' %.4g ',par(2)/s.escala), ...
            'VerticalAlignment',alineacion,'HorizontalAlignment',horizontal, ...
            'FontSize',8,'Clipping','on');
    end
end
end
function flecha(ax,x,y,dx)
if dx~=0, quiver(ax,x,y,dx,0,0,'k','LineWidth',1,'MaxHeadSize',.7); end
end
function pared(ax,x,sentido,separacion)
x=x+sentido*separacion;
line(ax,[x x],[-.45 .45],'Color','k','LineWidth',1.1);
w=diff(xlim(ax))*.015;
for y=linspace(-.4,.4,7)
    plot(ax,[x x+sentido*w],[y y+.08],'k-','LineWidth',.6);
end
end
function t=mult(v,simbolo)
if abs(v-1)<1e-10, t=simbolo; else, t=sprintf('%.3g%s',v,simbolo); end
end

