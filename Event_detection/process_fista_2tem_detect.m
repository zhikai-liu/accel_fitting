function process_fista_2tem_detect(filename_h)
f_mat = dir([filename_h '*.mat']);
load('EPSC_templates.mat');
for i =1:length(f_mat)
    %% Initiation
    fista=struct();
    S = load(f_mat(i).name);
    signal=smooth(S.Data(:,1)-median(S.Data(:,1)));
    EPSC_w1=fast_EPSC(1:441)';
    EPSC_w2=slow_EPSC';
    fista.template1=EPSC_w1;
    alpha=EPSC_w1'*EPSC_w1/(EPSC_w1'*EPSC_w2);
    fista.template2=EPSC_w1-alpha.*EPSC_w2;
    opts.backtracking=true;
    opts.verbose=true;
    opts.lambda1=rms(signal).*max(abs(fista.template1)).*norminv(0.99);
    opts.lambda2=rms(signal).*max(abs(fista.template2)).*norminv(0.99);
    opts.pos=false;
    Xinit=[];
    %% Main fista algorithm
    if parallel.gpu.GPUDevice.isAvailable
        [fista.X1,fista.X2,fista.cost_iter] = fista_lasso_backtracking_2tems(gpuArray(signal),...
            gpuArray(fista.template1),gpuArray(fista.template2), gpuArray(Xinit),gpuArray(Xinit), opts);
    else
        [fista.X1,fista.X2,fista.cost_iter] = fista_lasso_backtracking_2tems(signal, fista.template1,fista.template2, Xinit,Xinit, opts);
    end
    [fista.X1_max,fista.recon_integral,fista.chemical]=fista_local_maxima(signal,fista.X1,fista.X2,fista.template1,fista.template2);
    fista_autocorrelogram(fista.X1_max,fista.recon_integral,fista.chemical)
    save(f_mat(i).name,'fista','-append');
end
end