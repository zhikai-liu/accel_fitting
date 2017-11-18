% Bode plot for one amplitude bins of a neuron which requires recordings at
% different frequencies of stimulation.
function plot_ampbins_bode(filename,range)
    H=load(filename);
    S=struct();
    FNames=fieldnames(H);
    count=1;
    if strcmp(range,'all')
        range=1:length(FNames);
    end
    for i=range
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
                        color='b';
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
            gain_fit=fit(log2(S_freq)',freq_gain','poly1');
            phase_fit=fit(log2(S_freq)',freq_phase','poly1');
            S(count).S_freq=S_freq;
            S(count).freq_gain=freq_gain;
            S(count).freq_phase=freq_phase;
            S(count).color=color;
            S(count).direction=direction;
            S(count).amp_range=H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).amp_range;
            S(count).rec_file=FNames{i};
            S(count).gain_fit=gain_fit;
            S(count).phase_fit=phase_fit;
            count=count+1;
        end
    end
    save('afferents_summary','S');
    S_rostral=S([S.direction]==pi/2);
    S_caudal=S([S.direction]==-pi/2);
   	freq_num=length(S(1).S_freq);
    
    rostral_gain_a1=cell2mat(arrayfun(@(x) x.gain_fit.p1,S_rostral(:)','Uniform',0));
    rostral_gain_b1=cell2mat(arrayfun(@(x) x.gain_fit.p2,S_rostral(:)','Uniform',0));
    rostral_phase_a1=cell2mat(arrayfun(@(x) x.phase_fit.p1,S_rostral(:)','Uniform',0));
    rostral_phase_b1=cell2mat(arrayfun(@(x) x.phase_fit.p2,S_rostral(:)','Uniform',0));
    caudal_gain_a1=cell2mat(arrayfun(@(x) x.gain_fit.p1,S_caudal(:)','Uniform',0));
    caudal_gain_b1=cell2mat(arrayfun(@(x) x.gain_fit.p2,S_caudal(:)','Uniform',0));
    caudal_phase_a1=cell2mat(arrayfun(@(x) x.phase_fit.p1,S_caudal(:)','Uniform',0));
    caudal_phase_b1=cell2mat(arrayfun(@(x) x.phase_fit.p2,S_caudal(:)','Uniform',0));
    
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
    subplot(1,2,1)
    hold on;
    for i=1:length(S)
    plot(log2(S(i).S_freq),S(i).freq_gain,'Color',S(i).color,'LineWidth',0.5)
    end
    errorbar(log2(S(i).S_freq),rostral_gain_avr,rostral_gain_std,'r','Marker','.','MarkerSize',15,'LineWidth',5)
    errorbar(log2(S(i).S_freq),caudal_gain_avr,caudal_gain_std,'b','Marker','.','MarkerSize',15,'LineWidth',5)
    hold off;
    xlim([-2 4]);
    xticks([-1 0 1 2 3])
    xticklabels({0.5 1 2 4 8});
    ylabel('Gain (EPSC/s)','FontSize',20,'FontWeight','bold')
    A=gca;
    xlabel('Hz')
    set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k');
    %set(A.XAxis,'Visible','off');
    set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k');
    subplot(1,2,2)
    hold on;
    for i=1:length(S)
    plot(log2(S(i).S_freq),S(i).freq_phase.*180./pi,'Color',S(i).color,'LineWidth',0.5)
    end
    errorbar(log2(S(i).S_freq),rostral_phase_avr.*180./pi,rostral_phase_std.*180./pi,'r','Marker','.','MarkerSize',15,'LineWidth',5)
    errorbar(log2(S(i).S_freq),caudal_phase_avr.*180./pi,caudal_phase_std.*180./pi,'b','Marker','.','MarkerSize',15,'LineWidth',5)
    hold off;
    xlim([-2 4]);
    xticks([-1 0 1 2 3])
    xticklabels({0.5 1 2 4 8});
    ylim([-90 270])
    xlabel('Hz')
    ylabel('Phase (degree)')
    A=gca;
    set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k');
    set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k');
    figure;
    subplot(2,1,1)
    hold on;
    errorbar(2,...
        mean(rostral_gain_a1),...
        std(rostral_gain_a1)/sqrt(length(rostral_gain_a1)),...
        'r','Marker','.','MarkerSize',15,'LineWidth',2)
    errorbar(3,...
        mean(caudal_gain_a1),...
        std(caudal_gain_a1)/sqrt(length(caudal_gain_a1)),...
        'b','Marker','.','MarkerSize',15,'LineWidth',2)
    errorbar(7,...
        mean(rostral_gain_b1),...
        std(rostral_gain_b1)/sqrt(length(rostral_gain_b1)),...
        'r','Marker','.','MarkerSize',15,'LineWidth',2)
    errorbar(8,...
        mean(caudal_gain_b1),...
        std(caudal_gain_b1)/sqrt(length(caudal_gain_b1)),...
        'b','Marker','.','MarkerSize',15,'LineWidth',2)
    hold off;
    xlim([0 10])
    ylabel('Gain')
    A=gca;
    set(A,'box','off')
    set(A.XAxis,'Visible','off');
    set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',3);
    subplot(2,1,2)
    hold on;
    errorbar(2,...
        mean(rostral_phase_a1.*180./pi),...
        std(rostral_phase_a1.*180./pi)/sqrt(length(rostral_phase_a1)),...
        'r','Marker','.','MarkerSize',15,'LineWidth',2) 
    errorbar(3,...
        mean(caudal_phase_a1.*180./pi),...
        std(caudal_phase_a1.*180./pi)/sqrt(length(caudal_phase_a1)),...
        'b','Marker','.','MarkerSize',15,'LineWidth',2)
    
    errorbar(7,...
        mean(rostral_phase_b1.*180./pi),...
        std(rostral_phase_b1.*180./pi)/sqrt(length(rostral_phase_b1)),...
        'r','Marker','.','MarkerSize',15,'LineWidth',2)    
    errorbar(8,...
        mean(caudal_phase_b1.*180./pi),...
        std(caudal_phase_b1.*180./pi)/sqrt(length(caudal_phase_b1)),...
        'b','Marker','.','MarkerSize',15,'LineWidth',2)
    text(0.2,0,'Slope','FontSize',20,'FontWeight','bold','Units','Normalized')
    text(0.65,0,'Intercept','FontSize',20,'FontWeight','bold','Units','Normalized')
    hold off;
    xlim([0 10])
    ylabel('Phase')
    A=gca;
    set(A,'box','off')
    set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','b');
    set(A.XAxis,'Visible','off');
    set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',3);
    
end