% plot for several frequency
plot_order = [9 8 7 10];
plot_period = {5:9,4:8,4:8,3.5:0.5:7.5};
S=load('Trials_EPSC_accel_ZL170517_fish03a.mat');
figure;
n = length(plot_order);
for i = 1:n
    trial = load(['EPSC_accel_' S.Trials(plot_order(i)).Filename '.mat']);
    period = plot_period{i}(1).*1e6/trial.si:plot_period{i}(end).*1e6/trial.si;
    subplot(2*n,1,2*i-1)
    plot([1:length(period)].*trial.si.*1e-6,smooth(trial.Data(period,1)),'r','LineWidth',1);
    ylabel('pA');
    ylim([-100 10]);
    xlim([-0.2 4.2]);
    A = gca;
    set(A,'XTick',[])
    set(A,'YTick',[-80 -40 0])
    set(A.XAxis,'Visible','off')
    subplot(2*n,1,2*i)
    plot([1:length(period)].*trial.si.*1e-6,smooth(trial.Data(period,2),5e3,'sgolay'),'b','LineWidth',2);
    ylabel('g');
    xlim([-0.2 4.2]);
    ylim([-0.045 0.045]);
    A = gca;
    set(A,'YTick',[-0.04 0 0.04])
    if i~=n
    set(A,'XTick',[])
    set(A.XAxis,'Visible','off')
    end
end
xlabel('Second');
samexaxis('ytac','box','off');