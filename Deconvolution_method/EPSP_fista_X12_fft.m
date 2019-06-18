function fft_results=EPSP_fista_X12_fft(filename)
d_c=dir([filename '_EPSC_*.mat']);
d_p=dir([filename '_EPSP_*.mat']);
S_c=load(d_c(1).name);
S_p=load(d_p(1).name);
field_names={'X','Y','XpYp','XpYn'};
fft_results=struct();
fft_results.name={d_c,d_p};
color={'k','r','g','b'};
for i=1:4
    if ~isempty(fieldnames(S_c.(field_names{i})))&& ~isempty(fieldnames(S_p.(field_names{i})))
    fista=S_c.(field_names{i}).fista;
    data_c=S_c.(field_names{i}).Data(:,1);
    data_p=S_p.(field_names{i}).Data(:,1);
%     poi_c_start = S.(fieldnames{i}).poi{1}(1)*1e6/S.(fieldnames{i}).si;
%     poi_c_end = S.(fieldnames{i}).poi{1}(end)*1e6/S.(fieldnames{i}).si;
%     
%     poi_c = poi_c_start+1:poi_c_end;
    poi_c=S_c.(field_names{i}).S_period{1};
    poi_p=S_p.(field_names{i}).S_period{1};
    X1_reconstruct=conv(fista.X1,fista.template1);
    X1_reconstruct=X1_reconstruct(1:end-length(fista.template1)+1);
    X2_reconstruct=conv(fista.X2,fista.template2);
    X2_reconstruct=X2_reconstruct(1:end-length(fista.template2)+1);
    
    
    Fs_c=1e6./S_c.(field_names{i}).si;
    Fs_p=1e6./S_p.(field_names{i}).si;
    %T=1/Fs;
    L_c=length(poi_c);
    L_p=length(poi_p);
    %t=(0:L-1)*T;
    
    fft_results(i).EPSC_fft=fft(-data_c(poi_c));
    fft_results(i).EPSP_fft=fft(data_p(poi_p));
    fft_results(i).X1_fft=fft(-X1_reconstruct(poi_c));
    fft_results(i).X2_fft=fft(-X2_reconstruct(poi_c));
    switch mod(L_c,2)
        case 0
            f_c=Fs_c*(0:(L_c/2))/L_c;
        case 1
            f_c=Fs_c*(0:((L_c-1)/2))/(L_c-1);
    end
    switch mod(L_p,2)
        case 0
            f_p=Fs_p*(0:(L_p/2))/L_p;
        case 1
            f_p=Fs_p*(0:((L_p-1)/2))/(L_p-1);
    end
    
    fftA_p=zeros(1,length(f_p));
    fftP_p=zeros(1,length(f_p));
    fftA_c=zeros(3,length(f_c));
    fftP_c=zeros(3,length(f_c));
    [~,index2_c]=min(abs(f_c-2));% find x index near 2 Hz
    [~,index2_p]=min(abs(f_p-2));
    [~,index4_c]=min(abs(f_c-4));% find x index near 4 Hz
    [~,index4_p]=min(abs(f_p-4));% find x index near 4 Hz
    range_f_c=(f_c>0.2&f_c<20);
    range_f_p=(f_p>0.2&f_p<20);
    figure('units','normal','position',[0.3 0 0.5 1]);
    for k=1:4
        
        if k<2
            Y_p=fft_results(i).EPSP_fft;
            Y_label='EPSP';
            P2_p=Y_p/L_p;
            fftA_p(1,:)=abs(P2_p(1:fix(L_p/2)+1));
            fftP_p(1,:)=angle(P2_p(1:fix(L_p/2)+1));
            fftA_p(1,2:end-1)=2*fftA_p(1,2:end-1);
            fft_results(i).EPSP.power_std=std(fftA_p(1,range_f_p));
            fft_results(i).EPSP.power2Hz=fftA_p(1,index2_p);
            fft_results(i).EPSP.phase2Hz=fftP_p(1,index2_p);
            fft_results(i).EPSP.power4Hz=fftA_p(1,index4_p);
            fft_results(i).EPSP.phase4Hz=fftP_p(1,index4_p);
            
            subplot(5,1,k)
            plot(f_p,fftA_p(k,:),color{k},'LineWidth',2.5)
            ylabel(Y_label)
            AxisFormat;
        else
            
        switch k

            case 2
                Y_c=fft_results(i).EPSC_fft;
                Y_label='total EPSC';
            case 3
                Y_c=fft_results(i).X1_fft;
                Y_label='elec. EPSC';
            case 4
                Y_c=fft_results(i).X2_fft;
                Y_label='chem. EPSC';
        end
        P2_c=Y_c/L_c;
        fftA_c(k-1,:)=abs(P2_c(1:fix(L_c/2)+1));
        fftP_c(k-1,:)=angle(P2_c(1:fix(L_c/2)+1));
        fftA_c(k-1,2:end-1)=2*fftA_c(k-1,2:end-1);
        switch k
                
            case 2
                fft_results(i).EPSC.power_std=std(fftA_c(1,range_f_c));
                fft_results(i).EPSC.power2Hz=fftA_c(1,index2_c);
                fft_results(i).EPSC.phase2Hz=fftP_c(1,index2_c);
                fft_results(i).EPSC.power4Hz=fftA_c(1,index4_c);
                fft_results(i).EPSC.phase4Hz=fftP_c(1,index4_c);
            case 3
                fft_results(i).X1.power_std=std(fftA_c(2,range_f_c));
                fft_results(i).X1.power2Hz=fftA_c(2,index2_c);
                fft_results(i).X1.phase2Hz=fftP_c(2,index2_c);
                fft_results(i).X1.power4Hz=fftA_c(2,index4_c);
                fft_results(i).X1.phase4Hz=fftP_c(2,index4_c);
            case 4
                fft_results(i).X2.power_std=std(fftA_c(3,range_f_c));
                fft_results(i).X2.power2Hz=fftA_c(3,index2_c);
                fft_results(i).X2.phase2Hz=fftP_c(3,index2_c);
                fft_results(i).X2.power4Hz=fftA_c(3,index4_c);
                fft_results(i).X2.phase4Hz=fftP_c(3,index4_c);
        end
        subplot(5,1,k)
        plot(f_c,fftA_c(k-1,:),color{k},'LineWidth',2.5)
        ylabel(Y_label)
        AxisFormat; 
        end
    end
    subplot(5,1,5)
    scatter(f_p([index2_p,index4_p]),[fft_results(i).EPSP.phase2Hz,fft_results(i).EPSP.phase4Hz],28,color{1},'filled')
    hold on;
    scatter(f_c([index2_c,index4_c]),[fft_results(i).EPSC.phase2Hz,fft_results(i).EPSC.phase4Hz],28,color{2},'filled')
    scatter(f_c([index2_c,index4_c]),[fft_results(i).X1.phase2Hz,fft_results(i).X1.phase4Hz],28,color{3},'filled')
    scatter(f_c([index2_c,index4_c]),[fft_results(i).X2.phase2Hz,fft_results(i).X2.phase4Hz],28,color{4},'filled')
    hold off;
    ylim([-pi pi])
    ylabel('Phase')
    %ylim([0 3])
    xlabel('f (Hz)')
    samexaxis('ytac','join','box','off');
    xlim([0.5 20])
    AxisFormat;
    print([field_names{i} '_fft.jpg'],'-r300','-djpeg')
    end
end
end