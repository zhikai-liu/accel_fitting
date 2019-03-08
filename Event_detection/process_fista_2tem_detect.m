function process_fista_2tem_detect(filename_h)
f_mat = dir(filename_h);
load('EPSC_templates.mat');
for i =1:length(f_mat)
    %% Initiation
    fista=struct();
    S = load(f_mat(i).name);
    signal=smooth(S.data_pad-median(S.data_pad));
    EPSC_w1=fast_EPSC(1:441)';
    EPSC_w2=slow_EPSC';
    fista.template1=EPSC_w1;
    % template1 is the fast EPSC wave form, template2 is the part of slow
    % EPSC that is orthogonal to template1, orthogonal components sometimes
    % can be separated better (like PCA)
    alpha=EPSC_w1'*EPSC_w1/(EPSC_w1'*EPSC_w2);
    fista.template2=EPSC_w2;
    opts.backtracking=true;
    opts.verbose=true;
    % Sparsity is defined by the rms of signal and template max amplitude
    opts.lambda1=rms(signal).*max(abs(fista.template1)).*norminv(0.99);
    opts.lambda2=rms(signal).*max(abs(fista.template2)).*norminv(0.99);
    opts.pos=true;
    Xinit=[];
    %% Main fista algorithm
    if parallel.gpu.GPUDevice.isAvailable
        GpuD=gpuDevice();
        [X1_gpu,X2_gpu,cost_iter_gpu] = fista_lasso_backtracking_2tems(gpuArray(signal),...
            gpuArray(fista.template1),gpuArray(fista.template2), gpuArray(Xinit),gpuArray(Xinit), opts);
        fista.X1=gather(X1_gpu);
        fista.X2=gather(X2_gpu);
        fista.cost_iter=gather(cost_iter_gpu);
        reset(GpuD);
    else
        [fista.X1,fista.X2,fista.cost_iter] = fista_lasso_backtracking_2tems(signal, fista.template1,fista.template2, Xinit,Xinit, opts);
    end
    [fista.X1_max,fista.recon_integral,fista.chemical]=fista_local_maxima(signal,fista.X1,fista.X2,fista.template1,fista.template2,0);
    fista.opts=opts;
    fista.X12_ratio=sum(abs(fista.X1))./sum(abs(fista.X2));
    save(f_mat(i).name,'fista','-append');
    %fista_autocorrelogram(fista.X1_max,fista.recon_integral,fista.chemical)
end
end