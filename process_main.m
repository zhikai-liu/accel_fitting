% view files 
process_view_files('ZL170517_fish03a');

process_EPSC_detect('ZL170517_fish03a');
process_fit('ZL170517_fish03a');
%Plot fitting results for all
process_plot_fit('ZL170517_fish03a')
%Gather amplitudes and phase information together for further analysis
% .mat file will be generated (Amps.mat and trials.mat)
process_gather('ZL170517_fish03a');
%Plot amp histogram for each recording file
num_plot_per_figure = 8;
process_amps_hist_plot('ZL170517_fish03a',num_plot_per_figure);
%phase plot
Amp_range = -80:-40;
process_phase_hist_plot('ZL170517_fish03a',num_plot_per_fig,Amp_range)
