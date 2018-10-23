function [min_result,orien]=fitting_ellipse_manual(x,y)
% This function is used to fit the gain of different axis into an ellipse
% model, which comes from a paper of Dora Angelaki, 1993
% In the model, 
% c is the orientation of the Smax vector,
% a is the gain of the Smax vector, 
% b is the gain of the Smin vecotr.
% x, as an input, is the orientation of the vector for measurement
% y, as the output, is the gain of the input vector
% The equation goes like this: y^2=a^2*cos(c-x)^2+b^2*sin(c-x)^2
% Notice that cos(c-x)^2+sin(c-x)^2=1, the equation can be simplified as:
% Y=A*X+B*(1-X)
testing_orien=(1:90)./180*pi;
Y_input=y;
results=struct();
errors=zeros(length(testing_orien),1);

fo=fitoptions('Method','NonLinearLeastSquares',...
    'Lower',[0,0],...
    'Upper',[Inf,Inf],...
    'StartPoint',[0,0]);
F=fittype('sqrt(p1.*x+p2)','independent','x','options',fo);

for i=1:length(testing_orien)
    X_input=cos(testing_orien(i)-x).^2;
    %% Fitting (a-b)*x+b, which is a*x+(1-x)*b
    [results(i).fitobj,results(i).gof,results(i).op]=fit(X_input,Y_input,F);
    errors(i)=results(i).gof.sse;
end
[~,index]=min(errors);
min_result=results(index);
orien=testing_orien(index);
end