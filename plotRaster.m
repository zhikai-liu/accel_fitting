function plotRaster(spikes,timePerBin) 
    [trials,timebins] = find(spikes);
    [nTrials,nTimes] = size(spikes);
    trials = trials';
    timebins = timebins'.*timePerBin;
    vertSpikeHeight = 1;
    halfSpikeHeight = vertSpikeHeight/2;
    xPoints = [ timebins;
                timebins;
                NaN(size(timebins)) ];
    yPoints = [ trials - halfSpikeHeight;
                trials + halfSpikeHeight;
                NaN(size(trials))];
    xPoints = xPoints(:);
    yPoints = yPoints(:);
    plot(xPoints,yPoints,'k','LineWidth',1.5,'Color',[0.3 0.3 0.3]);
    xlim([0-1 nTimes.*timePerBin+1]);
    ylim([0 nTrials+1]);
end