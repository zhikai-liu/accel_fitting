function process_phase_circ_subplot(filename_h, amp_range,plot_order)
S = load(['Trials_' filename_h '.mat']);
plot_order = plot_order';
[m,n] = size(plot_order);
plot_num = m*n;
subplot_data=struct();
F = figure('Units','normal',...
                'Position',[0.3 0 0.12*m+0.1 1],...
                'Visible', 'on');
for j = 1:plot_num
    i = plot_order(j);
    if i ~= 0
%        plot([1,2],[3,4])
        subplot_data(j).c_phase = S.Trials(i).period_index.phase(S.Trials(i).period_index.amp>amp_range(1)&S.Trials(i).period_index.amp<amp_range(end));
        subplot_data(j).FR_cycle= S.Trials(i).S_freq*length(subplot_data(j).c_phase)/S.Trials(i).S_cycle;
    else
        subplot_data(j).c_phase = [0];
    end
end
max_FR = max([subplot_data.FR_cycle]);
for j = 1:plot_num
    i = plot_order(j);
    subplot(n,m,j)
    weight=subplot_data(j).FR_cycle/max_FR;
    A = circular_phase_plot(subplot_data(j).c_phase,1);
    set(A,'Visible','off')
%         text(0,-0.1,['Mean direction: ' num2str(rad2deg(circ_mean(c_phase))) '^o'],...
%                     'FontWeight','bold',...
%                     'FontSize',12)
    if i == 0
        set(A.Children(1:end),'Visible','off');
    else
        set(A.Children(1:4),'fontsize',16,'FontWeight','bold');
        set(A.Children(end),'MarkerSize',6,'LineWidth',2,'Color','blue');
        set(A.Children(end-4),'LineWidth',16*weight,'Color','red');
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
                'FontSize',24)
    end
    if mod(j,m) == 1 || m==1
        for k = 1:m
            if plot_order(j+k-1)~=0
                freq_index = plot_order(j+k-1);
            end
        end
        Hz = round(S.Trials(freq_index).S_freq,1);
            text(-2.8,0,[num2str(Hz) 'Hz'],...
                'interpreter','none',...
                'FontWeight','bold',...
                'FontSize',24)
    end
end
print([filename_h '_phase_subplot(' num2str(amp_range(1)) 'to' num2str(amp_range(end)) 'pA).jpg'],'-r300','-djpeg')
end

function A=circular_phase_plot(alpha,weight,varargin)
% convert angles to unit vectors
    z = exp(1i*alpha);

    % create unit circle
    zz = exp(1i*linspace(0, 2*pi, 101));

    plot(real(z), imag(z), 'o', real(zz), imag(zz), 'k', [-2 2], [0 0], 'k:', [0 0], [-2 2], 'k:');
    set(gca, 'XLim', [-1.1 1.1], 'YLim', [-1.1 1.1])

    % plot mean directions with an overlaid arrow if desired
    if nargin > 2 && ~isempty(varargin{1})
      s = varargin{1};
    else
      s = true;
    end
    
    if s
      r = circ_r(alpha)*weight;
      phi = circ_mean(alpha);
      hold on;
      zm = r*exp(1i*phi);
      plot([0 real(zm)], [0, imag(zm)],varargin{2:end})
      hold off;
    end

    axis square;
    set(gca,'box','off')
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    text(1.2, 0, '0'); text(-.05, 1.2, '\pi/2');  text(-1.35, 0, '±\pi');  text(-.075, -1.2, '-\pi/2');
    A=gca;
end