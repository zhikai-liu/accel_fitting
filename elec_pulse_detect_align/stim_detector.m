% This function is used to detect the artifact of electrical pulse that is applied to stimulate
% the vestibular ganglion. The timing and shape of those pulses are
% important to distinguish real neuronal voltage signal from stimulation
% artifact.

% Modified from EPSC_detection code

function stim_detector(data,si)
    v_d=data(:,1);
    diff_v=diff(v_d)./si.*1e6;
    thre=4e6;
    cross_thre=diff_v>thre;
    sign_cross_thre=diff(cross_thre)==1;
    X_=1:length(sign_cross_thre);
    X=X_(sign_cross_thre);
    figure;
    plot(v_d)
    hold on;
    scatter(X,ones(length(X),1),'r*');
    hold off;
    figure;
    hold on;
    range_zero=X(1)-5:X(1)+20;
    for i=1:length(X)
        range=X(i)-5:X(i)+20;
        delay=finddelay(range_zero,range);
        X_plot=X(i)-delay;
        plot(-1000:1000,v_d(X_plot-1000:X_plot+1000))
    end
    hold off;
end