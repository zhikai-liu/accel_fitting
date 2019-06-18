function process_fista_clust(filename)
% Cluster the events with isosplit5 algorithm, also make sure the labels 
% will follow them after events are separated into different files.
    S=load(filename);
    fista=S.fista;
    data_s=smooth(S.data_pad);
    fista.X1_max=fista.X1_max(fista.X1_max>5&fista.X1_max<(length(fista.X1)-5));
    fista.X1_prox=zeros(length(fista.X1_max),11);
    %fista.X1_neighbor=zeros(length(fista.X1_max),56);
    fista.X1_waveform=zeros(length(fista.X1_max),71);
    fista.X1_integral=zeros(length(fista.X1_max),1);
    fista.X1_std=zeros(length(fista.X1_max),1);
    fista.X12_ratio=sum(abs(fista.X1))./sum(abs(fista.X2));
    for i=1:length(fista.X1_max)
        fista.X1_prox(i,:)=fista.X1(fista.X1_max(i)-5:fista.X1_max(i)+5)';
        fista.X1_waveform(i,:)=data_s(fista.X1_max(i):fista.X1_max(i)+70)'-data_s(fista.X1_max(i));
        fista.X1_integral(i)=sum(fista.X1(fista.X1_max(i)-5:fista.X1_max(i)+5));
        fista.X1_std(i)=std(fista.X1(fista.X1_max(i)-5:fista.X1_max(i)+5)); 
        %fista.X1_neighbor(i,:)=fista.X1(fista.X1_max(i)-5:fista.X1_max(i)+50)';
    end
    opts.isocut_threshold=0.7;% setting threshold for clustering, see isosplit5 for specifics
    %fista.X1_clust=isosplit5(fista.X1_prox',opts)';
    fista.X1_clust=isosplit5([fista.X1_integral';fista.X1_std';fista.amps'],opts);
    %fista.X1_clust=isosplit5(fista.X1_neighbor',opts)';
    %fista.X1_clust=isosplit5(fista.X1_waveform',opts)';
    %fista.X1_clust=isosplit5([fista.X1_integral]',opts)';
    save(filename,'fista','-append')
end