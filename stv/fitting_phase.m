function [phi_,MSE]=fitting_phase(stv,direction,phase)
% This funciton is used to fit the phase of different angles of tuning, a
% stv(spatio-temporal vector) model is needed, which is the result of
% fitting_ellipse. So see that function first before using this one, also
% see fit_2d_4axis for exmaple usage
        phase_diff=pi/2.;
        %This is the equation to calculate phase accroding to Dora's paper
        fit_func=@(phi,direction) complex(stv.Smax.*cos(direction-stv.alpha).*cos(phi)+stv.Smin.*sin(direction-stv.alpha).*cos(phi+phase_diff),...
            stv.Smax.*cos(direction-stv.alpha).*sin(phi)+stv.Smin.*sin(direction-stv.alpha).*sin(phi+phase_diff));
        %Test range is -180 to 180 degree, resolution is 1 degree
        test_range=linspace(-pi,pi,361)';
        %Er is used to track the squared error for each phase at a specific
        %direction
        Er=zeros(length(test_range),length(direction));
        for i=1:length(direction)
            fit_angle=fit_func(test_range,direction(i));
            %When no  weight is used for Er calculation, errors on
            %different axis are equally weighted.
            %But usually measurement for phases on high-gain axis is more
            %accurate, another way is to weight them based on gain
%             %% Equally weighted
%             Er(:,i)=abs(fit_angle./abs(fit_angle)-exp(1i.*phase(i))).^2;
            %% Gain weighted
            Er(:,i)=abs(fit_angle-abs(fit_angle).*exp(1i.*phase(i))).^2;
        end
        total_er=sum(Er,2);
        [MSE,index]=min(total_er);
        phi_=test_range(index);
end
