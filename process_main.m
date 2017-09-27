filename_h = 'ZL170830_fish04b';
process_abf2mat(filename_h);
process_event_detect(['EPSC_*_accel_' filename_h]);
%process_event_detect(['EPSP_accel_' filename_h]);
process_fit(['EPSC_*_accel_' filename_h]);
%process_fit(['EPSP_accel_' filename_h]);
%Plot fitting results for all
%process_plot_fit(['EPSC_accel_' filename_h]);
%process_plot_fit(['EPSP_accel_' filename_h]);
%%process_plot_each_cycle(['EPSP_accel_' filename_h]);
%close all
%   Gather amplitudes and phase information together for further analysis
%   .mat file will be generated (Amps.mat and trials.mat)
%process_cell_opening(['EPSC_accel_' filename_h]);
process_gather(['EPSC_accel_' filename_h]);
%process_gather(['EPSP_accel_' filename_h]);
process_amp_dep_gain_phase(['Trials_EPSC_accel_' filename_h '.mat'],'all',0,'save'); % use 'all' or include the trials you want to use
%close all
process_plot_gain_phase_amp_freq_bode(['Trials_EPSC_accel_' filename_h '.mat'],'all'); % use 'all' or include the trials you want to use
process_plot_all_ampVSphase(['Trials_EPSC_accel_' filename_h '.mat'],'all')  % use 'all' or include the trials you want to use
%   Plot amp histogram for each recording file
% num_plot_per_figure = 4;
% process_amps_hist_plot(['EPSC_accel_' filename_h],num_plot_per_figure);
% close all
% %phase plot
% Amp_range1 = -120:-50;
% % Amp_range2 = -30:-15;
% % %process_phase_hist_plot('ZL170517_fish03a',num_plot_per_fig,Amp_range);
% process_phase_circ_plot(filename_h,Amp_range1);
% process_phase_circ_plot(filename_h,Amp_range2);