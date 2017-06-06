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
        Trials(counter).Phase = S.period_index(j).phase;
        Trials(counter).Amps = S.period_index(j).amp;
        Trials(counter).Filename = S.name;
        counter = counter+1;
    end
end
save(['Amps_' filename_h '.mat'],'Amp_all');
save(['Trials_' filename_h '.mat'],'Trials');
end