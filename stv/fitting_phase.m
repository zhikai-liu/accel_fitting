function [phi_,MSE,Rsquared,Rs_weighed]=fitting_phase(stv,direction,phase,Smin_leading)
% This funciton is used to fit the phase of different angles of tuning, a
% stv(spatio-temporal vector) model is needed, which is the result of
% fitting_ellipse. So see that function first before using this one, also
% see fit_2d_4axis for exmaple usage
        phase_diff=pi/2.*Smin_leading;
        %This is the equation to calculate phase accroding to Dora's paper
        fit_func=@(phi,direction) complex(stv.Smax.*cos(direction-stv.alpha).*cos(phi)+stv.Smin.*sin(direction-stv.alpha).*cos(phi+phase_diff),...
            stv.Smax.*cos(direction-stv.alpha).*sin(phi)+stv.Smin.*sin(direction-stv.alpha).*sin(phi+phase_diff));
        %Test range is -180 to 180 degree, resolution is 1 degree
        test_range=linspace(-pi,pi,361)';
        %Er is used to track the squared error for each phase at a specific
        %direction
        Er=zeros(length(test_range),length(direction));
        %% For each direction, calculate the error between measured and predicted phase
        for i=1:length(direction)
            fit_angle=fit_func(test_range,direction(i));
            %When no  weight is used for Er calculation, errors on
            %different axis are equally weighted.
            %But usually measurement for phase on high-gain axis is more
            %accurate/reliable, therefore it could be better to weight the
            %errors with gain, so that low-gain axis(whose phase is prone
            %to error) will affect less for the fitting
%             %% Equally weighted
%             Er(:,i)=abs(fit_angle./abs(fit_angle)-exp(1i.*phase(i))).^2;
            %% Weighted by gain
            Er(:,i)=abs(fit_angle-abs(fit_angle).*exp(1i.*phase(i))).^2;
        end
        total_er=sum(Er,2);
        [MSE,index]=min(total_er);
        phi_=test_range(index);
        fit_complex=fit_func(phi_,direction);
        predict_phase=angle(fit_complex);
        predict_gain=abs(fit_complex);
        MSE=MSE./sum(predict_gain.^2);
        %% Calculate R squared with complex value weighted by gain
        SS_y=predict_gain.*exp(1i.*phase);
        SS_T=sum(abs(SS_y-mean(SS_y)).^2);
        SS_R=sum(abs(fit_complex-SS_y).^2);
        Rs_weighed=1-SS_R/SS_T;
        %% Calculate R squared with just angle, equally weighted
        SS_y=exp(1i.*phase);
        fit_complex=exp(1i.*predict_phase);
        SS_res=sum(abs(SS_y-mean(SS_y)).^2);
        SS_total=sum(abs(fit_complex-SS_y).^2);
        Rsquared=1-SS_res/SS_total;
end
