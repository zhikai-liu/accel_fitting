function plot_ampbins_bode_amp_dep(filename)
    H=load(filename);
    S=struct();
    FNames=fieldnames(H);
    count=1;
    color_all=colormap(jet(150));
    for i=1:length(FNames)
        Freq_FNames=fieldnames(H.(FNames{i}));
        S_freq=zeros(1,length(Freq_FNames));
        freq_gain=zeros(1,length(Freq_FNames));
        freq_phase=zeros(1,length(Freq_FNames));
        freq_amp=zeros(1,length(Freq_FNames));
        freq_var=zeros(1,length(Freq_FNames));;
        ampbin_num=length(H.(FNames{i})(1).(Freq_FNames{1})(1).AmpBins);
        for j=1:ampbin_num
            for k=1:length(Freq_FNames)
                S_freq(k)=mean([H.(FNames{i}).(Freq_FNames{k}).S_freq]);
                gain_avr=zeros(1,length(H.(FNames{i}).(Freq_FNames{k})));
                phase_avr=gain_avr;
                angle_var=gain_avr;
                for h=1:length(H.(FNames{i}).(Freq_FNames{k}))              
                    phase=H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).phase;
                    amp_avr=H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).amp;
                    if strcmp('rostral',H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).direction)
                        direction=pi/2;
                        line_stype='-';
                    elseif strcmp('caudal',H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).direction)
                        direction=-pi/2;
                         line_stype='-';
                    end
                    r=sum(exp(1i*phase));
                    [~, angle_var(h)]=circ_var(phase);
                    gain_avr(h)=abs(r)./H.(FNames{i}).(Freq_FNames{k})(h).S_cycle.*H.(FNames{i}).(Freq_FNames{k})(h).S_freq;
                    %gain_avr(h)=abs(r)./H.(FNames{i}).(Freq_FNames{k})(h).S_cycle;
                    phase_avr(h)=angle(r);
                end
                freq_var(k)=mean(angle_var);
                freq_gain(k)=mean(gain_avr);
                freq_phase(k)=direction-mean(phase_avr);
                freq_amp(k)=mean(amp_avr);
                if freq_phase(k)<-pi/2
                    freq_phase(k)=freq_phase(k)+2*pi;
                end
            end
            gain_fit=fit(log2(S_freq)',freq_gain','poly1');
            phase_fit=fit(log2(S_freq)',freq_phase','poly1');
            if mean(freq_amp)>150
                color=color_all(150,:);
            else
                color=color_all(round(mean(freq_amp)),:);
            end
            S(count).S_freq=S_freq;
            S(count).freq_amp=freq_amp;
            S(count).freq_gain=freq_gain;
            S(count).freq_phase=freq_phase;
            S(count).freq_var=freq_var;
            S(count).color=color;
            S(count).line_stype=line_stype;
            S(count).direction=direction;
            S(count).amp_range=H.(FNames{i}).(Freq_FNames{k})(h).AmpBins(j).amp_range;
            S(count).rec_file=FNames{i};
            S(count).gain_fit=gain_fit;
            S(count).phase_fit=phase_fit;
            count=count+1;
        end
    end
    save('afferents_summary_amp_color','S');
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
    
    all_gain_slope=cell2mat(arrayfun(@(x) x.gain_fit.p1,S(:)','Uniform',0));
    all_gain_intercept=cell2mat(arrayfun(@(x) x.gain_fit.p2,S(:)','Uniform',0));
    all_amp_avr=cell2mat(arrayfun(@(x) mean(x.freq_amp),S(:)','Uniform',0));
    all_phase_slope=cell2mat(arrayfun(@(x) x.phase_fit.p1,S(:)','Uniform',0));
    all_phase_intercept=cell2mat(arrayfun(@(x) x.phase_fit.p2,S(:)','Uniform',0));
    
    all_gain_slope_avr=mean(all_gain_slope);
    all_gain_slope_std=std(all_gain_slope)/sqrt(length(all_gain_slope));
    all_phase_slope_avr=mean(all_phase_slope);
    all_phase_slope_std=std(all_phase_slope)/sqrt(length(all_phase_slope));
    
    rostral_gain_avr=zeros(1,freq_num);
    rostral_gain_std=zeros(1,freq_num);
    caudal_gain_avr=zeros(1,freq_num);
    caudal_gain_std=zeros(1,freq_num);
    rostral_phase_avr=zeros(1,freq_num);
    rostral_phase_std=zeros(1,freq_num);
    caudal_phase_avr=zeros(1,freq_num);
    caudal_phase_std=zeros(1,freq_num);
    all_gain_avr=zeros(1,freq_num);
    all_gain_std=zeros(1,freq_num);
    all_phase_avr=zeros(1,freq_num);
    all_phase_std=zeros(1,freq_num);
    figure('units','normal','position',[0.1,0,0.5,1]);
    for i=1:freq_num
        subplot(freq_num,1,i)
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
        all_amp=cell2mat(arrayfun(@(x) x.freq_amp(i),S(:)','Uniform',0));
        all_gain=cell2mat(arrayfun(@(x) x.freq_gain(i),S(:)','Uniform',0));
        all_phase=cell2mat(arrayfun(@(x) x.freq_phase(i),S(:)','Uniform',0));
        all_gain_avr(i)=mean(all_gain);
        all_gain_std(i)=std(all_gain)/sqrt(length(all_gain));
        all_phase_avr(i)=mean(all_phase);
        all_phase_std(i)=std(all_phase)/sqrt(length(all_phase));
        %%plot gain vs amp for each frequency
        scatter(all_amp,all_gain,25,'filled')
        [gain_inc_amp_fit,gof]=fit(all_amp',all_gain','poly1');
        x_amp=0:250;
        y_predict=x_amp.*gain_inc_amp_fit.p1+gain_inc_amp_fit.p2;
        hold on;
        plot(x_amp,y_predict,'r','LineWidth',2)
        text(0.8,0.8,[num2str(S(1).S_freq(i)) ' Hz'],'Units','normalized')
        text(0.8,0.6,['R^2=' num2str(gof.rsquare)],'Units','normalized')
        text(0.8,0.4,['Y=' num2str(round(gain_inc_amp_fit.p1,3)) 'X+' num2str(round(gain_inc_amp_fit.p2,2))],...
            'Units','normalized');
    end
    print('GainVSamp_all_frequency.jpg','-r300','-djpeg')
    %plot results
    figure('units','normal','position',[0.1,0,0.5,1]);
    subplot(3,1,1)
    hold on;
    for i=1:length(S)
    plot(log2(S(i).S_freq),S(i).freq_gain,'Color',S(i).color,'LineStyle',S(i).line_stype,'LineWidth',2)
    end
%     errorbar(log2(S(i).S_freq),rostral_gain_avr,rostral_gain_std,'r','Marker','o','MarkerSize',5,'LineWidth',5)
%     errorbar(log2(S(i).S_freq),caudal_gain_avr,caudal_gain_std,'k','Marker','o','MarkerSize',5,'LineWidth',5)
    hold off;
    xlim([-2 4]);
    xticks([-1 0 1 2 3])
    xticklabels({0.5 1 2 4 8});
    ylabel('Gain, EPSC/s')
    subplot(3,1,2)
    hold on;
    for i=1:length(S)
    plot(log2(S(i).S_freq),S(i).freq_phase.*180./pi,'Color',S(i).color,'LineStyle',S(i).line_stype,'LineWidth',2)
    end
%     errorbar(log2(S(i).S_freq),rostral_phase_avr.*180./pi,rostral_phase_std.*180./pi,'r','Marker','o','MarkerSize',5,'LineWidth',5)
%     errorbar(log2(S(i).S_freq),caudal_phase_avr.*180./pi,caudal_phase_std.*180./pi,'k','Marker','o','MarkerSize',5,'LineWidth',5)
    hold off;
    xlim([-2 4]);
    xticks([-1 0 1 2 3])
    xticklabels({0.5 1 2 4 8});
    %ylim([-90 180])
    xlabel('Hz')
    ylabel('phase')
    
    subplot(3,1,3)
    hold on;
    for i=1:length(S)
    plot(log2(S(i).S_freq),S(i).freq_var.*180./pi,'Color',S(i).color,'LineStyle',S(i).line_stype,'LineWidth',2)
    end
    hold off;
    xlim([-2 4]);
    xticks([-1 0 1 2 3])
    xticklabels({0.5 1 2 4 8});
    %ylim([-90 180])
    xlabel('Hz')
    ylabel('phase variance')
    
    
    print('Bode_amp_heatmap.jpg','-r300','-djpeg')
    [gain_inc_amp_fit,gof]=fit(all_amp_avr',all_gain_slope','poly1');
    x_amp=0:250;
    y_predict=x_amp.*gain_inc_amp_fit.p1+gain_inc_amp_fit.p2;
    figure('units','normal','position',[0.1,0,0.5,1]);
    subplot(4,1,1)
    scatter(all_amp_avr,all_gain_slope,25,'filled')
    hold on;
    plot(x_amp,y_predict,'r','LineWidth',2)
    text(200,10,['R^2=' num2str(gof.rsquare)])
    text(200,5,['Y=' num2str(round(gain_inc_amp_fit.p1,3)) 'X+' num2str(round(gain_inc_amp_fit.p2,2))]);
    ylabel('gain slope')
    subplot(4,1,2)
    scatter(all_amp_avr,all_gain_intercept,25,'filled')
    ylabel('gain intercept')
    subplot(4,1,3)
    scatter(all_amp_avr,all_phase_slope.*180./pi,25,'filled')
    ylabel('phase slope')
    subplot(4,1,4)
    scatter(all_amp_avr,all_phase_intercept.*180./pi,25,'filled')
    ylabel('phase intercept')
    xlabel('Amp (pA)')
    print('slope_intercept_VSamp.jpg','-r300','-djpeg')
    

    
end