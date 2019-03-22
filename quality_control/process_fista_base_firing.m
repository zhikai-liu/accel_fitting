function process_fista_base_firing(filename)
    S=load(filename);
    fista=S.fista;
    fista.clust_num=max(fista.X1_clust); 
    %fista.base_firing=zeros(fista.clust_num,1);
    for i=1:fista.clust_num
        clust_index=fista.X1_max(fista.X1_clust==i);
        fista.base_firing(i).IEI=diff(clust_index).*S.si.*1e-6;
        fista.base_firing(i).firing_rate=1./mean(fista.base_firing(i).IEI,'omitnan');
        fista.base_firing(i).CV=mean(fista.base_firing(i).IEI,'omitnan')./std(fista.base_firing(i).IEI,'omitnan');
    end
    save(filename,'fista','-append')
end