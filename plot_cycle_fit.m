function [cycle_index,amps] = plot_cycle_fit(Data,event_index,amps,poi,fit_model,S_period,type)
        t_per_cycle = round(2*pi/fit_model.b1);
        cycle_num = round(length(S_period)/t_per_cycle);
        t_unit = 2*pi/t_per_cycle;
        subplot(3,1,1);
            for i = 1:cycle_num
                hold on;
                plot([0:t_unit:2*pi].*180/pi,Data(S_period(1)+(i-1)*t_per_cycle:S_period(1)+i*t_per_cycle,1))
                hold off;
            end
            xlim([0 360]);
            if strcmp(type,'EPSC+accel')||strcmp(type,'IPSC+accel')
                ylabel('pA','Rotation',0);
            elseif strcmp(type,'EPSP+accel')||strcmp(type,'IPSP+accel')
                ylabel('mV','Rotation',0);
            end
        subplot(3,1,2);
            color = {'r','g','b'};
            for i = 1:cycle_num
                for j = 2:4
                hold on;
                plot([0:t_unit:2*pi].*180/pi,Data(S_period(1)+(i-1)*t_per_cycle:S_period(1)+i*t_per_cycle,j)-mean(Data(poi,j)),color{j-1})
                hold off;
                end
            end
            xlim([0 360]);
            ylabel('g','Rotation',0);
        if ~isempty(event_index)
            amps = amps(event_index>=S_period(1)&event_index<=S_period(end));
            event_index = event_index(event_index>=S_period(1)&event_index<=S_period(end));
            angle_index = fit_model.b1.*event_index+fit_model.c1;
            cycle_index = mod(angle_index,2*pi);
            subplot(3,1,3);
            for i = 1:length(event_index)
                hold on;
                scatter(cycle_index(i)*180/pi,amps(i),'r');
            end
            hold off;
            xlim([0 360]);
            if strcmp(type,'EPSC+accel')||strcmp(type,'IPSC+accel')
                ylabel('pA','Rotation',0);
            elseif strcmp(type,'EPSP+accel')||strcmp(type,'IPSP+accel')
                ylabel('mV','Rotation',0);
            end
            xlabel('degree');
        end
        samexaxis('abc','xmt','on','ytac','join','yld',1);  
end