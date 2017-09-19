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
%     Model_pdf=@(x)pdf(GMModel,x);
%     XData=min(Amps):max(Amps);
%     hold on;
%     plot(XData,Model_pdf(XData'),'LineWidth',5)
%     hold off;
%     idx=zeros(100,length(Amps));
    idx=kmeans(Amps,NumOfPeaks);
    Amps_clust=cell(1,NumOfPeaks);
    GMM=cell(1,NumOfPeaks);
    AIC=zeros(1,NumOfPeaks);
    for j=1:NumOfPeaks
        Amps_clust{j}=Amps(idx==j);
        GMM{j}=fitgmdist(Amps_clust{j},1);
        AIC(j)=GMM{j}.AIC
    end
    nhist(Amps_clust,'numbers','smooth','binfactor',20)
end