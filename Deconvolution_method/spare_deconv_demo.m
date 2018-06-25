%% Sparse deconvolution
%load signal
load('all_traces_padded.mat');
data=data_pad';
%load the template
load('EPSC_templates.mat');
model_T=fast_EPSC';
% smooth signal
s_data=smooth(data-mean(data));
% main function for deconvolving
[deconv_s,cost]=sparse_deconv(data,kernel,lam,nit);
%Plot results
figure;
plot(deconv_s);
figure;
plot(cost)


function [deconv_s,cost]=sparse_deconv(data,kernel,lam,nit);
    cost=zeros(1,nit);
    
end