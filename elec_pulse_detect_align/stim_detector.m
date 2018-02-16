% This function is used to detect the artifact of electrical pulse that is applied to stimulate
% the vestibular ganglion. The timing and shape of those pulses are
% important to distinguish real neuronal voltage signal from stimulation
% artifact.

% Modified from EPSC_detection code

function [s_trials,f_trials,aligned_succ_EPSC]=stim_detector(data,si,color)
    v_d=smooth(data(:,1)); % data smoothing
    %% calculate derivative of signal and find threshold crossing point
    diff_v=diff(v_d)./si.*1e6;
    thre=2e6;
    cross_thre=diff_v>thre;
    sign_cross_thre=diff(cross_thre)==1;% find the first crossing point for an electrical pulse event
    X_=1:length(sign_cross_thre);
    X=X_(sign_cross_thre);
    %% Plot data and detected beginning of an electrical pulse
    x_data=(1:length(v_d)).*si*1e-6;
    figure('Unit','Normal','position',[0 0.3 1 0.6]);
    plot(x_data,v_d,'k','LineWidth',2);
    hold on;
    scatter(X.*si*1e-6,v_d(X),'r*');
    hold off;
    xlabel('s')
    ylabel('pA','Rotation',90)
%     xlim([14.7 14.9])
%     ylim([-200 -20])
    A=gca;
    set(A,'fontsize',20,'fontweight','bold','box','off')
    %% Align and baseline substract all stimulated events

    range_zero=X(1)-5:X(1)+20;
    trials=zeros(length(X),1001);
    for i=1:length(X)
        range=X(i)-5:X(i)+20;
        %delay=finddelay(v_d(range_zero)-mean(v_d(X(1)-50:X(1)-10)),v_d(range)-mean(v_d(X(i)-50:X(i)-10)));
        delay=get_delay(v_d(range_zero)-mean(v_d(X(1)-50:X(1)-10)),v_d(range)-mean(v_d(X(i)-50:X(i)-10)));
        X(i)=X(i)+delay;
        trials(i,:)=v_d(X(i)-500:X(i)+500)-mean(v_d(X(i)-50:X(i)-10));
    end
    threshold=-100;
    if strcmp(color,'g')
        low_thre=-100;
    else
        low_thre=-100;
    end
    failures=find_failures(trials,threshold,low_thre);
    
%     %% Cluster all events with PCA and kmeans
%     [coeff,score,latent] = pca(trials(:,500:750));
%     clust_index = kmeans(trials(:,500:750),clust_num);
%     color_map=colormap(jet(clust_num));
%     figure;
%     hold on;
%     for i = 1:length(score)
%         scatter3(score(i,1),score(i,2),score(i,3),'MarkerEdgeColor',color_map(clust_index(i),:));
%     end
%     hold off;
%     figure
%     hold on;
%     for i=1:size(trials,1)
%         plot(x_data,trials(i,:),'color',color_map(clust_index(i),:))
%     end
%     hold off;
    x_data=(1:size(trials,2))*si*1e-3-10;
    f_trials=trials(failures==1,:);
    s_trials=trials(failures==0,:);
    if sum(failures==1)>1
    f_average=mean(f_trials,1);  
    %% Subtract failures to remove electrical artifact and only real signal remains
    fail_EPSC=zeros(sum(failures==1),size(trials,2));
    succ_EPSC=zeros(sum(failures==0),size(trials,2));
    latency=zeros(sum(failures==0),1);
    j=1;
    k=1;
%     figure;
%     hold on;

    for i=1:length(X)
        if failures(i)==1
            fail_EPSC(j,:)=trials(i,:)-f_average;
%             plot(x_data,fail_EPSC(j,:),'b')  
            j=j+1;
        elseif failures(i)==0
            succ_EPSC(k,:)=trials(i,:)-f_average;
%             plot(x_data,succ_EPSC(k,:),'Color',[0.3,0.3,0.3])
            latency(k)=find_ten_per_rise(succ_EPSC(k,501:end));
            k=k+1;
        end
    end
%     hold off;
%     xlabel('ms')
%     ylabel('pA')
%     A=gca;
%     set(A,'fontsize',20,'fontweight','bold','box','off')
    else
        succ_EPSC=zeros(sum(failures==0),size(trials,2));
        latency=zeros(sum(failures==0),1);
        k=1;
        for i=1:size(trials,1)
            if failures(i)==0
                succ_EPSC(k,:)=trials(i,:);
                latency(k)=find_ten_per_rise(succ_EPSC(k,501:end));
                k=k+1;
            end
        end
    end
    %% Align the EPSC signals based on their peaks or 10%/50% rise time
    figure('Unit','Normal','position',[0.2 0.3 0.4 0.6]);
    hold on;
    latency_ms=latency*si*1e-3;
    laten_med=round(median(latency));
    aligned_succ_EPSC=succ_EPSC;
    for i=1:size(succ_EPSC,1)
        discre=latency(i)-laten_med;
        if discre>0
            aligned_succ_EPSC(i,:)=[succ_EPSC(i,1+discre:end),zeros(1,discre)];
        elseif discre<0
            aligned_succ_EPSC(i,:)=[zeros(1,-discre),succ_EPSC(i,1:end+discre)];
        end
        plot(x_data,aligned_succ_EPSC(i,:),'Color',[0.3,0.3,0.3])
    end
    aligned_succ_EPSC_aver=mean(aligned_succ_EPSC,1);
    plot(x_data,aligned_succ_EPSC_aver,color,'LineWidth',4)
    hold off;
    xlabel('ms')
    ylabel('pA')
    xlim([-1 5])
%     ylim([-200 150])
    
    A=gca;
    set(A,'fontsize',20,'fontweight','bold','box','off')
    figure;
    histogram(latency_ms,'BinWidth',0.05,'Normalization','probability','FaceColor',color,'EdgeColor','k')
    xlabel('ms')
    A=gca;
    set(A,'fontsize',20,'fontweight','bold','box','off')
    MEAN=mean(latency_ms)
    STD=std(latency_ms)
%     figure;
%     plot(X(failures==0),latency_ms)
end

function index=get_delay(w0,w1)
    dist=zeros(11,1);
%     figure;
%     hold on;
    for i=-5:5
        if i<0
            dist(i+6)=sum((w1(1:end+i)-w0(1-i:end)).^2/(11-abs(i))).^0.5;
            %dist(i+7)=max(abs(w1(1:end+i)-w0(1-i:end)));
            %plot(w1(1:end+i)-w0(1-i:end),'r')
        else
            dist(i+6)=sum((w1(1+i:end)-w0(1:end-i)).^2/(11-abs(i))).^0.5;
            %dist(i+7)=max(abs(w1(1+i:end)-w0(1:end-i))); 
            %plot(w1(1+i:end)-w0(1:end-i),'g')
        end
    end
    [~,index]=min(dist);
    index=index-6;
end

function i=find_ten_per_rise(w)
    [EPSC_peak,index]=min(w);
    i=1;
    per=0.5;% 0.5 indicate 50% rise time
    while i<index-1
        if w(i)>per*EPSC_peak&&w(i+1)<per*EPSC_peak 
            break
        end
        i=i+1;
    end 
end
% use peak to distinguish success and failures, not the best way,
% need to be modified later
function failure_index=find_failures(trials,threshold,varargin)
    failure_index=zeros(size(trials,1),1);
    low_thre=0;
    if ~isempty(varargin)
    low_thre=varargin{1};
    end
    for i=1:size(trials,1)
        if trials(i,:)>threshold
            if trials(i,:)>low_thre
                failure_index(i)=2;
            else
                failure_index(i)=1;
            end
        end
    end
end