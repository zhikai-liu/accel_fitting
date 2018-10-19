function process_export_to_excel(filename)
    S=load(filename);
    T=struct();
    for i=1:length(S.Trials)
        %% Info that can be directly obtained from the filename
        T(i).name=S.Trials(i).mat_file;
        T(i).poi_num=S.Trials(i).poi_num;
        T(i).S_freq=round(S.Trials(i).S_freq,2);
        T(i).S_amp=round(S.Trials(i).S_amp,2);
        T(i).S_cycle=S.Trials(i).S_cycle;
        T(i).clust_num=S.Trials(i).fista.clust_num;
        %% Gain and phase of each cluster need to be calculated from info in
        %fista
        phase=S.Trials(i).fista.period_index.phase;
        X1_clust=S.Trials(i).fista.period_index.X1_clust;
        amps=S.Trials(i).fista.period_index.amps;
        event_index=S.Trials(i).fista.period_index.event_index;
        %% Exclude chemical events if labeled
        if isfield(S.Trials(i).fista.period_index,'X1_chemical')
            phase=phase(~S.Trials(i).fista.period_index.X1_chemical);
            X1_clust=X1_clust(~S.Trials(i).fista.period_index.X1_chemical);
            amps=amps(~S.Trials(i).fista.period_index.X1_chemical);
            event_index=event_index(~S.Trials(i).fista.period_index.X1_chemical);
        end
        %% Only include events within the period of stimulation, sometimes multiple periods were performed in one trial
        phase=phase(event_index>S.Trials(i).S_period(1)&event_index<S.Trials(i).S_period(end));
        X1_clust=X1_clust(event_index>S.Trials(i).S_period(1)&event_index<S.Trials(i).S_period(end));
        amps=amps(event_index>S.Trials(i).S_period(1)&event_index<S.Trials(i).S_period(end));
        %% Calculate phase/gain/amp for each cluster and put them as fields for writing out in tables
        for j=1:T(i).clust_num
            clust_phase=phase(X1_clust==j);
            clust_amps=amps(X1_clust==j);
            phase_sum=sum(exp(1i*clust_phase));
            T(i).(['c' num2str(j) '_phase'])=round(angle(phase_sum),2);
            T(i).(['c' num2str(j) '_gain'])=round(abs(phase_sum)./T(i).S_cycle.*T(i).S_freq,2);
            T(i).(['c' num2str(j) '_amp'])=round(mean(clust_amps),2);
        end
    end
    writetable(struct2table(T),[filename '.csv']);
end