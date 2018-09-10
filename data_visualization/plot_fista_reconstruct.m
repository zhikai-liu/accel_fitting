function plot_fista_reconstruct(filename)
    S=load(filename);
    clust_num=max(S.fista.X1_clust);
    map=colormap(jet(clust_num));
    figure;
    subplot(3,1,1)
    hold on;
    Y1_data=conv(S.fista.X1,S.fista.template1);
    plot((1:length(Y1_data))*S.si*1e-6,Y1_data,'r');
    Y2_data=conv(S.fista.X2,S.fista.template2);
    plot((1:length(Y2_data))*S.si*1e-6,Y2_data,'g');
    hold off;
    recons_data=Y1_data+Y2_data;
    subplot(3,1,2)
    x_data=(1:length(S.data_pad))*S.si*1e-6;
    plot(x_data,S.data_pad,'k')
    hold on
    plot(x_data,recons_data,'g')
    plot(x_data,recons_data'-S.data_pad,'r')
    for i=1:clust_num
        x_data=S.fista.X1_max(S.fista.X1_clust==i);
        scatter(x_data*S.si*1e-6,S.data_pad(x_data),[],map(i,:),'*');
    end
    hold off

    subplot(3,1,3)
    y_data=S.fista.X1;
    plot((1:length(y_data))*S.si*1e-6,y_data)
    hold on
    for i=1:clust_num
        x_data=S.fista.X1_max(S.fista.X1_clust==i);
        scatter(x_data*S.si*1e-6,S.fista.X1(x_data),[],map(i,:),'*');
    end
    hold off
    
    samexaxis('ytac','join','box','off');
    xlabel('s')
end