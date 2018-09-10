function process_plot_fit(filename_h)
f_abf = dir([filename_h '*.mat']);
for i =1:length(f_abf)
    clearvars S cycle_index amps_cycle
    S = load(f_abf(i).name);
    for j =1:length(S.poi)
        clearvars poi
        poi_start = S.poi{j}(1)*1e6/S.si;
        poi_end = S.poi{j}(end)*1e6/S.si;
        poi = poi_start+1:poi_end;
        %% Plotting the raw traces of different periods stacking on each other
        F1 = figure('units','normal','position',[0 0 0.5 0.5]);
        plot_accel_fit(S.Data,poi,S.fit_model{j},S.S_period{j},S.accel_axis{j},S.si,S.type,S.other_axis(:,j),S.other_axis_fit(:,j));
        title(F1.Children(end),[S.name ' Period ' num2str(j) ' of ' num2str(length(S.poi))],...
            'interpreter','none','FontSize',20,'FontWeight','bold');
        A1=F1.Children;
        for k=1:length(A1)
        set(A1(k).Children,'LineWidth',3)
        set(A1(k).XAxis,'FontSize',20,'LineWidth',3,'FontWeight','bold');
        set(A1(k).YAxis,'FontSize',20,'LineWidth',3,'FontWeight','bold');
        set(A1(k).YAxis.Label,'Units','normalized','Position',[-0.08 0.5 0])
        end
        print([S.name '_period_' num2str(j) '_raw_fit.jpg'],'-r300','-djpeg');
        %% Plotting the amp of each event as a point so it is easier to see which clusters are tuned to the stimulus
        F2 = figure('units','normal','position',[0.1 0 0.7 1]);
        if isfield(S.der,'event_index')
            plot_cycle_fit(S.Data,S.der.event_index,S.der.amps,poi,S.fit_model{j},S.S_period{j},S.type);
        else
            plot_cycle_fit(S.Data,[],[],poi,S.fit_model{j},S.S_period{j},S.type);
        end
        title(F2.Children(2),{[S.name ' (Period ' num2str(j) ')'], [' Sin: Freq ' num2str(S.fit_freq{j}) '  Amp ' num2str(S.fit_amp{j}) 'g']},...
            'interpreter','none','FontSize',20,'FontWeight','bold');
        A2=F2.Children;
        xticks([0 90 180 270 360])
        xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
        for k=1:length(A2)
        set(A2(k).Children,'LineWidth',3)
        set(A2(k).XAxis,'FontSize',20,'LineWidth',3,'FontWeight','bold');
        set(A2(k).YAxis,'FontSize',20,'LineWidth',3,'FontWeight','bold');
        set(A2(k).YAxis.Label,'Units','normalized','Position',[-0.08 0.5 0])
        end
        print([S.name '_period_' num2str(j) '_cycle_fit_der.jpg'],'-r300','-djpeg');
        %% Plotting event index based on the FISTA result
        F3 = figure('units','normal','position',[0.1 0 0.7 1]);
        if isfield(S,'fista')
            plot_cycle_fit(S.Data,S.fista.X1_max,S.fista.X1_integral,poi,S.fit_model{j},S.S_period{j},S.type);
        else
            plot_cycle_fit(S.Data,[],[],poi,S.fit_model{j},S.S_period{j},S.type);
        end
        title(F3.Children(2),{[S.name ' (Period ' num2str(j) ')'], [' Sin: Freq ' num2str(S.fit_freq{j}) '  Integral ' num2str(S.fit_amp{j}) 'g']},...
            'interpreter','none','FontSize',20,'FontWeight','bold');
        A3=F3.Children;
        xticks([0 90 180 270 360])
        xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
        for k=1:length(A3)
        set(A3(k).Children,'LineWidth',3)
        set(A3(k).XAxis,'FontSize',20,'LineWidth',3,'FontWeight','bold');
        set(A3(k).YAxis,'FontSize',20,'LineWidth',3,'FontWeight','bold');
        set(A3(k).YAxis.Label,'Units','normalized','Position',[-0.08 0.5 0])
        end
        print([S.name '_period_' num2str(j) '_cycle_fit_fista.jpg'],'-r300','-djpeg');
        close all;
    end
end
