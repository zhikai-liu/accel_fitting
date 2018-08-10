function process_fista_redist(filename)
    S=load(filename);
    X1=[S.fista.X1;zeros(length(S.fista.template1)-1,1)];
    X1_re=reshape(X1,S.data_size);
    X2=[S.fista.X2;zeros(length(S.fista.template2)-1,1)];
    X2_re=reshape(X2,S.data_size);
    X1_max=zeros(length(X1),1);
    X1_max(S.fista.X1_max)=1:length(S.fista.X1_max);
    X1_max_re=reshape(X1_max,S.data_size);
    for i=S.range
        fista=struct();
        fista.X1=X1_re(:,i);
        fista.X2=X2_re(:,i);
        fista.X1_max=find(X1_max_re(:,i));
        fista.X1_max_ori_index=X1_max_re(X1_max_re(:,i)~=0,i);
        fista.X1_prox=S.fista.X1_prox(fista.X1_max_ori_index,:);
        fista.X1_integral=S.fista.X1_integral(fista.X1_max_ori_index);
        fista.X1_clust=S.fista.X1_clust(fista.X1_max_ori_index);
        fista.tempate1=S.fista.template1;
        fista.tempate2=S.fista.template2;
        fista.opts=S.fista.opts;
        save(S.f_mat(i).name,'fista','-append');
    end
end