%% Example analysis for ZL171220_fish01a
f_name_nodrug={'08','09','10','11'};
f_name_NBQX={'20','21','22','23'};
concate_wave_nodrug=[0];
for i=1:length(f_name_nodrug)
    [w,si,~]=abfload(['ZL171220_fish01a_00' f_name_nodrug{i} '.abf']);
    pad=linspace(concate_wave_nodrug(end),w(1,1),100);
    concate_wave_nodrug=[concate_wave_nodrug;w(:,1)];
end

concate_wave_NBQX=[0];
for i=1:length(f_name_NBQX)
    [w,si,~]=abfload(['ZL171220_fish01a_00' f_name_NBQX{i} '.abf']);
    pad=linspace(concate_wave_NBQX(end),w(1,1),100);
    concate_wave_NBQX=[concate_wave_NBQX;w(:,1)];
end
clust_num=1;
[EPSC_trials_nodrug_s,EPSC_trials_nodrug_f,aligned_EPSC_nodrug]=stim_detector(concate_wave_nodrug,si,'g');
[EPSC_trials_NBQX_s,EPSC_trials_NBQX_f,aligned_EPSC_NBQX]=stim_detector(concate_wave_NBQX,si,'r');

% figure('Unit','Normal','position',[0 0 1 1]);
 x_data=(1:size(EPSC_trials_nodrug_s,2)).*si.*1e-3-10;
% % for i=1:size(EPSC_trials_nodrug,1)
% %     plot(x_data,EPSC_trials_nodrug(i,:),'g--')
% % end
% EPSC_trials_aver_nodrug=mean(EPSC_trials_nodrug_s,1);
% A1=subplot(2,1,1);
% hold on;
% for i=1:size(EPSC_trials_nodrug_s,1)
%     plot(x_data,EPSC_trials_nodrug_s(i,:),'color',[0.3,0.3,0.3])
% end
% for i=1:size(EPSC_trials_nodrug_f,1)
%     plot(x_data,EPSC_trials_nodrug_f(i,:),'color','b')
% end
% 
% plot(x_data,EPSC_trials_aver_nodrug,'g','LineWidth',4)
% nodrug_EPSC_peak=min(EPSC_trials_aver_nodrug);
% hold off
% ylim([-200,25])
% xlim([-1,6])
% EPSC_trials_aver_NBQX=mean(EPSC_trials_NBQX_s,1);
% NBQX_EPSC_peak=min(EPSC_trials_aver_NBQX);
% set(A1.XAxis,'Visible','off')
% set(A1,'fontsize',20,'fontweight','bold')
% legend({'pre-NBQX'},'TextColor','g')
% A2=subplot(2,1,2);
% hold on;
% for i=1:size(EPSC_trials_NBQX_s,1)
%     plot(x_data,EPSC_trials_NBQX_s(i,:),'color',[0.3,0.3,0.3])
% end
% for i=1:size(EPSC_trials_NBQX_f,1)
%     plot(x_data,EPSC_trials_NBQX_f(i,:),'color','b')
% end
% plot(x_data,EPSC_trials_aver_NBQX,'r','LineWidth',4)
% hold off;
% ylim([-200,25])
% xlim([-1,6])
% xlabel('ms')
% ylabel('pA')
% legend({'post-NBQX'},'TextColor','r')
% set(A2,'fontsize',20,'fontweight','bold')
% samexaxis('abc','xmt','on','ytac','join','yld',1,'box','off');

%% Cluster all events with PCA and kmeans
clust_num=2;
mean_clust=cell(2,1);
for j=1:2
    if j==1
        clust_ori=aligned_EPSC_nodrug;
    elseif j==2
        clust_ori=aligned_EPSC_NBQX;
    end
    mean_clust{j}=zeros(clust_num,size(aligned_EPSC_nodrug,2));
[coeff,score,latent] = pca(clust_ori(:,525:600));
clust_index = kmeans(clust_ori(:,525:600),clust_num);
color_map=colormap(jet(clust_num));
figure;
hold on;
for i = 1:length(score)
    scatter3(score(i,1),score(i,2),score(i,3),'MarkerEdgeColor',color_map(clust_index(i),:));
end
hold off;
figure
hold on;
for i=1:size(clust_ori,1)
    plot(x_data,clust_ori(i,:),'color',color_map(clust_index(i),:))
end
hold off;
figure;
clust=cell(clust_num,1);
for k=1:clust_num
    h.a(k)=subplot(clust_num,1,k);
    clust{k}=clust_ori(clust_index==k,:);
    hold on;
    for i=1:size(clust{k},1)
    plot(x_data,clust{k}(i,:),'color',[0.3 0.3 0.3])
    end
    mean_clust{j}(k,:)=mean(clust{k},1);
    plot(x_data,mean_clust{j}(k,:),'color',color_map(k,:),'LineWidth',4)
    hold off;
    set(h.a(k),'fontsize',20,'fontweight','bold')
end
xlabel('ms')
ylabel('pA')
samexaxis('abc','xmt','on','ytac','join','yld',1,'box','off');
xlim([0 4])

end


aligned_EPSC_nodrug_aver=mean(aligned_EPSC_nodrug,1);
nodrug_EPSC_peak=min(aligned_EPSC_nodrug_aver);
aligned_EPSC_NBQX_aver=mean(aligned_EPSC_NBQX,1);
NBQX_EPSC_peak=min(aligned_EPSC_NBQX_aver);
aver_delay=finddelay(aligned_EPSC_nodrug_aver,aligned_EPSC_NBQX_aver)*si*1e-3;
peak_ratio=abs(nodrug_EPSC_peak/NBQX_EPSC_peak);
diff_EPSC=aligned_EPSC_nodrug_aver(4:end)-aligned_EPSC_NBQX_aver(1:end-3).*peak_ratio;
% 
% figure;
% hold on;
% plot(x_data,aligned_EPSC_nodrug_aver,'g','LineWidth',4,'DisplayName','Pre-NBQX')
% plot(x_data-aver_delay,aligned_EPSC_NBQX_aver.*peak_ratio,'r','LineWidth',4,'DisplayName','Scaled post-NBQX')
% plot(x_data(1:end-3),diff_EPSC,'k','LineWidth',4,'DisplayName','Reduced components by NBQX');
% xlabel('ms')
% ylabel('pA')
% xlim([-1 9])
% legend('show')
% A=gca;
% set(A,'fontsize',20,'fontweight','bold')


LineStyle={'--','-'};
delay=[0,aver_delay];
%peak_ratio=0.8;
ratio=[1,peak_ratio];
figure;
hold on
for j=1:2
    for i=1:clust_num
        plot(x_data-delay(j),mean_clust{j}(i,:).*ratio(j),'color',color_map(i,:),'LineWidth',4,'LineStyle',LineStyle{j})
    end
xlabel('ms')
ylabel('pA')
A=gca;
set(A,'fontsize',20,'fontweight','bold')
end
hold off
xlim([0 4])






function failure_index=find_failures(trials,threshold)
    failure_index=zeros(size(trials,1),1);
    figure;
    hold on;
    for i=1:size(trials,1)
        if trials(i,:)>threshold
            failure_index(i)=1;
            plot(trials(i,:))
        end
    end
    hold off;
end