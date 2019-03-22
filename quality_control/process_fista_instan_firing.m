function process_fista_instan_firing(filename)
    S=load(filename);
    fista=S.fista;
    fista.clust_num=max(fista.X1_clust); 
    subplot_num=fista.clust_num+1;
    instan_index=zeros(fista.clust_num,length(S.data_pad));
    map=colormap(jet(fista.clust_num));
    figure;
    for i=1:fista.clust_num
        subplot(subplot_num,1,i)
        clust_index=fista.X1_max(fista.X1_clust==i);
        firing_interval=diff(clust_index)*S.si*1e-6;
        instan_firing=1./firing_interval;
        for j=1:length(instan_firing)
            instan_index(i,clust_index(j):clust_index(j+1)-1)=instan_firing(j);
        end
        plot(log10(instan_index(i,:)),'color',map(i,:))
        hold on;
        plot([1,length(instan_index)],[log10(500),log10(500)],'k:')
        plot([1,length(instan_index)],[log10(1000),log10(1000)],'k:')
        hold off;
    end
    subplot(subplot_num,1,subplot_num)
    plot(S.data_pad,'k')
    samexaxis('ytac','join','box','off');
    %save(filename,'fista','-append')
end