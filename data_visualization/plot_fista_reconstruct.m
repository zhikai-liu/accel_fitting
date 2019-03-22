function plot_fista_reconstruct(filename)
    S=load(filename);
    if isfield(S,'data_pad')
        data_pad=S.data_pad;
    elseif isfield(S,'Data')
        data_pad=S.Data(:,1);
    end
    clust_num=max(S.fista.X1_clust);
    map=colormap(jet(clust_num));
    figure;
    subplot(5,1,1)
    hold on;
    Y1_data=conv(S.fista.X1,S.fista.template1);
    
    plot((1:length(Y1_data))*S.si*1e-6,Y1_data,'r');
    Y2_data=conv(S.fista.X2,S.fista.template2);
    plot((1:length(Y2_data))*S.si*1e-6,Y2_data,'g');
    hold off;
    recons_data=Y1_data+Y2_data;
    subplot(5,1,2)
    x_data=(1:length(data_pad))*S.si*1e-6;
    Y=smooth(data_pad'-median(data_pad));
    plot(x_data,Y,'k')
    hold on
    plot(x_data,recons_data(1:length(x_data)),'g')
    plot(x_data,recons_data(1:length(x_data))'-Y','r')
    for i=1:clust_num
        x_data=S.fista.X1_max(S.fista.X1_clust==i);
        scatter(x_data*S.si*1e-6,Y(x_data),[],map(i,:),'*');
    end
    hold off

    subplot(5,1,3)
    instan_index=zeros(clust_num,length(S.data_pad));
    x_data=(1:length(data_pad))*S.si*1e-6;
    hold on
    for i=1:clust_num
        clust_index=S.fista.X1_max(S.fista.X1_clust==i);
        firing_interval=diff(clust_index)*S.si*1e-6;
        instan_firing=1./firing_interval;
        for j=1:length(instan_firing)
            instan_index(i,clust_index(j):clust_index(j+1)-1)=instan_firing(j);
        end
        plot(x_data,log10(instan_index(i,:)),'color',map(i,:))
    end
    plot([x_data(1),x_data(end)],[log10(500),log10(500)],'k:')
    plot([x_data(1),x_data(end)],[log10(1000),log10(1000)],'k:')
    hold off 
    
    
    
    
    subplot(5,1,4)
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
    
    subplot(5,1,5)
    y_data=S.fista.X2;
    plot((1:length(y_data))*S.si*1e-6,y_data)
    hold on
    for i=1:clust_num
        x_data=S.fista.X1_max(S.fista.X1_clust==i);
        scatter(x_data*S.si*1e-6,S.fista.X2(x_data),[],map(i,:),'*');
    end
    hold off
    samexaxis('ytac','join','box','off');
    xlabel('s')
    
    
end