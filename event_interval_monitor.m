function event_interval_monitor(filename)
    S=load(filename);
    si=20;
    %% Each FName here is recording from one neuron
    FNames=fieldnames(S);
    for i=1:length(FNames)
        Freq_names=fieldnames(S.(FNames{i}));
        %% plot each figure with one neuron's data, different ampbins in separate subplots
        AmpBin_Num=length(S.(FNames{i}).S_freq_1(1).AmpBins);
        figure
        for h=1:AmpBin_Num
            %% Count intervals for each FName, sum all events together across frequencies
            interval_counts=[];
            subplot(AmpBin_Num,1,h)
            for j=1:length(Freq_names)
                freq_trials=length(S.(FNames{i}).(Freq_names{j}));
                %% some frequency has multiple trials, put them in the same interval counts too
                for k=1:freq_trials
                    intervals=diff(S.(FNames{i}).(Freq_names{j})(k).AmpBins(h).events).*si.*1e-6;
                    interval_counts=[interval_counts;intervals];
                end
            end
            %% plot histogram of IFR, 1000 = 1ms interval
            histogram(1./interval_counts,'BinWidth',100)
            amp_range=S.(FNames{i}).(Freq_names{j}).AmpBins(h).amp_range;
            text(0.4,0.8,[num2str(amp_range(1)) ' to ' num2str(amp_range(end)) ' pA' ],'units','Normalized')
        end
        text(0.4,-0.3,FNames{i},'units','Normalized','interpreter','none')
    end

end