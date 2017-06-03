f_abf = dir('ZL170517_fish03a_00*.mat');
f_num = length(f_abf);
num_plot_per_fig = 8;
Rem = mod(f_num,num_plot_per_fig);
fig_num = (f_num-Rem)/num_plot_per_fig;
Amp_S = struct();
for i =1:f_num
    clearvars S
    S = load(f_abf(i).name);
    Amp_S.(S.name)=S.amps;
end
for i = 1:fig_num+1
    Amp_plot = struct();
    for j =1:num_plot_per_fig
        clearvars S
        file_num = (i-1)*num_plot_per_fig+j;
        if file_num<=f_num
            S = load(f_abf(file_num).name);
            Amp_plot.(S.name)=S.amps;
        end
    end
    figure;
    nhist(Amp_plot,'binfactor',40,'separate');
    clearvars Amp_plot
end