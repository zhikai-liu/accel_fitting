function process_2d_linear_polar_plot(filename)
% This code is used to plot tuning direction on 4 different axis of linear
% movement
S=load(filename);
% X Y are orthogonal, 0 and 90. XpYp is 45, XpYn is -45 degrees
fNames={'X','Y','XpYp','XpYn'};
% tuning_r is the gain of tuning
tuning_r=zeros(length(fNames),1);
% tuning_angle is the phase of tuning
tuning_angle=zeros(length(fNames),1);
% Frequency of stimulation is 2Hz
stim_freq=2;
% Lim for plotting axis value
Lim=40;
clust_num=S.X.fista.clust_num;
clust_polar=struct();
figure('Units','Normal','Position',[0.1,0.2,0.85,0.5]);
for j=1:clust_num
    trial_amps=cell(length(fNames),1);
    for i=1:length(fNames)
        phase=S.(fNames{i}).fista.period_index.phase;
        X1_clust=S.(fNames{i}).fista.period_index.X1_clust;
        amps=S.(fNames{i}).fista.period_index.amps;
        %if there are chemical events specified, exclude those events
        if isfield(S.(fNames{i}).fista.period_index,'X1_chemical')
            phase=phase(~S.(fNames{i}).fista.period_index.X1_chemical);
            X1_clust=X1_clust(~S.(fNames{i}).fista.period_index.X1_chemical);
            amps=amps(~S.(fNames{i}).fista.period_index.X1_chemical);
        end
        cycle_num=S.(fNames{i}).fista.cycle_num;
        % Extract the phases for different clusters
        clust_phase=phase(X1_clust==j);
        trial_amps{i}=amps(X1_clust==j);
        phase_sum=sum(exp(1i*clust_phase));
        % Calculate the gain of tuning
        tuning_r(i)=abs(phase_sum)./cycle_num{1}.*stim_freq;
        % Calculate the angle of tuning
        tuning_angle(i)=angle(phase_sum);
        % Convert angle values from +-pi to 0-2pi
        %tuning_angle(tuning_angle<0)=tuning_angle(tuning_angle<0)+2*pi;
    end
    % For each cycle of acceleration, one phase can show up twice, therefore
    % one value of phase can't specify the exact 'phase', additional direction
    % needs to be provided.
    % Values between pi/2 to 3pi/2 have negative directions because their
    % value is decreasing.
    cos_sign=sign(cos(tuning_angle));
    sin_sign=sign(sin(tuning_angle));
    subplot(1,clust_num,j)
    hold on;
    % Four basis for four axis
    basis=[1,0;0,1;1/sqrt(2),1/sqrt(2);-1/sqrt(2),1/sqrt(2)];
    x=zeros(length(fNames),1);
    y=zeros(length(fNames),1);
    for i=1:length(fNames)
        x(i)=tuning_r(i).*basis(i,1);
        y(i)=tuning_r(i).*basis(i,2);
        plot([0, sin_sign(i).*x(i)],[0 sin_sign(i).*y(i)],'k','LineWidth',5);
        %scatter(sin(tuning_angle(i)).*x(i),sin(tuning_angle(i)).*y(i),'*k')
        h=quiver(sin(tuning_angle(i)).*x(i),sin(tuning_angle(i)).*y(i),x(i).*cos_sign(i)*0.25,y(i).*cos_sign(i)*0.25,...
            'color','red','LineWidth',4,'MaxHeadSize',2,'Marker','*');
        set(h,'AutoScale','on', 'AutoScaleFactor', 3)
    end
    xlim([-Lim Lim])
    ylim([-Lim Lim])
    legend({['Cluster ' num2str(j)]},'FontSize',24)
    legend('boxoff')
    %set(gca,'Units','inches','position',[1+8.*(j-1),1,6,6])
    AxisFormat()
    clust_polar(j).x=x;
    clust_polar(j).y=y;
    clust_polar(j).phase=tuning_angle;
    clust_polar(j).amps=trial_amps;
end
save(filename,'clust_polar','-append');
print([filename '_polar_plot.jpg'],'-r300','-djpeg');
end


function AxisFormat()
A=gca;
set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
axis square
end