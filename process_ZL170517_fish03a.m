f_abf = dir('ZL170517_fish03a_00*.mat');
for i =1:length(f_abf)
    clearvars name S poi S_period fit_model accel_axis
    [~,name,~] = fileparts(f_abf(i).name);
    S = load(f_abf(i).name);
    %filename = sprintf('ZL170511_fish01b_%.4d.abf',file_number);
    if_fit = 0;
    %poi = repmat({{1:750000}},length(f_abf),1);
    poi_start = S.poi{1}(1)*1e6/S.si;
    poi_end = S.poi{1}(end)*1e6/S.si;
    poi = {poi_start:poi_end};
    %F = figure('KeyPressFcn',{@file_move_by_key,f_abf,if_fit,poi,if_plot=1});
    %setappdata(F,'f_num',1);
    if_plot=0;
    [S_period,fit_model,accel_axis]= fit_accel(S.Data,S.si,name,poi,if_plot);
    save([name '.mat'],'S_period','fit_model','accel_axis','-append')
end
% amp_thre = 6; diff_gap = 240; diff_thre =-8;
% [event_index, amps] = EPSC_detection(Data,si,amp_thre,diff_gap,diff_thre);
% save('test.mat','Data','si','event_index','amps')
% EPSC_check('test.mat',1)
for i =1:length(f_abf)
    clearvars S cycle_index amps_cycle
    S = load(f_abf(i).name);
    poi_start = S.poi{1}(1)*1e6/S.si;
    poi_end = S.poi{1}(end)*1e6/S.si;
    poi = {poi_start:poi_end};
    F1 = figure;
    plot_accel_fit(S.Data,poi{1},S.fit_model{1},S.S_period{1},S.accel_axis,si);
    title(F1.Children(end),[S.name ' period ' num2str(1) ' of ' num2str(1)],'interpreter','none');
    F2 = figure;
    [cycle_index,amps_cycle] = plot_cycle_fit(S.Data,S.event_index,S.amps,poi{1},S.fit_model{1},S.S_period{1},S.si);
    F3 = figure;
    circ_plot(cycle_index,'pretty');
end

