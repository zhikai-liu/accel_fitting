function process_fit(filename_h)
%filename_h = 'ZL170518_fish01a'
f_mat = dir([filename_h '_0*.mat']);
for i =1:length(f_mat)
    clearvars name S poi S_period fit_model accel_axis
    S = load(f_mat(i).name);
    %filename = sprintf('ZL170511_fish01b_%.4d.abf',file_number);
    %if_fit = 0;
    %poi = repmat({{1:750000}},length(f_abf),1);
    poi = cell(1,length(S.poi));
    for j = 1:length(S.poi)
        poi_start = S.poi{j}(1)*1e6/S.si;
        poi_end = S.poi{j}(end)*1e6/S.si;
        poi{j} = poi_start:poi_end;
    end
    %F = figure('KeyPressFcn',{@file_move_by_key,f_abf,if_fit,poi,if_plot=1});
    %setappdata(F,'f_num',1);
    if_plot=0;
    [S_period,fit_model,accel_axis]= fit_accel(S.Data,S.si,S.name,poi,if_plot);
    [period_index,cycle_num] = cycle_fit(S.event_index,S.amps,fit_model,S_period);
    fit_freq = cell(1,length(fit_model)); fit_amp = fit_freq;
    for j = 1:length(fit_model)
        fit_amp{j} = fit_model{j}.a1;
        fit_freq{j} = fit_model{j}.b1*1e6/S.si/2/pi;
    end
    save([S.name '.mat'],'S_period','fit_model','accel_axis','fit_amp','fit_freq','period_index','cycle_num','-append')
end
end
% amp_thre = 6; diff_gap = 240; diff_thre =-8;
% [event_index, amps] = EPSC_detection(Data,si,amp_thre,diff_gap,diff_thre);
% save('test.mat','Data','si','event_index','amps')
% EPSC_check('test.mat',1)
