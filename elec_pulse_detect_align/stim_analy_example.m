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
[EPSC_trials_nodrug_s,EPSC_trials_nodrug_f]=stim_detector(concate_wave_nodrug,si,'g');
[EPSC_trials_NBQX_s,EPSC_trials_NBQX_f]=stim_detector(concate_wave_NBQX,si,'r');

figure('Unit','Normal','position',[0 0 1 1]);
x_data=(1:size(EPSC_trials_nodrug_s,2)).*si.*1e-3-10;
% for i=1:size(EPSC_trials_nodrug,1)
%     plot(x_data,EPSC_trials_nodrug(i,:),'g--')
% end
EPSC_trials_aver_nodrug=mean(EPSC_trials_nodrug_s,1);
A1=subplot(2,1,1);
hold on;
for i=1:size(EPSC_trials_nodrug_s,1)
    plot(x_data,EPSC_trials_nodrug_s(i,:),'color',[0.3,0.3,0.3])
end
for i=1:size(EPSC_trials_nodrug_f,1)
    plot(x_data,EPSC_trials_nodrug_f(i,:),'color','b')
end

plot(x_data,EPSC_trials_aver_nodrug,'g','LineWidth',4)
nodrug_EPSC_peak=min(EPSC_trials_aver_nodrug);
hold off
ylim([-200,25])
xlim([-1,6])
% for i=1:size(EPSC_trials_NBQX,1)
%     plot(x_data,EPSC_trials_NBQX(i,:),'r--')
% end
EPSC_trials_aver_NBQX=mean(EPSC_trials_NBQX_s,1);
NBQX_EPSC_peak=min(EPSC_trials_aver_NBQX);
set(A1.XAxis,'Visible','off')
set(A1,'fontsize',20,'fontweight','bold')
legend({'pre-NBQX'},'TextColor','g')
%EPSC_trials_aver=EPSC_trials_aver.*abs(nodrug_EPSC_peak/NBQX_EPSC_peak);
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
ylim([-200,25])
xlim([-1,6])
xlabel('ms')
ylabel('pA')
legend({'post-NBQX'},'TextColor','r')
set(A2,'fontsize',20,'fontweight','bold')
samexaxis('abc','xmt','on','ytac','join','yld',1,'box','off');

% figure;
% hold on;
% plot(x_data,EPSC_trials_aver_nodrug,'g','LineWidth',4)
% plot(x_data,EPSC_trials_aver_NBQX,'r','LineWidth',4)
% plot(x_data,EPSC_trials_aver_nodrug-EPSC_trials_aver_NBQX,'k','LineWidth',4);
% xlabel('ms')

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