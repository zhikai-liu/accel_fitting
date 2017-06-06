function process_amps_hist_plot(filename_h,num_plot_per_fig)
f_mat = dir([filename_h '*.mat']);
f_num = length(f_mat);
Rem = mod(f_num,num_plot_per_fig);
fig_num = (f_num-Rem)/num_plot_per_fig;
if Rem ~= 0
    fig_num = fig_num+1;
end
for i = 1:fig_num
    Amp_plot = struct();
    for j =1:num_plot_per_fig
        clearvars S
        file_num = (i-1)*num_plot_per_fig+j;
        if file_num<=f_num
            S = load(f_mat(file_num).name);
            Amp_plot.(S.name)=S.amps;
        end
    end
    figure;
    nhist(Amp_plot,'binfactor',20,'separate')
    print([filename_h '_amp_hist' num2str(i) '.pdf'],'-fillpage','-dpdf');
    clearvars Amp_plot
end
end