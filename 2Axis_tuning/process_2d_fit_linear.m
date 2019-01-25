function fname_h=process_2d_fit_linear(fname,range)

X=struct();
Y=struct();
XpYp=struct();
XpYn=struct();
num_rec=length(range);
base=[1/sqrt(2),-1/sqrt(2);1/sqrt(2),1/sqrt(2)];
if length(range)>=1
    X=load(fname{range(1)});
    X=add_accel_fit(X);
    if length(range)>=2
        Y=load(fname{range(2)});
        Y=add_accel_fit(Y);
        if length(range)>=3
            XpYp=load(fname{range(3)});
            XpYp.Data(:,2:3)=XpYp.Data(:,2:3)*base;
            XpYp=add_accel_fit(XpYp);
            if length(range)>=4
                XpYn=load(fname{range(4)});
                XpYn.Data(:,2:3)=XpYn.Data(:,2:3)*base;
                XpYn=add_accel_fit(XpYn);
            end
        end
    end
end

fname_h=['2d_linear_' fname{range(1)}(1:end-6) '.mat'];
if exist(fname_h,'file')
    save(fname_h,'X','Y','XpYp','XpYn','num_rec','-append');
else
    save(fname_h,'X','Y','XpYp','XpYn','num_rec');
end

end

function S=add_accel_fit(S)
% if ~isfield(S,'poi')
%     pause
% end
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
    S.cycle_num=S.fista.cycle_num;
end
if isfield(S,'der')
     [S.period_index,S.cycle_num,S.per_cycle_index] = cycle_fit(S.der.event_index,S.der.amps,fit_model,S_period);
end
S.S_period=S_period;
S.fit_model=fit_model;
S.accel_axis=accel_axis;
S.other_axis_fit=other_axis_fit;
S.other_axis=other_axis;
S.fit_amp=fit_amp;
S.fit_freq=fit_freq;
if round(fit_amp{1},2)~=0.02||round(fit_freq{1})~=2
    warning([S.name ' frequency: ' num2str(fit_freq{1}) ' Amp: ' num2str(fit_amp{1})])
end
end