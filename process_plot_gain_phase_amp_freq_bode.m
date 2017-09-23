function process_plot_gain_phase_amp_freq_bode(filename,range,varargin)
    S=load(filename);
    Global=load('Accel_globalvar.mat');
%     Global.Amp_field_names={'POtwoG','POfourG','POsixG','POeightG','POneG'};
%     Global.Amp_cor_value={0.02,0.04,0.06,0.08,0.1};
%     Global.Freq_field_names={'halfHz','oneHz','twoHz','fourHz','eightHz','sixteenHz','thirtytwoHz'};
%     Global.Freq_cor_value={0.5,1,2,4,8,16,32};
%     save('Accel_globalvar.mat','-struct','Global') 
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
    color_all=colormap(jet(length(Freq_cor_value)));
    
     for i=1:length(Amp_order)
        if ~isempty(Amp_order{i})
            X_range=[10 10];
            AcrFreq_YGain={};
            AcrFreq_FreqOrderIndex=[];
            AcrFreq_X_Amp={};
        figure('units','normal','position',[0,0,1,1]);
        H1=subplot(2,1,1);
        hold on;
        for j=1:length(Freq_order)
            if ~isempty(Freq_order{j})
                for k=1:length(Freq_order{j})
                    if sum(Amp_order{i}==Freq_order{j}(k))
                    trial=Freq_order{j}(k);
                    X_Amp=S.Trials(trial).X_Amp;
                    X_Amp_step=S.Trials(trial).X_Amp_step;
                    X_range=[min(X_Amp(1),X_range(1)),max(X_Amp(end),X_range(end))];
                    YGain=S.Trials(trial).YGain;
                    AcrFreq_X_Amp=[AcrFreq_X_Amp,{X_Amp}];
                    AcrFreq_YGain=[AcrFreq_YGain,{YGain}];
                    AcrFreq_FreqOrderIndex=[AcrFreq_FreqOrderIndex,j];
                    Sm_XData=linspace(X_Amp(1),X_Amp(end),(length(X_Amp)-1)*10);
                    Sm_YGain=pchip(X_Amp,YGain,Sm_XData);
                    max_YGain(j,k)=max(Sm_YGain);
                    phase_scale{j,k}=Sm_YGain./max(Sm_YGain);
                    if ~isempty(varargin)
                        if  strcmp(varargin{1},'showtrial')
                            Trial_num_str=[' trial ' num2str(trial)];
                        else
                            Trial_num_str=[];
                        end
                    else
                            Trial_num_str=[];
                    end
                    plot(Sm_XData,Sm_YGain,'Color',color_all(j,:),'LineWidth',3,'DisplayName',[num2str(S_freq(trial)) ' Hz' Trial_num_str])
                    end
                end
            end
        end
%         hold off;
        ylabel('Gain FR/g','FontSize',20);
        %ylim([-10 Inf]);
             
        max_YGain=max_YGain./max(max(max_YGain));
        %%
%         H2=subplot(3,1,2);
%         hold on;
        X_Amp=max(cell2mat(arrayfun(@(c) c{:}(1),AcrFreq_X_Amp,'Uniform',0))):X_Amp_step:min(cell2mat(arrayfun(@(c) c{:}(end),AcrFreq_X_Amp,'Uniform',0)));
        X_index=zeros(length(AcrFreq_YGain),2);
        for j=1:length(AcrFreq_YGain)
            X_index(j,1)=find(AcrFreq_X_Amp{j}==X_Amp(1));
            X_index(j,2)=find(AcrFreq_X_Amp{j}==X_Amp(end));
        end
        Gain_increase_slope=zeros(1,length(X_Amp));
        Gain_increase=zeros(1,length(AcrFreq_YGain));
        Mean_Gain_scale=zeros(1,length(X_Amp));
        yyaxis right;
        for j=1:length(X_Amp)
            for k=1:length(AcrFreq_YGain)
                Gain_increase(k)=AcrFreq_YGain{k}((X_index(k,1)+j-1));
            end
            Mean_Gain_scale(j)=mean(Gain_increase);
            FitP=fit(log2([Freq_cor_value{AcrFreq_FreqOrderIndex}]'),Gain_increase','poly1');
            Gain_increase_slope(j)=FitP.p1;
        end
        Mean_Gain_scale=Mean_Gain_scale./max(Mean_Gain_scale);
        scatter(X_Amp,Gain_increase_slope,Mean_Gain_scale.*48+0.01,'o','filled',...
            'MarkerEdgeColor','k','MarkerFaceColor','k','DisplayName','Gain increase')
        ylabel('Gain increase')
        A1=gca;
        set(A1.XAxis,'visible','off');
        set(A1.YAxis,'FontSize',20,'LineWidth',3,'Color','k');
        LG=legend('show');
        set(LG,'Box','off','FontSize',20,'LineWidth',3)
        title({filename(1:end-4),['Amp: ' num2str(S_amp(trial)) ' g']},'interpreter','none','FontSize',20)  
        
        %% plot phase versus amp
        H3=subplot(2,1,2);
        hold on;
        for j=1:length(Freq_order)
            if ~isempty(Freq_order{j})
                for k=1:length(Freq_order{j})
                    if sum(Amp_order{i}==Freq_order{j}(k))
                    trial=Freq_order{j}(k);
                    X_Amp=S.Trials(trial).X_Amp;
                    YPhase=S.Trials(trial).YPhase;
                    Sm_XData=linspace(X_Amp(1),X_Amp(end),(length(X_Amp)-1)*10);
                    Sm_YPhase=pchip(X_Amp,YPhase,Sm_XData);
                %% Find phase cross -pi->pi that will cause unsmooth sudden phase shift
                    pi_cross_NP=((YPhase(1:end-1)+pi/2<=0).*(YPhase(2:end)-pi/2>=0));
                    pi_cross_PN=((YPhase(2:end)+pi/2<=0).*(YPhase(1:end-1)-pi/2>=0));
                    XData_index_NP=find(pi_cross_NP);
                    XData_index_PN=find(pi_cross_PN);
                %% Adjust those crossing points
                    for h=1:length(XData_index_NP)
                        Adj_XData=linspace(X_Amp(XData_index_NP(h)),X_Amp(XData_index_NP(h)+1),10)';
                        Sm_YPhase((XData_index_NP(h)-1)*10+1:XData_index_NP(h)*10)=pchip(X_Amp(1:XData_index_NP(h)+1),[YPhase(1:XData_index_NP(h));YPhase(XData_index_NP(h)+1)-2*pi],Adj_XData);
                    end
                    for h=1:length(XData_index_PN)
                        Adj_XData=linspace(X_Amp(XData_index_PN(h)),X_Amp(XData_index_PN(h)+1),10)';
                        Sm_YPhase((XData_index_PN(h)-1)*10+1:XData_index_PN(h)*10)=pchip(X_Amp(1:XData_index_PN(h)+1),[YPhase(1:XData_index_PN(h));YPhase(XData_index_PN(h)+1)+2*pi],Adj_XData);
                    end
                %% Plot Phase
                    X_NoDraw=[XData_index_NP.*10;XData_index_PN.*10]; 
                    adj_phase_scale=phase_scale{j,k}.*max_YGain(j,k);
                    for h=1:length(Sm_YPhase)-1
                        if phase_scale{j,k}(h)>0.2&&~ismember(h,X_NoDraw)                          
                            color_phase=[1 1 1].*(1-phase_scale{j,k}(h))+color_all(j,:).*phase_scale{j,k}(h);
                            plot([Sm_XData(h) Sm_XData(h+1)],[Sm_YPhase(h) Sm_YPhase(h+1)].*180./pi,...
                                'Color',color_all(j,:),'LineWidth',10*adj_phase_scale(h)+0.01)
                        end
                    end
                
                    end
                end
            end

        end
            plot(X_range,[90 90],'k--');
            plot(X_range,[180 180],'r--');
            plot(X_range,[-90 -90],'k--');
            plot(X_range,[-180 -180],'r--');
            hold off;
            ylim([-200 200]);
            yticks([ -180 -90 0 90 180 ])
            xlabel('EPSC amplitude (pA)','FontSize',20);
            ylabel('Average phase','FontSize',20);
            A2=gca;
            set(A2.XAxis,'FontSize',20,'LineWidth',3);
            set(A2.YAxis,'FontSize',20,'LineWidth',3);
            xlim(X_range)
            samexaxis('YAxisLocation','none','Box','off');
            set(A1.YAxis(1).Label,'Units','normalized','Position',[-0.05 0.5 0])
            set(A2.YAxis(1).Label,'Units','normalized','Position',[-0.0415 0.5 0])
            print([filename(1:end-4) '_' num2str(round(S_amp(trial),2)) 'g_allFreq.jpg'],...
            '-r300','-djpeg')
        end
    end