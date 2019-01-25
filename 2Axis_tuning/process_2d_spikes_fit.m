function [X,All_vectors]=process_2d_spikes_fit(filename)
    S=load(filename);
    fNames={'X','Y','XpYp','XpYn'};
    All_vectors=zeros(length(fNames),1);
    tuning_r=zeros(length(fNames),1);
    tuning_angle=zeros(length(fNames),1);
    clust_polar=struct();
    for i=1:4
    All_vectors(i)=events_fit2tuning(S.(fNames{i}).der.event_index,S.(fNames{i}).fit_model{1});
    stim_freq=S.(fNames{i}).fit_freq{1};
    cycle_num=S.(fNames{i}).cycle_num{1};
    tuning_r(i)=abs(All_vectors(i))./cycle_num.*stim_freq;
    tuning_angle(i)=angle(All_vectors(i));
    end
    cos_sign=sign(cos(tuning_angle));
    sin_sign=sign(sin(tuning_angle));
    basis=[1,0;0,1;1/sqrt(2),1/sqrt(2);-1/sqrt(2),1/sqrt(2)];
    x=zeros(length(fNames),1);
    y=zeros(length(fNames),1);
    figure
    hold on
    for i=1:length(fNames)
        x(i)=tuning_r(i).*basis(i,1);
        y(i)=tuning_r(i).*basis(i,2);
        plot([0, sin_sign(i).*x(i)],[0 sin_sign(i).*y(i)],'k','LineWidth',5);
        %scatter(sin(tuning_angle(i)).*x(i),sin(tuning_angle(i)).*y(i),'*k')
        h=quiver(sin(tuning_angle(i)).*x(i),sin(tuning_angle(i)).*y(i),x(i).*cos_sign(i)*0.25,y(i).*cos_sign(i)*0.25,...
           'color','red','LineWidth',4,'MaxHeadSize',2,'Marker','*');
        set(h,'AutoScale','on', 'AutoScaleFactor', 3)
    end
    Lim=max(tuning_r)*1.5;
    xlim([-Lim Lim])
    ylim([-Lim Lim])
    title({filename},'interpreter','none','FontSize',24)
    legend('boxoff')
    %set(gca,'Units','inches','position',[1+8.*(j-1),1,6,6])
    AxisFormat()
    clust_polar.x=x;
    clust_polar.y=y;
    clust_polar.phase=tuning_angle;
    save(filename,'clust_polar','-append')
    print([filename '_spikes_fit_model.jpg'],'-r300','-djpeg')
    fit_2d_4axis(filename,1);
    print([filename '_spikes_fit_model_stv.jpg'],'-r300','-djpeg')
    
%     %print([filename '_polar_cycle'],'-r300','-djpeg')
%     orientations=[0,pi/2,pi/4,3*pi/4];
%     [fitobj,gof,~]=fitting_ellipse(orientations',tuning_r');
%     %Sratio=fitobj.b./fitobj.a;
%     
%     X=STV;
%     if fitobj.a>fitobj.b
%         X.alpha=fitobj.c;
%         X.Smax=fitobj.a;
%         X.Smin=fitobj.b;
%     else
%         X.alpha=fitobj.c+pi/2;
%         X.Smax=fitobj.b;
%         X.Smin=fitobj.a;
%     end
%     X.gain_gof=gof;
%     %% Plot fitting results
%     if if_plot
%         figure('Units','Normal','Position',[0,0,0.6,1]);
%         plot_ellipse(X,All_vectors)
%         Ax_lim=max([abs(All_vectors),X.Smax]);
%         
%         xlim([-Ax_lim Ax_lim])
%         ylim([-Ax_lim Ax_lim])
%         axis square
%         title({filename,['gof: ', num2str(X.gain_gof.rsquare)],['Sratio: ', num2str(X.Smin/X.Smax)]},'FontSize',24,'interpreter','none')
%         print([filename '_spikes_fit_model'],'-r300','-djpeg')
%     end
end

function AxisFormat()
A=gca;
set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
axis square
end