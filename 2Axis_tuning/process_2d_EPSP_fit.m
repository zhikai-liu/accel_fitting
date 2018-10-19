function process_2d_EPSP_fit(filename)
    S=load(filename);
    resting_potential=mean_resting(S);
    min_V=threshold_potential;
    figure;
    subplot(1,4,1)
    X_vector=process_potential_cycle_fit(S.X.Data,S.X.S_period{1},S.X.fit_model{1},resting_potential,min_V);
    subplot(1,4,2)
    Y_vector=process_potential_cycle_fit(S.Y.Data,S.Y.S_period{1},S.Y.fit_model{1},resting_potential,min_V);
    subplot(1,4,3)
    XpYp_vector=process_potential_cycle_fit(S.XpYp.Data,S.XpYp.S_period{1},S.XpYp.fit_model{1},resting_potential,min_V);
    subplot(1,4,4)
    XpYn_vector=process_potential_cycle_fit(S.XpYn.Data,S.XpYn.S_period{1},S.XpYn.fit_model{1},resting_potential,min_V);
end

function M=mean_resting(S)
    resting_1=S.X.Data(S.X.S_period{1},1);
    resting_2=S.Y.Data(S.Y.S_period{1},1);
    resting_3=S.XpYp.Data(S.XpYp.S_period{1},1);
    resting_4=S.XpYp.Data(S.XpYp.S_period{1},1);
    M=mean([resting_1;resting_2;resting_3;resting_4]);
end