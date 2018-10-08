function process_fista_redist(filename)
%% Redistribute event index and related event stats to individual files.
    S=load(filename);
    X1=[S.fista.X1;zeros(length(S.fista.template1)-1,1)];
    X1_re=reshape(X1,S.data_size);
    X2=[S.fista.X2;zeros(length(S.fista.template2)-1,1)];
    X2_re=reshape(X2,S.data_size);
    X1_max=zeros(length(X1),1);
    %% use X1_max index to track their original index in the matrix
    X1_max(S.fista.X1_max)=1:length(S.fista.X1_max);
    %% after reshape, each column contains event index for each file
    X1_max_re=reshape(X1_max,S.data_size);
    for i=1:length(S.range)
        fista=struct();
        fista.X1=X1_re(:,i);
        fista.X2=X2_re(:,i);
        fista.X1_max=find(X1_max_re(:,i));
        fista.X1_max_ori_index=X1_max_re(X1_max_re(:,i)~=0,i);
        fista.X1_prox=S.fista.X1_prox(fista.X1_max_ori_index,:);
        fista.X1_integral=S.fista.X1_integral(fista.X1_max_ori_index);
        fista.X1_clust=S.fista.X1_clust(fista.X1_max_ori_index);
        fista.clust_num=max(S.fista.X1_clust);
        fista.X1_std=S.fista.X1_std(fista.X1_max_ori_index);
        fista.amps=S.fista.amps(fista.X1_max_ori_index);
        fista.amp_index=S.fista.amp_index(fista.X1_max_ori_index);
        if isfield(S.fista,'X1_chemical')
            fista.X1_chemical=S.fista.X1_chemical(fista.X1_max_ori_index);
        end
        fista.tempate1=S.fista.template1;
        fista.tempate2=S.fista.template2;
        if isfield(S.fista,'opts')
        fista.opts=S.fista.opts;
        end
        save(S.f_mat(S.range(i)).name,'fista','-append');
    end
end