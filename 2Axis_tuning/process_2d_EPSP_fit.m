function [X,All_vectors]=process_2d_EPSP_fit(filename,if_plot)
    S=load(filename);
    [min_V,resting_potential]=mean_resting(S);
    if_sub=1;
    figure;
    subplot(1,4,1)
    X_vector=process_potential_cycle_fit(S.X.Data,S.X.S_period{1},S.X.fit_model{1},resting_potential,min_V,if_sub);
    xlabel('X')
    subplot(1,4,2)
    Y_vector=process_potential_cycle_fit(S.Y.Data,S.Y.S_period{1},S.Y.fit_model{1},resting_potential,min_V,if_sub);
    xlabel('Y')
    subplot(1,4,3)
    XpYp_vector=process_potential_cycle_fit(S.XpYp.Data,S.XpYp.S_period{1},S.XpYp.fit_model{1},resting_potential,min_V,if_sub);
    xlabel('X+Y+')
    subplot(1,4,4)
    XpYn_vector=process_potential_cycle_fit(S.XpYn.Data,S.XpYn.S_period{1},S.XpYn.fit_model{1},resting_potential,min_V,if_sub);
    xlabel('X-Y+')
    print([filename '_polar_cycle'],'-r300','-djpeg')
    
    All_vectors=[X_vector,Y_vector,XpYp_vector,XpYn_vector];
    orientations=[0,pi/2,pi/4,3*pi/4];
    [fitobj,gof,~]=fitting_ellipse(orientations',abs(All_vectors)');
    %Sratio=fitobj.b./fitobj.a;
    
    X=STV;
    if fitobj.a>fitobj.b
        X.alpha=fitobj.c;
        X.Smax=fitobj.a;
        X.Smin=fitobj.b;
    else
        X.alpha=fitobj.c+pi/2;
        X.Smax=fitobj.b;
        X.Smin=fitobj.a;
    end
    X.gain_gof=gof;
    %% Manual fitting
%     [min_res,vector_orien]=fitting_ellipse_manual(orientations',abs(All_vectors)');
%     X_man=STV;
%     A=sqrt(min_res.fitobj.p1+min_res.fitobj.p2);
%     B=sqrt(min_res.fitobj.p2);
%     if A>B
%         X_man.alpha=vector_orien;
%         X_man.Smax=A;
%         X_man.Smin=B;
%     else
%         X_man.alpha=vector_orien+pi/2;
%         X_man.Smax=B;
%         X_man.Smin=A;
%     end
%     X_man.gain_gof=min_res.gof;
    %% Plot fitting results
    if if_plot
        figure('Units','Normal','Position',[0,0,0.6,1]);
        plot_ellipse(X,All_vectors)
        Ax_lim=max([abs(All_vectors),X.Smax]);
        
        xlim([-Ax_lim Ax_lim])
        ylim([-Ax_lim Ax_lim])
        axis square
        title({filename,['gof: ', num2str(X.gain_gof.rsquare)],['Sratio: ', num2str(X.Smin/X.Smax)]},'FontSize',24,'interpreter','none')
        print([filename '_fit_model'],'-r300','-djpeg')
    end
end

function [min_V,M]=mean_resting(S)
    resting_1=S.X.Data(S.X.S_period{1},1);
    resting_2=S.Y.Data(S.Y.S_period{1},1);
    resting_3=S.XpYp.Data(S.XpYp.S_period{1},1);
    resting_4=S.XpYp.Data(S.XpYp.S_period{1},1);
    all_resting=[resting_1;resting_2;resting_3;resting_4];
    M=mean(all_resting);
    L=length(all_resting);
    thre_L=round(0.001*L);% Top 5% of the data will be included. Therefore we need to find the min_V at 5%
    [~,index]=sort(all_resting);% Sort the data from small to large
    min_V=all_resting(index(end-thre_L))-M;% min_V at 5%
end