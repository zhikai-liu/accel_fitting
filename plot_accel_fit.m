function plot_accel_fit(Data,poi,fit_model,S_period,accel_axis,si,type)
%% plot results
    [~,D_y] = size(Data);
    if strcmp(type,'EPSC+accel')||strcmp(type,'IPSC+accel')
    YLabel = {'pA','g','g','g'};
    elseif strcmp(type,'EPSP+accel')||strcmp(type,'IPSP+accel')
    YLabel = {'mV','g','g','g'};
    end
    fit_accel_y = fit_model.a1.*sin(fit_model.b1.*S_period+fit_model.c1);
    for i=1:D_y
        subplot(D_y,1,i);
        plot(poi*si*1e-6,Data(poi,i));
        hold on;
        plot((S_period)*si*1e-6,Data(S_period,i),'r');
        ylabel(YLabel{i},'Rotation',0);
        if i == accel_axis
        plot(S_period*si*1e-6,fit_accel_y,'g')
        end
        hold off;
    end
    xlabel('Second');
    samexaxis('ytac','join');
end