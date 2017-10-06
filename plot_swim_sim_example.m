[Data,si,info]=abfload('ZL170901_fish04a_0014.abf'); %22
S=struct();
data_l=length(Data);
S.Data=Data;
S.si=si;
t_range(1,:)=[4.48 4.68];
t_range(2,:)=[7.82 8.12];
% t_range(1,:)=[17.48 17.78];
% t_range(2,:)=[8.03 8.33];

for i=1:size(t_range,1)
xrange=1:data_l;
XAxis_l=0.2*6/5;
pA_YAxis_h=0.6;
g_YAxis_h=0.4;
Scale_XAxis=0.04;
Scale_YAxis=0.075;
XLIM=[0 data_l*S.si*1e-6];
XLIM=t_range(i,:);
pA_YLIM=[-200 40];
g_YLIM=[-0.08 0.08];
X_Scale=(XLIM(end)-XLIM(1))/XAxis_l*Scale_XAxis;
pA_Y_Scale=(pA_YLIM(end)-pA_YLIM(1))/pA_YAxis_h*Scale_YAxis;
g_Y_Scale=(g_YLIM(end)-g_YLIM(1))/g_YAxis_h*Scale_YAxis;
figure('Units','normal',...
    'Position',[0 0 1 1],...
    'Visible', 'on');
h(1).handle=subplot(3,1,1);
plot(xrange*S.si*1e-6,S.Data(xrange,1),'r','LineWidth',3)
xlim(XLIM)
ylim(pA_YLIM)
h(2).handle=subplot(3,1,2);
plot(xrange*S.si*1e-6,S.Data(xrange,2),'b','LineWidth',6)
xlim(XLIM)
ylim(g_YLIM)
samexaxis('ytac','box','off');
h(3).handle=subplot(3,1,3);
plot([0;0], [0;1],'-k',[0;1], [0;0],'-k','LineWidth',4);
xlim([0 1]);
ylim([0 1]);
set(h(1).handle,'Units','normal',...
     'position',[0.4,0.4,XAxis_l,pA_YAxis_h],...
     'Visible','off')
 set(h(2).handle,'Units','normal',...
     'position',[0.4,0.2,XAxis_l,g_YAxis_h],...
     'Visible','off')
set(h(3).handle,'Units','normal',...
         'position',[0.65,0.3,Scale_XAxis,Scale_YAxis],...
         'Visible','off')
text(0.2,1.3,['\color{blue}' num2str(g_Y_Scale) 'g\color{black}/\color{red}' num2str(pA_Y_Scale) 'pA'],'fontsize',20,'fontweight','bold')
text(1.1,0,[num2str(X_Scale*1000) 'ms'],'fontsize',20,'fontweight','bold')
print(['Swim_example_',num2str(i)],'-dsvg')
end
%text(-19,1,'0.05Hz 0.06g','fontsize',32,'fontweight','bold')