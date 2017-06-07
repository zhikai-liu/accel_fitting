function process_phase_circ_subplot(filename_h, amp_range,plot_order)
S = load(['Trials_' filename_h '.mat']);
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
        c_phase = S.Trials(i).Phase(S.Trials(i).Amps>amp_range(1)&S.Trials(i).Amps<amp_range(end));
    else
        c_phase = [0];
    end
    A = circ_plot(c_phase,'pretty');
    set(A,'Visible','off')
    set(A.Children(end),'MarkerSize',4,'LineWidth',1);
    set(A.Children(end-4),'LineWidth',2);
%         text(0,-0.1,['Mean direction: ' num2str(rad2deg(circ_mean(c_phase))) '^o'],...
%                     'FontWeight','bold',...
%                     'FontSize',12)
    if i == 0
        set(A.Children(1:end),'Visible','off');
    end
    if j<=m
            text(-0.3,2,[num2str(j*0.02) 'g'],...
                'interpreter','none',...
                'FontWeight','bold',...
                'FontSize',12)
    end
    if mod(j,m) == 1
            text(-2.5,0,[num2str(2^((j-1-m)/m)) 'Hz'],...
                'interpreter','none',...
                'FontWeight','bold',...
                'FontSize',12)
    end
end
print([filename_h '_phase_subplot(' num2str(amp_range(1)) 'to' num2str(amp_range(end)) 'pA).pdf'],'-fillpage','-dpdf')
end