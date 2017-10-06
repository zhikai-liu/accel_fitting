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
    trial = load(S.Trials(plot_order(i)).mat_file);
    period = plot_period{i}(1).*1e6/trial.si:plot_period{i}(end).*1e6/trial.si;
    h(i).pA=subplot(2*n+1,1,2*i-1);
    plot_cycle_overlay(trial.Data,1,trial.fit_model{S.Trials(plot_order(i)).poi_num},trial.S_period{S.Trials(plot_order(i)).poi_num},...
        'k','LineWidth',2)
    ylim(pA_YLIM_range);
%     A = gca;
%     set(A,'linewidth',4,'fontsize',20,'fontweight','bold')
%     set(A,'XTick',[])
%     set(A,'YTick',[-80 -40 0])
%     set(A.XAxis,'Visible','off')
    h(i).g=subplot(2*n+1,1,2*i);
    plot_cycle_overlay(trial.Data,2,trial.fit_model{S.Trials(plot_order(i)).poi_num},trial.S_period{S.Trials(plot_order(i)).poi_num},...
        'r','LineWidth',4)
    ylabel('g');
    ylim(g_YLIM_ragne);
    text(-4,0.1,[num2str(2^(i-2)) ' Hz 0.04g'],'fontsize',20,'fontweight','bold')
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
XAxis_l=0.16;
pA_YAxis_h=0.15;
g_YAxis_h=0.05;
for i = 1:n
    set(h(i).pA,'Units','normal',...
         'position',[0.4,1-0.25*i+0.1,XAxis_l,pA_YAxis_h],...
         'Visible','off')
     set(h(i).g,'Units','normal',...
         'position',[0.4,1-0.25*i+0.05,XAxis_l,g_YAxis_h],...
         'Visible','off')
     
end
set(h(2*n+1).scaleBar,'Units','normal',...
         'position',[0.6,0.1,0.04,0.05],...
         'Visible','off')
text(0.2,1.3,'\color{red}0.1g\color{black}/40pA','fontsize',20,'fontweight','bold')
text(1.1,0,'90^o','fontsize',20,'fontweight','bold')
print('severalFreq_example_cycle_overlay','-dsvg')


function plot_cycle_overlay(Data,dim,fit_model,S_period,varargin)
        t_per_cycle = round(2*pi/fit_model.b1);
        cycle_num = round(length(S_period)/t_per_cycle);
        t_unit = 2*pi/t_per_cycle;
        for i = 1:cycle_num
                hold on;
                plot(0:t_unit:2*pi,Data(S_period(1)+(i-1)*t_per_cycle:S_period(1)+i*t_per_cycle,dim),varargin{:})
                hold off;
        end
        xlim([0 2*pi]);
        xticks([0 pi/2 pi 3*pi/2 2*pi])
end
