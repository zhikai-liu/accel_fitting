function process_fista_accel_fit(filename)
    S=load(filename);
    poi = cell(1,length(S.poi));
    for j = 1:length(S.poi)
        poi_start = S.poi{j}(1)*1e6/S.si;
        poi_end = S.poi{j}(end)*1e6/S.si;
        poi{j} = poi_start+1:poi_end;
    end
    if_plot=0;
    [S_period,fit_model,accel_axis,other_axis_fit,other_axis]= fit_man_accel(S.Data,S.si,S.name,poi,if_plot);
    fit_freq = cell(1,length(fit_model)); fit_amp = fit_freq;
    for j = 1:length(fit_model)
        fit_amp{j} = fit_model{j}.a1;
        fit_freq{j} = fit_model{j}.b1*1e6/S.si/2/pi;
    end
    if isfield(S,'fista')
        fista = fista_cycle_fit(S.fista,fit_model,S_period);
    end
    cycle_num=fista.cycle_num;
    save(filename,'fista','S_period','fit_model','accel_axis',...
        'other_axis_fit','other_axis','fit_amp','fit_freq',...
        'cycle_num','-append')
end