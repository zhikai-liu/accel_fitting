function sum_vector=process_potential_cycle_fit(Data,S_period,fit_model,resting_potential,min_V)
    S_period_phase=S_period.*fit_model.b1+fit_model.c1;
    V_length=Data(S_period,1)-resting_potential;
    index=V_length>min_V;
    A1_potential=V_length.*exp(1i.*S_period_phase');
    sum_vector=sum(A1_potential(index));
    %sum_vector=sum_vector./length(A1_potential(index));
    plot(real(A1_potential),imag(A1_potential))
    hold on;
    quiver(0,0,real(sum_vector),imag(sum_vector));
    hold off;
    Axis_lim=max(abs(A1_potential));
    xlim([-Axis_lim,Axis_lim])
    ylim([-Axis_lim,Axis_lim])
    axis square;
    title(num2str(abs(sum_vector)))
end
