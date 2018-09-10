function process_fista_IDmixed(filename,clust_num)
    S=load(filename);
    fista=S.fista;
    X1_max_diff=diff(S.fista.X1_max);
    X1_within1ms=X1_max_diff<2000/S.si;
    mixed_EPSC=logical(sum(S.fista.X1_clust==clust_num(:),2));
    fista.X1_chemical=[0;X1_within1ms&mixed_EPSC(1:end-1)];
    save(filename,'fista','-append')
end