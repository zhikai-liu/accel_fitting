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
hist_YLIM_range=[0 180];
pA_YLIM_range=[-120 0];
g_YLIM_ragne=[-0.05 0.05];
for i = 1:n
    trial = load(S.Trials(plot_order(i)).mat_file);
    period = plot_period{i}(1).*1e6/trial.si:plot_period{i}(end).*1e6/trial.si;
    h(i).hist=subplot(3*n+1,1,3*i-2);
    amp_range=40:90;
    plot_EPSC_hist(trial,amp_range);
    ylim(hist_YLIM_range);
    
    h(i).pA=subplot(3*n+1,1,3*i-1);
    plot_cycle_overlay(trial.Data,1,trial.fit_model{S.Trials(plot_order(i)).poi_num},trial.S_period{S.Trials(plot_order(i)).poi_num},...
        'k','LineWidth',1)
    text(0,-150,[num2str(2^(i-2)) ' Hz 0.04g'],'fontsize',20,'fontweight','bold')
    ylim(pA_YLIM_range);
%     A = gca;
%     set(A,'linewidth',4,'fontsize',20,'fontweight','bold')
%     set(A,'XTick',[])
%     set(A,'YTick',[-80 -40 0])
%     set(A.XAxis,'Visible','off')
    h(i).g=subplot(3*n+1,1,3*i);
    plot_cycle_overlay(trial.Data,2,trial.fit_model{S.Trials(plot_order(i)).poi_num},trial.S_period{S.Trials(plot_order(i)).poi_num},...
        'r','LineWidth',2)
    hold off;
    ylabel('g');
    ylim(g_YLIM_ragne);
%     A = gca;
%     set(A,'linewidth',4,'fontsize',20,'fontweight','bold')
%     set(A,'YTick',[-0.04 0 0.04])
%     if i~=n
%     set(A,'XTick',[])
%     set(A.XAxis,'Visible','off')
%     end

    xlabel('Second');
    samexaxis('ytac','box','off');
end
h(n+1).scaleBar=subplot(3*n+1,1,3*n+1);
plot([0;0], [0;1],'-k',[0;1], [0;0],'-k','LineWidth',4);
xlim([0 1]);
ylim([0 1]);
XAxis_l=0.16;
pA_YAxis_h=0.15;
hist_YAxis_h=0.15;
g_YAxis_h=0.1;
for i = 1:n
    set(h(i).hist,'Units','normal',...
         'position',[0.16*(i-1)+0.2,0.55,XAxis_l,hist_YAxis_h],...
         'Visible','off')
    set(h(i).pA,'Units','normal',...
         'position',[0.16*(i-1)+0.2,0.4,XAxis_l,pA_YAxis_h],...
         'Visible','off')
    set(h(i).g,'Units','normal',...
         'position',[0.16*(i-1)+0.2,0.55,XAxis_l,g_YAxis_h],...
         'Visible','off')
     
end
set(h(n+1).scaleBar,'Units','normal',...
         'position',[0.8,0.3,0.04,0.05],...
         'Visible','off')
text(0.2,1.3,{'\color{red}0.05g\color{black}/40pA','60 EPSC/s'},'fontsize',20,'fontweight','bold')
text(-1,-0.7,{'            1/4 cycle','(500ms/250ms/125ms/62.5ms)'},'fontsize',20,'fontweight','bold')
print('severalFreq_example_cycle_overlay','-dsvg')


function plot_cycle_overlay(Data,dim,fit_model,S_period,varargin)
        period_phase.raw=mod(S_period*fit_model.b1+fit_model.c1,2*pi);
        period_phase.diff=diff(period_phase.raw);
        period_phase.diff_index=find(period_phase.diff<0);
%         t_per_cycle = round(2*pi/fit_model.b1);
%         cycle_num = round(length(S_period)/t_per_cycle);
%         %t_unit = 2*pi/t_per_cycle;
        for i = 1:length(period_phase.diff_index)
                hold on;
                if period_phase.diff_index(i)>1
                    if i==1
                        plot_index=1:period_phase.diff_index(i);
                    else
                        plot_index=period_phase.diff_index(i-1)+1:period_phase.diff_index(i);
                    end
                        plot(period_phase.raw(plot_index),Data(S_period(plot_index),dim),...
                            varargin{:})
                end
                
        end
        if period_phase.diff_index(end)+1<length(period_phase.raw)
            plot_index=period_phase.diff_index(end)+1:length(period_phase.raw);
            plot(period_phase.raw(plot_index),Data(S_period(plot_index),dim),...
                            varargin{:})
        end
        hold off;
        xlim([0 2*pi]);
        xticks([0 pi/2 pi 3*pi/2 2*pi])
end
function plot_EPSC_hist(trial,amp_range)
    n_cycles=length(trial.per_cycle_index);
    phases_to_hist=trial.period_index.phase(trial.period_index.amp>amp_range(1)&trial.period_index.amp<amp_range(end));
    phases_to_hist=mod(phases_to_hist,2*pi);
    phases_r=sum(exp(1i*phases_to_hist));
    phases_angle=angle(phases_r);
    if phases_angle<0
        phases_angle=phases_angle+2*pi;
    end
    phases_mean=abs(phases_r)./n_cycles.*trial.fit_freq{1};
    nbins=36;
    xbins=linspace(0,2*pi,nbins+1);
    [counts,centers]=hist(phases_to_hist,xbins);
    bar(centers,counts./n_cycles.*trial.fit_freq{1}.*nbins,...
        'BarWidth',1,'FaceColor',[0.7,0.7,0.7],'EdgeColor',[0.7,0.7,0.7]);
    hold on;
    arrow_x=[phases_angle phases_angle];
    arrow_y=[0 phases_mean*2];
%     drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0,varargin{:} );
%     drawArrow(arrow_x,arrow_y,'Linewidth',4,'Color','blue','MaxHeadSize',0.05)
    ann=annotation('arrow');
    ann.Parent=gca;
    ann.X=arrow_x;
    ann.Y=arrow_y;
    ann.Color='blue';
    ann.LineWidth=2;
    ann.HeadWidth=10;
    ann.HeadLength=10;
    hold off;
end