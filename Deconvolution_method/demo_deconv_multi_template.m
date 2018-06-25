% load('all_events.mat');
% data=S.Data;
load('all_traces_padded.mat');
data=data_pad';
%% calculate the template for single EPSC
load('template2.mat');
load('EPSC_templates.mat');
%f=fit([1:length(t)-36]',t(37:end),'exp2'); %model the falling phase with double exponential
%model_T=-[t(1:75);f(105:1000)]; 
%% model_T=t(1:75);
model_T=fast_EPSC';
%model_T=slow_EPSC';
s_data=smooth(data-mean(data));
% s_data=diff(s_data);
% model_T=diff(model_T);
[results,count]=deconv_iterative(s_data,model_T);
%% Use the least square root error round (count-1) for later analysis
D=results(count-1).D;
D_fs=results(count-1).D_fs;
model_T=results(count-1).model_T;
penalty=[results(:).penalty];
LM=results(count-1).LM;
LM_l=[results(:).LM_l];
LM_Y=results(count-1).LM_Y;
D_re=results(count-1).D_re;
signal_re=results(count-1).signal_re;
%% Plot penalty cost for each iteration
figure;
plot(penalty)
title('Penalty vs iteration');
figure;
plot(LM_l)
title('Event number vs iteration');
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
clust=struct();
for i=1:clust_num
    clust(i).LM=LM(clust_index==i);
end

%% Plot the results

%plot the signal and reconstructed signal
figure;
subplot(2,1,1);
plot(s_data)
hold on;
plot(signal_re);
%scatter(LM,LM_Y)
scatter(LM,s_data(LM))
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
    subplot(clust_num,2,2*j-1)
    c_LM=clust(j).LM;
    ISI=diff(c_LM).*si.*1e-3;
    c_xdata_1=c_LM([ISI;10]<2);
    c_xdata_2=c_LM([10;ISI]<2);
    c_xdata_3=c_LM([ISI;10]>2&[10;ISI]>2);
    hold on;
    for i=1:length(c_xdata_1)
         y_data=s_data(c_xdata_1(i)-200:c_xdata_1(i)+200);
         plot(y_data,'r');
         ylim([min(s_data) max(s_data)])
    end
    hold off;
    subplot(clust_num,2,2*j)
    hold on;
    for i=1:length(c_xdata_3)
         y_data=s_data(c_xdata_3(i)-200:c_xdata_3(i)+200);
         plot(y_data,'k');
         ylim([min(s_data) max(s_data)])
    end
    hold off;
end
%samexaxis('ytac','box','off');

%Plotting corrolegram
figure;
subplot_num=1;
for j=1:clust_num
    spikes_j=zeros(1,max(LM)+2*pad);
    spikes_j(clust(j).LM+pad)=1;
    for i=1:clust_num 
        spikes_i=zeros(1,max(LM)+2*pad);
        spikes_i(clust(i).LM+pad)=1;
        dist_prox_index=[];
        for k=1:length(spikes_j)
            if spikes_j(k)==1
                bin_train=spikes_i(k-pad:k+pad);
                bin_train(pad+1)=0;
                dist_prox_index=[dist_prox_index,find(bin_train==1)-pad-1];
            end
        end
        dist_prox_index=dist_prox_index.*si/1e3;
        bin=-20:1:20;
        subplot(clust_num,clust_num,subplot_num)
        if i==j
            map_color=map(j,:);
        else
            map_color=[0.3 0.3 0.3];
        end
        histogram(dist_prox_index,bin,'Normalization','pdf','FaceColor',map_color,'EdgeColor','none')
        xlim([-20,20])
        subplot_num=subplot_num+1;
    end
end
%samexaxis('ytac','box','off');
xlabel('ms')
ylabel('Probability')
%AxisFormat;


%% Multiple template analysis
% if count-1>1
%     multitemplate_pca_deconv(results(count-1),s_data);
% end

%Plot clustering results with template deconvolved scores
% figure;
% hold on;
% for i = 1:clust_num
%     inds=LM(clust_index==i);
%     scatter3(multi_template(1).D_fs(inds),multi_template(2).D_fs(inds),multi_template(3).D_fs(inds),'MarkerEdgeColor',map(i,:));
% end

%Plot clustering results with recontruction coefficient
% figure;
% hold on;
% for i = 1:clust_num
%     inds=find(clust_index==i);
%     scatter3(multi_template(1).coeff_delta(inds),multi_template(2).coeff_delta(inds),multi_template(3).coeff_delta(inds),'MarkerEdgeColor',map(i,:));
% end

