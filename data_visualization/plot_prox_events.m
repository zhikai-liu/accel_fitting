function plot_prox_events(filename)
    S=load(filename);
    clust_num=max(S.fista.X1_clust);
    map=colormap(jet(clust_num));
    thre=50;
    figure;
    for i=1:clust_num
    events=S.fista.X1_max(S.fista.X1_clust==i);
    diff_events=[diff(events);0];
    vio_events=events(diff_events<thre);
    subplot(clust_num,1,i)
    hold on
    for j=1:length(vio_events)
        plot(S.data_pad(vio_events(j):vio_events(j)+200),'color',map(i,:))
    end
    hold off
    end
    samexaxis('ytac','join','box','off');
end