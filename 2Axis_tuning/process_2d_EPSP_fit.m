function [X,All_vectors]=process_2d_EPSP_fit(filename)
    S=load(filename);
    [min_V,resting_potential]=mean_resting(S);
    figure;
    subplot(1,4,1)
    X_vector=process_potential_cycle_fit(S.X.Data,S.X.S_period{1},S.X.fit_model{1},resting_potential,min_V);
    subplot(1,4,2)
    Y_vector=process_potential_cycle_fit(S.Y.Data,S.Y.S_period{1},S.Y.fit_model{1},resting_potential,min_V);
    subplot(1,4,3)
    XpYp_vector=process_potential_cycle_fit(S.XpYp.Data,S.XpYp.S_period{1},S.XpYp.fit_model{1},resting_potential,min_V);
    subplot(1,4,4)
    XpYn_vector=process_potential_cycle_fit(S.XpYn.Data,S.XpYn.S_period{1},S.XpYn.fit_model{1},resting_potential,min_V);
    All_vectors=[X_vector,Y_vector,XpYp_vector,XpYn_vector];
    orientations=[0,pi/2,pi/4,3*pi/4];
    [fitobj,~,~]=fitting_ellipse(orientations',abs(All_vectors)');
    %Sratio=fitobj.b./fitobj.a;
    X=STV;
    X.alpha=fitobj.c;
    X.Smax=fitobj.a;
    X.Smin=fitobj.b;
end

function [min_V,M]=mean_resting(S)
    resting_1=S.X.Data(S.X.S_period{1},1);
    resting_2=S.Y.Data(S.Y.S_period{1},1);
    resting_3=S.XpYp.Data(S.XpYp.S_period{1},1);
    resting_4=S.XpYp.Data(S.XpYp.S_period{1},1);
    all_resting=[resting_1;resting_2;resting_3;resting_4];
    M=mean(all_resting);
    L=length(all_resting);
    thre_L=round(0.01*L);% Top 5% of the data will be included. Therefore we need to find the min_V at 5%
    [~,index]=sort(all_resting);% Sort the data from small to large
    min_V=all_resting(index(end-thre_L))-M;% min_V at 5%
end