function process_bode_trial(filename_h, amp_range,plot_order)
S = load(filename_h);
plot_order = plot_order';
[m,n] = size(plot_order);
subplot_data=struct();
F = figure('Units','normal',...
                'Position',[0.3 0 0.3 1],...
                'Visible', 'on');
            if m==1
                color='k';
            else
                color=colormap(jet(m));
            end
for j = 1:m
%     freq_num=sum(plot_order(m,:)~=0);
%     subplot_data(j).S_freq=zeros(1,freq_num);
    count=1;
    for i=1:n
        if plot_order(j,i)~=0
            trial=plot_order(j,i);
            subplot_data(j).S_freq(count)=round(S.Trials(trial).S_freq,1);
            subplot_data(j).S_amp(count)=round(S.Trials(trial).S_amp,2);
            c_phase = S.Trials(trial).period_index.phase(S.Trials(trial).period_index.amp>amp_range(1)&S.Trials(trial).period_index.amp<amp_range(end));
            r=sum(exp(1i*c_phase));
            subplot_data(j).phase_mean(count)=pi/2-angle(r);
            subplot_data(j).gain(count)= abs(r).*S.Trials(trial).S_freq./S.Trials(trial).S_cycle;
            count=count+1;
        end
    end
end
subplot(2,1,1)
hold on;
for j = 1:m
    S_freq= subplot_data(j).S_freq;
    freq_gain=subplot_data(j).gain;
    plot(log2(S_freq),freq_gain,...
        'color',color(j,:),'Marker','.','MarkerSize',35,'LineWidth',5,...
        'DisplayName',[num2str(subplot_data(j).S_amp(1)) ' g'])
end
hold off;
xlim([-2 5]);
xticks([-1 0 1 2 3])
xticklabels({0.5 1 2 4 8});
LG=legend('show');
ylabel('Gain (EPSC/s)','FontSize',20,'FontWeight','bold')
A=gca;
set(A.XAxis,'Visible','off');
set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k');
set(LG,'Box','off','FontSize',20,'FontWeight','bold','LineWidth',3)
subplot(2,1,2)
hold on;
for j = 1:m
    S_freq= subplot_data(j).S_freq;
    freq_phase=subplot_data(j).phase_mean;
    plot(log2(S_freq),freq_phase*180/pi,'color',color(j,:),'Marker','.','MarkerSize',35,'LineWidth',5)
end
hold off;
xlim([-2 5]);
xticks([-1 0 1 2 3])
xticklabels({0.5 1 2 4 8});
ylim([-90 270])
xlabel('Hz')
ylabel('Phase (degree)')
A=gca;
set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k');
set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k');
print([filename_h '_phase_bode(' num2str(amp_range(1)) 'to' num2str(amp_range(end)) 'pA).jpg'],'-r300','-djpeg')
print([filename_h '_phase_bode(' num2str(amp_range(1)) 'to' num2str(amp_range(end)) 'pA).svg'],'-dsvg')
end