function event_raw = process_cluster_PCA(filename_h,range)
f_mat = dir([filename_h '*.mat']);
si=20;
rise_index=[];
event_raw = [];
Amps=[];
trial_num=[];
peak_index=[];
if strcmp(range,'all')
    range=1:length(f_mat);
end
for i =range
    clearvars S
    S = load(f_mat(i).name);
    SD=smooth(S.Data);
    for j = 1:length(S.event_index)
        index = S.event_index(j);
        if abs(index-16700)>200&& abs(index-26700)>200&&index-50>1&&index+100<length(SD)
            %if S.der_index(j)==2
            rise_index=[rise_index,index];
            Amps=[Amps,S.amps(j)];
            peak_index=[peak_index,S.event_peak(j)];
            trial_num=[trial_num,i];
            %der_index=[der_index,S.der_index(j)];
            %event_clips=SD(index-50:index+100,1); %% align on the beginning of the EPSC
            %event_clips=event_clips-mean(event_clips(40:50));
            
            event_clips=SD(S.event_peak(j)-50:S.event_peak(j)+5000,1); %% align on the EPSC peak
            event_clips=event_clips-mean(SD(index-5:index));
            event_raw = [event_raw,event_clips];
            
            %end
        end
    end
end
cluster_parts=event_raw(30:80,:);
[coeff,score,latent,~,explained] = pca(cluster_parts');
%clust_num = 10;
%clust_index = kmeans(event_raw(50:120,:)',clust_num);
opts.isocut_threshold=1;
%opts.prevent_merge=true;
clust_index=isosplit5(cluster_parts,opts);
%Color = {'r','g','b','k','m','c'};
%map=[1,0,0;0,1,0;0,0,1;0,0,0;1,0,1;0,1,1];
%map=[map;map./2];
%ms_view_clusters(score',clust_index);
clust_num=max(clust_index);
map=colormap(jet(clust_num));

% Plot figures
%plotting PCA space and cluster visualization
figure;
hold on;
for i = 1:clust_num
    inds=find(clust_index==i);
    scatter3(score(inds,1),score(inds,2),score(inds,3),'MarkerEdgeColor',map(i,:));
end

%plotting amplitudes distribution
figure;
Amps_clust=cell(1,clust_num);
for j=1:clust_num
    Amps_clust{j}=Amps(clust_index==j);
end
colormap(map(1:clust_num,:));
nhist(Amps_clust,'numbers','smooth','binfactor',20,'color','colormap')

%plotting overlap EPSC traces colored by clusters
figure;
for i = 1:length(event_raw)
    plot(event_raw(:,i),'color',map(clust_index(i),:))
    hold on;
end

%plotting each cluster of EPSC separately in subplots
figure;
for i = 1:clust_num
    subplot(clust_num,1,i)
    for j =1:length(score)
        if clust_index(j) == i
            plot(event_raw(:,j),'color',map(clust_index(j),:))
            hold on;
        end
    end
end
samexaxis('ytac','join','box','off');

%plotting time series of events in their amps, colored by clusters
figure;
hold on;
x_start=zeros(length(range),1);
for i=range
    xdata=x_start(i)+peak_index(trial_num==i);
    ydata=Amps(trial_num==i);
    cdata=clust_index(trial_num==i);
    for j=1:clust_num
        c_xdata=xdata(cdata==j);
        c_ydata=ydata(cdata==j);
        scatter(c_xdata.*si.*1e-6,c_ydata,'MarkerEdgeColor',map(j,:))
    end
    plot([x_start.*si.*1e-6 x_start.*si.*1e-6],[0 100],'k--')
    if i<length(range)
        x_start(i+1)=max(xdata)+5000;
    end
end
hold off;


%Plottign corrolegram
figure;
pad=100*1e3/si;%pad length is 100ms

for j=1:clust_num
    cross_corr=zeros(sum(clust_index==j),2*pad+1);
    count=1;
    subplot(clust_num,1,j)
    for i=range
        xdata=peak_index(trial_num==i);
        cdata=clust_index(trial_num==i);
        c_xdata=xdata(cdata==j);
        spikes=zeros(1,max(c_xdata)+2*pad);
        spikes(c_xdata+pad)=1;
        for k=1:length(spikes)
            if spikes(k)==1
                bin_train=spikes(k-pad:k+pad);
                bin_train(pad+1)=0;
                cross_corr(count,:)=bin_train;
                count=count+1;
            end
        end
        
    end
    corr=sum(cross_corr);
    box=1e3/si;
    corr_ms=zeros(1,2*pad/box);
    for i=1:length(corr_ms)/2
        ms_range=1+box*(i-1):box*i;
        corr_ms(i)=sum(corr(ms_range));
    end
    bar(-pad/box:-1,corr_ms(1:pad/box),'FaceColor',map(j,:),'EdgeColor',map(j,:))
    hold on;
    for i=1+length(corr_ms)/2:length(corr_ms)
        ms_range=2+box*(i-1):1+box*i;
        corr_ms(i)=sum(corr(ms_range));
    end
    bar(1:pad/box,corr_ms(1+pad/box:end),'FaceColor',map(j,:),'EdgeColor',map(j,:))
    hold off;
end
end
