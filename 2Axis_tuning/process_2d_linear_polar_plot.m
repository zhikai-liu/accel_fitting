function process_2d_linear_polar_plot(filename)
S=load(filename);
fNames={'X','Y','XpYp','XpYn'};

tuning_r=zeros(length(fNames),1);
tuning_angle=zeros(length(fNames),1);
direction_sign=ones(length(fNames),1);
stim_freq=2;
Lim=40;
clust_num=S.X.fista.clust_num;
clust_polar=struct();
figure('Units','Normal','Position',[0.1,0.2,0.85,0.5]);
for j=1:clust_num
% figure;
for i=1:length(fNames)
%     subplot(4,1,i)
    phase=S.(fNames{i}).fista.period_index.phase;
    cycle_num=S.(fNames{i}).fista.cycle_num;
    X1_clust=S.(fNames{i}).fista.period_index.X1_clust;
    clust_phase=phase(X1_clust==j);
    phase_sum=sum(exp(1i*clust_phase));
    tuning_r(i)=abs(phase_sum)./cycle_num{1}.*stim_freq;
    tuning_angle(i)=angle(phase_sum);
    tuning_angle(tuning_angle<0)=tuning_angle(tuning_angle<0)+2*pi;
end
direction_sign(tuning_angle>pi/2&tuning_angle<3*pi/2)=-1;
subplot(1,clust_num,j)
hold on;
basis=[1,0;0,1;1/sqrt(2),1/sqrt(2);-1/sqrt(2),1/sqrt(2)];
x=zeros(length(fNames),1);
y=zeros(length(fNames),1);
for i=1:length(fNames)
    x(i)=direction_sign(i).*tuning_r(i).*basis(i,1);
    y(i)=direction_sign(i).*tuning_r(i).*basis(i,2);
    plot([-x(i) x(i)],[-y(i) y(i)],'k','LineWidth',5);
    %scatter(sin(tuning_angle(i)).*x(i),sin(tuning_angle(i)).*y(i),'*k')
    h=quiver(sin(tuning_angle(i)).*x(i),sin(tuning_angle(i)).*y(i),3.*x(i)./tuning_r(i),3.*y(i)./tuning_r(i),...
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
end
save('2d_linear_polar_plot.mat','clust_polar');
print([filename '_polar_plot.jpg'],'-r300','-djpeg');
end


function AxisFormat()
    A=gca;
    set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
    set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
    axis square
end