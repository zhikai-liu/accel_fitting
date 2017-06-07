function [period_index,cycle_num] = cycle_fit(event_index,amps,fit_model,S_period)
    N = length(fit_model);
    period_index = struct();
    cycle_num = cell(1,N);
    for i =1:length(fit_model)
        t_per_cycle = round(2*pi/fit_model{i}.b1);
        cycle_num{i} = round(length(S_period{i})/t_per_cycle);
%         per_cycle_index = cell(cycle_num,4);
%         %t_unit = 2*pi/t_per_cycle;
%%  This part is for finding the events index for each cycle of the sine wave
%         for i = 1:cycle_num
%             per_cycle_index{i,1} = event_index(event_index>=S_period(1)+(i-1)*t_per_cycle&event_index<S_period(1)+i*t_per_cycle);
%             per_cycle_index{i,2} = fit_model.b1.*per_cycle_index{i,1}+fit_model.c1;
%             per_cycle_index{i,3} = mod(per_cycle_index{i,2},2*pi);
%             per_cycle_index{i,4} = amps(event_index>=S_period(1)+(i-1)*t_per_cycle&event_index<S_period(1)+i*t_per_cycle);
%         end
%%
        %For each period, we select only the EPSC events happned during that period.
        %first colunm is the event index of each EPSC
        if ~isempty(event_index)
        period_index(i).event_index = event_index(event_index>=S_period{i}(1)&event_index<S_period{i}(end));
        %second column is the angle calculated based on the modelling,
        %which is the phase information
        period_index(i).angle_raw = fit_model{i}.b1.*period_index(i).event_index+fit_model{i}.c1;
        %third column is also the anlge but converted within [0 2*pi]
        period_index(i).phase = mod(period_index(i).angle_raw,2*pi);
        %fourth column is the amplitude of ESPC
        period_index(i).amp = amps(event_index>=S_period{i}(1)&event_index<S_period{i}(end));
        end
    end
end
        