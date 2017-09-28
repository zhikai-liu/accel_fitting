function process_plot_gain_phase_amp_order_bode(filename,range,varargin)
    S=load(filename);
    if strcmp(range,'all')
        range=1:length(S.Trials);
    end
    S_amp=round([S.Trials(range).S_amp],2);
    S_freq=round([S.Trials(range).S_freq],1);
%     freq_num=length(unique(S_freq));
%     Freq_cor_value=Global.Freq_cor_value(1:freq_num);
%     Amp_cor_value=Global.Amp_cor_value;
%     Amp_order=cell(length(Amp_cor_value),1);
%     Freq_order=cell(length(Freq_cor_value),1);
%     for i=1:length(Amp_cor_value)
%         Amp_order{i}=find(S_amp==Amp_cor_value{i});
%     end
%     for i=1:length(Freq_cor_value)
%         Freq_order{i}=find(S_freq==Freq_cor_value{i});
%     end
    color_all=colormap(jet(length(range)));
    %color_all=colormap(jet(5));
%      for i=1:length(Amp_order)
%         if ~isempty(Amp_order{i})
             X_range=[10 10];
%             AcrFreq_YGain={};
%             AcrFreq_FreqOrderIndex=[];
%             AcrFreq_X_Amp={};
        AcrTrial=struct();
        figure('units','normal','position',[0.1,0,0.7,1]);
        H1=subplot(2,1,1);
        hold on;
        for j=1:length(range)
            trial=range(j);
            X_Amp=S.Trials(trial).X_Amp;
            X_range=[min(X_Amp(1),X_range(1)),max(X_Amp(end),X_range(end))];
            YGain=S.Trials(trial).YGain;
            Sm_XData=linspace(X_Amp(1),X_Amp(end),(length(X_Amp)-1)*10);
            Sm_YGain=pchip(X_Amp,YGain,Sm_XData);
            AcrTrial(trial).Sm_XData=Sm_XData;
            AcrTrial(trial).Sm_YGain=Sm_YGain;
            if ~isempty(varargin)
                if  strcmp(varargin{1},'showtrial')
                    Trial_num_str=[' trial ' num2str(trial)];
                else
                    Trial_num_str=[];
                end
            else
                    Trial_num_str=[];
            end
            dname=[num2str(S_freq(j)) ' Hz ' num2str(S_amp(j)) ' g'];
            if isfield(S.Trials,'bode_displayname')
                if ~isempty(S.Trials(trial).bode_displayname)
                    dname=[dname ' ' S.Trials(trial).bode_displayname];
                end
            end
            plot(Sm_XData,Sm_YGain,'Color',color_all(j,:),'LineWidth',3,'DisplayName', [dname Trial_num_str])        
        end
%         hold off;
        ylabel('Gain FR/g','FontSize',20);
        %ylim([-10 Inf]);
        max_Sm_YGain=cell2mat(arrayfun(@(x) max(x.Sm_YGain),AcrTrial(:)','Uniform',0));
        max_YGain_norm=max_Sm_YGain./max(max_Sm_YGain);

        A1=gca;
        set(A1.XAxis,'visible','off');
        set(A1.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k');
        LG=legend('show');
        set(LG,'Box','off','FontSize',20,'FontWeight','bold','LineWidth',3)
        title({filename(1:end-4)},'interpreter','none','FontSize',20,'FontWeight','bold')  
        
        %% plot phase versus amp
        H3=subplot(2,1,2);
        hold on;
        for j=1:length(range)
                    trial=range(j);
                    X_Amp=S.Trials(trial).X_Amp;
                    YPhase=S.Trials(trial).YPhase;
                    Sm_XData=AcrTrial(trial).Sm_XData;
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
                    plot_thre=AcrTrial(trial).Sm_YGain/max(AcrTrial(trial).Sm_YGain);
                    phase_scale=plot_thre.*max_YGain_norm(trial);
                    for h=1:length(Sm_YPhase)-1
                        if plot_thre(h)>0.2&&~ismember(h,X_NoDraw)
                            plot([Sm_XData(h) Sm_XData(h+1)],[Sm_YPhase(h) Sm_YPhase(h+1)].*180./pi,...
                                'Color',color_all(j,:),'LineWidth',10*phase_scale(h)+0.01)
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
            yticklabels({'\pi','3\pi/2','0','\pi/2','\pi'});
            xlabel('EPSC amplitude (pA)','FontSize',20,'FontWeight','bold');
            ylabel('Average phase','FontSize',20,'FontWeight','bold');
            A2=gca;
            set(A2.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',3);
            set(A2.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',3);
            xlim(X_range)
            samexaxis('YAxisLocation','none','Box','off');
            set(A1.YAxis(1).Label,'Units','normalized','Position',[-0.08 0.5 0])
            set(A2.YAxis(1).Label,'Units','normalized','Position',[-0.08 0.5 0])
            %set(A1.YAxis(2),'Visible','off')
            print([filename(1:end-4) '_all.jpg'],...
            '-r200','-djpeg')
%         end
    end