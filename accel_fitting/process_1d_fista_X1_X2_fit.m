function process_1d_fista_X1_X2_fit(filename_h)
f_EPSC = dir([filename_h '*.mat']);
%f_EPSP = dir([filename_h 'EPSP*.mat']);
for m=1:length(f_EPSC)
    C = load(f_EPSC(m).name);
    %P = load(f_EPSP(1).name);
    %field_names={'X','Y','XpYp','XpYn'};
    if isfield(C,'fista')
        %         for l=1:length(C.Trials)
        %if isfield(C,field_names{l})&&isfield(P,field_names{l})
        S_c=C;
        %if ~isempty(fieldnames(S_c))&&~isempty(fieldnames(S_p))
        if ~isempty(fieldnames(S_c))
            for j =1:length(S_c.poi)
                clearvars poi_c poi_p
                poi_c_start = S_c.poi{j}(1)*1e6/S_c.si;
                poi_c_end = S_c.poi{j}(end)*1e6/S_c.si;
                %             poi_p_start = S_p.poi{j}(1)*1e6/S_p.si;
                %             poi_p_end = S_p.poi{j}(end)*1e6/S_p.si;
                poi_c = poi_c_start+1:poi_c_end;
                %             poi_p = poi_p_start+1:poi_p_end;
                %% Plotting the raw traces of different periods stacking on each other
                F1 = figure('units','normal','position',[0.3 0 0.6 1]);
                plot_cycle_fit(S_c.Data,S_c.fista,poi_c,S_c.fit_model{j},S_c.S_period{j},S_c.type);
                title(F1.Children(end),{[S_c.name ' (Period ' num2str(j) ')'], ...
                    [' Sin: Freq ' num2str(S_c.fit_freq{j}) '  Amp ' num2str(S_c.fit_amp{j}) 'g'],...
                    ['FISTA']},...
                    'interpreter','none','FontSize',20,'FontWeight','bold');
                A1=F1.Children;
                for k=1:length(A1)
                    set(A1(k),'box','off')
                    set(A1(k).Children,'LineWidth',3)
                    set(A1(k).XAxis,'FontSize',20,'LineWidth',3,'FontWeight','bold');
                    set(A1(k).YAxis,'FontSize',20,'LineWidth',3,'FontWeight','bold');
                    set(A1(k).YAxis.Label,'Units','normalized','Position',[-0.08 0.5 0])
                end
                print([S_c.name '_period_' num2str(j) '_cycle_fit_X12.jpg'],'-r300','-djpeg');
                close all
                
            end
        end
    end
end
end



function plot_cycle_fit(Data_c,fista,poi_c,fit_model_c,S_period_c,type_c)


% This function is used to plot the fitted traces of all cycles overlaying
% together
% Time per cycle (how many data points in one cycle, not in seconds)
t_per_cycle = round(2*pi/fit_model_c.b1);
% Cycle numbers
cycle_num = round(length(S_period_c)/t_per_cycle);
% All the data points evenly spreaded in one cycle, 2pi
% t_unit is the amount per data point
t_unit = 2*pi/t_per_cycle;

X1_reconstruct=conv(fista.X1,fista.tempate1);
X1_reconstruct=X1_reconstruct(1:end-length(fista.tempate1)+1);
X2_reconstruct=conv(fista.X2,fista.tempate2);
X2_reconstruct=X2_reconstruct(1:end-length(fista.tempate2)+1);
EPSC_reconstruct=X1_reconstruct+X2_reconstruct;
% Subplot numbers
subplot_num =4;
%% Plot as following:
% First subplot is the overlay of EPSC trace for each cycle
S_period_phase=mod(fit_model_c.b1.*S_period_c+fit_model_c.c1,2*pi);
% Finding the first phase 0 in the S_period
zero_phase=find_first_phase_o(S_period_phase);
compen_for_zero=0;
if zero_phase>t_per_cycle/1.5
    compen_for_zero=t_per_cycle;
end
signal_names={'Data','X1','X1/2','EPSC-Rs'};
color_M={'k','r','g','b'};
mean_trace=cell(4,1);
for j=[1,4,2,3]
    switch j
        case 1
            trace=smooth(Data_c(:,1)-median(Data_c(:,1)));
            subplot(subplot_num,1,j);
        case 4
            trace=EPSC_reconstruct;
        case 2
            trace=X1_reconstruct;
            subplot(subplot_num,1,j);
        case 3
            trace=X2_reconstruct;
    end
    
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
    mean_trace{j}=mean(signal_all_cycles,2);
    plot(0:t_unit:2*pi,mean_trace{j},color_M{j})
    %     hold off;
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
g_all_cycles=zeros(t_per_cycle+1,cycle_num,3);
mean_g=zeros(t_per_cycle+1,3);
for i = 1:cycle_num
    for j = 2:4
        hold on;
        if S_period_c(zero_phase)+i*t_per_cycle-compen_for_zero<length(Data_c)
            g_all_cycles(:,i,j-1)=Data_c(S_period_c(zero_phase)+(i-1)*t_per_cycle-compen_for_zero:S_period_c(zero_phase)+i*t_per_cycle-compen_for_zero,j)-mean(Data_c(poi_c,j));
            plot(0:t_unit:2*pi,Data_c(S_period_c(zero_phase)+(i-1)*t_per_cycle-compen_for_zero:S_period_c(zero_phase)+i*t_per_cycle-compen_for_zero,j)-mean(Data_c(poi_c,j)),color{j-1})
        end
        hold off;
    end
end
for j=1:3
    mean_g(:,j)=mean(g_all_cycles(:,:,j),2);
end
xlim([0 2*pi]);
ylabel('EPSC-g','Rotation',0);

samexaxis('ytac','join','box','off');
xticks([0 90 180 270 360])
xticklabels({'0','\pi/2','\pi','3\pi/2','2\pi'});

[~,g_index]=max(std(mean_g,1));
subplot(subplot_num,1,subplot_num);
hold on;
si=20;
[cross_corr_X1,lag_X1]=xcorr(mean_g(:,g_index),-mean_trace{2});
[cross_corr_X2,lag_X2]=xcorr(mean_g(:,g_index),-mean_trace{3});

lag_X1_ms=lag_X1*si*1e-3;
plot(lag_X1_ms,cross_corr_X1,'r')
[~,max_X1_index]=max(cross_corr_X1);
plot([lag_X1_ms(max_X1_index),lag_X1_ms(max_X1_index)],[0,cross_corr_X1(max_X1_index)],'r:')

lag_X2_ms=lag_X2*si*1e-3;
plot(lag_X2_ms,cross_corr_X2,'g')
[~,max_X2_index]=max(cross_corr_X2);
plot([lag_X2_ms(max_X2_index),lag_X2_ms(max_X2_index)],[0,cross_corr_X2(max_X2_index)],'g:')
hold off
%xlim([-100,100])
xlabel(['Lag X1-X2: ',num2str(lag_X1_ms(max_X1_index)-lag_X2_ms(max_X2_index),2) ' ms'])
ylabel({'cross corr','X1/X2'},'Rotation',0)
end



function zero_phase=find_first_phase_o(S_period_phase)
% Phase should keeping increasing from 0 to 2pi unless it is the end
phase_diff=diff(S_period_phase);
cycle_end=find(phase_diff<0);
zero_phase=cycle_end(1);
end