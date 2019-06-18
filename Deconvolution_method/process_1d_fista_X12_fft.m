function fft_results=process_1d_fista_X12_fft(filename)
d_c=dir([filename '*.mat']);

fft_results=struct();
fft_results.name={d_c};
color={'r','g','b'};
for i=1:length(d_c)
    S_c=load(d_c(i).name);
    if isfield(S_c,'fista')
    fista=S_c.fista;
    data_c=S_c.Data(:,1);
    
    poi_c=S_c.S_period{1};

    X1_reconstruct=conv(fista.X1,fista.tempate1);
    X1_reconstruct=X1_reconstruct(1:end-length(fista.tempate1)+1);
    X2_reconstruct=conv(fista.X2,fista.tempate2);
    X2_reconstruct=X2_reconstruct(1:end-length(fista.tempate2)+1);
    
    
    Fs_c=1e6./S_c.si;

    L_c=length(poi_c);

    %t=(0:L-1)*T;
    
    fft_results(i).EPSC_fft=fft(-data_c(poi_c));

    fft_results(i).X1_fft=fft(-X1_reconstruct(poi_c));
    fft_results(i).X2_fft=fft(-X2_reconstruct(poi_c));
    switch mod(L_c,2)
        case 0
            f_c=Fs_c*(0:(L_c/2))/L_c;
        case 1
            f_c=Fs_c*(0:((L_c-1)/2))/(L_c-1);
    end


    fftA_c=zeros(3,length(f_c));
    fftP_c=zeros(3,length(f_c));
    stim_freq=round(S_c.fit_freq{1},1);
    stim_amp=round(S_c.fit_amp{1},2);
    [~,index1sf_c]=min(abs(f_c-stim_freq));% find x index near stimulus frequency
    range_f_c=(f_c>0.2&f_c<20);
    [~,index2sf_c]=min(abs(f_c-stim_freq*2));% find x index near 2 times of stimulus frequency
    figure('units','normal','position',[0.3 0 0.5 1]);
    for k=1:3
    
        switch k

            case 1
                Y_c=fft_results(i).EPSC_fft;
                Y_label='total EPSC';
            case 2
                Y_c=fft_results(i).X1_fft;
                Y_label='elec. EPSC';
            case 3
                Y_c=fft_results(i).X2_fft;
                Y_label='chem. EPSC';
        end
        P2_c=Y_c/L_c;
        fftA_c(k,:)=abs(P2_c(1:fix(L_c/2)+1));
        fftP_c(k,:)=angle(P2_c(1:fix(L_c/2)+1));
        fftA_c(k,2:end-1)=2*fftA_c(k,2:end-1);
        switch k
                
            case 1
                fft_results(i).EPSC.power_std=std(fftA_c(1,range_f_c));
                fft_results(i).EPSC.power1sf=fftA_c(1,index1sf_c);
                fft_results(i).EPSC.phase1sf=fftP_c(1,index1sf_c);
                fft_results(i).EPSC.power2sf=fftA_c(1,index2sf_c);
                fft_results(i).EPSC.phase2sf=fftP_c(1,index2sf_c);
                
            case 2
                fft_results(i).X1.power_std=std(fftA_c(2,range_f_c));
                fft_results(i).X1.power1sf=fftA_c(2,index1sf_c);
                fft_results(i).X1.phase1sf=fftP_c(2,index1sf_c);
                fft_results(i).X1.power2sf=fftA_c(2,index2sf_c);
                fft_results(i).X1.phase2sf=fftP_c(2,index2sf_c);
                
            case 3
                fft_results(i).X2.power_std=std(fftA_c(3,range_f_c));
                fft_results(i).X2.power1sf=fftA_c(3,index1sf_c);
                fft_results(i).X2.phase1sf=fftP_c(3,index1sf_c);
                fft_results(i).X2.power2sf=fftA_c(3,index2sf_c);
                fft_results(i).X2.phase2sf=fftP_c(3,index2sf_c);
        end
        fft_results(i).stim_freq=stim_freq;
        fft_results(i).stim_amp=stim_amp;
        subplot(4,1,k)
        plot(f_c,fftA_c(k,:),color{k},'LineWidth',2.5)
        if k==1
        title(d_c(i).name(1:end-4),'interpreter','none')
        end
        ylabel(Y_label)
        AxisFormat; 
    end
    subplot(4,1,4)
    hold on;
    scatter(f_c([index1sf_c,index2sf_c]),[fft_results(i).EPSC.phase1sf,fft_results(i).EPSC.phase2sf],28,color{1},'filled')
    scatter(f_c([index1sf_c,index2sf_c]),[fft_results(i).X1.phase1sf,fft_results(i).X1.phase2sf],28,color{2},'filled')
    scatter(f_c([index1sf_c,index2sf_c]),[fft_results(i).X2.phase1sf,fft_results(i).X2.phase2sf],28,color{3},'filled')
    hold off;
    ylim([-pi pi])
    ylabel('Phase')
    %ylim([0 3])
    xlabel('f (Hz)')
    samexaxis('ytac','join','box','off');
    xlim([stim_freq*0.5 stim_freq*5])
    AxisFormat;
    print([d_c(i).name(1:end-4) '_fft.jpg'],'-r300','-djpeg')
    end
end
end