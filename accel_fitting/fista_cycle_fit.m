function fista = fista_cycle_fit(fista,fit_model,S_period)
    N = length(fit_model);
    fista.period_index = struct();
    fista.cycle_num = cell(1,N);
    fista.per_cycle_index = struct();
    event_index=fista.X1_max;
    
    for i =1:N
        t_per_cycle = round(2*pi/fit_model{i}.b1);
        fista.cycle_num{i} = round(length(S_period{i})/t_per_cycle);
        %         t_unit = 2*pi/t_per_cycle;
        %  This part is for finding the events index for each cycle of the sine wave
        for j = 1:fista.cycle_num{i}
            tmp_index=event_index>=S_period{i}(1)+(j-1)*t_per_cycle&event_index<S_period{i}(1)+j*t_per_cycle;
            fista.per_cycle_index(i,j).event_index= event_index(tmp_index);
            fista.per_cycle_index(i,j).angle_raw = fit_model{i}.b1.*fista.per_cycle_index(i,j).event_index+fit_model{i}.c1;
            fista.per_cycle_index(i,j).phase = mod(fista.per_cycle_index(i,j).angle_raw,2*pi);
            fista.per_cycle_index(i,j).X1_integral = fista.X1_integral(tmp_index);
            fista.per_cycle_index(i,j).X1_max_ori_index=fista.X1_max_ori_index(tmp_index);
            fista.per_cycle_index(i,j).X1_prox= fista.X1_prox(tmp_index,:);
            fista.per_cycle_index(i,j).X1_clust=fista.X1_clust(tmp_index);
            if isfield(fista,'X1_chemical')
            fista.per_cycle_index(i,j).X1_chemical=fista.X1_chemical(tmp_index);
            end
        end
        %%
        %For each period, we select only the EPSC events happned during that period.
        %first colunm is the event index of each EPSC
        tmp_index=event_index>=S_period{i}(1)&event_index<S_period{i}(end);
        fista.period_index(i).event_index = event_index(tmp_index);
        %second column is the angle calculated based on the modelling,
        %which is the phase information
        fista.period_index(i).angle_raw = fit_model{i}.b1.*fista.period_index(i).event_index+fit_model{i}.c1;
        %third column is also the anlge but converted within [0 2*pi]
        fista.period_index(i).phase = mod(fista.period_index(i).angle_raw,2*pi);
        %fourth column is the amplitude of ESPC
        fista.period_index(i).X1_integral = fista.X1_integral(tmp_index);
        
        fista.period_index(i).X1_max_ori_index=fista.X1_max_ori_index(tmp_index);
        fista.period_index(i).X1_prox= fista.X1_prox(tmp_index,:);
        fista.period_index(i).X1_clust=fista.X1_clust(tmp_index);
        if isfield(fista,'X1_chemical')
        fista.period_index(i).X1_chemical=fista.X1_chemical(tmp_index);
        end
    end
end
        