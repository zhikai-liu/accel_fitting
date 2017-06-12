function process_plot_raster(filename_h,plot_range,amp_range)
f_abf = dir([filename_h '*.mat']);
for i =1:length(f_abf)
    clearvars T X
    T = load(f_abf(i).name);
    X = 0.1:0.1:360;
    for j = plot_range
        clearvars raster F1
        raster = zeros(T.Trials(j).S_cycle,length(X));
        for k =1:T.Trials(j).S_cycle
            clearvars phase amp X_index
            phase = T.Trials(j).per_cycle_index(k).phase;
            amp = T.Trials(j).per_cycle_index(k).amp;
            X_index = phase(amp>amp_range(1)&amp<amp_range(end));
            X_index = round(X_index.*180/pi,1).*10;
            raster(k,int64(X_index)) = 1;
        end
        raster = logical(raster);
        %plotSpikeRaster(raster,'TimePerBin',0.1,'PlotType','vertline');
        timePerBin = 0.1;
        plotRaster(raster,timePerBin)
        %Title = {[T.Trials(j).Filename ' Total cycle ' num2str(T.Trials(j).S_cycle)], [' Sin: Freq ' num2str(T.Trials(j).S_freq) '  Amp ' num2str(T.Trials(j).S_amp) 'g ' ]};
        Title = {[num2str(round(T.Trials(j).S_freq,1)) ' Hz'], [num2str(round(T.Trials(j).S_amp,2)) 'g ' ]};
        ylabel(Title,'interpreter','none');
       % print([S.name '_period_' num2str(j) '_each_cycle.pdf'],'-fillpage','-dpdf');
    end
end