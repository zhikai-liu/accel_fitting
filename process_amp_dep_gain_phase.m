function Amp_dep=process_amp_dep_gain_phase(filename,trial)
    S=load(filename);
%     Amps=cell2mat( arrayfun(@(c) c.period_index.amp(:,:), S.Trials', 'Uniform', 0) );
%     Phases=cell2mat( arrayfun(@(c) c.period_index.phase(:,:), S.Trials', 'Uniform', 0) );
    Amps=S.Trials(trial).period_index.amp;
    Phases=S.Trials(trial).period_index.phase;
    binsize=2;
    figure('units','normal','position',[0.25,0,0.5,1]);
    h(1).handle=subplot(3,1,1);
    H=histogram(Amps,'BinWidth',binsize);
    %xlabel('pA 2pA/bin');
    ylabel('Number');
    title({[S.Trials(trial).mat_file ' Histogram'], [num2str(S.Trials(trial).S_freq) ' Hz ' num2str(S.Trials(trial).S_amp) ' g']},'interpreter','none')
    Edges=H.BinEdges;
    S_h=struct();
    for i=1:length(Edges)-1
        %S_h(i).amp=Amps(Amps>=Edges(i)&Amps<Edges(i+1));
        S_h(i).phase=Phases(Amps>=Edges(i)&Amps<Edges(i+1));
    end
    Amp_dep=struct();
    expand=0;
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
            Amp_dep(i).gain=circ_r(Bin_phases).*length(Bin_phases)./length(Bin_range).*S.Trials(trial).S_freq./S.Trials(trial).S_amp./S.Trials(trial).S_cycle;
            Amp_dep(i).phase=circ_mean(Bin_phases);
        else
            Amp_dep(i).gain=0;
            Amp_dep(i).phase=0;
        end
    end
    XData=[Edges(1:end-1)+Edges(2:end)]/2;
    YGain=[Amp_dep(:).gain]';
    h(2).handle=subplot(3,1,2);
    bar(XData,[Amp_dep(:).gain],'FaceColor','r','BarWidth',1)
    %xlabel('pA 2pA/bin');
    ylabel('gain fr/g');
    %title({[S.Trials(trial).mat_file ' Gain'], [num2str(S.Trials(trial).S_freq) ' Hz ' num2str(S.Trials(trial).S_amp) ' g']},'interpreter','none')
    h(3).handle=subplot(3,1,3);
    color=[1 1 1].*(1-YGain./max(YGain));
    hold on;
    for i=1:length(Amp_dep)
    bar(XData(i),[Amp_dep(i).phase].*180./pi,'FaceColor',color(i,:),'BarWidth',binsize)
    end
    hold off;
    xlabel('pA 2pA/bin');
    ylabel('average phase');
    %title({[S.Trials(trial).mat_file ' Phase'], [num2str(S.Trials(trial).S_freq) ' Hz ' num2str(S.Trials(trial).S_amp) ' g']},'interpreter','none')
    samexaxis('ytac','box','off');
end