function result=fitting_ellipse_manual(x,y)
% This function is used to fit the gain of different axis into an ellipse
% model, which comes from a paper of Dora Angelaki, 1993
% In the model, 
% c is the orientation of the Smax vector,
% a is the gain of the Smax vector, 
% b is the gain of the Smin vecotr.
% x, as an input, is the orientation of the vector for measurement
% y, as the output, is the gain of the input vector
testing_orien=(1:180)./180*pi;
Y_input=y.^2;
result=struct();
for i=1:length(testing_orien)
    X_input=cos(testing_orien(i)-x).^2;
    fo=fitoptions('Method','NonLinearLeastSquares',...
        'Lower',[0,0],...
        'Upper',[Inf,Inf],...
        'StartPoint',[0,0]);
    F=fittype('a.*x+b-b.*x','independent','x','options',fo);
    [result(i).fitobj,result(i).gof,result(i).op]=fit(X_input,Y_input,F);
end
end