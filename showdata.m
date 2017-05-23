f_abf = dir('ZL170517_fish03a_004*.abf');
%f_name = 'ZL170517_fish03a_0042.abf';
%filename = sprintf('ZL170511_fish01b_%.4d.abf',file_number);
if_fit = 1;
doi = repmat({{1:300000,350000:750000}},length(f_abf),1);
F = figure('KeyPressFcn',{@file_move,f_abf,if_fit,doi});
setappdata(F,'f_num',1);
%[S_period,fit_model]= fit_accel(f_name,doi);

function file_move(varargin)
    F1 = gcf;
    f_abf = varargin{3};
    if_fit = varargin{4};
    [f_size,~] = size(f_abf);
    update_file_index(varargin{2}.Key,f_size);
    f_num = getappdata(F1,'f_num');
    header = show_data(F1,f_abf(f_num).name);
    doi_x = varargin{5};
    if if_fit && header.nADCNumChannels~=1
        fit_accel(f_abf(f_num).name,doi_x{f_num});
    end
end

function update_file_index(key,f_size)
    F = gcf;
    f_num = getappdata(F,'f_num');
    switch key
        case 'rightarrow'
            if f_num >= f_size
                beep;
            else
                f_num = f_num+1;
                setappdata(F,'f_num',f_num)
            end
        case 'leftarrow'
            if f_num <= 1
                beep;
            else
                f_num = f_num-1;
                setappdata(F,'f_num',f_num)
            end      
    end
end

function [header] = show_data(F1,f_name)
    [Data,si,header] = abfload(f_name);
    [D_x,D_y] = size(Data);   
    %% smoothing data
    for i = 1:D_y
        Data(:,i) = smooth(Data(:,i));
    end
    
    clf;
    
    if header.nADCNumChannels==1
        for i=1:D_y
        hold on;
        plot([1:D_x]*si*1e-6,Data(:,i));
        end
        hold off;
    else
        [D_x,D_y] = size(Data);
        for i=1:D_y
            subplot(D_y,1,i);
            plot([1:D_x]*si*1e-6,Data(:,i));
        end
        samexaxis('abc','xmt','on','ytac','join','yld',1);  
    end
    title(F1.Children(end),f_name,'interpreter','none');
end

function [S_period,fit_model]=fit_accel(f_name,doi)
    [Data,si,~] = abfload(f_name);
    [~,D_y] = size(Data);
    [~,doi_y] = size(doi);
    S_period = cell(1,doi_y);
    fit_model = cell(1,doi_y);
        for k = 1:doi_y
            doi_p = doi{k};
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
            Data(doi_p,i) = smooth(Data(doi_p,i));
        end
        
            STD =zeros(1,D_y);
            for i = 1:D_y
                STD(i) = std(Data(doi_p,i));
            end
            [~,accel_axis] = max(STD(2:D_y));
            accel_axis = accel_axis+1;
            %% find the start and end of sine wave
            Dev_ = Data(doi_p,accel_axis)-mean(Data(doi_p,accel_axis));
            cross_ = find(Dev_(1:end-1).*Dev_(2:end)<0);
            start_index = find(cross_<find(Dev_>0.70*max(Dev_),1),1,'last');
            S_start = doi_p(1)-1+cross_(start_index);
            end_index = find(cross_>find(Dev_<0.70*min(Dev_),1,'last'),1);
            S_end = doi_p(1)-1+cross_(end_index);
            S_period{k} = S_start:S_end;
            fit_model{k} = fit(S_period{k}',Data(S_period{k},accel_axis),'sin1');
            F1 = figure;
            plot_accel_fit(Data,doi_p,fit_model{k},S_period{k},accel_axis,si);
            title(F1.Children(end),[f_name ' period ' num2str(k) ' of ' num2str(doi_y)],'interpreter','none');
            figure;
            plot_cycle_fit(Data,doi_p,fit_model{k},S_period{k},si);
        end      
end

function plot_accel_fit(Data,doi_p,fit_model,S_period,accel_axis,si)
%% plot results
    [~,D_y] = size(Data);
    fit_accel_y = fit_model.a1.*sin(fit_model.b1.*S_period+fit_model.c1);
    for i=1:D_y
        subplot(D_y,1,i);
        plot([doi_p]*si*1e-6,Data(doi_p,i));
        hold on;
        plot((S_period)*si*1e-6,Data(S_period,i),'r');
        if i == accel_axis
        plot(S_period*si*1e-6,fit_accel_y,'g')
        end
        hold off;
    end
    samexaxis('abc','xmt','on','ytac','join','yld',1);
end

function plot_cycle_fit(Data,doi_p,fit_model,S_period,si)
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
                plot([0:t_unit:2*pi].*180/pi,Data(S_period(1)+(i-1)*t_per_cycle:S_period(1)+i*t_per_cycle,j)-mean(Data(doi_p,j)),color{j-1})
                hold off;
                end
            end
            xlim([0 360]);
        samexaxis('abc','xmt','on','ytac','join','yld',1);
        fit_freq = fit_model.b1/(si*1e-6)/2/pi;
        title(F2.Children(end),['Sin: Freq ' num2str(fit_freq) '  Amp ' num2str(fit_model.a1) 'g'])    
end