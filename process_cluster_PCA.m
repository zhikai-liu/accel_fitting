function event_raw = process_cluster_PCA(filename_h,range)
    f_mat = dir([filename_h '*.mat']);
    event_raw = [];
    Amps=[];
    if strcmp(range,'all')
        range=1:length(f_mat);
    end
    for i =range
        clearvars S
        S = load(f_mat(i).name);
        for j = 1:length(S.event_index)
            index = S.event_index(j);
            if abs(index-16700)>200&& abs(index-26700)>200 && index-50>1 &&index+100<length(S.Data)
            event_raw = [event_raw,smooth(S.Data(index-50:index+100,1))];
            Amps=[Amps,S.amps(j)];
            end
        end
    end
    [coeff,score,latent] = pca(event_raw(50:120,:)');
    clust_num = 4;
    clust_index = kmeans(event_raw(50:120,:)',clust_num);
    %Color = {'r','g','b','k','m','c'};
    map=[1,0,0;0,1,0;0,0,1;0,0,0;1,0,1;0,1,1];
    figure;
    hold on;
    for i = 1:length(score)
    scatter3(score(i,1),score(i,2),score(i,3),'MarkerEdgeColor',map(clust_index(i),:));
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
        event_raw(:,i)=event_raw(:,i)-mean(event_raw(40:50,i));
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
end