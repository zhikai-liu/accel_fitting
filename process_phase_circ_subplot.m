function process_phase_circ_subplot(filename_h, amp_range,plot_order)
S = load(['Trials_' filename_h '.mat']);
max_FR = max([S.Trials.FR_cycle]);
plot_order = plot_order';
[m,n] = size(plot_order);
plot_num = m*n;
F = figure;
for j = 1:plot_num
    clearvars c_phase A
    i = plot_order(j);
    subplot(n,m,j)
    if i ~= 0
%        plot([1,2],[3,4])
        c_phase = S.Trials(i).period_index.phase(S.Trials(i).period_index.amp>amp_range(1)&S.Trials(i).period_index.amp<amp_range(end));
    else
        c_phase = [0];
    end
    A = circ_plot(c_phase,'pretty');
    set(A,'Visible','off')
%         text(0,-0.1,['Mean direction: ' num2str(rad2deg(circ_mean(c_phase))) '^o'],...
%                     'FontWeight','bold',...
%                     'FontSize',12)
    if i == 0
        set(A.Children(1:end),'Visible','off');
    else
        set(A.Children(end),'MarkerSize',4,'LineWidth',1);
        set(A.Children(end-4),'LineWidth',8*S.Trials(i).FR_cycle/max_FR);
    end
    if j<=m
        for k = 1:n
            if plot_order(j+(k-1)*m)~=0
                g_index = plot_order(j+(k-1)*m);
            end
        end
        G = round(S.Trials(g_index).S_amp,2);
            text(-0.3,2,[num2str(G) 'g'],...
                'interpreter','none',...
                'FontWeight','bold',...
                'FontSize',12)
    end
    if mod(j,m) == 1 || m==1
        for k = 1:m
            if plot_order(j+k-1)~=0
                freq_index = plot_order(j+k-1);
            end
        end
        Hz = round(S.Trials(freq_index).S_freq,1);
            text(-2.5,0,[num2str(Hz) 'Hz'],...
                'interpreter','none',...
                'FontWeight','bold',...
                'FontSize',12)
    end
end
print([filename_h '_phase_subplot(' num2str(amp_range(1)) 'to' num2str(amp_range(end)) 'pA).pdf'],'-fillpage','-dpdf')
end