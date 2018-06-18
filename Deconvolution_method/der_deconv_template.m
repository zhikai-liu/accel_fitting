function der_deconv_template(signal,template)
% This is a similar script to demo_deconv, the difference is that here we
% use the derivative of signal and template to perform deconvolution.
% In theory, the result should be similar to not using derivative. But
% based on some tests for multi-template analysis. The derivative templates
% (3 PCA components) often has only one component that represents the best 
% shape of EPSC, and the other two look more like noise. So it is possible that
% single derivative template might give better performance.

s_data=diff(signal);
model_T=diff(template);
results=deconv_iterative(s_data,model_T);
count=length(results);
end