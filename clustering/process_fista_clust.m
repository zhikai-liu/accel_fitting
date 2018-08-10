function process_fista_clust(filename)
% Cluster the events with isosplit5 algorithm, also make sure the labels 
% will follow them after events are separated into different files.
    S=load(filename);
    fista=S.fista;
    fista.X1_max=fista.X1_max(fista.X1_max>5&fista.X1_max<(length(fista.X1)-5));
    fista.X1_prox=zeros(length(fista.X1_max),11);
    fista.X1_integral=zeros(length(fista.X1_max),1);
    for i=1:length(fista.X1_max)
        fista.X1_prox(i,:)=fista.X1(fista.X1_max(i)-5:fista.X1_max(i)+5)';
        fista.X1_integral(i)=sum(fista.X1(fista.X1_max(i)-5:fista.X1_max(i)+5));
    end
    fista.X1_clust=isosplit5(fista.X1_prox')';
    save(filename,'fista','-append')
end