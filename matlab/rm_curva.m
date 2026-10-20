function rm_curva(ax,x,y,titulo,rayar)
if nargin<5, rayar=true; end
hold(ax,'on'); x=x(:); y=y(:);
plot(ax,[min(x) max(x)],[0 0],'-','Color',[.35 .35 .35],'LineWidth',1);
if rayar && numel(x)>1
    ix=unique(round(linspace(1,numel(x),min(85,numel(x)))));
    plot(ax,[x(ix) x(ix)]',[zeros(size(ix(:))) y(ix)]','-','Color',[.55 .55 .55],'LineWidth',.5);
end
plot(ax,x,y,'k-','LineWidth',1.5); xlim(ax,[min(x) max(x)]+[-1 1]*max(max(x)-min(x),eps)*.02);
lo=min([y;0]); hi=max([y;0]); delta=hi-lo; if delta==0, delta=1; end
ylim(ax,[lo-.15*delta hi+.2*delta]);
title(ax,titulo,'Interpreter','tex','Units','normalized','Position',[.5 1.03 0],'FontSize',10);
end
