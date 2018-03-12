% load('all_events.mat');
% data=S.Data;
load('all_traces_padded.mat');
data=data_pad';
%% calculate the template for single EPSC
load('template2.mat');
f=fit([1:length(t)-36]',t(37:end),'exp2'); %model the falling phase with double exponential
model_T=[t(1:75);f(105:1000)]; 
s_data=smooth(data-mean(data));
results=struct();
%model_T=t;
%% calculate the deconvolved signal
count=1;
results(count).model_T=model_T;

while 1
    [results(count).D,results(count).D_fs]=signal_deconv(s_data,results(count).model_T,5e4,50,2000);
    results(count).LM=get_local_maxima_above_threshold(results(count).D_fs,3.5*std(results(count).D_fs),1);
    
    results(count).LM=results(count).LM(results(count).LM+8<=length(s_data)&results(count).LM-8>=0); %delete events that is at the edge of trace
    
    
   
    %% Reconstruct the signal from the deconvolution trace
    results(count).D_re=zeros(length(results(count).D_fs),1);
    %D_re(LM)=D(LM);
    
    results(count).coeff_delta=coeff_delta_signal(s_data,results(count).model_T,results(count).LM);% get coeff of the delta function, that minimize the least square root error
    results(count).LM=results(count).LM(results(count).coeff_delta>0);% elminate some events that are in the oppose direction of template but still picked up
    results(count).D_re(results(count).LM)=results(count).coeff_delta(results(count).coeff_delta>0);
    results(count).LM_Y=s_data(results(count).LM);
    results(count).signal_re=fft(results(count).D_re).*fft(results(count).model_T,size(s_data,1));
    
    results(count).penalty=(results(count).signal_re-s_data)'*(results(count).signal_re-s_data); % penalty function used for later if iteration is needed to improve peformance
    if count>1
        if results(count-1).penalty-results(count).penalty<1000
            break
        end
    end
%     %% Only use the given template
%     if count==1
%         count=count+1;
%         break;
%     end
%     
   
    %% Find single event that is temporally isolated from other events and use their average as the next template
    inter_LM=diff(results(count).LM);
    long_single_events=results(count).LM(inter_LM>1000&[0;inter_LM(1:end-1)]>200);
    all_template=zeros(520,length(long_single_events));
    figure;
    hold on;
    for i=1:length(long_single_events)
        all_template(:,i)=s_data(long_single_events(i)-20:long_single_events(i)+499)-mean(s_data(long_single_events(i)-30:long_single_events(i)-20));
        plot(all_template(:,i),'color',[0.3,0.3,0.3])
    end
    count=count+1;
    results(count).model_T=mean(all_template,2);
    plot(results(count).model_T,'k','LineWidth',5)
    hold off;
    
    %% clustering
    [~,score,~,~,~] = pca(all_template(1:120,:)');
    clust_index=isosplit5(score(:,1:3)');
    clust_num=max(clust_index);
    map=colormap(jet(clust_num));
    
    figure;
    subplot(2,1,1)
    hold on;
    for i = 1:clust_num
        inds=find(clust_index==i);
        scatter3(score(inds,1),score(inds,2),score(inds,3),'MarkerEdgeColor',map(i,:));
    end
    hold off;
    subplot(2,1,2)
    hold on;
    for i=1:length(long_single_events)
        plot(all_template(:,i),'color',map(clust_index(i),:))
    end
    hold off;
    
end


%% Use the least square root error round for later analysis
D=results(count-1).D;
D_fs=results(count-1).D_fs;
model_T=results(count-1).model_T;
penalty=[results(:).penalty];
LM=results(count-1).LM;
LM_Y=results(count-1).LM_Y;
D_re=results(count-1).D_re;
signal_re=results(count-1).signal_re;



%% Plot penalty cost for each iteration
figure;
plot(penalty)



%% Collect a short length of the deconvolved signal at the local maxima
event_D=D_fs(LM);
for i=1:8
    event_D=[D_fs(LM-i),event_D,D_fs(LM+i)];
end
%% Plot the results

%plot the signal and reconstructed signal
figure;
subplot(2,1,1);
plot(s_data)
hold on;
plot(real(ifft(signal_re)));
scatter(LM,LM_Y)
subplot(2,1,2)
plot(D_fs)
Q=D_fs(LM);
hold on;
scatter(LM,Q)
samexaxis('ytac','join','box','off');



%% clustering
[coeff,score,latent,~,explained] = pca(event_D);
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
        for k=1:length(spikes)
            if spikes(k)==1
                bin_train=spikes(k-pad:k+pad);
                bin_train(pad+1)=0;
                cross_corr(count,:)=bin_train;
                count=count+1;
            end
        end

    corr=sum(cross_corr);
    box=1e3/si;
    corr_ms=zeros(1,2*pad/box);
    for i=1:length(corr_ms)/2
        ms_range=1+box*(i-1):box*i;
        corr_ms(i)=sum(corr(ms_range));
    end
    bar(-pad/box:-1,corr_ms(1:pad/box),'FaceColor',map(j,:),'EdgeColor',map(j,:))
    hold on;
    for i=1+length(corr_ms)/2:length(corr_ms)
        ms_range=2+box*(i-1):1+box*i;
        corr_ms(i)=sum(corr(ms_range));
    end
    bar(1:pad/box,corr_ms(1+pad/box:end),'FaceColor',map(j,:),'EdgeColor',map(j,:))
    hold off;
end


function coeff=coeff_delta_signal(data,kernel,timepoint)

    %% This function is solving an equation: M*x=b
    k_l=length(kernel);
    t_l=length(timepoint);
    ij_lookup=zeros(k_l,1); 
    %% First calculate a lookup sheet for matrix M
    for i=1:k_l % here, i-1 is the difference between ij for later
        %ij_lookup(1) means delta_ij is zero, ij_lookup(k_l) means delta_ij is k_l-1;
        ij_lookup(i)=kernel(1:k_l-i+1)'*kernel(i:k_l);
    end
    %% Fill M with value based on the lookup sheet
    M=zeros(t_l);
    for i=1:t_l
        for j=1:t_l
            if abs(timepoint(i)-timepoint(j))<k_l
            M(i,j)=ij_lookup(abs(timepoint(i)-timepoint(j))+1);
            end
        end
    end
    %% Calculate the vector B
    B=zeros(t_l,1);
    for i=1:length(B)
        if timepoint(i)+k_l<=length(data)
            B(i)=data(timepoint(i)+1:timepoint(i)+k_l)'*kernel;
        else
            B(i)=data(timepoint(i)+1:end)'*kernel(1:length(data)-timepoint(i));
        end
    end   
    coeff=M\B;
end