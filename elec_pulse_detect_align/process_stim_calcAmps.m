function mean_amps=process_stim_calcAmps(filename_h)
f_mat = dir([filename_h '*.mat']);
for i =1:length(f_mat)
    S=load(f_mat(i).name);
    [D_x,D_y,D_z]=size(S.Data);
    amps=zeros(D_z,1);
    aligned_trace=zeros(D_x,D_z);
    figure;
    hold on;
    for j=1:D_z
        aligned_trace(:,j)=smooth(S.Data(:,1,j)-S.baseline(j));
        EPSC_trace=aligned_trace(S.stim_onset(j)+20:S.stim_onset(j)+70,j);
        plot(EPSC_trace,'k')
        [max_value,max_index]=max(EPSC_trace(1:12));
        [min_value,min_index]=min(EPSC_trace(12:30));
        amps(j)=max_value-min_value;
    end
    hold off;
    figure;histogram(amps,100)
    mean_amps=mean(amps);
    save(f_mat(i).name,'amps','aligned_trace','-append');
end