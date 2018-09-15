function fit_2d_4axis(filename)
    S=load(filename);
    clust_num=length(S.clust_polar);
    x=[0;pi/2;pi/4;0.75*pi];
    figure;
    for i=1:clust_num
        gain=sqrt(S.clust_polar(i).x.^2+S.clust_polar(i).y.^2);
        [fitobj,gof,~]=fitting_ellipse(x,gain);
        stv=STV;
        stv.Smax=fitobj.a;
        stv.Smin=fitobj.b;
        stv.alpha=fitobj.c;
        subplot(1,clust_num,i)
        plot_ellipse(stv)
        hold on;
        for j=1:length(S.clust_polar(i).x)
            plot([S.clust_polar(i).x(j),-S.clust_polar(i).x(j)],[S.clust_polar(i).y(j),-S.clust_polar(i).y(j)],'k')
        end
        title({['Cluster ' num2str(i) ' Ratio: ' num2str(stv.Smin/stv.Smax)],['Rsquare: ' num2str(gof.rsquare)]})
        hold off;
    end
end