% plot for several frequency
plot_order = [9 8 7 10];
plot_period = {5:9,4:8,4:8,3.5:0.5:7.5};
S=load('Trials_EPSC_accel_ZL170517_fish03a.mat');
figure('Units','normal',...
    'Position',[0 0 1 1],...
    'Visible', 'on');
h=struct();
n = length(plot_order);
XLIM_range=[-0.5 4.5];
pA_YLIM_range=[-120 0];
g_YLIM_ragne=[-0.05 0.05];
for i = 1:n
    trial = load(['EPSC_accel_' S.Trials(plot_order(i)).Filename '.mat']);
    period = plot_period{i}(1).*1e6/trial.si:plot_period{i}(end).*1e6/trial.si;
    h(i).pA=subplot(2*n+1,1,2*i-1);
    plot([1:length(period)].*trial.si.*1e-6,smooth(trial.Data(period,1)),'r','LineWidth',2.5);
    ylabel('pA');
    ylim(pA_YLIM_range);
    xlim(XLIM_range);
%     A = gca;
%     set(A,'linewidth',4,'fontsize',20,'fontweight','bold')
%     set(A,'XTick',[])
%     set(A,'YTick',[-80 -40 0])
%     set(A.XAxis,'Visible','off')
    h(i).g=subplot(2*n+1,1,2*i);
    plot([1:length(period)].*trial.si.*1e-6,smooth(trial.Data(period,2),5e3,'sgolay'),'b','LineWidth',6);
    ylabel('g');
    xlim(XLIM_range);
    ylim(g_YLIM_ragne);
    text(-0.55,0.1,[num2str(2^(i-2)) ' Hz 0.04g'],'fontsize',20,'fontweight','bold')
%     A = gca;
%     set(A,'linewidth',4,'fontsize',20,'fontweight','bold')
%     set(A,'YTick',[-0.04 0 0.04])
%     if i~=n
%     set(A,'XTick',[])
%     set(A.XAxis,'Visible','off')
%     end
end
xlabel('Second');
samexaxis('ytac','box','off');
h(2*n+1).scaleBar=subplot(2*n+1,1,2*n+1);
plot([0;0], [0;1],'-k',[0;1], [0;0],'-k','LineWidth',4);
xlim([0 1]);
ylim([0 1]);
XAxis_l=0.8;
pA_YAxis_h=0.15;
g_YAxis_h=0.05;
for i = 1:n
    set(h(i).pA,'Units','normal',...
         'position',[0.1,1-0.25*i+0.1,XAxis_l,pA_YAxis_h],...
         'Visible','off')
     set(h(i).g,'Units','normal',...
         'position',[0.1,1-0.25*i+0.05,XAxis_l,g_YAxis_h],...
         'Visible','off')
     
end
set(h(2*n+1).scaleBar,'Units','normal',...
         'position',[0.85,0.1,0.04,0.05],...
         'Visible','off')
text(0.2,1.3,'\color{blue}0.1g\color{black}/\color{red}40pA','fontsize',20,'fontweight','bold')
text(1.1,0,'0.25s','fontsize',20,'fontweight','bold')



