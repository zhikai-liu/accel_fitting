function process_plot_heatmap_ampVSphase(filename,range)
    S=load(filename);
    Global=load('Accel_globalvar.mat');   
    if strcmp(range,'all')
        range=1:length(S.Trials);
    end
    S_amp=round([S.Trials(range).S_amp],2);
    S_freq=round([S.Trials(range).S_freq],1);
    freq_num=length(unique(S_freq));
    Freq_cor_value=Global.Freq_cor_value(1:freq_num);
    Amp_cor_value=Global.Amp_cor_value;
    Amp_order=cell(length(Amp_cor_value),1);
    Freq_order=cell(length(Freq_cor_value),1);
    for i=1:length(Amp_cor_value)
        Amp_order{i}=find(S_amp==Amp_cor_value{i});
    end
    for i=1:length(Freq_cor_value)
        Freq_order{i}=find(S_freq==Freq_cor_value{i});
    end
    %color_all=colormap(jet(length(Freq_cor_value)));
    
    for i=1:length(Amp_order)
        if ~isempty(Amp_order{i})
        %figure('units','normal','position',[0,0,1,1]);
        for j=1:length(Freq_order)
            if ~isempty(Freq_order{j})
                for k=1:length(Freq_order{j})
                    if sum(Amp_order{i}==Freq_order{j}(k))
                        trial=Freq_order{j}(k);
                        Amps=S.Trials(trial).period_index.amp;
                        Phases=S.Trials(trial).period_index.phase;
    % %                     scatter(Phases.*180./pi,Amps,'filled',...
    % %                         'MarkerFaceColor',color_all(j,:),...
    % %                         'MarkerEdgeColor',color_all(j,:),...
    % %                         'DisplayName',[num2str(S_freq(trial)),' Hz']);
                        X_step=0.3;
                        Y_step=0.1;
                        amp_bin=3;
                        X_phase=-180:X_step:180;
                        X_phase=X_phase./180.*pi;
                        Y_amp=floor(min(Amps)):Y_step:ceil(max(Amps));
                        HM=zeros(length(X_phase),length(Y_amp));
                        for y=1:length(Y_amp)
                            amp_range=[max(Y_amp(y)-amp_bin,Y_amp(1)), min(Y_amp(y)+amp_bin,Y_amp(end))];
                            x_y_phase=Phases((Amps>=amp_range(1)).*(Amps<amp_range(end))==1);
                            rep_x_y_phase=repmat(x_y_phase,1,length(X_phase))-X_phase;
                            HM(:,y)=sum(cos(rep_x_y_phase),1)./diff(amp_range);
                         
                        end
                        HM=HM./X_step./Y_step./S_freq(trial)./S_amp(trial)./S.Trials(trial).S_cycle;
                        HM(HM<0)=0;
                        HM_gray=mat2gray(HM');
                        imshow(HM_gray);
                        HMH=HeatMap(HM','Colormap','jet');
                    end
                end
            end
        end
%             LG=legend('show');
%             set(LG,'Box','off','FontSize',20)
%            title({filename(1:end-4),[num2str(Amp_cor_value{i}) ' g']},'interpreter','none')
%             print(HMH,[filename(1:end-4) '_' num2str(Amp_cor_value{i}) 'g_allFreq_heatmap.jpg'],...
%                 '-r300','-djpeg')
        end
    end
end
