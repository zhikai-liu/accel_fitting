function process_plot_each_cycle(filename_h)
f_abf = dir([filename_h '*.mat']);
for i =1:length(f_abf)
    clearvars S cycle_index amps_cycle
    S = load(f_abf(i).name);
    for j =1:length(S.poi)
        clearvars poi
        poi_start = S.poi{j}(1)*1e6/S.si;
        poi_end = S.poi{j}(end)*1e6/S.si;
        poi = poi_start:poi_end;
        F1 = figure;
        cycle_num = plot_every_cycle(S.Data,poi,S.fit_model{j},S.S_period{j});
        title(F1.Children(end),{[S.name ' (Period ' num2str(j) ') Total cycle ' num2str(cycle_num)], [' Sin: Freq ' num2str(S.fit_freq{j}) '  Amp ' num2str(S.fit_amp{j}) 'g ' ]},'interpreter','none');
        print([S.name '_period_' num2str(j) '_each_cycle.pdf'],'-fillpage','-dpdf');
    end
end