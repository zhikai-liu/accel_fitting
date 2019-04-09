function process_fista_X12_fft(filename)
S=load(filename);
fieldnames={'X','Y','XpYp','XpYn'};
for i=1:4
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
    T=1/Fs;
    L=length(poi_c);
    %t=(0:L-1)*T;
    
    raw_fft=fft(data_c(poi_c));
    X1_fft=fft(X1_reconstruct(poi_c));
    X2_fft=fft(X2_reconstruct(poi_c));
    switch mod(L,2)
        case 0
            f=Fs*(0:(L/2))/L;
        case 1
            f=Fs*(0:((L-1)/2))/(L-1);
    end
    P1=zeros(3,length(f));
    figure('units','normal','position',[0.3 0 0.5 1]);
    for k=1:3
        switch k
            case 1
                Y=raw_fft;
                Y_label='total EPSC';
            case 2
                Y=X1_fft;
                Y_label='elec. EPSC';
            case 3
                Y=X2_fft;
                Y_label='chem. EPSC';
        end
        P2=abs(Y/L);
        switch mod(L,2)
            case 0
                P1(k,:)=P2(1:L/2+1);
            case 1
                P1(k,:)=P2(1:L/2+1/2);
        end
        P1(k,2:end-1)=2*P1(k,2:end-1);
        subplot(4,1,k)
        plot(f,P1(k,:),'k','LineWidth',2.5)
        ylabel(Y_label)
        AxisFormat; 
    end
    [~,index2]=min(abs(f-2));
    [~,index4]=min(abs(f-4));
    subplot(4,1,4)
    bar([2 4],...
        [sum(P1(3,index2-1:index2+1))./sum(P1(2,index2-1:index2+1)),...
        sum(P1(3,index4-1:index4+1))./sum(P1(2,index4-1:index4+1))])
    ylabel('X2/X1')
    ylim([0 3])
    xlabel('f (Hz)')
    samexaxis('ytac','join','box','off');
    xlim([0 20])
    AxisFormat;
end
end