function [fitobj,gof,op]=fitting_ellipse(x,y)
% This function is used to fit the gain of different axis into an ellipse
% model, which comes from a paper of Dora Angelaki, 1993
F=fittype('sqrt(a.^2.*cos(c-x).^2+b.^2.*sin(c-x).^2)','independent','x');
[fitobj,gof,op]=fit(x,y,F,'StartPoint',[0,0,0]);
end