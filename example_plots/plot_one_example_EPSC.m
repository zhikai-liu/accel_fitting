% plot for several frequency
plot_order = [1];
plot_period = {5.7:0.1:6.2};
S=load('Trials_EPSC_accel_ZL170901_fish04a.mat');
figure('Units','normal',...
    'Position',[0 0 1 1],...
    'Visible', 'on');
h=struct();
n = length(plot_order);
XLIM_range=[0 0.5];
pA_YLIM_range=[-200 40];
g_YLIM_range=[-0.08 0.08];
for i = 1:n
    trial = load(S.Trials(plot_order(i)).mat_file);
    period = plot_period{i}(1).*1e6/trial.si:plot_period{i}(end).*1e6/trial.si;
    h(i).pA=subplot(2*n+1,1,2*i-1);
    plot([1:length(period)].*trial.si.*1e-6,smooth(trial.Data(period,1)),'r','LineWidth',2.5);
    ylabel('pA');
    ylim(pA_YLIM_range);
    xlim(XLIM_range);
    h(i).g=subplot(2*n+1,1,2*i);
    plot([1:length(period)].*trial.si.*1e-6,smooth(trial.Data(period,2),5e3,'sgolay'),'b','LineWidth',6);
    ylabel('g');
    xlim(XLIM_range);
    ylim(g_YLIM_range);
    text(-0.55,-0.1,[num2str(2^(i-2)) ' Hz 0.06g'],'fontsize',40,'fontweight','bold')
end
xlabel('Second');
samexaxis('ytac','box','off');
h(2*n+1).scaleBar=subplot(2*n+1,1,2*n+1);
plot([0;0], [0;1],'-k',[0;1], [0;0],'-k','LineWidth',10);
xlim([0 1]);
ylim([0 1]);
XAxis_l=0.8;
pA_YAxis_h=0.4;
g_YAxis_h=0.2;
scale_XAxis=0.04/7*10;
scale_YAxis=0.075;

unit_YAxis_pA=(pA_YLIM_range(2)-pA_YLIM_range(1))/pA_YAxis_h*scale_YAxis;
unit_YAxis_g=(g_YLIM_range(2)-g_YLIM_range(1))/g_YAxis_h*scale_YAxis;
unit_XAxis_time=(XLIM_range(2)-XLIM_range(1))/XAxis_l*scale_XAxis;


for i = 1:n
    set(h(i).pA,'Units','normal',...
         'position',[0.1,0.5-0.25*i+0.1,XAxis_l,pA_YAxis_h],...
         'Visible','off')
     set(h(i).g,'Units','normal',...
         'position',[0.1,0.5-0.25*i+0.05,XAxis_l,g_YAxis_h],...
         'Visible','off')
     
end
set(h(2*n+1).scaleBar,'Units','normal',...
         'position',[0.85,0.1,scale_XAxis,scale_YAxis],...
         'Visible','off')
text(0.2,1.3,['\color{blue}' num2str(round(unit_YAxis_g,3)) 'g\color{red}/\color{red}' num2str(round(unit_YAxis_pA,2)) 'pA'],'fontsize',40,'fontweight','bold')
text(1.1,0,[num2str(round(unit_XAxis_time,2)) 's'],'fontsize',40,'fontweight','bold')
print('one_example_frac','-dsvg')
print('one_example_frac','-r300','-djpeg')

