% load('all_events.mat');
% data=S.Data;
load('all_traces_padded.mat');
data=data_pad';
%% calculate the template for single EPSC
load('template2.mat');
%f=fit([1:length(t)-36]',t(37:end),'exp2'); %model the falling phase with double exponential
%model_T=-[t(1:75);f(105:1000)]; 
model_T=t(1:75);
s_data=data-mean(data);
results=struct();
%model_T=t;
%% calculate the deconvolved signal
count=1;
results(count).model_T=model_T;

while 1
    [results(count).D,results(count).D_fs]=signal_deconv(s_data,results(count).model_T,5e4,0,2000);
    results(count).LM=get_local_maxima_above_threshold(results(count).D_fs,3.5*std(results(count).D_fs),1);
    
    results(count).LM=results(count).LM(results(count).LM+8<=length(s_data)&results(count).LM-8>=0); %delete events that is at the edge of trace, edge is defined as 8 points away from the start or the end of trace

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

    results(count+1).model_T=mean(all_template,2);
    results(count+1).all_template=all_template;
    plot(results(count+1).model_T,'k','LineWidth',5)
    hold off;
    
    %% clustering templates
    [~,score,~,~,~] = pca(all_template(1:500,:)');
    clust_index=isosplit5(score(:,1:3)');
    results(count+1).template_cluster=clust_index;
    clust_num=max(clust_index);
    map=colormap(jet(clust_num));
    
    figure;
    subplot(3,1,1)
    hold on;
    for i = 1:clust_num
        inds=find(clust_index==i);
        scatter3(score(inds,1),score(inds,2),score(inds,3),'MarkerEdgeColor',map(i,:));
    end
    hold off;
    subplot(3,1,2)
    hold on;
    for i=1:length(long_single_events)
        plot(all_template(:,i),'color',map(clust_index(i),:))
    end
    hold off;
    subplot(3,1,3)
    hold on;
    for i = 1:clust_num
        plot(mean(all_template(:,clust_index==i),2),'color',map(i,:),'LineWidth',5)
    end
    hold off;
    
        %% Reconstruct the signal from the deconvolution trace
    results(count).D_re=zeros(length(results(count).D_fs),1);
    %D_re(LM)=D(LM);
    
    results(count).coeff_delta=coeff_delta_signal(s_data,results(count).model_T,results(count).LM);% get coeff of the delta function, that minimize the least square root error
    
    results(count).coeff_delta=coeff_delta_signal(s_data,results(count).model_T,results(count).LM);
    results(count).LM=results(count).LM(results(count).coeff_delta>0);% elminate some events that are in the oppose direction of template but still picked up
    results(count).D_re(results(count).LM)=results(count).coeff_delta(results(count).coeff_delta>0);
    results(count).LM_Y=s_data(results(count).LM);
    results(count).signal_fft_re=fft(results(count).D_re).*fft(results(count).model_T,size(s_data,1));
    results(count).signal_re=real(ifft(results(count).signal_fft_re));
    results(count).penalty=(results(count).signal_re-s_data)'*(results(count).signal_re-s_data); % penalty function used for later if iteration is needed to improve peformance
    if count>2
        if results(count-1).penalty-results(count).penalty<1000
            break
        end
    end
    count=count+1;
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

function coeff=coeff_multi_template(data,kernels,timepoint)

    %% This function is solving a series of equations, here the example is three: 
    %M11*A+M12*B+M13*C=Y1
    %M21*A+M22*B+M23*C=Y2
    %M31*A+M32*B+M33*C=Y3
    
    k_n=size(kernels,2);
    k_l=size(kernels,1);
    t_l=length(timepoint);
    ij_lookup=cell(k_n);
    M=cell(k_n);
    %% First calculate a lookup sheet for matrix M
    for m=1:size(ij_lookup,1)
        for n=1:size(ij_lookup,2)
            ij_lookup{m,n}=zeros(k_l,1); 
            for i=1:k_l % here, i-1 is the difference between ij for later
                %ij_lookup(1) means delta_ij is zero, ij_lookup(k_l) means delta_ij is k_l-1;
                ij_lookup{m,n}(i)=kernels(1:k_l-i+1,m)'*kernels(i:k_l,n);
                % in the lookup sheet, kernel n is always before kernel m
                % on the timeline
            end
        end
    end
    %% Fill M with value based on the lookup sheet
    for m=1:size(M,1)
        for n=1:size(M,2)
             M{m,n}=zeros(t_l);
            for i=1:t_l
                for j=1:t_l
                    if abs(timepoint(i)-timepoint(j))<k_l
                        if timepoint(i)>timepoint(j) %is this larger or smaller?
                            M{m,n}(i,j)=ij_lookup{m,n}(timepoint(i)-timepoint(j)+1);
                        else
                            M{m,n}(i,j)=ij_lookup{n,m}(timepoint(j)-timepoint(i)+1);
                        end
                    end
                end
            end
        end
    end
    %% Calculate the vector Y
    Y=cell(k_n,1);
    for m=1:k_n
        Y{m}=zeros(t_l,1);
        for i=1:t_l
            if timepoint(i)+k_l<=length(data)
                Y{m}(i)=data(timepoint(i)+1:timepoint(i)+k_l)'*kernels(:,m);
            else
                Y{m}(i)=data(timepoint(i)+1:end)'*kernels(1:length(data)-timepoint(i),m);
            end
        end
    end
    %% The series of equations can also be presented as:
    % M11, M12, M13   A   Y1
    %(M21, M22, M23)*(B)=(Y2)
    % M31, M32, M33   C   Y3
    %% in which the question will be simplified as M*X=Y
    M_all=zeros(k_n*t_l);
    for m=1:size(M,1)
        for n=1:size(M,2)
            M_all(t_l*(m-1)+1:t_l*m,t_l*(n-1)+1:t_l*n)=M{m,n};
        end
    end
    Y_all=zeros(k_n*t_l,1);
    for m=1:k_n
        Y_all(t_l*(m-1)+1:t_l*m,1)=Y{m,1};
    end
    coeff=M_all\Y_all;
    coeff=reshape(coeff,t_l,k_n);
end