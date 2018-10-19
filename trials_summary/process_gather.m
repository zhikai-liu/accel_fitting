function process_gather(filename_h)
f_abf = dir([filename_h '*.mat']);
f_num = length(f_abf);
Trials = struct();
counter = 1;
for i =1:f_num
    clearvars S
    S = load(f_abf(i).name);
    for j = 1:length(S.fit_model)
        Trials(counter).S_freq = S.fit_freq{j};
        Trials(counter).S_amp = S.fit_amp{j};
        Trials(counter).S_cycle = S.cycle_num{j};
        Trials(counter).S_period= S.S_period{j};
        Trials(counter).mat_file = f_abf(i).name;
        Trials(counter).abf_file = S.name;
        Trials(counter).poi_num=j;
        if isfield(S,'fista')
            Trials(counter).fista=S.fista;
            Trials(counter).fista.period_index=S.fista.period_index(j);
            Trials(counter).fista.per_cycle_index = S.fista.per_cycle_index(j,:);
        end
%         if ~isempty(S.event_index)
%         Trials(counter).FR_cycle = S.fit_freq{j}*length(S.period_index(j).phase)/S.cycle_num{j};
%         Trials(counter).period_index = S.period_index(j);
%         Trials(counter).per_cycle_index = S.per_cycle_index(j,:);
%         end
        if isfield(S,'cell_opening')
            Trials(counter).cell_opening = S.cell_opening;
        end
        if isfield(S,'other_axis')
            Trials(counter).other_axis=S.other_axis(:,j);
            Trials(counter).other_axis_fit=S.other_axis_fit(:,j);
            Trials(counter).accel_axis=S.accel_axis{j};
        end
        counter = counter+1;
    end
end
save(['Trials_' filename_h '.mat'],'Trials');
end