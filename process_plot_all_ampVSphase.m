function process_plot_all_ampVSphase(filename,range)
    S=load(filename);
    Global=load('Accel_globalvar.mat');   
    if strcmp(range,'all')
        range=1:length(S.Trials);
    end
    S_amp=round([S.Trials(range).S_amp],2);
    S_freq=round([S.Trials(range).S_freq],1);
    freq_num=length(unique(S_freq));
    Freq_cor_value=Global.Freq_cor_value(1:freq_num);
    Amp_cor_value=Global.Amp_cor_value;
    Amp_order=cell(length(Amp_cor_value),1);
    Freq_order=cell(length(Freq_cor_value),1);
    for i=1:length(Amp_cor_value)
        Amp_order{i}=find(S_amp==Amp_cor_value{i});
    end
    for i=1:length(Freq_cor_value)
        Freq_order{i}=find(S_freq==Freq_cor_value{i});
    end
    color_all=colormap(jet(length(Freq_cor_value)));
    %color_all=colormap(jet(5));
    Amp_max=0;
    for i=1:length(Amp_order)
        if ~isempty(Amp_order{i})
        figure('units','normal','position',[0.1,0,0.7,1]);
        hold on;
        for j=1:length(Freq_order)
            if ~isempty(Freq_order{j})
                for k=1:length(Freq_order{j})
                    if sum(Amp_order{i}==Freq_order{j}(k))
                    trial_index=Freq_order{j}(k);
                    trial=range(trial_index);
                    Amps=S.Trials(trial).period_index.amp;
                    Amp_max=max(max(Amps),Amp_max);
                    Phases=S.Trials(trial).period_index.phase;
                    scatter(Phases,Amps,64,'filled',...
                        'MarkerFaceColor',color_all(j,:),...
                        'MarkerEdgeColor',color_all(j,:),...
                        'DisplayName',[num2str(S_freq(trial_index)),' Hz trial ' num2str(trial)]);    
                    end
                end
            end
        end
            hold off;
            LG=legend('show');
            set(LG,'Box','off','FontSize',30,'FontWeight','bold')
            A=gca;
            set(A.XAxis,'FontSize',30,'LineWidth',3,'FontWeight','bold');
            set(A.YAxis,'FontSize',30,'LineWidth',3,'FontWeight','bold');
            set(A,'XLim',[0 2*pi],...
                'YLim',[0 Amp_max*1.5])
           	ylabel('EPSC amplitude (pA)','FontSize',30,'FontWeight','bold')
            set(A,'XTick',[0 0.5*pi pi 1.5*pi 2*pi],...
                'XTickLabel',{'0','\pi/2', '\pi', '3\pi/2', '2\pi'})
            title({filename(1:end-4),[num2str(Amp_cor_value{i}) ' g']},'interpreter','none','FontSize',30,'FontWeight','bold')
            print([filename(1:end-4) '_' num2str(Amp_cor_value{i}) 'g_allFreq_ampVSphase_scatter.jpg'],...
                '-r300','-djpeg')
        end
    end
end
