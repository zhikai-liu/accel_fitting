function [X,All_vectors]=process_2d_spikes_fit(filename,if_plot)
    S=load(filename);
    Fnames={'X','Y','XpYp','XpYn'};
    All_vectors=zeros(1,4);
    for i=1:4
    All_vectors(i)=events_fit2tuning(S.(Fnames{i}).der.event_index,S.(Fnames{i}).fit_model{1});
    end
    %print([filename '_polar_cycle'],'-r300','-djpeg')
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
    %% Plot fitting results
    if if_plot
        figure('Units','Normal','Position',[0,0,0.6,1]);
        plot_ellipse(X,All_vectors)
        Ax_lim=max([abs(All_vectors),X.Smax]);
        
        xlim([-Ax_lim Ax_lim])
        ylim([-Ax_lim Ax_lim])
        axis square
        title({filename,['gof: ', num2str(X.gain_gof.rsquare)],['Sratio: ', num2str(X.Smin/X.Smax)]},'FontSize',24,'interpreter','none')
        print([filename '_spikes_fit_model'],'-r300','-djpeg')
    end
end