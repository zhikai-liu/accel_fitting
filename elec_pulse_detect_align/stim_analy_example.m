%% Example analysis for ZL171220_fish01a
f_name_nodrug={'08','09','10','11'};
f_name_NBQX={'20','21','22','23'};
f_header='ZL171220_fish01a_00';
concate_wave_nodrug=[0];
for i=1:length(f_name_nodrug)
    [w,si,~]=abfload([f_header f_name_nodrug{i} '.abf']);
    pad=linspace(concate_wave_nodrug(end),w(1,1),100);
    concate_wave_nodrug=[concate_wave_nodrug;w(25e3:end,1)];
end

concate_wave_NBQX=[0];
for i=1:length(f_name_NBQX)
    [w,si,~]=abfload([f_header f_name_NBQX{i} '.abf']);
    pad=linspace(concate_wave_NBQX(end),w(1,1),100);
    concate_wave_NBQX=[concate_wave_NBQX;w(25e3:end,1)];
end
[EPSC_trials_nodrug_s,EPSC_trials_nodrug_f,aligned_EPSC_nodrug]=stim_detector(concate_wave_nodrug,si,'g');
[EPSC_trials_NBQX_s,EPSC_trials_NBQX_f,aligned_EPSC_NBQX]=stim_detector(concate_wave_NBQX,si,'r');

F1=figure('Unit','Normal','position',[0.2 0.2 0.4 0.6]);
 x_data=(1:size(EPSC_trials_nodrug_s,2)).*si.*1e-3-10;
% for i=1:size(EPSC_trials_nodrug,1)
%     plot(x_data,EPSC_trials_nodrug(i,:),'g--')
% end
EPSC_trials_aver_nodrug=mean(EPSC_trials_nodrug_s,1);
nodrug_EPSC_peak=min(EPSC_trials_aver_nodrug);
EPSC_trials_aver_NBQX=mean(EPSC_trials_NBQX_s,1);
NBQX_EPSC_peak=min(EPSC_trials_aver_NBQX);
A1=subplot(2,1,1);
hold on;
for i=1:size(EPSC_trials_nodrug_s,1)
    plot(x_data,EPSC_trials_nodrug_s(i,:),'color',[0.3,0.3,0.3])
end
for i=1:size(EPSC_trials_nodrug_f,1)
    plot(x_data,EPSC_trials_nodrug_f(i,:),'color','b')
end

plot(x_data,EPSC_trials_aver_nodrug,'g','LineWidth',4)
hold off
% ylim([-150,25])
% xlim([-1,6])
set(A1.XAxis,'Visible','off')
set(A1,'fontsize',20,'fontweight','bold')
legend({'pre-NBQX'},'TextColor','g')
A2=subplot(2,1,2);
hold on;
for i=1:size(EPSC_trials_NBQX_s,1)
    plot(x_data,EPSC_trials_NBQX_s(i,:),'color',[0.3,0.3,0.3])
end
for i=1:size(EPSC_trials_NBQX_f,1)
    plot(x_data,EPSC_trials_NBQX_f(i,:),'color','b')
end
plot(x_data,EPSC_trials_aver_NBQX,'r','LineWidth',4)
hold off;
% ylim([-150,25])
% xlim([-1,6])
xlabel('ms')
ylabel('pA')
legend({'post-NBQX'},'TextColor','r')
set(A2,'fontsize',20,'fontweight','bold')
samexaxis('abc','xmt','on','ytac','join','yld',1,'box','off');
xlim([-1 9])
title(f_header(1:end-3),'interpreter','none')
print([f_header(1:end-3) '_all_traces.jpg'],'-r300','-djpeg');
%% Cluster all events with PCA and kmeans
mean_clust=cell(2,1);
for j=1:2
    if j==1
        clust_ori=aligned_EPSC_nodrug;
        %clust_ori=EPSC_trials_nodrug_s;
    elseif j==2
        clust_ori=aligned_EPSC_NBQX;
        %clust_ori=EPSC_trials_NBQX_s;
    end    
[coeff,score,latent] = pca(clust_ori(:,525:600));
clust_index = isosplit5(clust_ori(:,525:600)');
clust_num=max(clust_index);
mean_clust{j}=zeros(clust_num,size(aligned_EPSC_nodrug,2));
color_map=colormap(jet(clust_num));
% figure;
% hold on;
% for i = 1:length(score)
%     scatter3(score(i,1),score(i,2),score(i,3),'MarkerEdgeColor',color_map(clust_index(i),:));
% end
% hold off;
% figure
% hold on;
% for i=1:size(clust_ori,1)
%     plot(x_data,clust_ori(i,:),'color',color_map(clust_index(i),:))
% end
% hold off;

% figure;
% clust=cell(clust_num,1);
% for k=1:clust_num
%     h(k).a=subplot(clust_num,1,k);
%     clust{k}=clust_ori(clust_index==k,:);
%     hold on;
%     for i=1:size(clust{k},1)
%     plot(x_data,clust{k}(i,:),'color',[0.3 0.3 0.3])
%     end
%     mean_clust{j}(k,:)=mean(clust{k},1);
%     plot(x_data,mean_clust{j}(k,:),'color',color_map(k,:),'LineWidth',4)
%     hold off;
%     set(h(k).a,'fontsize',20,'fontweight','bold')
% end
% xlabel('ms')
% ylabel('pA')
% samexaxis('abc','xmt','on','ytac','join','yld',1,'box','off');
% xlim([0 4])
end

aligned_EPSC_nodrug_aver=mean(aligned_EPSC_nodrug,1);
%aligned_EPSC_nodrug_aver=mean_clust{1}(1,:);
nodrug_EPSC_peak=min(aligned_EPSC_nodrug_aver(500:600));
%aligned_EPSC_NBQX_aver=mean_clust{2}(2,:);
aligned_EPSC_NBQX_aver=mean(aligned_EPSC_NBQX,1);
NBQX_EPSC_peak=min(aligned_EPSC_NBQX_aver(500:600));
peak_ratio=abs(nodrug_EPSC_peak/NBQX_EPSC_peak);
%peak_ratio=1;
aver_delay=get_delay(aligned_EPSC_nodrug_aver(520:560),aligned_EPSC_NBQX_aver(520:560).*peak_ratio);
if aver_delay<0
    diff_EPSC=aligned_EPSC_nodrug_aver(1-aver_delay:end)-aligned_EPSC_NBQX_aver(1:end+aver_delay).*peak_ratio;
elseif aver_delay>=0
    diff_EPSC=aligned_EPSC_nodrug_aver(1:end-aver_delay)-aligned_EPSC_NBQX_aver(1+aver_delay:end).*peak_ratio;
end

F2=figure('Unit','Normal','position',[0.2 0.2 0.6 0.6]);
hold on;
plot(x_data,aligned_EPSC_nodrug_aver,'g','LineWidth',4,'DisplayName','Pre-NBQX')
plot(x_data-aver_delay*si*1e-3,aligned_EPSC_NBQX_aver.*peak_ratio,'r','LineWidth',4,'DisplayName','Scaled post-NBQX')
if aver_delay>0
    plot(x_data(1:end-aver_delay),diff_EPSC,'k','LineWidth',4,'DisplayName','Reduced components by NBQX');
else
    plot(x_data(1-aver_delay:end),diff_EPSC,'k','LineWidth',4,'DisplayName','Reduced components by NBQX');
end
xlabel('ms')
ylabel('pA')
xlim([-1 9])
legend('show')
A=gca;
set(A,'fontsize',20,'fontweight','bold')
title(f_header(1:end-3),'interpreter','none')
print([f_header(1:end-3) '_aver.jpg'],'-r300','-djpeg');

save([f_header(1:end-3) '_summary.mat'],'aligned_EPSC_nodrug','aligned_EPSC_nodrug_aver'...
    ,'aligned_EPSC_NBQX','aligned_EPSC_NBQX_aver','peak_ratio'...
    ,'diff_EPSC','aver_delay','si');

%peak_ratio=1;
LineStyle={'--','-'};
delay=[0,aver_delay];
ratio=[1,peak_ratio];
% figure;
% hold on
% for j=1:2
%     for i=1:clust_num
%         plot(x_data-delay(j),mean_clust{j}(i,:).*ratio(j),'color',color_map(i,:),'LineWidth',4,'LineStyle',LineStyle{j})
%     end
% end 
% hold off
% xlabel('ms')
% ylabel('pA')
% A=gca;
% set(A,'fontsize',20,'fontweight','bold')
% xlim([0 4])


%% Plot the area of charge transfer for electrical and chemical components
F3=figure('Unit','Normal','position',[0.2 0.2 0.6 0.6]);
hold on;
if aver_delay>0
    area(aligned_EPSC_nodrug_aver,'FaceColor','g','EdgeColor','g','DisplayName','Pre-NBQX')
    area(aligned_EPSC_NBQX_aver(1+aver_delay:end).*peak_ratio,'FaceColor','r','EdgeColor','r'...
        ,'DisplayName','Scaled post-NBQX')
else
    area(aligned_EPSC_nodrug_aver(1-aver_delay:end),'FaceColor','g','EdgeColor','g','DisplayName','Pre-NBQX')
    area(aligned_EPSC_NBQX_aver.*peak_ratio,'FaceColor','r','EdgeColor','r'...
    ,'DisplayName','Scaled post-NBQX')
end
xlim([500 1000])
xlabel('ms')
ylabel('pA')
legend('show')
A=gca;
A.XTick=500:100:1000;
A.XTickLabel={'0','2','4','6','8','10'};
set(A,'fontsize',20,'fontweight','bold')
title(f_header(1:end-3),'interpreter','none')
print([f_header(1:end-3) '_area.jpg'],'-r300','-djpeg');



function index=get_delay(w0,w1)
    dist=zeros(11,1);
%     figure;
%     hold on;
    for i=-5:5
        if i<0
            dist(i+6)=sum((w1(1:end+i)-w0(1-i:end)).^2/(11-abs(i))).^0.5;
            %dist(i+7)=max(abs(w1(1:end+i)-w0(1-i:end)));
            %plot(w1(1:end+i)-w0(1-i:end),'r')
        else
            dist(i+6)=sum((w1(1+i:end)-w0(1:end-i)).^2/(11-abs(i))).^0.5;
            %dist(i+7)=max(abs(w1(1+i:end)-w0(1:end-i))); 
            %plot(w1(1+i:end)-w0(1:end-i),'g')
        end
    end
    [~,index]=min(dist);
    index=index-6;
end





function failure_index=find_failures(trials,threshold)
    failure_index=zeros(size(trials,1),1);
%     figure;
%     hold on;
    for i=1:size(trials,1)
        if trials(i,:)>threshold
            failure_index(i)=1;
%             plot(trials(i,:))
        end
    end
    hold off;
end