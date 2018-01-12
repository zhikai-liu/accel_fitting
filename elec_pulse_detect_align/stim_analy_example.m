%% Example analysis for ZL171220_fish01a
f_name_nodrug={'08','09','10','11','12'};
f_name_NBQX={'20','21','22','23','24'};
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

EPSC_trials_nodrug=stim_detector(concate_wave_nodrug,si);
EPSC_trials_NBQX=stim_detector(concate_wave_NBQX,si);

figure;
hold on;
x_data=(1:size(EPSC_trials_nodrug,2)).*si.*1e-3;
% for i=1:size(EPSC_trials_nodrug,1)
%     plot(x_data,EPSC_trials_nodrug(i,:),'g--')
% end
EPSC_trials_aver=mean(EPSC_trials_nodrug,1);
plot(x_data,EPSC_trials_aver,'g','LineWidth',4)



% for i=1:size(EPSC_trials_NBQX,1)
%     plot(x_data,EPSC_trials_NBQX(i,:),'r--')
% end
EPSC_trials_aver=mean(EPSC_trials_NBQX,1);
plot(x_data,EPSC_trials_aver,'r','LineWidth',4)

hold off;
