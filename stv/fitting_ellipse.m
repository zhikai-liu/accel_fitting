function [fitobj,gof,op]=fitting_ellipse(x,y)
F=fittype('sqrt(a.^2.*cos(c-x).^2+b.^2.*sin(c-x).^2)','independent','x');
[fitobj,gof,op]=fit(x,y,F,'StartPoint',[0,0,0]);
end