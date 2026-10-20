function [f,a]=rm_figura(n,nombre)
% Distribucion vertical con espacio para titulos al exportar y en Live Editor.
assert(n>=1 && n<=5,'RM:Grafica','Entre una y cinco filas por figura.');
alto=min(780,210+175*n);
f=figure('Color','w','Name',char(nombre),'Position',[90 40 850 alto]);
annotation(f,'textbox',[.09 .96 .86 .035],'String',char(nombre),'Interpreter','none', ...
    'EdgeColor','none','HorizontalAlignment','center','FontSize',11);
separacion=65/alto;
h=(.90-.115-separacion*(n-1))/n; borde=.90; a=gobjects(n,1);
for j=1:n
    borde=borde-h; a(j)=axes(f,'Position',[.10 borde .84 h],'FontSize',9);
    borde=borde-separacion; box(a(j),'on');
end
end
