function AxisFormat()
    A=gca;
    set(A.XAxis,'FontName','Helvetica','FontSize',9,'LineWidth',0.75,'Color','k');
    set(A.YAxis,'FontName','Helvetica','FontSize',9,'LineWidth',0.75,'Color','k');
    set(A,'box','off','TickDir','out','TickLength',[0.06 0.025],'FontName','Helvetica','FontSize',9,'FontWeight','Normal')
end