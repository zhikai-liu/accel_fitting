function [S_period,fit_model,accel_axis]=fit_accel(f_name,poi,if_plot_figures)
    [Data,si,~] = abfload(f_name);
    [~,D_y] = size(Data);
    [~,doi_y] = size(poi);
    S_period = cell(1,doi_y);
    fit_model = cell(1,doi_y);
        for k = 1:doi_y
            poi_k = poi{k};
%         if doi_x == 1
%             doi_p = doi{k};
%         else
%             if doi_y == 1
%             doi_p = doi{f_num};
%             else
%             doi_p = doi{f_num}{k};
%             end
%         end
        %% smoothing data
        for i = 1:D_y
            Data(poi_k,i) = smooth(Data(poi_k,i));
        end
        
            STD =zeros(1,D_y);
            for i = 1:D_y
                STD(i) = std(Data(poi_k,i));
            end
            [~,accel_axis] = max(STD(2:D_y));
            accel_axis = accel_axis+1;
            %% find the start and end of sine wave
            Dev_ = Data(poi_k,accel_axis)-mean(Data(poi_k,accel_axis));
            cross_ = find(Dev_(1:end-1).*Dev_(2:end)<0);
            start_index = find(cross_<find(Dev_>0.70*max(Dev_),1),1,'last');
            S_start = poi_k(1)-1+cross_(start_index);
            end_index = find(cross_>find(Dev_<0.70*min(Dev_),1,'last'),1);
            S_end = poi_k(1)-1+cross_(end_index);
            S_period{k} = S_start:S_end;
            fit_model{k} = fit(S_period{k}',Data(S_period{k},accel_axis),'sin1');
            if if_plot_figures
                F1 = figure;
                plot_accel_fit(Data,poi_k,fit_model{k},S_period{k},accel_axis,si);
                title(F1.Children(end),[f_name ' period ' num2str(k) ' of ' num2str(doi_y)],'interpreter','none');
                figure;
                plot_cycle_fit_subp2(Data,poi_k,fit_model{k},S_period{k},si);
            else
            end
        end      
end

function plot_cycle_fit_subp2(Data,poi,fit_model,S_period,si)
        F2 = gcf;
        t_per_cycle = round(2*pi/fit_model.b1);
        cycle_num = round(length(S_period)/t_per_cycle);
        t_unit = 2*pi/t_per_cycle;
        subplot(2,1,1);
            for i = 1:cycle_num
                hold on;
                plot([0:t_unit:2*pi].*180/pi,Data(S_period(1)+(i-1)*t_per_cycle:S_period(1)+i*t_per_cycle,1))
                hold off;
            end
            xlim([0 360]);
        subplot(2,1,2);
            color = {'r','g','b'};
            for i = 1:cycle_num
                for j = 2:4
                hold on;
                plot([0:t_unit:2*pi].*180/pi,Data(S_period(1)+(i-1)*t_per_cycle:S_period(1)+i*t_per_cycle,j)-mean(Data(poi,j)),color{j-1})
                hold off;
                end
            end
            xlim([0 360]);
        samexaxis('abc','xmt','on','ytac','join','yld',1);
        fit_freq = fit_model.b1/(si*1e-6)/2/pi;
        title(F2.Children(end),['Sin: Freq ' num2str(fit_freq) '  Amp ' num2str(fit_model.a1) 'g'])    
end