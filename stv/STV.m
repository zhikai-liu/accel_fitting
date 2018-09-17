classdef STV
    properties
        alpha
        Smax
        Smin
        phi
        Smin_leading
    end
    methods
        function plot_ellipse(stv)
            range=0:360;
            theta=range./180.*pi;
            S=cal_STV_gain(stv,theta);
            plot(S.*cos(theta),S.*sin(theta))
%             hold on;
%             S_=cal_STV_circle(stv,theta);
%             plot(S_.*cos(theta),S_.*sin(theta))
            
        end
        % Plot the ellipse shape based on Smax and Smin,theta determines
        % the rotation angle, phi is not involved
        function S=cal_STV_circle(stv,theta)
            R=(stv.Smax.^2+stv.Smin.^2)./2./stv.Smax;
            theta_=theta-stv.alpha;
            S=sqrt(R.^2-((stv.Smax-R).*sin(theta_)).^2)+(stv.Smax-R).*cos(theta_);
        end
        % Calculate the gain for a specific axis
        function S=cal_STV_gain(stv,theta)
            theta_=theta-stv.alpha;
            S=sqrt(stv.Smax.^2.*cos(theta_).^2+stv.Smin.^2.*sin(theta_).^2);
        end
        % Calculate the phase for a specific axis
        function phi=cal_STV_phase(stv,theta)
            phase_diff=+pi/2;
            theta_=theta-stv.alpha;
            exp_phi=complex(stv.Smax.*cos(theta_).*cos(stv.phi)+stv.Smin.*sin(theta_).*cos(stv.phi+phase_diff),...
                stv.Smax.*cos(theta_).*sin(stv.phi)+stv.Smin.*sin(theta_).*sin(stv.phi+phase_diff));
            phi=angle(exp_phi);
        end
        % Plot a 3d representation of the ellipse with phase info, phase is
        % represented on the Z axis
        function plot_ellipse_phase_3d(stv)
            range=0:360;
            theta=range'./180.*pi;
            S=cal_STV_gain(stv,theta);
            S_phi=cal_STV_phase(stv,theta);
            stv_3d=[S.*cos(S_phi).*cos(theta),S.*cos(S_phi).*sin(theta),S.*sin(S_phi)];
            figure;
            plot3(stv_3d(:,1),stv_3d(:,2),stv_3d(:,3))
            hold on;
            for i=1:5:length(range)
            quiver3(0,0,0,stv_3d(i,1),stv_3d(i,2),stv_3d(i,3))
            end
            hold off;
        end
        % Plot a 2d representation of the ellipse with phase info, phase is
        % represented by the red arrow
        function plot_ellipse_phase_2d(stv)
            range=0:360;
            theta=range'./180.*pi;
            S=cal_STV_gain(stv,theta);
            S_phi=cal_STV_phase(stv,theta);
            direction_sign=sign(cos(S_phi));
            sin_sign=sign(sin(S_phi));
            X=S.*cos(theta);Y=S.*sin(theta);
            plot(X,Y,'k')
            hold on;
            plot(X.*sin(S_phi),Y.*sin(S_phi),'r')
            for i=1:5:length(range)
                plot([0,sin_sign(i).*X(i)],[0,sin_sign(i).*Y(i)],'k')
                quiver(X(i).*sin(S_phi(i)),Y(i).*sin(S_phi(i)),direction_sign(i).*X(i).*0.25,direction_sign(i).*Y(i).*0.25,'r')
            end
            hold off;
        end
    end
end