S=load('EPSC_accel_ZL170901_fish04a_0009.mat');
v = VideoWriter('Rec_ZL170901_fish04a_0009.avi');
open(v);
figure('Units','normal',...
    'Position',[0 0 1 1],...
    'Visible', 'on');
unit_per_frame=1e6/S.si/30;
data_l=length(S.Data);
frame_num=floor(data_l/unit_per_frame);
XAxis_l=0.8;
pA_YAxis_h=0.6;
g_YAxis_h=0.2;
Scale_XAxis=0.04;
Scale_YAxis=0.075;
XLIM=[0 data_l*S.si*1e-6];
pA_YLIM=[-150 90];
g_YLIM=[-0.08 0.08];
X_Scale=(XLIM(end)-XLIM(1))/XAxis_l*Scale_XAxis;
pA_Y_Scale=(pA_YLIM(end)-pA_YLIM(1))/pA_YAxis_h*Scale_YAxis;
g_Y_Scale=(g_YLIM(end)-g_YLIM(1))/g_YAxis_h*Scale_YAxis;
for i=1:frame_num
xrange=1:round(i*unit_per_frame);
%xrange=1:data_l;
h(1).handle=subplot(3,1,1);
plot(xrange*S.si*1e-6,S.Data(xrange,1),'r','LineWidth',1)
xlim(XLIM)
ylim(pA_YLIM)
h(2).handle=subplot(3,1,2);
plot(xrange*S.si*1e-6,S.Data(xrange,2),'b','LineWidth',5)
xlim(XLIM)
ylim(g_YLIM)
samexaxis('ytac','box','off');
h(3).handle=subplot(3,1,3);
plot([0;0], [0;1],'-k',[0;1], [0;0],'-k','LineWidth',4);
xlim([0 1]);
ylim([0 1]);
set(h(1).handle,'Units','normal',...
     'position',[0.1,0.4,XAxis_l,pA_YAxis_h],...
     'Visible','off')
 set(h(2).handle,'Units','normal',...
     'position',[0.1,0.2,XAxis_l,g_YAxis_h],...
     'Visible','off')
set(h(3).handle,'Units','normal',...
         'position',[0.85,0.1,Scale_XAxis,Scale_YAxis],...
         'Visible','off')
text(0.2,1.3,['\color{blue}' num2str(g_Y_Scale) 'g\color{black}/\color{red}' num2str(pA_Y_Scale) 'pA'],'fontsize',20,'fontweight','bold')
text(1.1,0,[num2str(X_Scale) 's'],'fontsize',20,'fontweight','bold')
text(-19,1,'0.05Hz 0.06g','fontsize',32,'fontweight','bold')
%pause(0.1);
frame=getframe(gcf);
writeVideo(v,frame);
end
close(v);