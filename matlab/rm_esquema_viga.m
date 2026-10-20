function rm_esquema_viga(ax,d)
% Esquema visual: las flechas no representan una escala de fuerza.
hold(ax,'on'); x=d.x; longitud=x(end)-x(1);
plot(ax,[x(1) x(end)],[0 0],'k-','LineWidth',3);
for j=1:size(d.apoyos,1)
    p=d.apoyos(j,1);
    if ~isnan(d.apoyos(j,2))
        plot(ax,p,-.12,'k^','MarkerSize',8,'MarkerFaceColor',[.8 .8 .8]);
    end
    if ~isnan(d.apoyos(j,3))
        plot(ax,[p p],[-.25 .25],'k-','LineWidth',2);
    end
end
for j=1:size(d.puntuales,1)
    p=d.puntuales(j,1); fuerza=d.puntuales(j,2); par=d.puntuales(j,3);
    if fuerza~=0
        inicio=-sign(fuerza)*.6;
        quiver(ax,p,inicio,0,-inicio,0,'k','LineWidth',1.4,'MaxHeadSize',.5);
        text(ax,p,inicio-sign(fuerza)*.15,sprintf('%g kN',fuerza/1000),'HorizontalAlignment','center');
    end
    if par~=0
        text(ax,p,-.65,sprintf('M = %g kN m',par/1000),'HorizontalAlignment','center');
    end
end
for j=1:size(d.distribuidas,1)
    q=d.distribuidas(j,:); xs=linspace(q(1),q(2),9);
    ys=q(3)+(q(4)-q(3))*(xs-q(1))/(q(2)-q(1));
    for k=1:numel(xs)
        if ys(k)~=0
            inicio=-sign(ys(k))*.36;
            quiver(ax,xs(k),inicio,0,-inicio,0,'Color',[.4 .4 .4],'MaxHeadSize',.6);
        end
    end
    text(ax,mean(q(1:2)),1.02,sprintf('q: %g a %g kN/m',q(3)/1000,q(4)/1000), ...
        'HorizontalAlignment','center');
end
xlim(ax,[x(1)-.04*longitud x(end)+.04*longitud]); ylim(ax,[-1 1.25]);
set(ax,'YTick',[]); title(ax,'Viga, apoyos y cargas (flechas esquematicas)');
end
