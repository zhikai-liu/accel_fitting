function process_plot_fista_results(filename)
        S=load(filename);
        clust_num=max(S.fista.X1_clust);
        map=colormap(jet(clust_num));% Colormap for different clusters
        %% Plot the raw deconvolved signals for all clusters, color-coded by clusters, reflecting waveforms
        figure;
        hold on;
        for i=1:length(S.fista.X1_max)
            if S.fista.X1_clust(i)==0
                plot(S.fista.X1_prox(i,:),'k')
            else
                plot(S.fista.X1_prox(i,:),'color',map(S.fista.X1_clust(i),:))
            end
        end
        hold off
        title('Raw deconvolved signals')
        print('cluster_amp_waveforms.jpg','-r300','-djpeg');
        %% Plot integral of deconvolved signals for all events, color-coded by clusters, reflecting amplitudes
        figure;
        hold on;
        for i=1:clust_num
            histogram(S.fista.X1_integral(S.fista.X1_clust==i),'FaceColor',map(i,:));
        end
        hold off;
        title('Deconvolved signal integral')
        xlabel('X1_integral')
        print('cluster_X1_integral_histogram.jpg','-r300','-djpeg');
        %% Plot amplitudes of events detected
        figure;
        hold on;
        for i=1:clust_num
            histogram(S.fista.amps(S.fista.X1_clust==i),'FaceColor',map(i,:));
        end
        hold off;
        title('EPSC amps')
        xlabel('pA')
        print('cluster_amp_histogram.jpg','-r300','-djpeg');
        %% Plot scatter points for integral vs std, color-coded by clusters
        if S.fista.X1_clust~=0
            g_map=map;
        else
            g_map=[0,0,0;map];
        end
        figure;
        gscatter(S.fista.X1_integral,S.fista.X1_std,S.fista.X1_clust,g_map);
        title('Deconvolved signal integral VS std')
        xlabel('X1_integral')
        ylabel('X1_std')
        print('cluster_integral_std.jpg','-r300','-djpeg');
        %% Plot tsne visualization of the X1_prox
        figure;
        rng default;
        Y=tsne(S.fista.X1_prox);
        gscatter(Y(:,1),Y(:,2),S.fista.X1_clust,g_map)
        title('tsne')
        print('cluster_tsne.jpg','-r300','-djpeg');
        %% Plot autocorrelogram within a cluster and cross-correlogram between clusters
        fista_autocorrelogram(S.fista.X1_max,S.fista.X1_clust)
        %fista_autocorrelogram(S.fista.X1_max(~S.fista.X1_chemical),S.fista.X1_clust(~S.fista.X1_chemical))
        print('cluster_autocorrelogram.jpg','-r300','-djpeg');
        %% Plot reconstructed signals from deconvolution
        plot_fista_reconstruct(filename)
end