function process_gather(filename_h)
f_abf = dir([filename_h '*.mat']);
f_num = length(f_abf);
Amp_all = struct();
Trials = struct();
counter = 1;
for i =1:f_num
    clearvars S
    S = load(f_abf(i).name);
    Amp_all.(S.name)=S.amps;
    for j = 1:length(S.fit_model)
        Trials(counter).S_freq = S.fit_freq{j};
        Trials(counter).S_amp = S.fit_amp{j};
        Trials(counter).S_cycle = S.cycle_num{j};
        Trials(counter).Filename = S.name;
        Trials(counter).FR_cycle = S.fit_freq{j}*length(S.period_index(j).phase)/S.cycle_num{j};
        Trials(counter).period_index = S.period_index(j);
        Trials(counter).per_cycle_index = S.per_cycle_index(j,:);
        counter = counter+1;
    end
end
save(['Amps_' filename_h '.mat'],'Amp_all');
save(['Trials_' filename_h '.mat'],'Trials');
end