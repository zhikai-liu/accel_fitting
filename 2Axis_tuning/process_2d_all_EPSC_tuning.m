function all_tuning_r=process_2d_all_EPSC_tuning(filename)
% This code is used to calculate tuning of all EPSCs on 4 different axis of linear
% movement, input file name: '2d_linear_EPSC_2d_accel_ZL*.mat'
S=load(filename);
% X Y are orthogonal, 0 and 90. XpYp is 45, XpYn is -45 degrees
num_rec=S.num_rec;
fNames={'X','Y','XpYp','XpYn'};
fNames=fNames(1:num_rec);
all_tuning_r=zeros(1,num_rec);
for i=1:num_rec
    phase_all=S.(fNames{i}).period_index.phase;
    phase_sum=sum(exp(1i*phase_all));
    all_tuning_r(i)=abs(phase_sum)./S.(fNames{i}).cycle_num{1}.*S.(fNames{i}).fit_freq{1};
end
save(filename,'all_tuning_r','-append')
end