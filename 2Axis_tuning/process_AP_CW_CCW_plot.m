function process_AP_CW_CCW_plot(filename)
S1=load([filename '_5.mat']);
S2=load([filename '_6.mat']);
rev_vec=struct();
Axis_lim=0;
figure('Units','Normal','Position',[0.1,0.2,0.85,0.5]);

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
        stim_vector=X+1i*Y;
        stim_period=sum(abs(stim_vector)>0.01);
        stim_period_s=stim_period.*20.*1e-6;
        index_cluster=S.der.event_peak;
        cluster_vector=X(index_cluster)+1i*Y(index_cluster);
        valid_cluster_vector=cluster_vector(abs(cluster_vector)>0.01);
        %scatter(X(small_),Y(small_),'b')
        sum_vector=sum(valid_cluster_vector./abs(valid_cluster_vector))./stim_period_s;
        rev_vec.(TX)=sum_vector;
        h=quiver(0,0,real(sum_vector),imag(sum_vector),'r','LineWidth',3,'MaxHeadSize',2);
        %set(h,'AutoScale','on', 'AutoScaleFactor', 2)
        text(real(sum_vector),imag(sum_vector),TX,'FontSize',20)
        Axis_lim=max(Axis_lim,abs(sum_vector));
    end
    xlim([-Axis_lim Axis_lim])
    ylim([-Axis_lim Axis_lim])
    legend('boxoff')
    AxisFormat;
    Sratio=round(abs((abs(rev_vec.CW)-abs(rev_vec.CCW))./(abs(rev_vec.CW)+abs(rev_vec.CCW))),2);
title([filename ', Sratio: ' num2str(Sratio)],'FontSize',24,'interpreter','none');
print([filename '_CW_CCW_plot.jpg'],'-r300','-djpeg');
save(['CW_CCW_' filename '.mat'],'rev_vec')
end
function AxisFormat()
    A=gca;
    set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
    set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
    axis square
end