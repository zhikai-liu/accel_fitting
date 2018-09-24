function fit_2d_4axis(filename,if_plot)
    S=load(filename);
    clust_num=length(S.clust_polar);
    x=[0;pi/2;pi/4;3*pi/4];
    if if_plot
    figure('Unit','Normal','position',[0 0.3 0.3+0.1*clust_num 0.6]);
    end
    stv=STV;
    for i=1:clust_num
        gain=sqrt(S.clust_polar(i).x.^2+S.clust_polar(i).y.^2);
        phase=S.clust_polar(i).phase;
        cos_sign=sign(cos(phase));
        [gain_fitobj,gain_gof,~]=fitting_ellipse(x,gain);
        if gain_fitobj.a>gain_fitobj.b
            stv(i).Smax=gain_fitobj.a;
            stv(i).Smin=gain_fitobj.b;
            stv(i).alpha=gain_fitobj.c;
        else
            stv(i).Smax=gain_fitobj.b;
            stv(i).Smin=gain_fitobj.a;
            stv(i).alpha=gain_fitobj.c+pi/2;
        end
        [phase_fit,phase_gof,Rs_e,Rs_w]=fitting_phase(stv(i),x,phase,1);
        [phase_fit_al,phase_gof_al,Rs_e_al,Rs_w_al]=fitting_phase(stv(i),x,phase,-1);
        %% Two directions (CCW and CW) are fitted, choose the one fitted better
        if phase_gof_al<phase_gof
            stv(i).phi=phase_fit_al;
            stv(i).Smin_leading=-1;
            Rs=Rs_e_al;
            RsW=Rs_w_al;
        else
            stv(i).phi=phase_fit;
            stv(i).Smin_leading=1;
            Rs=Rs_e;
            RsW=Rs_w;
        end
        %% Make phase always between 0 and pi
        if stv(i).phi<0
            stv(i).phi=stv(i).phi+pi;
            stv(i).alpha=stv(i).alpha+pi;
            %stv(i).Smin_leading=stv(i).Smin_leading*-1;
        end
        %% Make vector angle always between 0 and 2pi
        while 1
        if stv(i).alpha<0
            stv(i).alpha=stv(i).alpha+2*pi;
        elseif stv(i).alpha>=2*pi
            stv(i).alpha=stv(i).alpha-2*pi; 
        else
            break;
        end
        end
        if if_plot
        subplot(2,clust_num,i)
        plot_ellipse_phase_2d(stv(i))
        hold on;
        for j=1:length(S.clust_polar(i).x)
            plot([S.clust_polar(i).x(j),-S.clust_polar(i).x(j)],[S.clust_polar(i).y(j),-S.clust_polar(i).y(j)],'g')
            
            quiver(sin(phase(j)).*S.clust_polar(i).x(j),sin(phase(j)).*S.clust_polar(i).y(j),...
                cos_sign(j).*S.clust_polar(i).x(j)*0.25,cos_sign(j).*S.clust_polar(i).y(j)*0.25,...
                 'color','blue','LineWidth',4,'MaxHeadSize',2,'Marker','*');
        end
        title({['Cluster ' num2str(i) ' Ratio: ' num2str(stv(i).Smin/stv(i).Smax)],['Gain Rsquare: ' num2str(gain_gof.rsquare)],...
            ['Phase Rs: ' num2str(Rs)]},'FontSize',20,'FontWeight','bold')
        hold off;
        Axis_lim=stv(i).Smax+stv(i).Smin;
        xlim([-Axis_lim Axis_lim])
        ylim([-Axis_lim Axis_lim])
        axis square
        subplot(2,clust_num,i+clust_num)
        plot_revolve(stv(i))
        Axis_lim=stv(i).Smax+stv(i).Smin;
        xlim([-Axis_lim Axis_lim])
        ylim([-Axis_lim Axis_lim])
        axis square
        end
    end
    save(filename,'stv','-append')
end