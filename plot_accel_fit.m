function plot_accel_fit(Data,poi,fit_model,S_period,accel_axis,si)
%% plot results
    [~,D_y] = size(Data);
    YLabel = {'pA','g','g','g'};
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
    samexaxis('abc','xmt','on','ytac','join','yld',1);
end