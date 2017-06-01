%f_abf = dir('ZL170517_fish03a_0011.abf');
f_name = 'ZL170517_fish03a_0013.abf';
[Data,si,~] = abfload(f_name);
%filename = sprintf('ZL170511_fish01b_%.4d.abf',file_number);
if_fit = 0;
%poi = repmat({{1:750000}},length(f_abf),1);
poi = {1:750000};
%F = figure('KeyPressFcn',{@file_move_by_key,f_abf,if_fit,poi,if_plot=1});
%setappdata(F,'f_num',1);
if_plot=0;
[S_period,fit_model,accel_axis]= fit_accel(Data,si,f_name,poi,if_plot);
amp_thre = 6; diff_gap = 240; diff_thre =-8;
[event_index, amps] = EPSC_detection(Data,si,amp_thre,diff_gap,diff_thre);
save('test.mat','Data','si','event_index','amps')
EPSC_check('test.mat',1)
% F1 = figure;
% plot_accel_fit(Data,poi{1},fit_model{1},S_period{1},accel_axis,si);
% title(F1.Children(end),[f_name ' period ' num2str(1) ' of ' num2str(1)],'interpreter','none');
% F2 = figure;
% [cycle_index,amps_cycle] = plot_cycle_fit(Data,event_index,amps,poi{1},fit_model{1},S_period{1},si);
% F3 = figure;
% circ_plot(cycle_index,'pretty');

