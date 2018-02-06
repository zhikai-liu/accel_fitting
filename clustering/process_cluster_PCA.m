function event_raw = process_cluster_PCA(filename_h,range)
f_mat = dir([filename_h '*.mat']);
rise_index=[];
event_raw = [];
Amps=[];
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
                %der_index=[der_index,S.der_index(j)];
                %event_clips=SD(index-50:index+100,1);
                %event_clips=event_clips-mean(event_clips(40:50));
                
                event_clips=SD(S.event_peak(j)-50:S.event_peak(j)+100,1);
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
clust_index=isosplit5(score(:,1:3)',opts);
%Color = {'r','g','b','k','m','c'};
%map=[1,0,0;0,1,0;0,0,1;0,0,0;1,0,1;0,1,1];
%map=[map;map./2];
%ms_view_clusters(score',clust_index);
clust_num=max(clust_index);
map=colormap(jet(clust_num));
figure;
hold on;
for i = 1:clust_num
    inds=find(clust_index==i);
    scatter3(score(inds,1),score(inds,2),score(inds,3),'MarkerEdgeColor',map(i,:));
end
figure;
Amps_clust=cell(1,clust_num);
for j=1:clust_num
    Amps_clust{j}=Amps(clust_index==j);
end
colormap(map(1:clust_num,:));
nhist(Amps_clust,'numbers','smooth','binfactor',20,'color','colormap')
figure;
for i = 1:length(event_raw)
    plot(event_raw(:,i),'color',map(clust_index(i),:))
    hold on;
end
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
end