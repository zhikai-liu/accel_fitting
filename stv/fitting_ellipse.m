function [fitobj,gof,op]=fitting_ellipse(x,y)
% This function is used to fit the gain of different axis into an ellipse
% model, which comes from a paper of Dora Angelaki, 1993
% In the model, 
% c is the orientation of the Smax vector,
% a is the gain of the Smax vector, 
% b is the gain of the Smin vecotr.
% x, as an input, is the orientation of the vector for measurement
% y, as the output, is the gain of the input vector
fo=fitoptions('Method','NonLinearLeastSquares',...
    'Lower',[0,0,-pi],...
    'Upper',[Inf,Inf,pi],...
    'StartPoint',[0,0,0]);
F=fittype('sqrt(a.^2.*cos(c-x).^2+b.^2.*sin(c-x).^2)','independent','x','options',fo);
[fitobj,gof,op]=fit(x,y,F);
end