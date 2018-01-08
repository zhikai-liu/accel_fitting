function process_fit_auto(filename_h)
%filename_h = 'ZL170518_fish01a'
f_mat = dir([filename_h '*.mat']);
for i =1:length(f_mat)
    clearvars name S poi S_period fit_model accel_axis
    S = load(f_mat(i).name);
    poi = cell(1,length(S.poi));
    for j = 1:length(S.poi)
        poi_start = S.poi{j}(1)*1e6/S.si;
        poi_end = S.poi{j}(end)*1e6/S.si;
        poi{j} = poi_start+1:poi_end;
    end
    %F = figure('KeyPressFcn',{@file_move_by_key,f_abf,if_fit,poi,if_plot=1});
    %setappdata(F,'f_num',1);
    if_plot=0;
    [S_period,fit_model,accel_axis]= fit_auto_accel(S.Data,S.si,S.name,poi,if_plot);
    fit_freq = cell(1,length(fit_model)); fit_amp = fit_freq;
    for j = 1:length(fit_model)
        fit_amp{j} = fit_model{j}.a1;
        fit_freq{j} = fit_model{j}.b1*1e6/S.si/2/pi;
    end
    if isfield(S,'event_index')
        [period_index,cycle_num,per_cycle_index] = cycle_fit(S.event_index,S.amps,fit_model,S_period);
    else
        [period_index,cycle_num,per_cycle_index] = cycle_fit([],[],fit_model,S_period);
    end
        save(f_mat(i).name,'S_period','fit_model','accel_axis','fit_amp','fit_freq','period_index','cycle_num','per_cycle_index','-append')
end
end
