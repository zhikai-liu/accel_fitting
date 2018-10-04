function process_2d_fit_linear(fname)
f_mat=dir([fname '*']);
X=load(f_mat(1).name);
X=add_accel_fit(X);
Y=load(f_mat(2).name);
Y=add_accel_fit(Y);
XpYp=load(f_mat(3).name);
base=[1/sqrt(2),-1/sqrt(2);1/sqrt(2),1/sqrt(2)];
XpYp.Data(:,2:3)=XpYp.Data(:,2:3)*base;
XpYp=add_accel_fit(XpYp);
XpYn=load(f_mat(4).name);
XpYn.Data(:,2:3)=XpYn.Data(:,2:3)*base;
XpYn=add_accel_fit(XpYn);
save(['2d_linear_' fname '.mat'],'X','Y','XpYp','XpYn','-append');
end

function S=add_accel_fit(S)
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
        S.fista = fista_cycle_fit(S.fista,fit_model,S_period);
    end
    S.S_period=S_period;
    S.fit_model=fit_model;
    S.accel_axis=accel_axis;
    S.other_axis_fit=other_axis_fit;
    S.other_axis=other_axis;
    S.fit_amp=fit_amp;
    S.fit_freq=fit_freq;
    S.cycle_num=S.fista.cycle_num;
end