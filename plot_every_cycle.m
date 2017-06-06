function [cycle_num] = plot_every_cycle(Data,poi,fit_model,S_period)
        t_per_cycle = round(2*pi/fit_model.b1);
        cycle_num = round(length(S_period)/t_per_cycle);
        t_unit = 2*pi/t_per_cycle;
        for i = 1:cycle_num
            clearvars data_cycle
            subplot(cycle_num+1,1,i);
            data_cycle = Data(S_period(1)+(i-1)*t_per_cycle:S_period(1)+i*t_per_cycle,1);
            y_range = max(data_cycle)-min(data_cycle);
            plot([0:t_unit:2*pi].*180/pi,data_cycle)
            xlim([0 360]);
            ylim([min(data_cycle)-0.15*y_range max(data_cycle)+0.15*y_range])
            ylabel('pA','Rotation',0);
        end  
        subplot(cycle_num+1,1,cycle_num+1);
        color = {'r','g','b'};
        for i = 1:cycle_num
            for j = 2:4
            hold on;
            plot([0:t_unit:2*pi].*180/pi,Data(S_period(1)+(i-1)*t_per_cycle:S_period(1)+i*t_per_cycle,j)-mean(Data(poi,j)),color{j-1})
            hold off;
            end
        end
        xlim([0 360]);
        xlabel('degree');
        samexaxis('abc','xmt','on','ytac','join','yld',1);  
end