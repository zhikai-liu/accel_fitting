function process_fista_lasso(filename)
S=load(filename);
T=load('EPSC_templates.mat');
Y=smooth(S.data_pad'-median(S.data_pad));
% l=6e4:12e4;
l=1:length(Y);
%l=6.48e6:6.6e6;
signal=Y(l,1);
fista=struct();
EPSC_w1=T.fast_EPSC(1:441)';
EPSC_w2=T.slow_EPSC';
fista.template1=EPSC_w1;
%template2=fast_EPSC(1:length(slow_EPSC))'-slow_EPSC';
alpha=EPSC_w1'*EPSC_w1/(EPSC_w1'*EPSC_w2);
fista.template2=EPSC_w1-alpha.*EPSC_w2;
opts.backtracking=true;
opts.verbose=true;
opts.lambda1=rms(signal).*norm(fista.template1);
opts.lambda2=rms(signal).*norm(fista.template2);
opts.pos=false;
Xinit=[];
%[~,Xinit]=signal_deconv(Y(1:length(Y)/100,1), template,5e4,50,2000);
%X = fista_lasso_backtracking_template(Y(l,1), template, Xinit, opts);
if parallel.gpu.GPUDevice.isAvailable
    [X1_gpu,X2_gpu,cost_iter_gpu] = fista_lasso_backtracking_2tems(gpuArray(signal),...
        gpuArray(fista.template1),gpuArray(fista.template2), gpuArray(Xinit),gpuArray(Xinit), opts);
    fista.X1=gather(X1_gpu);
    fista.X2=gather(X2_gpu);
    fista.cost_iter=gather(cost_iter_gpu);
else
[fista.X1,fista.X2,fista.cost_iter] = fista_lasso_backtracking_2tems(Y(l,1), fista.template1,fista.template2, Xinit,Xinit, opts);
end
fista.X1_max=get_local_maxima_above_threshold(fista.X1,3.5*std(fista.X1),1,10);
fista.opts=opts;
save(filename,'fista','-append');
%% The lasso problem is: argmin( 1/2(Y-A*x1-B*x2)^2+lambda1*|x1|+lambda2*|x2|)
end
