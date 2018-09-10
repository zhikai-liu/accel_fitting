function process_merge_clusters(filename,m_clusters)
% This codes is used to merge some clusters if they are over-clustered
    S=load(filename);
    fista=S.fista;
    new_clust=fista.X1_clust;
    %% all will be labeled by the smallest cluster number
    min_clust=min(m_clusters);
    for i=1:length(m_clusters)
        new_clust(new_clust==m_clusters(i))=min_clust;
    end
    %% After merging, there are some empty clusters to be cleaned
    for i=1:max(new_clust)
        if ~(new_clust==i)
            for j=i:max(new_clust)
                new_clust(new_clust==j)=j-1;
            end
        end
    end
    fista.X1_clust=new_clust;
    save(filename,'fista','-append')
end