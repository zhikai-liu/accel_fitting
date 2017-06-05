function process_plot_fit(filename_h)
f_abf = dir([filename_h '*.mat']);
for i =1:length(f_abf)
    clearvars S cycle_index amps_cycle
    S = load(f_abf(i).name);
    poi_start = S.poi{1}(1)*1e6/S.si;
    poi_end = S.poi{1}(end)*1e6/S.si;
    poi = {poi_start:poi_end};
    F1 = figure;
    plot_accel_fit(S.Data,poi{1},S.fit_model{1},S.S_period{1},S.accel_axis,S.si);
    title(F1.Children(end),[S.name ' period ' num2str(1) ' of ' num2str(1)],'interpreter','none');
    F2 = figure;
    plot_cycle_fit(S.Data,S.event_index,S.amps,poi{1},S.fit_model{1},S.S_period{1},S.si);
end
