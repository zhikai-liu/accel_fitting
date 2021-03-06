function process_fista_2vs4Hz_scatter(filename)
D=dir([filename '*.mat']);
% figure('units','normal','position',[0.3 0 0.5 1]);
% hold on
fft_results=struct();
cross_corr=struct();
%% Design a low pass filter
nfilt=34;
Fst=5;
F_s=5e4;
lp_filter=designfilt('lowpassfir','FilterOrder',nfilt,'CutoffFrequency',Fst,'SampleRate',F_s);
%grpdelay(d,N,Fs);
delay = mean(grpdelay(lp_filter));

%% fft analysis
for d=1:length(D)
    S=load(D(d).name);
    fieldnames={'X','Y','XpYp','XpYn'};
%     color={'r','g','b','k'};
    for i=1:4
        if isfield(S.(fieldnames{i}),'fista')
            fista=S.(fieldnames{i}).fista;
            
            data_c=S.(fieldnames{i}).Data(:,1);
            %     poi_c_start = S.(fieldnames{i}).poi{1}(1)*1e6/S.(fieldnames{i}).si;
            %     poi_c_end = S.(fieldnames{i}).poi{1}(end)*1e6/S.(fieldnames{i}).si;
            %
            %     poi_c = poi_c_start+1:poi_c_end;
            poi_c=S.(fieldnames{i}).S_period{1};
            X1_reconstruct=conv(fista.X1,fista.template1);
            X1_reconstruct=X1_reconstruct(1:end-length(fista.template1)+1);
            X2_reconstruct=conv(fista.X2,fista.template2);
            X2_reconstruct=X2_reconstruct(1:end-length(fista.template2)+1);
            
            Fs=1e6./S.(fieldnames{i}).si;
            %T=1/Fs;
            L=length(poi_c);
            %t=(0:L-1)*T;
            
            raw_fft=fft(data_c(poi_c));
            X1_fft=fft(X1_reconstruct(poi_c));
            X2_fft=fft(X2_reconstruct(poi_c));

%             X1_lp=filter(lp_filter,X1_reconstruct(poi_c));
%             X2_lp=filter(lp_filter,X2_reconstruct(poi_c));
            
            X1_lp=X1_reconstruct(poi_c);
            X2_lp=X2_reconstruct(poi_c);
            [cross_corr(d,i).corr,cross_corr(d,i).lag]=xcorr(X1_lp,X2_lp);
            
            
            switch mod(L,2)
                case 0
                    f=Fs*(0:(L/2))/L;
                case 1
                    f=Fs*(0:((L-1)/2))/(L-1);
            end
            P1=zeros(3,length(f));
            P1_phase=zeros(3,length(f));
            [~,index2]=min(abs(f-2));
            [~,index4]=min(abs(f-4));
            for k=1:3
                switch k
                    case 1
                        Y=raw_fft;
                        %Y_label='total EPSC';
                    case 2
                        Y=X1_fft;
                        %Y_label='elec. EPSC';
                    case 3
                        Y=X2_fft;
                        %Y_label='chem. EPSC';
                end
                P2=Y/L;
                P1(k,:)=abs(P2(1:fix(L/2)+1));
                P1_phase(k,:)=angle(P2(1:fix(L/2)+1));
                P1(k,2:end-1)=2*P1(k,2:end-1);
                fft_results(d,i,k).fft=P1(k,:);
                fft_results(d,i,k).index2a=P1(k,index2);
                fft_results(d,i,k).index2=index2;
                fft_results(d,i,k).index4a=P1(k,index4);
                fft_results(d,i,k).index2p=P1_phase(k,index2);
                fft_results(d,i,k).index4=index4;
                fft_results(d,i,k).index4p=P1_phase(k,index4);
                %         subplot(4,1,k)
                %         plot(f,P1(k,:),'k','LineWidth',2.5)
                %         ylabel(Y_label)
                %         AxisFormat;
            end
            
            
%             scatter(fft_results(d,i,3).index2a./fft_results(d,i,2).index2a,...
%                 fft_results(d,i,3).index4a./fft_results(d,i,2).index4a,28,color{i})
            %     ylabel('X2/X1')
            %     ylim([0 3])
            %     xlabel('f (Hz)')
            %     samexaxis('ytac','join','box','off');
            %     xlim([0 20])
        else
            warning(['No fista: ' D(d).name fieldnames{i}])
            for k=1:3
                fft_results(d,i,k).fft=nan;
                fft_results(d,i,k).index2a=nan;
                fft_results(d,i,k).index2=nan;
                fft_results(d,i,k).index4a=nan;
                fft_results(d,i,k).index2p=nan;
                fft_results(d,i,k).index4=nan;
                fft_results(d,i,k).index4p=nan;
            end
        end
    end
end
% AxisFormat;
% xlabel('2 Hz')
% ylabel('4 Hz')
% axis square
% title('chem./elec.')
save('fft_results.mat','fft_results','cross_corr')
end