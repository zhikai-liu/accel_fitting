% This function is used to detect the artifact of electrical pulse that is applied to stimulate
% the vestibular ganglion. The timing and shape of those pulses are
% important to distinguish real neuronal voltage signal from stimulation
% artifact.

% Modified from EPSC_detection code

function stim_detector(data,si)
    v_d=smooth(data(:,1)); % data smoothing
    %% calculate derivative of signal and find threshold crossing point
    diff_v=diff(v_d)./si.*1e6;
    thre=4e6;
    cross_thre=diff_v>thre;
    sign_cross_thre=diff(cross_thre)==1;% find the first crossing point for an electrical pulse event
    X_=1:length(sign_cross_thre);
    X=X_(sign_cross_thre);
    %% Plot data and detected beginning of an electrical pulse
    figure;
    plot(v_d)
    hold on;
    scatter(X,v_d(X),'r*');
    hold off;
    %% Plot all events together after alignment
    figure;
    hold on;
    range_zero=X(1)-5:X(1)+20;
    trials=zeros(length(X),1001);
    failures=zeros(length(X),1);
    for i=1:length(X)
        range=X(i)-5:X(i)+20;
        %delay=finddelay(v_d(range_zero)-mean(v_d(X(1)-50:X(1)-10)),v_d(range)-mean(v_d(X(i)-50:X(i)-10)));
        delay=get_delay(v_d(range_zero)-mean(v_d(X(1)-50:X(1)-10)),v_d(range)-mean(v_d(X(i)-50:X(i)-10)));
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
    %% Subtract failures to remove electrical artifact and only real signal remains
    fail_EPSC=zeros(sum(failures==1),size(trials,2));
    succ_EPSC=zeros(sum(failures~=1),size(trials,2));
    latency=zeros(sum(failures~=1),1);
    j=1;
    k=1;
    figure;
    hold on;
    for i=1:length(X)
        if failures(i)==1
            fail_EPSC(j,:)=trials(i,:)-f_average;
            plot(fail_EPSC(j,:),'r')  
            j=j+1;
        else
            succ_EPSC(k,:)=trials(i,:)-f_average;
            plot(succ_EPSC(k,:),'g')
            [~,EPSC_peak]=min(succ_EPSC(k,:));
            latency(k)=EPSC_peak-501;
            k=k+1;
        end
    end
    hold off;
    %% Align the EPSC signals based on their peaks
    figure;
    hold on;
    for i=1:size(succ_EPSC,1)
        x_range=1:1001;
        plot(x_range-latency(i),succ_EPSC(i,:),'g')
    end
    hold off;
    latency_ms=latency*si*1e-3;
    figure;
    histogram(latency_ms)
    xlabel('ms')
    STD=std(latency_ms)
end

function index=get_delay(w0,w1)
    dist=zeros(11,1);
    for i=-5:5
        if i<0
            dist(i+6)=sum((w1(1:end+i)-w0(1-i:end)).^2/(11-abs(i))).^0.5;
        else
            dist(i+6)=sum((w1(1+i:end)-w0(1:end-i)).^2/(11-abs(i))).^0.5;
        end
    end
    [~,index]=min(dist);
    index=index-6;
end