function f=ae_pagina(titulo,explicacion,ecuaciones)
f=figure('Color','w','Name',char(titulo),'Position',[100 60 980 650]);
annotation(f,'textbox',[.06 .90 .88 .07],'String',char(titulo), ...
    'Interpreter','none','FontWeight','bold','FontSize',13,'EdgeColor','none');
annotation(f,'textbox',[.06 .73 .88 .16],'String',char(explicacion), ...
    'Interpreter','none','FontSize',10,'EdgeColor','none');
a=axes(f,'Position',[.06 .08 .88 .64],'Visible','off','XLim',[0 1],'YLim',[0 1]);
n=numel(ecuaciones);
for j=1:n
    eq=adaptar(char(ecuaciones(j)));
    tam=15;if strlength(ecuaciones(j))>140,tam=12;end
    h=text(a,.01,1-(j-.45)/max(n,1),['$' eq '$'],'Interpreter','latex', ...
        'FontSize',tam,'VerticalAlignment','middle','Clipping','off');
    drawnow;
    ext=get(h,'Extent');
    if ext(3)>.96,set(h,'FontSize',max(8,tam*.96/ext(3)));end
end
end
function eq=adaptar(eq)
% El renderizador grafico admite array; bmatrix queda en la memoria LaTeX.
[tokens,ini,fin]=regexp(eq,'\\begin\{bmatrix\}(.*?)\\end\{bmatrix\}','tokens','start','end');
for k=numel(ini):-1:1
    cuerpo=tokens{k}{1};filas=regexp(cuerpo,'\\\\','split');
    columnas=1+sum(filas{1}=='&');
    nuevo=['\left[\begin{array}{' repmat('r',1,columnas) '}' cuerpo '\end{array}\right]'];
    eq=[eq(1:ini(k)-1) nuevo eq(fin(k)+1:end)];
end
eq=strrep(eq,'\boldsymbol','');
eq=regexprep(eq,'\\mathbf\s+([A-Za-z])','\\mathbf{$1}');
end
