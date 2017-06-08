function [period_index,cycle_num,per_cycle_index] = cycle_fit(event_index,amps,fit_model,S_period)
    N = length(fit_model);
    period_index = struct();
    cycle_num = cell(1,N);
    per_cycle_index = struct();
    for i =1:N
        t_per_cycle = round(2*pi/fit_model{i}.b1);
        cycle_num{i} = round(length(S_period{i})/t_per_cycle);
%         t_unit = 2*pi/t_per_cycle;
%  This part is for finding the events index for each cycle of the sine wave
        if ~isempty(event_index)
            for j = 1:cycle_num{i}
                per_cycle_index(i,j).event_index= event_index(event_index>=S_period{i}(1)+(j-1)*t_per_cycle&event_index<S_period{i}(1)+j*t_per_cycle);
                per_cycle_index(i,j).angle_raw = fit_model{i}.b1.*per_cycle_index(i,j).event_index+fit_model{i}.c1;
                per_cycle_index(i,j).phase = mod(per_cycle_index(i,j).angle_raw,2*pi);
                per_cycle_index(i,j).amp = amps(event_index>=S_period{i}(1)+(j-1)*t_per_cycle&event_index<S_period{i}(1)+j*t_per_cycle);
            end
%%
        %For each period, we select only the EPSC events happned during that period.
        %first colunm is the event index of each EPSC
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
        