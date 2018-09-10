function process_2d_CW_CCW_plot(filename)
S1=load([filename '_5.mat']);
S2=load([filename '_6.mat']);
clust_num=S1.fista.clust_num;
figure('Units','Normal','Position',[0.1,0.2,0.85,0.5]);
for j=1:clust_num
    subplot(1,clust_num,j)
    hold on;
    for i=1:2
        if i==1
            S=S1;
            TX='CW';
        else
            S=S2;
            TX='CCW';
        end
        X=smooth(S.Data(:,2));
        X=X-mean(X);
        Y=smooth(S.Data(:,3));
        Y=Y-mean(Y);
        index_ampbin=S.fista.X1_max(S.fista.X1_clust==j);
        ampbin_tuning=index_ampbin(X(index_ampbin).^2+Y(index_ampbin).^2>0.01^2);
        %scatter(X(small_),Y(small_),'b')
        ampbin_n=length(ampbin_tuning);
        h=quiver(0,0,ampbin_n.*mean(X(ampbin_tuning)),ampbin_n.*mean(Y(ampbin_tuning)),'r','LineWidth',3,'MaxHeadSize',2);
        %set(h,'AutoScale','on', 'AutoScaleFactor', 2)
        text(ampbin_n.*mean(X(ampbin_tuning)),ampbin_n.*mean(Y(ampbin_tuning)),TX,'FontSize',20)
    end
    Axis_lim=2;
    xlim([-Axis_lim Axis_lim])
    ylim([-Axis_lim Axis_lim])
    legend({['Cluster ' num2str(j)]},'FontSize',24)
    legend('boxoff')
    AxisFormat;
end
print([filename '_CW_CCW_plot.jpg'],'-r300','-djpeg');
end
function AxisFormat()
    A=gca;
    set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
    set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
    axis square
end