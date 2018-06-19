% load('all_events.mat');
% data=S.Data;
load('all_traces_padded.mat');
data=data_pad';
%% calculate the template for single EPSC
load('template2.mat');
%f=fit([1:length(t)-36]',t(37:end),'exp2'); %model the falling phase with double exponential
%model_T=-[t(1:75);f(105:1000)]; 
model_T=t(1:75);
s_data=smooth(data-mean(data));
% s_data=diff(s_data);
% model_T=diff(model_T);
results=deconv_iterative(s_data,model_T);
count=length(results);
%% Use the least square root error round (count-1) for later analysis
D=results(count-1).D;
D_fs=results(count-1).D_fs;
model_T=results(count-1).model_T;
penalty=[results(:).penalty];
LM=results(count-1).LM;
LM_Y=results(count-1).LM_Y;
D_re=results(count-1).D_re;
signal_re=results(count-1).signal_re;

%% Multiple template analysis
if count-1>1
    multitemplate_pca_deconv(results(count-1),s_data);
end
%% Plot penalty cost for each iteration
figure;
plot(penalty)

%% Collect a short length of the deconvolved signal at the local maxima
event_D=D_fs(LM);
for i=1:10
    event_D=[D_fs(LM-i),event_D,D_fs(LM+i)];
end


%% clustering
[~,score,~,~,explained] = pca(event_D);
opts.isocut_threshold=1;
clust_index=isosplit5(score(:,1:3)',opts);
clust_num=max(clust_index);
map=colormap(jet(clust_num));

%% Plot the results

%plot the signal and reconstructed signal
figure;
subplot(2,1,1);
plot(s_data)
hold on;
plot(signal_re);
%scatter(LM,LM_Y)
scatter(LM(1:end-1)+86,s_data(LM(1:end-1)+86))
subplot(2,1,2)
plot(D_fs)
Q=D_fs(LM);
hold on;
scatter(LM,Q)
samexaxis('ytac','join','box','off');





%Plot clustering results
figure;
hold on;
for i = 1:clust_num
    inds=find(clust_index==i);
    scatter3(score(inds,1),score(inds,2),score(inds,3),'MarkerEdgeColor',map(i,:));
end


%Plot clustering results with template deconvolved scores
figure;
hold on;
for i = 1:clust_num
    inds=LM(clust_index==i);
    scatter3(multi_template(1).D_fs(inds),multi_template(2).D_fs(inds),multi_template(3).D_fs(inds),'MarkerEdgeColor',map(i,:));
end

%Plot clustering results with recontruction coefficient
figure;
hold on;
%scatter3(multi_template(1).coeff_delta,multi_template(2).coeff_delta,multi_template(3).coeff_delta,'MarkerEdgeColor','k')
for i = 1:clust_num
    inds=find(clust_index==i);
    scatter3(multi_template(1).coeff_delta(inds),multi_template(2).coeff_delta(inds),multi_template(3).coeff_delta(inds),'MarkerEdgeColor',map(i,:));
end


%Plot each detected event
figure;
hold on;
for i=1:length(LM)
    plot(event_D(i,:),'Color',map(clust_index(i),:))
end

%Plot EPSC events that violate refractory period within the same cluster
si=20;
pad=100*1e3/si;%pad length is 100ms
figure;
for j=1:clust_num
    subplot(clust_num,1,j)
    c_LM=LM(clust_index==j);
    ISI=diff(c_LM).*si.*1e-3;
    %histogram(ISI(ISI<2),20)
    %xlim([0 2])
    c_xdata_1=c_LM([ISI;10]<2);
    c_xdata_2=c_LM([10;ISI]<2);
    c_xdata_3=c_LM([ISI;10]>2&[10;ISI]>2);
    hold on;
%     for i=1:length(c_xdata_1)
%         x_data=c_xdata_1(i):c_xdata_1(i)+200;
%         x_peak=c_xdata_1(i)+86:c_xdata_1(i)+87;
%         y_data=s_data(c_xdata_1(i):c_xdata_1(i)+200);
%         y_peak=s_data(c_xdata_1(i)+86:c_xdata_1(i)+87);
%         plot(x_data,y_data,'k');
%         plot(x_peak,y_peak,'color',map(j,:),'LineWidth',6);
%     end
%     for i=1:length(c_xdata_2)
%         x_data=c_xdata_2(i):c_xdata_2(i)+200;
%         x_peak=c_xdata_2(i)+86:c_xdata_2(i)+87;
%         y_data=s_data(c_xdata_2(i):c_xdata_2(i)+200);
%         y_peak=s_data(c_xdata_2(i)+86:c_xdata_2(i)+87);
%         plot(x_data,y_data,'k');
%         plot(x_peak,y_peak,'r','LineWidth',6);
%     end
    for i=1:length(c_xdata_1)
         y_data=s_data(c_xdata_1(i):c_xdata_1(i)+200);
         plot(y_data,'k');
    end
    for i=1:length(c_xdata_3)
         y_data=s_data(c_xdata_3(i):c_xdata_3(i)+200);
         plot(y_data,'r');
    end
    hold off;
end
samexaxis('ytac','box','off');

%Plotting corrolegram
figure;
for j=1:clust_num
    cross_corr=zeros(sum(clust_index==j),2*pad+1);
    count=1;
    subplot(clust_num,1,j)
    c_xdata_1=LM(clust_index==j);
    spikes=zeros(1,max(c_xdata_1)+2*pad);
    spikes(c_xdata_1+pad)=1;
    dist_prox_index=[];
    for k=1:length(spikes)
        if spikes(k)==1
            bin_train=spikes(k-pad:k+pad);
            bin_train(pad+1)=0;
            dist_prox_index=[dist_prox_index,find(bin_train==1)-pad-1];
            cross_corr(count,:)=bin_train;
            count=count+1;
        end
    end
    dist_prox_index=dist_prox_index.*si/1e3;
    bin=-20:1:20;
    histogram(dist_prox_index,bin,'Normalization','pdf','FaceColor',map(j,:),'EdgeColor','none')
    xlim([-20,20])
end
samexaxis('ytac','box','off');
xlabel('ms')
ylabel('Probability')
AxisFormat;

