% load('all_events.mat');
% data=S.Data;
load('all_traces_padded.mat');
data=data_pad';
%% calculate the template for single EPSC
load('template2.mat');
%f=fit([1:length(t)-36]',t(37:end),'exp2'); %model the falling phase with double exponential
%model_T=-[t(1:75);f(105:1000)]; 
model_T=t(1:75);
results=deconv_iterative(data,model_T);
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


if count-1>1
%% Multiple template analysis
all_template=results(count-1).all_template;
coeff_pca = pca(all_template(1:500,:)');
LM_for_fit=LM;
coeff_multi=coeff_multi_template(s_data,coeff_pca(:,1:3),LM_for_fit);%calculate least square root coefficients for each template

template_num=3;
map=colormap(jet(template_num));
multi_template=struct();
figure;
for i=1:template_num
subplot(template_num+1,1,i)
plot(coeff_pca(:,i),'color',map(i,:))
end 
samexaxis('ytac','join','box','off');
figure;
for i=1:template_num
    multi_template(i).model_T=coeff_pca(:,i);
    multi_template(i).coeff_delta=coeff_multi(:,i);
    [multi_template(i).D,multi_template(i).D_fs]=signal_deconv(s_data, multi_template(i).model_T,5e4,0,2000);
    multi_template(i).D_re=zeros(length(s_data),1);
    multi_template(i).D_re(LM_for_fit)=multi_template(i).coeff_delta;
    multi_template(i).signal_fft_re=fft(multi_template(i).D_re).*fft(multi_template(i).model_T,size(s_data,1));
    multi_template(i).signal_re=real(ifft(multi_template(i).signal_fft_re));
    %multi_template(i).LM=get_local_maxima_above_threshold(multi_template(i).D_fs,3.5*std(multi_template(i).D_fs),1);  
    %multi_template(i).LM=multi_template(i).LM(multi_template(i).LM+8<=length(s_data)&multi_template(i).LM-8>=0); %delete events that is at the edge of trace, edge is defined as 8 points away from the start or the end of trace
    subplot(template_num+1,1,i)
    plot(multi_template(i).D_fs)
%     hold on;
%     scatter(multi_template(i).LM,multi_template(i).D_fs(multi_template(i).LM),'MarkerEdgeColor',map(i,:))
%     hold off;
end
subplot(template_num+1,1,template_num+1)
plot(s_data);
samexaxis('ytac','join','box','off');
multi_signal_re=sum([multi_template(1).signal_re,multi_template(2).signal_re,multi_template(3).signal_re],2);
figure;
plot(s_data,'k')
hold on;
plot(multi_signal_re,'r')
hold off;
title('Multi-template reconstructed signal')




% figure;
% plot3(1:length(s_data),multi_template(1).D_fs,multi_template(2).D_fs)
% hold on;
% scatter3(LM,multi_template(1).D_fs(LM),multi_template(2).D_fs(LM),'r')
% hold off;
end

%% Plot penalty cost for each iteration
figure;
plot(penalty)



%% Collect a short length of the deconvolved signal at the local maxima


event_D=D_fs(LM);
for i=1:10
    event_D=[D_fs(LM-i),event_D,D_fs(LM+i)];
end
%% Plot the results

%plot the signal and reconstructed signal
figure;
subplot(2,1,1);
plot(s_data)
hold on;
plot(signal_re);
scatter(LM,LM_Y)
subplot(2,1,2)
plot(D_fs)
Q=D_fs(LM);
hold on;
scatter(LM,Q)
samexaxis('ytac','join','box','off');



%% clustering
[~,score,~,~,explained] = pca(event_D);
opts.isocut_threshold=1;
clust_index=isosplit5(score(:,1:3)',opts);
clust_num=max(clust_index);
map=colormap(jet(clust_num));

%% Plot clustering results
figure;
hold on;
for i = 1:clust_num
    inds=find(clust_index==i);
    scatter3(score(inds,1),score(inds,2),score(inds,3),'MarkerEdgeColor',map(i,:));
end


%% Plot clustering results with template deconvolved scores
figure;
hold on;
for i = 1:clust_num
    inds=LM(clust_index==i);
    scatter3(multi_template(1).D_fs(inds),multi_template(2).D_fs(inds),multi_template(3).D_fs(inds),'MarkerEdgeColor',map(i,:));
end

%% Plot clustering results with recontruction coefficient
figure;
hold on;
%scatter3(multi_template(1).coeff_delta,multi_template(2).coeff_delta,multi_template(3).coeff_delta,'MarkerEdgeColor','k')
for i = 1:clust_num
    inds=find(clust_index==i);
    scatter3(multi_template(1).coeff_delta(inds),multi_template(2).coeff_delta(inds),multi_template(3).coeff_delta(inds),'MarkerEdgeColor',map(i,:));
end





figure;
hold on;
for i=1:length(LM)
    plot(event_D(i,:),'Color',map(clust_index(i),:))
end

%% Plotting corrolegram
si=20;
figure;
pad=100*1e3/si;%pad length is 100ms

for j=1:clust_num
    cross_corr=zeros(sum(clust_index==j),2*pad+1);
    count=1;
    subplot(clust_num,1,j)
    c_xdata=LM(clust_index==j);
    spikes=zeros(1,max(c_xdata)+2*pad);
    spikes(c_xdata+pad)=1;
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
    %ylim([0 0.6])
    AxisFormat;
end
samexaxis('ytac','box','off');
xlabel('ms')
ylabel('Probability')
AxisFormat;

function AxisFormat()
    A=gca;
    set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
    set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',1.2,'Color','k');
    set(A,'box','off')
end

