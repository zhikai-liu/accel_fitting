function process_plot_raster(filename_h,amp_range)
f_abf = dir([filename_h '*.mat']);
for i =1:length(f_abf)
    clearvars  T X
    T = load(f_abf(i).name);
    for j =6:length(T.Trials)
        clearvars raster F1
        raster = cell(T.Trials(j).S_cycle,1);
        for k =1:T.Trials(j).S_cycle
            clearvars phase amp X_index
            phase = T.Trials(j).per_cycle_index(k).phase;
            amp = T.Trials(j).per_cycle_index(k).amp;
            X_index = phase(amp>amp_range(1)&amp<amp_range(end));
            X_index = X_index.*180/pi;
            raster{k} = X_index';
        end
        F1 = figure;
        plotSpikeRaster(raster,'PlotType','vertline','TimePerBin',1,'SpikeDuration',2);
        Title = {[T.Trials(j).Filename ' Total cycle ' num2str(T.Trials(j).S_cycle)], [' Sin: Freq ' num2str(T.Trials(j).S_freq) '  Amp ' num2str(T.Trials(j).S_amp) 'g ' ]};
        title(Title,'interpreter','none');
       % print([S.name '_period_' num2str(j) '_each_cycle.pdf'],'-fillpage','-dpdf');
    end
end