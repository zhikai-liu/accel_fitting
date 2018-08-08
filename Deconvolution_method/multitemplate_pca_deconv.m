function [coeff_pca,multi_template]=multitemplate_pca_deconv(S,s_data)
% %% Extract 3 PCA components as 3 templates for deconvolution
% all_template=S.all_template;
% [coeff_pca,~,latent] = pca(all_template(:,:)');
% template_num=3;
% map=colormap(jet(template_num));
% multi_template=struct();

%% Use given templates
template_num=2;
map=colormap(jet(template_num));
multi_template=struct();
coeff_pca=[S.template1,S.template2];
%% Plot 3 PCA components
figure;
for i=1:template_num
subplot(template_num+1,1,i)
plot(coeff_pca(:,i),'color',map(i,:))
end 
samexaxis('ytac','join','box','off');

%% Calculate coefficients for each template which result in least square root error between real and constructed signal 
coeff_multi=coeff_multi_template(s_data,coeff_pca(:,1:template_num),S.LM);

%% Plot the deconv traces for three templates and compare it with the real signal
figure;
for i=1:template_num
    multi_template(i).model_T=coeff_pca(:,i);
    multi_template(i).coeff_delta=coeff_multi(:,i);
    [multi_template(i).D,multi_template(i).D_fs]=signal_deconv(s_data, multi_template(i).model_T,5e4,0,2000);
    multi_template(i).D_re=zeros(length(s_data),1);
    multi_template(i).D_re(S.LM)=multi_template(i).coeff_delta;
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

%% Reconstruct signal by summing the results of each templates
% multi_signal_re=sum([multi_template(1).signal_re,multi_template(2).signal_re,multi_template(3).signal_re],2);
multi_signal_re=sum([multi_template(1).signal_re,multi_template(2).signal_re],2);% Two templates

%% Instead of the whole trace, calculate the signal for each individual event separately
% ind_event=multi_template(1).coeff_delta*multi_template(1).model_T'+multi_template(2).coeff_delta*multi_template(2).model_T'+multi_template(3).coeff_delta.*multi_template(3).model_T';
ind_event=multi_template(1).coeff_delta*multi_template(1).model_T'+multi_template(2).coeff_delta*multi_template(2).model_T';

%% Plot to compare real signal/reconstructed signal/each individual reconstructed event
figure;
subplot(2,1,1)
plot(s_data,'k')
hold on;

event_l=size(ind_event,2);
for i=1:length(S.LM)
    plot(S.LM(i):S.LM(i)+event_l-1,ind_event(i,:))
end
hold off;
title('Multi-template reconstructed signal')
subplot(2,1,2)
plot(s_data,'k')
hold on;
plot(multi_signal_re,'r')
hold off;
samexaxis('ytac','join','box','off');
end