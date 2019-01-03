function process_stim_plot_align(filename_h)

f_mat = dir([filename_h '*.mat']);

for i =1:length(f_mat)
    S=load(f_mat(i).name);
    [D_x,D_y,D_z]=size(S.Data);
    stim_onset=zeros(D_z,1);
    baseline=zeros(D_z,1);
    figure;
    hold on;
    for j=1:D_z
        [~,stim_onset(j)]=max(diff(S.Data(:,2,j)));
        baseline(j)=mean(S.Data(stim_onset(j)-5:stim_onset(j),1,j));
        plot(S.Data(stim_onset(j)-5:end,1,j)-baseline(j),'Color',[0.3 0.3 0.3])
    end
    hold off
    %ylim([-250 100])
    title(f_mat(i).name,'interpreter','none')
    save(f_mat(i).name,'stim_onset','baseline','-append');
end
end