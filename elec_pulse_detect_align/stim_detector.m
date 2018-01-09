% This function is used to detect the artifact of electrical pulse that is applied to stimulate
% the vestibular ganglion. The timing and shape of those pulses are
% important to distinguish real neuronal voltage signal from stimulation
% artifact.

% Modified from EPSC_detection code

function stim_detector(data,si)
    v_d=smooth(data(:,1));
    diff_v=diff(v_d)./si.*1e6;
    thre=4e6;
    cross_thre=diff_v>thre;
    sign_cross_thre=diff(cross_thre)==1;
    X_=1:length(sign_cross_thre);
    X=X_(sign_cross_thre);
    figure;
    plot(v_d)
    hold on;
    scatter(X,v_d(X),'r*');
    hold off;
    figure;
    hold on;
    range_zero=X(1):X(1)+15;
    trials=zeros(length(X),1001);
    failures=zeros(length(X),1);
    for i=1:length(X)
        range=X(i):X(i)+15;
        delay=finddelay(v_d(range_zero)-mean(v_d(X(1)-50:X(1)-10)),v_d(range)-mean(v_d(X(i)-50:X(i)-10)));
        X(i)=X(i)+delay;
        trials(i,:)=v_d(X(i)-500:X(i)+500)-mean(v_d(X(i)-50:X(i)-10));
        if trials(i,:)>-100
            failures(i)=1;
            plot(-500:500,trials(i,:),'r')
        else
            plot(-500:500,trials(i,:),'g')
        end
    end
    hold off;
    f_trials=trials(failures==1,:);
    f_average=mean(f_trials,1);
    colors=cell(length(X),1);
    colors{failures==1}='r';
    colors{failures==0}='g';
    figure;
    hold on;
    for i=1:length(X)
        plot(trials(i,:)-f_average,colors{i})
    end
    hold off;
end