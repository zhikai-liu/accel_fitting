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
                        color='r';
                    elseif strcmp('caudal',H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).direction)
                        direction=-pi/2;
                        color='k';
                    end
                    r=sum(exp(1i*phase));
                    gain_avr(h)=abs(r)./H.(FNames{i}).(Freq_FNames{k})(h).S_cycle.*H.(FNames{i}).(Freq_FNames{k})(h).S_freq;
                    phase_avr(h)=angle(r);
                end
                freq_gain(k)=mean(gain_avr);
                freq_phase(k)=direction-mean(phase_avr);
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
    %plot results
    figure;
    subplot(2,1,1)
    hold on;
    for i=1:length(S)
    plot(log2(S(i).S_freq),S(i).freq_gain,S(i).color,'Marker','o','MarkerSize',5,'LineWidth',4)
    end
    hold off;
    xticks([-1 0 1 2 3])
    xticklabels({0.5 1 2 4 8});
    subplot(2,1,2)
    hold on;
    for i=1:length(S)
    plot(log2(S(i).S_freq),S(i).freq_phase.*180./pi,S(i).color,'Marker','o','MarkerSize',5,'LineWidth',4)
    end
    hold off;
    xticks([-1 0 1 2 3])
    xticklabels({0.5 1 2 4 8});
    ylim([-90 180])
       
    
    
    
    
end