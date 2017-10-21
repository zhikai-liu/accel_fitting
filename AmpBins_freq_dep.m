S=load('ampbin_info.mat');
S_amp=0.02;
S_freq=[0.5 1 2 4 8];
FNames=fieldnames(S);
H=struct();
T_select=struct();
for i=1:length(FNames)
    ampbin_num=length(S.(FNames{i}));
    T=load(['Trials_EPSC_auto_accel_' FNames{i} '.mat']);
    amp_select=round([T.Trials.S_amp],2)==S_amp;
    T_select(i).FName=FNames{i};
    trials_all=1:length(T.Trials);
    trials_A_select=trials_all(amp_select);
    trials_select=[];
    A_select=T.Trials(amp_select);
    for k=1:length(S_freq)
        freq_select=round([A_select.S_freq],1)==S_freq(k);
        F_select=A_select(freq_select);
        trials_F_select=trials_A_select(freq_select);
        trials_select=[trials_select,trials_F_select];
        for h=1:length(F_select)
            H.(FNames{i}).(['S_freq_' num2str(k)])(h).S_freq=S_freq(k);
            H.(FNames{i}).(['S_freq_' num2str(k)])(h).period_index=F_select(h).period_index;
            H.(FNames{i}).(['S_freq_' num2str(k)])(h).S_cycle=F_select(h).S_cycle;
            H.(FNames{i}).(['S_freq_' num2str(k)])(h).AmpBins=S.(FNames{i});
            H.(FNames{i}).(['S_freq_' num2str(k)])(h).trial_num=trials_F_select(h);
            amps=F_select(h).period_index.amp;
            phases=F_select(h).period_index.phase;
            events=F_select(h).period_index.event_index;
            for j=1:ampbin_num
                amp_range=S.(FNames{i})(j).amp_range;
                direction=S.(FNames{i})(j).direction;
                H.(FNames{i}).(['S_freq_' num2str(k)])(h).AmpBins(j).phase=phases(amps>amp_range(1)&amps<amp_range(end));
                H.(FNames{i}).(['S_freq_' num2str(k)])(h).AmpBins(j).amp=amps(amps>amp_range(1)&amps<amp_range(end));
                H.(FNames{i}).(['S_freq_' num2str(k)])(h).AmpBins(j).events=events(amps>amp_range(1)&amps<amp_range(end));
            end
        end
    end
    T_select(i).trials_select=trials_select;
end
save('Trials_freq_dep.mat','-struct','H');
save('Trials_freq_dep_t_select.mat','T_select');