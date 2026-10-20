function figuras=rm_graficar_marco3d(r,vista,mostrarCeros)
if nargin<2,vista="ambas";end
if nargin<3,mostrarCeros=false;end
assert(ismember(string(vista),["locales" "espaciales" "ambas" "geometria"]),'RM:Vista','Vista: locales, espaciales, ambas o geometria.');
X=r.datos.nodos;B=r.datos.barras;nb=size(B,1);tam=max(max(X)-min(X));if tam==0,tam=1;end
col=lines(nb);muestras=cell(nb,1);umax=0;
for i=1:nb
    a=r.campos{i};s=linspace(0,a.L,61)';base=a.origen+s*a.R(1,:);
    ul=[polyval(a.u,s) polyval(a.v,s) polyval(a.w,s)]*a.R;
    muestras{i}={s,base,ul};umax=max(umax,max(vecnorm(ul,2,2)));
end
escala=.12*tam/max(umax,realmin);if umax==0,escala=1;end
[f,ax]=rm_figura(1,'Estructura 3D: negro original, rojo deformada amplificada');figuras=f;hold(ax,'on');
for i=1:nb
    a=r.campos{i};s=muestras{i}{1};base=muestras{i}{2};pd=base+escala*muestras{i}{3};
    plot3(ax,base(:,1),base(:,2),base(:,3),'k-','LineWidth',1.6);
    plot3(ax,pd(:,1),pd(:,2),pd(:,3),'r--','LineWidth',1.2);
    p=mean(base,1);text(ax,p(1),p(2),p(3),sprintf(' B%d',i),'Color',col(i,:));
    for j=1:3
        e=a.R(j,:)*.09*tam;colors=[.8 0 0;0 .5 0;0 .2 .9];
        quiver3(ax,base(1,1),base(1,2),base(1,3),e(1),e(2),e(3),0,'Color',colors(j,:),'HandleVisibility','off');
    end
end
for i=1:size(X,1),text(ax,X(i,1),X(i,2),X(i,3),sprintf('  %d',i));end
A=r.datos.apoyos;
for i=1:size(A,1)
    p=X(A(i,1),:);plot3(ax,p(1),p(2),p(3),'ks','MarkerFaceColor',[.65 .65 .65],'MarkerSize',8);
end
P=r.datos.cargas;
if ~isempty(P)
    escalaF=max(vecnorm(P(:,2:4),2,2));escalaM=max(vecnorm(P(:,5:7),2,2));
    for i=1:size(P,1)
        p=X(P(i,1),:);
        if norm(P(i,2:4))>0
            v=P(i,2:4)/escalaF*.22*tam;quiver3(ax,p(1)-v(1),p(2)-v(2),p(3)-v(3),v(1),v(2),v(3),0,'Color',[0 .45 .7],'LineWidth',1.6);
        end
        if norm(P(i,5:7))>0
            v=P(i,5:7)/escalaM*.18*tam;quiver3(ax,p(1),p(2),p(3),v(1),v(2),v(3),0,'Color',[.6 0 .6],'LineWidth',1.6);
            text(ax,p(1)+v(1),p(2)+v(2),p(3)+v(3),' M');
        end
    end
end
maxq=max(abs(r.qLocal(:,1:6)),[],'all');
if maxq>0
    for i=1:nb
        a=r.campos{i};ss=linspace(0,a.L,6);
        for t=ss
            p=a.origen+t*a.R(1,:);ql=r.qLocal(i,1:2:5)+(r.qLocal(i,2:2:6)-r.qLocal(i,1:2:5))*t/a.L;
            v=(ql*a.R)/maxq*.12*tam;
            quiver3(ax,p(1)-v(1),p(2)-v(2),p(3)-v(3),v(1),v(2),v(3),0,'Color',[0 .5 .7]);
        end
    end
end
rotulo3d(ax);title(ax,sprintf('Deformada x %.3g; ejes locales x rojo, y verde, z azul',escala),'FontSize',9);
if string(vista)=="geometria",return,end
nombres={'N','Vy','Vz','T','My','Mz'};rotulos={'N [kN]','Q_y [kN]','Q_z [kN]','M_x [kN m]','M_y [kN m]','M_z [kN m]'};
maximos=zeros(nb,6);
for i=1:nb
    for j=1:6,maximos(i,j)=max(abs(polyval(r.campos{i}.(nombres{j}),muestras{i}{1})));end
end
umbrales=[repmat(max(maximos(:,1:3),[],'all')*1e-9,1,3),repmat(max(maximos(:,4:6),[],'all')*1e-9,1,3)];
if ismember(string(vista),["locales" "ambas"])
    for i=1:nb
        ids=find(maximos(i,:)>max(umbrales,1e-12));if mostrarCeros,ids=1:6;end
        if isempty(ids),ids=1;end
        for desde=1:3:numel(ids)
            jj=ids(desde:min(desde+2,numel(ids)));[f,ax]=rm_figura(numel(jj),sprintf('Barra %d: nodo %d a nodo %d',i,B(i,1),B(i,2)));figuras(end+1)=f;
            for k=1:numel(jj)
                j=jj(k);rm_curva(ax(k),muestras{i}{1},polyval(r.campos{i}.(nombres{j}),muestras{i}{1})/1000,rotulos{j});
            end
            xlabel(ax(end),'s local [m]');
        end
    end
end
if ismember(string(vista),["espaciales" "ambas"])
    for j=1:6
        lim=max(maximos(:,j));if ~mostrarCeros && lim<=max(umbrales(j),1e-12),continue,end
        [f,ax]=rm_figura(1,['Epiura espacial: ' rotulos{j}]);figuras(end+1)=f;hold(ax,'on');
        for i=1:nb
            a=r.campos{i};base=muestras{i}{2};s=muestras{i}{1};valor=polyval(a.(nombres{j}),s);
            dir=a.R(2,:);if ismember(j,[3 5]),dir=a.R(3,:);end
            curva=base+(valor/max(lim,realmin))*(.20*tam)*dir;
            plot3(ax,base(:,1),base(:,2),base(:,3),'k-','LineWidth',1.3);
            plot3(ax,curva(:,1),curva(:,2),curva(:,3),'Color',col(i,:),'LineWidth',1.5);
            for k=1:4:numel(s),p=[base(k,:);curva(k,:)];plot3(ax,p(:,1),p(:,2),p(:,3),'-','Color',col(i,:));end
            [~,k]=max(abs(valor));p=curva(k,:);text(ax,p(1),p(2),p(3),sprintf(' B%d: %.3g',i,valor(k)/1000));
        end
        rotulo3d(ax);title(ax,'Separacion visual proporcional al esfuerzo; geometria negra = cero','FontSize',9);
    end
end
end
function rotulo3d(ax)
axis(ax,'equal');grid(ax,'on');view(ax,35,24);xlabel(ax,'X [m]');ylabel(ax,'Y [m]');zlabel(ax,'Z [m]');
end
