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
EPSC_trials_nodrug=stim_detector(concate_wave_nodrug,si,clust_num);
EPSC_trials_NBQX=stim_detector(concate_wave_NBQX,si,clust_num);

figure;
x_data=(1:size(EPSC_trials_nodrug,2)).*si.*1e-3;
% for i=1:size(EPSC_trials_nodrug,1)
%     plot(x_data,EPSC_trials_nodrug(i,:),'g--')
% end
EPSC_trials_aver=mean(EPSC_trials_nodrug,1);
subplot(2,1,1)
hold on;
for i=1:size(EPSC_trials_nodrug,1)
    plot(x_data,EPSC_trials_nodrug(i,:),'color',[0.3,0.3,0.3])
end
plot(x_data,EPSC_trials_aver,'g','LineWidth',4)
nodrug_EPSC_peak=min(EPSC_trials_aver);
hold off
ylim([-200,25])
xlim([9,16])
% for i=1:size(EPSC_trials_NBQX,1)
%     plot(x_data,EPSC_trials_NBQX(i,:),'r--')
% end
EPSC_trials_aver=mean(EPSC_trials_NBQX,1);
NBQX_EPSC_peak=min(EPSC_trials_aver);
%EPSC_trials_aver=EPSC_trials_aver.*abs(nodrug_EPSC_peak/NBQX_EPSC_peak);
subplot(2,1,2)
hold on;
for i=1:size(EPSC_trials_NBQX,1)
    plot(x_data,EPSC_trials_NBQX(i,:),'color',[0.3,0.3,0.3])
end
plot(x_data,EPSC_trials_aver,'r','LineWidth',4)
hold off;
ylim([-200,25])
xlim([9,16])
samexaxis('abc','xmt','on','ytac','join','yld',1);


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