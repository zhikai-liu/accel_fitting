EPSC_trials=load('Trials_EPSC_accel_ZL170901_fish04a.mat');
EPSP_trials=load('Trials_EPSP_accel_ZL170901_fish04a.mat');
for i=1:length(EPSC_trials.Trials)
    for j=1:length(EPSP_trials.Trials)
        if round(EPSC_trials.Trials(i).S_freq,1)==round(EPSP_trials.Trials(j).S_freq,1)...
                && round(EPSC_trials.Trials(i).S_amp,2)==round(EPSP_trials.Trials(j).S_amp,2)
            EPSC_file=load(EPSC_trials.Trials(i).mat_file);
            EPSP_file=load(EPSP_trials.Trials(j).mat_file);
            Stim_freq=round(EPSC_trials.Trials(i).S_freq,1);
            Stim_amp=round(EPSC_trials.Trials(i).S_amp,2);
            figure('Units','normal',...
                'Position',[0 0 1 1],...
                'Visible', 'on');
            h=struct();
            for k=1:2
                h(k).handle=subplot(3,1,k);
                plot_only_fit(EPSC_file.Data,...
                    EPSC_file.fit_model{EPSC_trials.Trials(i).poi_num},...
                    EPSC_file.S_period{EPSC_trials.Trials(i).poi_num},...
                    EPSC_file.accel_axis,...
                    EPSC_file.si,...
                    EPSC_file.type,...
                    k,Stim_amp*1.5);
                hold on;
                plot_only_fit(EPSP_file.Data,...
                    EPSP_file.fit_model{EPSP_trials.Trials(j).poi_num},...
                    EPSP_file.S_period{EPSP_trials.Trials(j).poi_num},...
                    EPSP_file.accel_axis,...
                    EPSP_file.si,...
                    EPSP_file.type,...
                    k,Stim_amp*1.5);
                if k==2
                    S_period=EPSP_file.S_period{EPSP_trials.Trials(j).poi_num};
                    si=EPSP_file.si;
                    S_period_sec=length(S_period)*si*1e-6;
                    text(-0.1*S_period_sec,Stim_amp*2,['\color{black}EPSP/\color{red}EPSC\color{black}: ' num2str(Stim_freq) ' Hz; ' num2str(Stim_amp) ' g'],'fontsize',20,'fontweight','bold');
                end
            hold off;
            end
            samexaxis('YAxisLocation','none','Box','off','ytac','join');
            h(3).handle=subplot(3,1,3);
            plot([0;0], [0;1],'-k',[0;1], [0;0],'-k','LineWidth',4);
            xlim([0 1]);
            ylim([0 1]);
            XAxis_l=[0.7,0.7];
            YAxis_h=[0.6,0.2];
            for l = 1:2
                set(h(l).handle,'Units','normal',...
                    'position',[0.1,1-0.2*l-0.5,XAxis_l(l),YAxis_h(l)],...
                    'Visible','off')
            end
            set(h(3).handle,'Units','normal',...
                     'position',[0.85,0.1,0.035,0.06],...
                     'Visible','off')
            text(0.2,1.3,'\color{black}16mV/\color{red}40pA','fontsize',20,'fontweight','bold')
            g_scale=round(2*1.5*Stim_amp/YAxis_h(2)*0.06,2);
            text(0.2,0.7,['\color{black}' num2str(g_scale) 'g' '/' '\color{red}' num2str(g_scale) 'g'],'fontsize',20,'fontweight','bold')
            x_scale=round(S_period_sec/XAxis_l(1)*0.035,2);
            text(1.1,0,[num2str(x_scale) 's'],'fontsize',20,'fontweight','bold')
            print(['Combined_EPSC' num2str(EPSC_trials.Trials(i).mat_file(end-7:end-4)) '_EPSP' num2str(EPSP_trials.Trials(j).mat_file(end-7:end-4)) '_' num2str(Stim_freq) 'Hz_' num2str(Stim_amp) 'g.jpg'],'-r300','-djpeg');
        end
    end
end

function plot_only_fit(Data,fit_model,S_period,accel_axis,si,type,subplot_order,Stim_amp)
    if strcmp(type,'EPSC+accel')||strcmp(type,'IPSC+accel')
    YLabel = {'pA','g','g','g'};
    Color='r';
    yAx='yyaxis left';
    yrange=[-200 200];
    elseif strcmp(type,'EPSP+accel')||strcmp(type,'IPSP+accel')
    YLabel = {'mV','g','g','g'};
    Color='k';
    yAx='yyaxis right';
    yrange=[-160 0];
    end
    %fit_accel_y = fit_model.a1.*sin(fit_model.b1.*S_period+fit_model.c1);
    xrange=S_period-S_period(1);
    if subplot_order==1
        eval(yAx);
        plot(xrange*si*1e-6,Data(S_period,1),Color,'LineWidth',2);
        ylabel(YLabel{1},'Rotation',0);
        ylim(yrange)
        xlim([xrange(1) xrange(end)]*si*1e-6)
    elseif subplot_order==2
        eval(yAx);
        plot(xrange*si*1e-6,Data(S_period,accel_axis),Color,'LineWidth',6)
        ylabel(YLabel{2},'Rotation',0);
        xlim([xrange(1) xrange(end)]*si*1e-6)
        ylim([-Stim_amp +Stim_amp])
    end
    xlabel('Second');
end