function process_phase_hist_plot(filename_h,num_plot_per_fig,Amp_range)
f_abf = dir([filename_h '*.mat']);
f_num = length(f_abf);
Rem = mod(f_num,num_plot_per_fig);
fig_num = (f_num-Rem)/num_plot_per_fig;
for i = 1:fig_num+1
    Phase_plot = cell(0);
    phase_legend = cell(0);
    for j =1:num_plot_per_fig
        clearvars S
        file_num = (i-1)*num_plot_per_fig+j;
        if file_num<=f_num
            S = load(f_abf(file_num).name);
            for k =1:length(S.fit_model)
                Phase_plot = [Phase_plot {S.period_index(k).phase(S.period_index(k).amp>Amp_range(1)&S.period_index(k).amp<Amp_range(end))}];
                phase_legend = [phase_legend,{['Freq_' num2str(S.fit_freq{k}) '_Amp_' num2str(S.fit_amp{k})]}];
            end
        end
    end
    figure;
    nhist(Phase_plot,'legend',phase_legend,'binfactor',10,'separate')
    clearvars Phase_plot
end
end