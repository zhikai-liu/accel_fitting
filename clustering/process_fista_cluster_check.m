function process_fista_cluster_check(filename)
S=load(filename);
s_data=smooth(S.data_pad);
map=colormap(jet(S.fista.clust_num));
figure;
for i=1:S.fista.clust_num
subplot(1,S.fista.clust_num,i)
event_index=S.fista.X1_max;
clust_index=event_index(S.fista.X1_clust==i);
%clust_amp=S.fista.X1_integral(S.fista.X1_clust==i);
clust_amp=S.fista.amps(S.fista.X1_clust==i);
diff_index=diff(clust_index);
scatter(diff_index*20*1e-3,clust_amp(2:end)./clust_amp(1:end-1),9,'MarkerFaceColor',map(i,:),'MarkerEdgeColor','k');
xlim([0 10])
ylim([0 3])
end
figure;
for i=1:S.fista.clust_num
subplot(1,S.fista.clust_num,i)
event_index=S.fista.X1_max;
clust_index=event_index(S.fista.X1_clust==i);
%clust_amp=S.fista.X1_integral(S.fista.X1_clust==i);
diff_index=diff(clust_index)*20*1e-3;
violaters=clust_index([diff_index<1;0<0]);

hold on
for j=1:length(violaters)
    plot((1:100)*20*1e-3,s_data(violaters(j):violaters(j)+99)-s_data(violaters(j)),'k')
end
hold off
end