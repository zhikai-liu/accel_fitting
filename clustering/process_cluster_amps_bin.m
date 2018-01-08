function GMM=process_cluster_amps_bin(amps_filename,range,NumOfPeaks)
    S=load(amps_filename);
    filenames=fieldnames(S.Amp_all);
    if strcmp(range,'all')
        range=1:length(filenames);
    end
    Amps=[];
    for i =range
        Amps=[Amps;getfield(S.Amp_all,filenames{i})];
    end
%     Start_model=struct('mu',[10;25;36;100],...
%         'Sigma',reshape([3,3,3,3],1,1,4),...
%         'PComponents',[0.2,0.2,0.2,0.4]);
    Start_model='plus';
    GMModel=fitgmdist(Amps,NumOfPeaks,'Start',Start_model);
    figure('Units','normal',...
    'Position',[0 0 1 1],...
    'Visible', 'on');
%     nhist(Amps,'binfactor',20,'separate','noerror','pdf','smooth')
    Model_pdf=@(x)pdf(GMModel,x);
    hold on;
%     idx=zeros(100,length(Amps));
    idx=kmeans(Amps,NumOfPeaks);
    Amps_clust=cell(1,NumOfPeaks);
    GMM=cell(1,NumOfPeaks);
    GMM_f=cell(1,NumOfPeaks);
    AIC=zeros(1,NumOfPeaks);
    for j=1:NumOfPeaks
        Amps_clust{j}=Amps(idx==j);
        GMM{j}=fitgmdist(Amps_clust{j},1);
        AIC(j)=GMM{j}.AIC;
        GMM_f{j}=@(x)pdf(GMM{j},x);
    end
    map=[1,0,0;0,1,0;0,0,1;1,0,1;0,1,1;1,1,0];
    colormap(map(1:NumOfPeaks,:));
    nhist(Amps,'numbers','smooth','binfactor',20,'noerror')
    nhist(Amps_clust,'numbers','smooth','binfactor',20,'color','colormap','noerror')
    for j=1:NumOfPeaks
        XData=min(Amps_clust{j}):0.01:max(Amps_clust{j});
        plot(XData,length(Amps_clust{j}).*GMM_f{j}(XData'),'Color',map(j,:),'LineWidth',5);
    end
        XData=min(Amps):max(Amps);
        plot(XData,length(Amps).*Model_pdf(XData'),'k--','LineWidth',5)
    hold off
end