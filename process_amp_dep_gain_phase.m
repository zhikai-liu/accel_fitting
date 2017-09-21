function process_amp_dep_gain_phase(filename,range,varargin)       
    S=load(filename);
    if strcmp(range,'all')
        range=1:length(S.Trials);
    end
%     Amps=cell2mat( arrayfun(@(c) c.period_index.amp(:,:), S.Trials', 'Uniform', 0) );
%     Phases=cell2mat( arrayfun(@(c) c.period_index.phase(:,:), S.Trials', 'Uniform', 0) );
for trial=range
    Amps=S.Trials(trial).period_index.amp;
    Phases=S.Trials(trial).period_index.phase;
    binsize=2;
    figure('units','normal','position',[0.25,0,0.5,1]);
    h(1).handle=subplot(3,1,1);
    H=histogram(Amps,'BinWidth',binsize);
    %xlabel('pA 2pA/bin');
    ylabel('Number','FontSize',20);
    S_freq=S.Trials(trial).S_freq;
    S_amp=S.Trials(trial).S_amp;
    title({[S.Trials(trial).mat_file(1:end-4) ' Histogram'], [num2str(round(S_amp,2)) ' g ' num2str(round(S_freq,1)) ' Hz']},...
        'interpreter','none','FontSize',20)
    Edges=H.BinEdges;
    S_h=struct();
    for i=1:length(Edges)-1
        %S_h(i).amp=Amps(Amps>=Edges(i)&Amps<Edges(i+1));
        S_h(i).phase=Phases(Amps>=Edges(i)&Amps<Edges(i+1));
    end
    Amp_dep=struct();
    expand=1;
    for i=1:length(S_h)
        if i<=expand
            Bin_range=1:i+expand;
        elseif i>=length(S_h)-expand
            Bin_range=i-expand:length(S_h);
        else
            Bin_range=i-expand:i+expand;
        end
        Bin_phases=cell2mat( arrayfun(@(c) c.phase, S_h(Bin_range)', 'Uniform', 0) );
        if ~isempty(Bin_phases)
            Amp_dep(i).gain=circ_r(Bin_phases).*length(Bin_phases)./length(Bin_range).*S_freq./S_amp./S.Trials(trial).S_cycle;
            Amp_dep(i).phase=circ_mean(Bin_phases);
        else
            Amp_dep(i).gain=0;
            Amp_dep(i).phase=0;
        end
    end
    XData=(Edges(1:end-1)+Edges(2:end))/2;
    Sm_XData=linspace(XData(1),XData(end),(length(XData)-1)*10)';
    YGain=[Amp_dep(:).gain]';
    Sm_YGain=pchip(XData,YGain,Sm_XData);
    YPhase=[Amp_dep(:).phase]';
    %% Find phase cross -pi->pi that will cause unsmooth sudden phase shift
    pi_cross_NP=((YPhase(1:end-1)+pi/2<=0).*(YPhase(2:end)-pi/2>=0));
    pi_cross_PN=((YPhase(2:end)+pi/2<=0).*(YPhase(1:end-1)-pi/2>=0));
    Sm_YPhase=pchip(XData,YPhase,Sm_XData);
    XData_index_NP=find(pi_cross_NP);
    XData_index_PN=find(pi_cross_PN);
    %% Adjust those crossing points
    for i=1:length(XData_index_NP)
        Adj_XData=linspace(XData(XData_index_NP(i)),XData(XData_index_NP(i)+1),10)';
        Sm_YPhase((XData_index_NP(i)-1)*10+1:XData_index_NP(i)*10)=pchip(XData(1:XData_index_NP(i)+1),[YPhase(1:XData_index_NP(i));YPhase(XData_index_NP(i)+1)-2*pi],Adj_XData);
    end
    for i=1:length(XData_index_PN)
        Adj_XData=linspace(XData(XData_index_PN(i)),XData(XData_index_PN(i)+1),10)';
        Sm_YPhase((XData_index_PN(i)-1)*10+1:XData_index_PN(i)*10)=pchip(XData(1:XData_index_PN(i)+1),[YPhase(1:XData_index_PN(i));YPhase(XData_index_PN(i)+1)+2*pi],Adj_XData);
    end
    
    %% Plot Gain versus Amp
    h(2).handle=subplot(3,1,2);
    %bar(XData,YGain,'FaceColor','r','BarWidth',1)
    plot(Sm_XData,Sm_YGain,'r','LineWidth',4)
    ylabel('Gain FR/g','FontSize',20);
    %% Plot Phase versus Amp
    h(3).handle=subplot(3,1,3);
    color=[1 1 1].*(1-YGain./max(YGain));
    phase_scale=Sm_YGain./max(Sm_YGain);
    Sm_color=[1 1 1].*(1-phase_scale);
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
    plot([XData(1),XData(end)],[90 90],'k--');
    plot([XData(1),XData(end)],[180 180],'r--');
    plot([XData(1),XData(end)],[-90 -90],'k--');
    plot([XData(1),XData(end)],[-180 -180],'r--');
    hold off;
    ylim([-270 270]);
    yticks([-270 -180 -90 0 90 180 270])
    xlabel('pA 2pA/bin','FontSize',20);
    ylabel('Average phase','FontSize',20);
    %title({[S.Trials(trial).mat_file ' Phase'], [num2str(S.Trials(trial).S_freq) ' Hz ' num2str(S.Trials(trial).S_amp) ' g']},'interpreter','none')
    samexaxis('ytac','box','off');
    print(['AmpBode_' filename(1:end-4) '_trial_' num2str(trial) '_' num2str(round(S_amp,2)) 'g_' num2str(round(S_freq,1)) 'Hz_bin' num2str(binsize) 'pA_' 'expand' num2str(expand) 'bin.jpg'],...
        '-r300','-djpeg')
    %% Save gain and phase into file
    if ~isempty(varargin)
    if strcmp(varargin{1},'save')
    if exist(['AmpBode_' filename],'file')==2&&(~strcmp(varargin{2},'replace')||trial~=1)
        AmpBode=load(['AmpBode_' filename]);
    else
        AmpBode=struct();
    end
    Global=load('Accel_globalvar.mat');
%     Global.Amp_field_names={'POtwoG','POfourG','POsixG','POeightG','POneG'};
%     Global.Amp_cor_value={0.02,0.04,0.06,0.08,0.1};
%     Global.Freq_field_names={'halfHz','oneHz','twoHz','fourHz','eightHz','sixteenHz','thirtytwoHz'};
%     Global.Freq_cor_value={0.5,1,2,4,8,16,32};
%     save('Accel_globalvar.mat','-struct','Global')
    S_freq_round=round(S.Trials(trial).S_freq,1);%get s_freq with 1 decimal
    Freq_field=Global.Freq_field_names{[Global.Freq_cor_value{:}]==S_freq_round};
    S_amp_round=round(S.Trials(trial).S_amp,2);
    Amp_field=Global.Amp_field_names{[Global.Amp_cor_value{:}]==S_amp_round};
    if isfield(AmpBode,Amp_field)
        if isfield(AmpBode.(Amp_field),Freq_field)
            if isfield(AmpBode.(Amp_field).(Freq_field),'XData')
                NumOfRec=length(AmpBode.(Amp_field).(Freq_field).XData);
                AmpBode.(Amp_field).(Freq_field).XData{NumOfRec+1}=XData';
                AmpBode.(Amp_field).(Freq_field).YGain{NumOfRec+1}=YGain;
                AmpBode.(Amp_field).(Freq_field).YPhase{NumOfRec+1}=YPhase;
            else
                AmpBode.(Amp_field).(Freq_field).XData{1}=XData';
                AmpBode.(Amp_field).(Freq_field).YGain{1}=YGain;
                AmpBode.(Amp_field).(Freq_field).YPhase{1}=YPhase;
            end
        else
            AmpBode.(Amp_field).(Freq_field).XData{1}=XData';
            AmpBode.(Amp_field).(Freq_field).YGain{1}=YGain;
            AmpBode.(Amp_field).(Freq_field).YPhase{1}=YPhase;
        end
    else
            AmpBode.(Amp_field).(Freq_field).XData{1}=XData';
            AmpBode.(Amp_field).(Freq_field).YGain{1}=YGain;
            AmpBode.(Amp_field).(Freq_field).YPhase{1}=YPhase;
    end
    save(['AmpBode_' filename],'-struct','AmpBode')
    end
    end
end
end