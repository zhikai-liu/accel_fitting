function process_plot_gain_phase_amp_freq_bode(filename)
    AmpBode=load(filename);
    Global=load('Accel_globalvar.mat');
%     Global.Amp_field_names={'POtwoG','POfourG','POsixG','POeightG','POneG'};
%     Global.Amp_cor_value={0.02,0.04,0.06,0.08,0.1};
%     Global.Freq_field_names={'halfHz','oneHz','twoHz','fourHz','eightHz','sixteenHz','thirtytwoHz'};
%     Global.Freq_cor_value={0.5,1,2,4,8,16,32};
%     save('Accel_globalvar.mat','-struct','Global')
    AmpBode_AmpFDnames=fieldnames(AmpBode);
    AmpBode_AmpFDnames_value=AmpBode_AmpFDnames;
    for i=1:length(AmpBode_AmpFDnames)
    AmpBode_AmpFDnames_value{i}=Global.Amp_cor_value{strcmp(AmpBode_AmpFDnames{i},Global.Amp_field_names)};
    end
    for i=1:length(Global.Amp_field_names)
        isamp=strcmp(Global.Amp_field_names{i},AmpBode_AmpFDnames);
        if sum(isamp)
        S_amp=AmpBode_AmpFDnames_value{isamp};
        AmpBode_FreqFDnames=fieldnames(AmpBode.(Global.Amp_field_names{i}));
        AmpBode_FreqFDnames_value=AmpBode_FreqFDnames;
        for j=1:length(AmpBode_FreqFDnames)
            AmpBode_FreqFDnames_value{j}=Global.Freq_cor_value{strcmp(AmpBode_FreqFDnames{j},Global.Freq_field_names)};
        end
        %color_all=[0,0,0;1,0,0;0,1,0;0,0,1;0,1,1;1,0,1;1,1,0];
        color_all=colormap(jet(length(Global.Freq_field_names)));
        figure('units','normal','position',[0.25,0,0.5,1])
        H1=subplot(2,1,1);
        hold on;
        for j=1:length(Global.Freq_field_names)
            isfreq=strcmp(Global.Freq_field_names{j},AmpBode_FreqFDnames);
            if sum(isfreq)
            Num_trials=length(AmpBode.(Global.Amp_field_names{i}).(Global.Freq_field_names{j}).XData);
            S_freq=AmpBode_FreqFDnames_value{isfreq};
            for k=1:Num_trials
                XData=AmpBode.(Global.Amp_field_names{i}).(Global.Freq_field_names{j}).XData{k};
                YGain=AmpBode.(Global.Amp_field_names{i}).(Global.Freq_field_names{j}).YGain{k};
                %YPhase=AmpBode.(AmpBode_AmpFDnames{i}).(AmpBode_FreqFDnames{j}).YPhase{k};
                Sm_XData=linspace(XData(1),XData(end),(length(XData)-1)*10);
                Sm_YGain=pchip(XData,YGain,Sm_XData);
                phase_scale{j,k}=Sm_YGain./max(Sm_YGain);
                plot(Sm_XData,Sm_YGain,'Color',color_all(j,:),'LineWidth',3,'DisplayName',[num2str(S_freq) ' Hz'])
            end
            end
        end
        hold off;
        ylabel('gain fr/g','FontSize',20);
        LG=legend('show');
        set(LG,'Box','off','FontSize',20,'LineWidth',3)
        title({filename(1:end-4),['Amp: ' num2str(S_amp) ' g']},'interpreter','none','FontSize',20)
        H2=subplot(2,1,2);
        hold on;
        for j=1:length(Global.Freq_field_names)
            isfreq=strcmp(Global.Freq_field_names{j},AmpBode_FreqFDnames);
            if sum(isfreq)
            Num_trials=length(AmpBode.(Global.Amp_field_names{i}).(Global.Freq_field_names{j}).XData);
            %S_freq=AmpBode_FreqFDnames_value{isfreq};
            for k=1:Num_trials
                XData=AmpBode.(Global.Amp_field_names{i}).(Global.Freq_field_names{j}).XData{k};
                YPhase=AmpBode.(Global.Amp_field_names{i}).(Global.Freq_field_names{j}).YPhase{k};
                Sm_XData=linspace(XData(1),XData(end),(length(XData)-1)*10);
                Sm_YPhase=pchip(XData,YPhase,Sm_XData);
                %% Find phase cross -pi->pi that will cause unsmooth sudden phase shift
                pi_cross_NP=((YPhase(1:end-1)+pi/2<=0).*(YPhase(2:end)-pi/2>=0));
                pi_cross_PN=((YPhase(2:end)+pi/2<=0).*(YPhase(1:end-1)-pi/2>=0));
                XData_index_NP=find(pi_cross_NP);
                XData_index_PN=find(pi_cross_PN);
                %% Adjust those crossing points
                for h=1:length(XData_index_NP)
                    Adj_XData=linspace(XData(XData_index_NP(h)),XData(XData_index_NP(h)+1),10)';
                    Sm_YPhase((XData_index_NP(h)-1)*10+1:XData_index_NP(h)*10)=pchip(XData(1:XData_index_NP(h)+1),[YPhase(1:XData_index_NP(h));YPhase(XData_index_NP(h)+1)-2*pi],Adj_XData);
                end
                for h=1:length(XData_index_PN)
                    Adj_XData=linspace(XData(XData_index_PN(h)),XData(XData_index_PN(h)+1),10)';
                    Sm_YPhase((XData_index_PN(h)-1)*10+1:XData_index_PN(h)*10)=pchip(XData(1:XData_index_PN(h)+1),[YPhase(1:XData_index_PN(h));YPhase(XData_index_PN(h)+1)+2*pi],Adj_XData);
                end
                %% Plot Phase
                X_NoDraw=[XData_index_NP.*10;XData_index_PN.*10];
                for h=1:length(Sm_YPhase)-1
                    if phase_scale{j,k}(h)>0.2&&~ismember(h,X_NoDraw)
                    plot([Sm_XData(h) Sm_XData(h+1)],[Sm_YPhase(h) Sm_YPhase(h+1)].*180./pi,...
                        'Color',color_all(j,:),'LineWidth',6*phase_scale{j,k}(h)^2+0.0001)
                    end
                end
                
            end
            end
        end
        plot([XData(1),XData(end)],[90 90],'k--');
        plot([XData(1),XData(end)],[180 180],'r--');
        plot([XData(1),XData(end)],[-90 -90],'k--');
        plot([XData(1),XData(end)],[-180 -180],'r--');
        hold off;
        ylim([-270 270]);
        yticks([-270 -180 -90 0 90 180 270])
        xlabel('pA 2pA/bin','FontSize',20);
        ylabel('average phase','FontSize',20);
        samexaxis('ytac','box','off');
        print([filename(1:end-4) '_' num2str(round(S_amp,2)) 'g_allFreq.jpg'],...
        '-r300','-djpeg')
        end
    end
end