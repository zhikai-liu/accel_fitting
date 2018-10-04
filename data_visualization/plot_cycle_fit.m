function [cycle_index,amps] = plot_cycle_fit(Data,event_index,amps,poi,fit_model,S_period,type)
% This function is used to plot the fitted traces of all cycles overlaying
% together
        % Time per cycle (how many data points in one cycle, not in seconds)
        t_per_cycle = round(2*pi/fit_model.b1);
        % Cycle numbers
        cycle_num = round(length(S_period)/t_per_cycle);
        % All the data points evenly spreaded in one cycle, 2pi
        % t_unit is the amount per data point
        t_unit = 2*pi/t_per_cycle;
        % Subplot numbers
        subplot_num =2;
        %% If event detection is already completed, add another subplot (the 3rd) for amplitudes
        if ~isempty(event_index)
            subplot_num =3;
            % Only use the index/amp within the period of interest
            amps = amps(event_index>=S_period(1)&event_index<=S_period(end));
            event_index = event_index(event_index>=S_period(1)&event_index<=S_period(end));
            angle_index = fit_model.b1.*event_index+fit_model.c1;
            cycle_index = mod(angle_index,2*pi);
            % Plotting
            subplot(subplot_num,1,3);
            for i = 1:length(event_index)
                hold on;
                scatter(cycle_index(i),amps(i),'r');
            end
            hold off;
            xlim([0 2*pi]);
            if strcmp(type{1},'EPSC')||strcmp(type{1},'IPSC')
                ylabel('pA','Rotation',0);
            elseif strcmp(type{1},'EPSP')||strcmp(type{1},'IPSP')
                ylabel('mV','Rotation',0);
            end
            xlabel('phase');
            xticks([0,pi/2,pi,3*pi/2,2*pi])
            xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'})
        end
        %% Plot as following:
        % First subplot is the overlay of EPSC trace for each cycle
        S_period_phase=mod(fit_model.b1.*S_period+fit_model.c1,2*pi);
        % Finding the first phase 0 in the S_period
        zero_phase=find_first_phase_o(S_period_phase);
        subplot(subplot_num,1,1);
            for i = 1:cycle_num
                hold on;
                % Make sure that all the data are plotted where they are aligned with 0-2pi
                % phase, because S_period doesn't always start at phase 0,
                % so plotting start at a point with zero phase
               
                plot(0:t_unit:2*pi,Data(S_period(zero_phase)+(i-1)*t_per_cycle:S_period(zero_phase)+i*t_per_cycle,1))
                hold off;
            end
            xlim([0 2*pi]);
            A=gca;
            set(A.XAxis,'visible','off')
            if strcmp(type{1},'EPSC')||strcmp(type{1},'IPSC')
                ylabel('pA','Rotation',0);
            elseif strcmp(type{1},'EPSP')||strcmp(type{1},'IPSP')
                ylabel('mV','Rotation',0);
            end
        % Second subplot is the overlay of the acceleration trace for each cycle
        subplot(subplot_num,1,2);
            color = {'r','g','b'};
            for i = 1:cycle_num
                for j = 2:4
                hold on;
                plot(0:t_unit:2*pi,Data(S_period(zero_phase)+(i-1)*t_per_cycle:S_period(zero_phase)+i*t_per_cycle,j)-mean(Data(poi,j)),color{j-1})
                hold off;
                end
            end
            xlim([0 2*pi]);
            ylabel('g','Rotation',0);
            if subplot_num==3
                  A=gca;
                  set(A.XAxis,'visible','off')
            end
        samexaxis('ytac','join','box','off');  
end
function zero_phase=find_first_phase_o(S_period_phase)
    % Phase should keeping increasing from 0 to 2pi unless it is the end
    phase_diff=diff(S_period_phase);
    cycle_end=find(phase_diff<0);
    zero_phase=cycle_end(1);
end