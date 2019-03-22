function process_fista_neighbor_clust(filename)
% Cluster the events with isosplit5 algorithm, also make sure the labels 
% will follow them after events are separated into different files.
    S=load(filename);
    fista=S.fista;
    %data_s=smooth(S.data_pad);
    fista.X1_neighbor=zeros(length(fista.X1_max),56);
    for i=1:length(fista.X1_max)
        fista.X1_neighbor(i,:)=fista.X1(fista.X1_max(i)-5:fista.X1_max(i)+50)';
    end
    opts.isocut_threshold=1;% setting threshold for clustering, see isosplit5 for specifics
    fista.neighbor_clust=isosplit5(fista.X1_neighbor',opts)';
    %fista.X1_clust=isosplit5(fista.X1_waveform',opts)';
    %fista.X1_clust=isosplit5([fista.X1_integral]',opts)';
    figure;
    clust_num=max(fista.neighbor_clust);
    map=colormap(jet(clust_num));
    for i=1:max(clust_num)
        subplot(clust_num,1,i)
        hold on;
        for j=1:length(fista.X1_max)
            if fista.neighbor_clust(j)==i
                plot(fista.X1_neighbor(j,:),'color',map(i,:))
            end
        end
        hold off;
    end
    fista_autocorrelogram(fista.X1_max,fista.neighbor_clust)
    
    if fista.neighbor_clust~=0
        g_map=map;
    else
        g_map=[0,0,0;map];
    end
    figure;
    gscatter(fista.X1_integral,fista.X1_std,fista.neighbor_clust,g_map);
    xlabel('X1_integral')
    ylabel('X1_std')
    figure;
    gscatter(fista.amps,fista.X1_std,fista.neighbor_clust,g_map);
    xlabel('amps')
    ylabel('X1_std')    
end