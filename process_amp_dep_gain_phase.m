function process_amp_dep_gain_phase(filename,range,if_plot,varargin)       
    S=load(filename);
    if strcmp(range,'all')
        range=1:length(S.Trials);
    end
%     Amps=cell2mat( arrayfun(@(c) c.period_index.amp(:,:), S.Trials', 'Uniform', 0) );
%     Phases=cell2mat( arrayfun(@(c) c.period_index.phase(:,:), S.Trials', 'Uniform', 0) );
for trial=range
    Amps=S.Trials(trial).period_index.amp;
    Phases=S.Trials(trial).period_index.phase;
    S_freq=S.Trials(trial).S_freq;
    S_amp=S.Trials(trial).S_amp;
    X_Amp_step=1;
    Amp_bin=6;
    X_Amp=floor(min(Amps)):X_Amp_step:ceil(max(Amps));
    S_h=struct();
    for i=1:length(X_Amp)
        %S_h(i).amp=Amps(Amps>=Edges(i)&Amps<Edges(i+1));
        amp_range=[max(X_Amp(i)-Amp_bin/2,X_Amp(1)), min(X_Amp(i)+Amp_bin/2,X_Amp(end))];
        S_h(i).bin_phase=Phases(Amps>=amp_range(1)&Amps<amp_range(end));
        if ~isempty(S_h(i).bin_phase)
            S_h(i).gain=circ_r(S_h(i).bin_phase).*length(S_h(i).bin_phase)./Amp_bin.*S_freq./S.Trials(trial).S_cycle;
            S_h(i).phase=circ_mean(S_h(i).bin_phase);
        else
            S_h(i).gain=0;
            S_h(i).phase=0;
        end
    end
    YGain=[S_h(:).gain]';
    YPhase=[S_h(:).phase]';
    %% plot results
    if if_plot==1
        binsize=2;
        figure('units','normal','position',[0.25,0,0.5,1]);
        %% plot histogram for amp distribution
        h(1).handle=subplot(3,1,1);
        H=histogram(Amps,'Normalization','count','BinWidth',binsize);
        ylabel('Number','FontSize',20);
        title({[S.Trials(trial).mat_file(1:end-4) ' Histogram'], [num2str(round(S_amp,2)) ' g ' num2str(round(S_freq,1)) ' Hz']},...
        'interpreter','none','FontSize',20)
        Sm_XData=linspace(X_Amp(1),X_Amp(end),(length(X_Amp)-1)*10)';
        Sm_YGain=pchip(X_Amp,YGain,Sm_XData);
        %% Find phase cross -pi->pi that will cause unsmooth sudden phase shift
        pi_cross_NP=((YPhase(1:end-1)+pi/2<=0).*(YPhase(2:end)-pi/2>=0));
        pi_cross_PN=((YPhase(2:end)+pi/2<=0).*(YPhase(1:end-1)-pi/2>=0));
        Sm_YPhase=pchip(X_Amp,YPhase,Sm_XData);
        XData_index_NP=find(pi_cross_NP);
        XData_index_PN=find(pi_cross_PN);
        %% Adjust those crossing points
        for i=1:length(XData_index_NP)
            Adj_XData=linspace(X_Amp(XData_index_NP(i)),X_Amp(XData_index_NP(i)+1),10)';
            Sm_YPhase((XData_index_NP(i)-1)*10+1:XData_index_NP(i)*10)=pchip(X_Amp(1:XData_index_NP(i)+1),[YPhase(1:XData_index_NP(i));YPhase(XData_index_NP(i)+1)-2*pi],Adj_XData);
        end
        for i=1:length(XData_index_PN)
            Adj_XData=linspace(X_Amp(XData_index_PN(i)),X_Amp(XData_index_PN(i)+1),10)';
            Sm_YPhase((XData_index_PN(i)-1)*10+1:XData_index_PN(i)*10)=pchip(X_Amp(1:XData_index_PN(i)+1),[YPhase(1:XData_index_PN(i));YPhase(XData_index_PN(i)+1)+2*pi],Adj_XData);
        end

        %% Plot Gain versus Amp
        h(2).handle=subplot(3,1,2);
        %bar(XData,YGain,'FaceColor','r','BarWidth',1)
        plot(Sm_XData,Sm_YGain,'r','LineWidth',4)
        ylabel('Gain FR','FontSize',20);
        %% Plot Phase versus Amp
        h(3).handle=subplot(3,1,3);
        phase_scale=Sm_YGain./max(Sm_YGain);
        Sm_color=[1 1 1].*(1-phase_scale)+[0 0 0].*phase_scale;
        hold on;
    %     for i=1:length(YPhase)
    %     bar(XData(i),YPhase(i).*180./pi,'FaceColor',color(i,:),'EdgeColor',color(i,:),'BarWidth',binsize)
    %     end
        X_NoDraw=[XData_index_NP.*10;XData_index_PN.*10];
        for i=1:length(Sm_YPhase)-1
            if ~ismember(i,X_NoDraw)
            plot([Sm_XData(i) Sm_XData(i+1)],[Sm_YPhase(i) Sm_YPhase(i+1)].*180./pi,...
                'Color',Sm_color(i,:),'LineWidth',6*phase_scale(i)+0.1)
            end
        end
        plot([X_Amp(1),X_Amp(end)],[90 90],'k--');
        plot([X_Amp(1),X_Amp(end)],[180 180],'r--');
        plot([X_Amp(1),X_Amp(end)],[-90 -90],'k--');
        plot([X_Amp(1),X_Amp(end)],[-180 -180],'r--');
        hold off;
        ylim([-270 270]);
        yticks([-270 -180 -90 0 90 180 270])
        xlabel('EPSC amplitude (pA)','FontSize',20);
        ylabel('Average phase','FontSize',20);
        %title({[S.Trials(trial).mat_file ' Phase'], [num2str(S.Trials(trial).S_freq) ' Hz ' num2str(S.Trials(trial).S_amp) ' g']},'interpreter','none')
        samexaxis('ytac','box','off');
        print(['AmpBode_' filename(1:end-4) '_trial_' num2str(trial) '_' num2str(round(S_amp,2)) 'g_' num2str(round(S_freq,1)) 'Hz_bin' num2str(Amp_bin) 'pA.jpg'],...
            '-r300','-djpeg')
    end
    
    %% Save gain and phase info into file
    if ~isempty(varargin)
    if strcmp(varargin{1},'save')
    S.Trials(trial).X_Amp=X_Amp;
    S.Trials(trial).YGain=YGain;
    S.Trials(trial).YPhase=YPhase;
    S.Trials(trial).X_Amp_step=X_Amp_step;
    save(filename,'-struct','S')
    end
    end
end
end