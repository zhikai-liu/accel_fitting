function process_fista_X1_X2_fit(filename_h)
f_EPSC = dir([filename_h 'EPSC*.mat']);
f_EPSP = dir([filename_h 'EPSP*.mat']);
C = load(f_EPSC(1).name);
P = load(f_EPSP(1).name);
field_names={'X','Y','XpYp','XpYn'};
for l=1:length(field_names)
    if isfield(C,field_names{l})&&isfield(P,field_names{l})
        S_c=C.(field_names{l});
        S_p=P.(field_names{l});
        if ~isempty(fieldnames(S_c))&&~isempty(fieldnames(S_p))
        for j =1:length(S_c.poi)
            clearvars poi_c poi_p
            poi_c_start = S_c.poi{j}(1)*1e6/S_c.si;
            poi_c_end = S_c.poi{j}(end)*1e6/S_c.si;
            poi_p_start = S_p.poi{j}(1)*1e6/S_p.si;
            poi_p_end = S_p.poi{j}(end)*1e6/S_p.si;
            poi_c = poi_c_start+1:poi_c_end;
            poi_p = poi_p_start+1:poi_p_end;
            %% Plotting the raw traces of different periods stacking on each other
            F1 = figure('units','normal','position',[0.3 0 0.6 1]);
            plot_cycle_fit(S_c.Data,S_c.fista,poi_c,S_c.fit_model{j},S_c.S_period{j},S_c.type,...
                S_p.Data,poi_p,S_p.fit_model{j},S_p.S_period{j},S_p.type);
            title(F1.Children(end),{[S_c.name ' (Period ' num2str(j) ')'], ...
                [' Sin: Freq ' num2str(S_c.fit_freq{j}) '  Amp ' num2str(S_c.fit_amp{j}) 'g'],...
                ['FISTA']},...
                'interpreter','none','FontSize',20,'FontWeight','bold');
            A1=F1.Children;
            xticks([0 90 180 270 360])
            xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});
            for k=1:length(A1)
                set(A1(k).Children,'LineWidth',3)
                set(A1(k).XAxis,'FontSize',20,'LineWidth',3,'FontWeight','bold');
                set(A1(k).YAxis,'FontSize',20,'LineWidth',3,'FontWeight','bold');
                set(A1(k).YAxis.Label,'Units','normalized','Position',[-0.08 0.5 0])
            end
            print([S_c.name '_period_' num2str(j) '_cycle_fit_fista.jpg'],'-r300','-djpeg');
        end
        end
    end
end
end


function plot_cycle_fit(Data_c,fista,poi_c,fit_model_c,S_period_c,type_c,Data_p,poi_p,fit_model_p,S_period_p,type_p)


% This function is used to plot the fitted traces of all cycles overlaying
% together
% Time per cycle (how many data points in one cycle, not in seconds)
t_per_cycle = round(2*pi/fit_model_c.b1);
% Cycle numbers
cycle_num = round(length(S_period_c)/t_per_cycle);
% All the data points evenly spreaded in one cycle, 2pi
% t_unit is the amount per data point
t_unit = 2*pi/t_per_cycle;

X1_reconstruct=conv(fista.X1,fista.template1);
X1_reconstruct=X1_reconstruct(1:end-length(fista.template1)+1);
X2_reconstruct=conv(fista.X2,fista.template2);
X2_reconstruct=X2_reconstruct(1:end-length(fista.template2)+1);
% Subplot numbers
subplot_num =6;
%% Plot as following:
% First subplot is the overlay of EPSC trace for each cycle
S_period_phase=mod(fit_model_c.b1.*S_period_c+fit_model_c.c1,2*pi);
% Finding the first phase 0 in the S_period
zero_phase=find_first_phase_o(S_period_phase);
compen_for_zero=0;
if zero_phase>t_per_cycle/1.5
    compen_for_zero=t_per_cycle;
end
signal_names={'Data','X1','X2'};
color={'k','r','g'};

subplot(subplot_num,1,1)
t_per_cycle_p = round(2*pi/fit_model_p.b1);

cycle_num_p = round(length(S_period_p)/t_per_cycle_p);

t_unit_p = 2*pi/t_per_cycle_p;
signal_all_cycles=zeros(t_per_cycle_p+1,cycle_num_p);
trace=Data_p(:,1);
S_period_phase_p=mod(fit_model_p.b1.*S_period_p+fit_model_p.c1,2*pi);
% Finding the first phase 0 in the S_period
zero_phase_p=find_first_phase_o(S_period_phase_p);
compen_for_zero_p=0;
if zero_phase_p>t_per_cycle_p/1.5
    compen_for_zero_p=t_per_cycle_p;
end

for i = 1:cycle_num_p
    hold on;
    % Make sure that all the data are plotted where they are aligned with 0-2pi
    % phase, because S_period doesn't always start at phase 0,
    % so plotting start at a point with zero phase
    if S_period_p(zero_phase)+i*t_per_cycle_p-compen_for_zero_p<length(trace)
        signal_all_cycles(:,i)=trace(S_period_p(zero_phase)+(i-1)*t_per_cycle_p-compen_for_zero_p:S_period_p(zero_phase)+i*t_per_cycle_p-compen_for_zero_p);
        %plot(0:t_unit:2*pi,signal_all_cycles(i,:),color{j})
    end
    
end
plot(0:t_unit_p:2*pi,mean(signal_all_cycles,2))
hold off;
xlim([0 2*pi]);
A=gca;
set(A.XAxis,'visible','off')
if strcmp(type_p{1},'EPSC')||strcmp(type_p{1},'IPSC')
    ylabel('pA','Rotation',0);
elseif strcmp(type_p{1},'EPSP')||strcmp(type_p{1},'IPSP')
    ylabel('mV','Rotation',0);
end


for j=1:3
    switch j
        case 1
            trace=Data_c(:,1);
        case 2
            trace=X1_reconstruct;
        case 3
            trace=X2_reconstruct;
    end
    subplot(subplot_num,1,j+1);
    signal_all_cycles=zeros(t_per_cycle+1,cycle_num);
    for i = 1:cycle_num
        hold on;
        % Make sure that all the data are plotted where they are aligned with 0-2pi
        % phase, because S_period doesn't always start at phase 0,
        % so plotting start at a point with zero phase
        if S_period_c(zero_phase)+i*t_per_cycle-compen_for_zero<length(trace)
            signal_all_cycles(:,i)=trace(S_period_c(zero_phase)+(i-1)*t_per_cycle-compen_for_zero:S_period_c(zero_phase)+i*t_per_cycle-compen_for_zero);
            %plot(0:t_unit:2*pi,signal_all_cycles(i,:),color{j})
        end
        
    end
    plot(0:t_unit:2*pi,mean(signal_all_cycles,2))
    hold off;
    xlim([0 2*pi]);
    A=gca;
    set(A.XAxis,'visible','off')
    if strcmp(type_c{1},'EPSC')||strcmp(type_c{1},'IPSC')
        ylabel([ signal_names{j} ' pA'],'Rotation',0);
    elseif strcmp(type_c{1},'EPSP')||strcmp(type_c{1},'IPSP')
        ylabel('mV','Rotation',0);
    end
end


% Last subplot is the overlay of the acceleration trace for each cycle
subplot(subplot_num,1,subplot_num-1);
color = {'r','g','b'};
for i = 1:cycle_num
    for j = 2:4
        hold on;
        if S_period_c(zero_phase)+i*t_per_cycle-compen_for_zero<length(Data_c)
            plot(0:t_unit:2*pi,Data_c(S_period_c(zero_phase)+(i-1)*t_per_cycle-compen_for_zero:S_period_c(zero_phase)+i*t_per_cycle-compen_for_zero,j)-mean(Data_c(poi_c,j)),color{j-1})
        end
        hold off;
    end
end
xlim([0 2*pi]);
ylabel('EPSC-g','Rotation',0);

subplot(subplot_num,1,subplot_num);
color = {'r','g','b'};
for i = 1:cycle_num_p
    for j = 2:4
        hold on;
        if S_period_p(zero_phase_p)+i*t_per_cycle_p-compen_for_zero_p<length(Data_p)
            plot(0:t_unit_p:2*pi,Data_p(S_period_p(zero_phase_p)+(i-1)*t_per_cycle_p-compen_for_zero_p:S_period_p(zero_phase_p)+i*t_per_cycle_p-compen_for_zero_p,j)-mean(Data_p(poi_p,j)),color{j-1})
        end
        hold off;
    end
end
xlim([0 2*pi]);
ylabel('EPSP-g','Rotation',0);

samexaxis('ytac','join','box','off');
end



function zero_phase=find_first_phase_o(S_period_phase)
% Phase should keeping increasing from 0 to 2pi unless it is the end
phase_diff=diff(S_period_phase);
cycle_end=find(phase_diff<0);
zero_phase=cycle_end(1);
end