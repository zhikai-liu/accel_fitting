function [S_period,fit_model,accel_axis,other_axis_fit,other_axis]=fit_man_accel(Data,si,f_name,poi,if_plot_figures)
    [~,D_y] = size(Data);
    [~,poi_y] = size(poi);
    S_period = cell(1,poi_y);
    fit_model = cell(1,poi_y);
    accel_axis = cell(1,poi_y);
    all_axis=2:D_y;
    other_axis_fit=cell(2,poi_y);
    other_axis=zeros(2,poi_y);
        for k = 1:poi_y
            poi_k = poi{k};
        %% smoothing data
        for i = 1:D_y
            Data(poi_k,i) = smooth(Data(poi_k,i));
        end
        
            STD =zeros(1,D_y);
            for i = 1:D_y
                STD(i) = std(Data(poi_k,i));
            end
            [~,accel_axis{k}] = max(STD(all_axis));
            accel_axis{k} = accel_axis{k}+1;
            %% find the start and end of sine wave
            max_ratio=0.6;
            Dev_ = Data(poi_k,accel_axis{k})-mean(Data(poi_k,accel_axis{k}));
            cross_ = find(Dev_(1:end-1).*Dev_(2:end)<0);
            start_index = find(cross_<find(Dev_>max_ratio*max(Dev_),1),1,'last');
            S_start = poi_k(1)-1+cross_(start_index);
            end_index = find(cross_>find(Dev_<max_ratio*min(Dev_),1,'last'),1);
            S_end = poi_k(1)-1+cross_(end_index);
            S_period{k} = S_start:S_end;
            %ft=fittype(@(a1,b1,c1,d1,x) a1*sin(b1*x+c1)+d1);
            fit_model{k} = fit(S_period{k}',Data(S_period{k},accel_axis{k})-mean(Data(S_period{k},accel_axis{k})),'sin1');
            %% Fit other axis
            other_axis(:,k)=all_axis(all_axis~=accel_axis{k});
            for h=1:2
            other_axis_fit{h,k}=fit(S_period{k}',Data(S_period{k},other_axis(h,k))-mean(Data(S_period{k},other_axis(h,k))),'sin1',...
                'Lower',[-Inf,fit_model{k}.b1,-Inf],'Upper',[Inf,fit_model{k}.b1,Inf]);
            end
            %% Plot figures
            if if_plot_figures
                F1 = figure;
                plot_accel_fit(Data,poi_k,fit_model{k},S_period{k},accel_axis{k},si);
                title(F1.Children(end),[f_name ' period ' num2str(k) ' of ' num2str(poi_y)],'interpreter','none');
                figure;
                plot_cycle_fit_subp2(Data,poi_k,fit_model{k},S_period{k},si);
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