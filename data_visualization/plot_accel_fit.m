function plot_accel_fit(Data,poi,model,S_period,accel_axis,si,type,other_axis,other_axis_fit)
%% plot results
    [~,D_y] = size(Data);
    if strcmp(type{1},'EPSC')||strcmp(type{1},'IPSC')
    YLabel = {'pA','g','g','g'};
    elseif strcmp(type{1},'EPSP')||strcmp(type{1},'IPSP')
    YLabel = {'mV','g','g','g'};
    end
    axis_model=[{model};other_axis_fit];
    axis=[accel_axis;other_axis];
   
    for i=1:D_y
        subplot(D_y,1,i);
        plot(poi*si*1e-6,Data(poi,i));
        hold on;
        plot((S_period)*si*1e-6,Data(S_period,i),'r');
        ylabel(YLabel{i},'Rotation',0);
        if i>1
        fit_model=axis_model{axis==i};
        fit_accel_y = fit_model.a1.*sin(fit_model.b1.*S_period+fit_model.c1);
        plot(S_period*si*1e-6,fit_accel_y+mean(Data(S_period,i)),'g')
        end
        hold off;
        if i~=D_y
            A=gca;
            set(A.XAxis,'visible','off')
        end
    end
    xlabel('Second');
    samexaxis('ytac','join','box','off');
end