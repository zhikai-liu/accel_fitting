function plot_cycle_fit(Data,event_index,amps,poi,fit_model,S_period,si)
        F2 = gcf;
        t_per_cycle = round(2*pi/fit_model.b1);
        cycle_num = round(length(S_period)/t_per_cycle);
        t_unit = 2*pi/t_per_cycle;
        amps = amps(event_index>=S_period(1)&event_index<=S_period(end));
        event_index = event_index(event_index>=S_period(1)&event_index<=S_period(end));
        angle_index = fit_model.b1.*event_index+fit_model.c1;
        cycle_index = mod(angle_index,2*pi);
        subplot(3,1,1);
            for i = 1:cycle_num
                hold on;
                plot([0:t_unit:2*pi].*180/pi,Data(S_period(1)+(i-1)*t_per_cycle:S_period(1)+i*t_per_cycle,1))
                hold off;
            end
            xlim([0 360]);
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
        subplot(3,1,3);
            for i = 1:length(event_index)
                hold on;
                scatter(cycle_index(i)*180/pi,amps(i),'r');
            end
            hold off;
            xlim([0 360]);
        samexaxis('abc','xmt','on','ytac','join','yld',1);
        fit_freq = fit_model.b1/(si*1e-6)/2/pi;
        title(F2.Children(end),['Sin: Freq ' num2str(fit_freq) '  Amp ' num2str(fit_model.a1) 'g'])    
end