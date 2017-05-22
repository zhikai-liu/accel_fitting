f_abf = dir('ZL170517_fish03a_004*.abf');
%filename = sprintf('ZL170511_fish01b_%.4d.abf',file_number);
F = figure('KeyPressFcn',{@file_move,f_abf});
setappdata(F,'f_num',1);



function file_move(varargin)
    F = gcf;
    f_abf = varargin{3};
    f_num = getappdata(F,'f_num');
    [f_size,~] = size(f_abf);
    switch varargin{2}.Key
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
    [Data,si,header] = abfload(f_abf(f_num).name);
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
        STD =zeros(1,D_y);
        for i = 1:D_y
            STD(i) = std(Data(:,i));
        end
        [~,accel_axis] = max(STD(2:D_y));
        accel_axis = accel_axis+1;
        %% find the start and end of sine wave
        Dev_ = Data(:,accel_axis)-mean(Data(:,accel_axis));
        cross_ = find(Dev_(1:end-1).*Dev_(2:end)<0);
        start_index = find(cross_<find(Dev_>0.70*max(Dev_),1),1,'last');
        S_start = cross_(start_index);
        end_index = find(cross_>find(Dev_<0.70*min(Dev_),1,'last'),1);
        S_end = cross_(end_index);
        S_period = S_start:S_end;
        fit_model = fit(S_period',Data(S_period,accel_axis),'sin1');
        fit_accel = fit_model.a1.*sin(fit_model.b1.*S_period+fit_model.c1);
        t_per_cycle = round(2*pi/fit_model.b1);
        cycle_num = round(length(S_period)/t_per_cycle);        
%         [P1,f] = SinFit(Data(:,accel_axis),si*1e-6);
%         [pw,f_index] = max(P1);
%         fit_f =f(f_index);
%         fit_accel = 2*pw.*sin(2.*pi.*fit_f.*(0:S_end-S_start)*si*1e-6);
        %% plot results
        for i=1:D_y
            subplot(D_y,1,i);
            plot([1:D_x]*si*1e-6,Data(:,i));
            hold on;
            plot((S_period)*si*1e-6,Data(S_period,i),'r');
            if i == accel_axis
            plot(S_period*si*1e-6,fit_accel,'g')
            end
            hold off;
        end
        %subplot(D_y+1,1,D_y+1);
        %plot((S_start:S_end)*si*1e-6,fit_accel);
        samexaxis('abc','xmt','on','ytac','join','yld',1);
        figure;
        t_unit = 2*pi/t_per_cycle;
        for i = 1:cycle_num
            hold on;
            plot([0:t_unit:2*pi].*180/pi,Data(S_start+(i-1)*t_per_cycle:S_start+i*t_per_cycle,1))
            hold off;
        end
        xlim([0 360]);
        fit_freq = fit_model.b1/(si*1e-6)/2/pi;
        title(['Sin: Freq ' num2str(fit_freq) '  Amp ' num2str(fit_model.a1) 'g'])
    end   
    title(F.Children(end),f_abf(f_num).name,'interpreter','none');
end


% function [P1,f] = SinFit(D,T)
% Fs = 1/T;
% L = length(D);
% Y = fft(D);
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs*(0:(L/2))/L;
% end