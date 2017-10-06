function plot_ampbins_bode(filename)
    H=load(filename);
    S=struct();
    FNames=fieldnames(H);
    count=1;

    for i=1:length(FNames)
        Freq_FNames=fieldnames(H.(FNames{i}));
        S_freq=zeros(1,length(Freq_FNames));
        freq_gain=zeros(1,length(Freq_FNames));
        freq_phase=zeros(1,length(Freq_FNames));
        ampbin_num=length(H.(FNames{i})(1).(Freq_FNames{1})(1).AmpBins);
        for j=1:ampbin_num
            for k=1:length(Freq_FNames)
                S_freq(k)=mean([H.(FNames{i}).(Freq_FNames{k}).S_freq]);
                gain_avr=zeros(1,length(H.(FNames{i}).(Freq_FNames{k})));
                phase_avr=gain_avr;
                for h=1:length(H.(FNames{i}).(Freq_FNames{k}))              
                    phase=H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).phase;
                    if strcmp('rostral',H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).direction)
                        direction=pi/2;
                        color=[1 0 0];
                    elseif strcmp('caudal',H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).direction)
                        direction=-pi/2;
                        color=[0.5 0.5 0.5];
                    end
                    r=sum(exp(1i*phase));
                    gain_avr(h)=abs(r)./H.(FNames{i}).(Freq_FNames{k})(h).S_cycle.*H.(FNames{i}).(Freq_FNames{k})(h).S_freq;
                    %gain_avr(h)=abs(r)./H.(FNames{i}).(Freq_FNames{k})(h).S_cycle;
                    phase_avr(h)=angle(r);
                end
                freq_gain(k)=mean(gain_avr);
                freq_phase(k)=direction-mean(phase_avr);
                if freq_phase(k)<-pi/2
                    freq_phase(k)=freq_phase(k)+2*pi;
                end
            end
            S(count).S_freq=S_freq;
            S(count).freq_gain=freq_gain;
            S(count).freq_phase=freq_phase;
            S(count).color=color;
            S(count).direction=direction;
            S(count).amp_range=H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).amp_range;
            S(count).rec_file=FNames{i};
            count=count+1;
        end
    end
    save('afferents_summary','S');
    S_rostral=S([S.direction]==pi/2);
    S_caudal=S([S.direction]==-pi/2);
   	freq_num=length(S(1).S_freq);
    rostral_gain_avr=zeros(1,freq_num);
    rostral_gain_std=zeros(1,freq_num);
    caudal_gain_avr=zeros(1,freq_num);
    caudal_gain_std=zeros(1,freq_num);
    rostral_phase_avr=zeros(1,freq_num);
    rostral_phase_std=zeros(1,freq_num);
    caudal_phase_avr=zeros(1,freq_num);
    caudal_phase_std=zeros(1,freq_num);
    for i=1:freq_num
        rostral_gain=cell2mat(arrayfun(@(x) x.freq_gain(i),S_rostral(:)','Uniform',0));
        rostral_gain_avr(i)=mean(rostral_gain);
        rostral_gain_std(i)=std(rostral_gain)/sqrt(length(rostral_gain));
        rostral_phase=cell2mat(arrayfun(@(x) x.freq_phase(i),S_rostral(:)','Uniform',0));
        rostral_phase_avr(i)=mean(rostral_phase);
        rostral_phase_std(i)=std(rostral_phase)/sqrt(length(rostral_phase));
        caudal_gain=cell2mat(arrayfun(@(x) x.freq_gain(i),S_caudal(:)','Uniform',0));
        caudal_gain_avr(i)=mean(caudal_gain);
        caudal_gain_std(i)=std(caudal_gain)/sqrt(length(caudal_gain));
        caudal_phase=cell2mat(arrayfun(@(x) x.freq_phase(i),S_caudal(:)','Uniform',0));
        caudal_phase_avr(i)=mean(caudal_phase);
        caudal_phase_std(i)=std(caudal_phase)/sqrt(length(caudal_phase));
    end
    %plot results
    figure;
    subplot(2,1,1)
    hold on;
    for i=1:length(S)
    plot(log2(S(i).S_freq),S(i).freq_gain,'Color',S(i).color,'LineWidth',0.5)
    end
    errorbar(log2(S(i).S_freq),rostral_gain_avr,rostral_gain_std,'r','Marker','o','MarkerSize',5,'LineWidth',5)
    errorbar(log2(S(i).S_freq),caudal_gain_avr,caudal_gain_std,'k','Marker','o','MarkerSize',5,'LineWidth',5)
    hold off;
    xlim([-2 4]);
    xticks([-1 0 1 2 3])
    xticklabels({0.5 1 2 4 8});
    ylabel('Gain, EPSC/s')
    subplot(2,1,2)
    hold on;
    for i=1:length(S)
    plot(log2(S(i).S_freq),S(i).freq_phase.*180./pi,'Color',S(i).color,'LineWidth',0.5)
    end
    errorbar(log2(S(i).S_freq),rostral_phase_avr.*180./pi,rostral_phase_std.*180./pi,'r','Marker','o','MarkerSize',5,'LineWidth',5)
    errorbar(log2(S(i).S_freq),caudal_phase_avr.*180./pi,caudal_phase_std.*180./pi,'k','Marker','o','MarkerSize',5,'LineWidth',5)
    hold off;
    xlim([-2 4]);
    xticks([-1 0 1 2 3])
    xticklabels({0.5 1 2 4 8});
    %ylim([-90 180])
    xlabel('Hz')
    ylabel('phase')
    
    
    
    
end