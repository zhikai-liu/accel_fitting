function [fitobj,gof,op]=fitting_phase(stv,direction,phase)
% This funciton is used to fit the phase of different angles of tuning, a
% stv(spatio-temporal vector) model is needed, which is the result of
% fitting_ellipse. So see that function first before using this one, also
% see fit_2d_4axis for exmaple usage
    if ~isempty(stv.Smin_leading)
        phase_diff=pi/2.*stv.Smin_leading;
        fit_func=@(phi,direction) angle(complex(stv.Smax.*cos(direction-stv.alpha).*cos(phi)+stv.Smin.*sin(direction-stv.alpha).*cos(phi+phase_diff),...
            stv.Smax.*cos(direction-stv.alpha).*sin(phi)+stv.Smin.*sin(direction-stv.alpha).*sin(phi+phase_diff)));
        F=fittype(fit_func,'independent','direction');
        [fitobj,gof,op]=fit(direction,phase,F,'StartPoint',0);
    else
        for i=[-1,1]
            phase_diff=pi/2.*i;
            fit_func=@(phi,direction) angle(complex(stv.Smax.*cos(direction-stv.alpha).*cos(phi)+stv.Smin.*sin(direction-stv.alpha).*cos(phi+phase_diff),...
            stv.Smax.*cos(direction-stv.alpha).*sin(phi)+stv.Smin.*sin(direction-stv.alpha).*sin(phi+phase_diff)));
            F=fittype(fit_func,'independent','direction');
            [fitobj(i),gof(i),op(i)]=fit(direction,phase,F,'StartPoint',0);
        end
    end
end
