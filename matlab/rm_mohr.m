function rm_mohr(ax,r)
p=r.principales/1e6; hold(ax,'on'); t=linspace(0,2*pi,361);
for par=[1 2;2 3;1 3]'
    c=mean(p(par)); radio=abs(diff(p(par)))/2;
    plot(ax,c+radio*cos(t),radio*sin(t),'LineWidth',1.2);
end
yline(ax,0,'Color',[.35 .35 .35]); axis(ax,'equal'); grid(ax,'on');
xlabel(ax,'\sigma [MPa]'); ylabel(ax,'\tau [MPa]');
title(ax,'Circulos de Mohr','Units','normalized','Position',[.5 1.03 0]);
end
