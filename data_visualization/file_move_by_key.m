function file_move_by_key(varargin)
    F1 = gcf;
    f_abf = varargin{3};
    if_fit = varargin{4};
    [f_size,~] = size(f_abf);
    update_file_index(varargin{2}.Key,f_size);
    f_num = getappdata(F1,'f_num');
    header = show_data(F1,f_abf(f_num).name);
    if if_fit && header.nADCNumChannels~=1
        poi_x = varargin{5};
        fit_accel(f_abf(f_num).name,poi_x{f_num});
    end
end

function update_file_index(key,f_size)
    F = gcf;
    f_num = getappdata(F,'f_num');
    switch key
        case 'rightarrow'
            if f_num >= f_size
                beep;
            else
                f_num = f_num+1;
                setappdata(F,'f_num',f_num)
            end
        case 'leftarrow'
            if f_num <= 1
                beep;
            else
                f_num = f_num-1;
                setappdata(F,'f_num',f_num)
            end      
    end
end

function [header] = show_data(F1,f_name)
    [Data,si,header] = abfload(f_name);
    [D_x,D_y,D_z] = size(Data); 
    %% smoothing data
    for i = 1:D_y
        Data(:,i) = smooth(Data(:,i));
    end
    
    clf;
    
    if header.nADCNumChannels==1
        for i=1:D_z
        hold on;
        plot([1:D_x]*si*1e-6,Data(:,1,i));
        end
        hold off;
        
    elseif header.nADCNumChannels==2
        subplot(2,1,1)
        hold on;
        for i=1:D_z
            plot([1:D_x]*si*1e-6,Data(:,1,i));
        end
        hold off;
        subplot(2,1,2)
        hold on;
        for i=1:D_z
            plot([1:D_x]*si*1e-6,Data(:,2,i));
        end
        hold off;
        samexaxis('abc','xmt','on','ytac','join','yld',1);
    elseif header.nADCNumChannels==4
        h=struct();
        y_pA_max=max(max(Data(:,1,:)));
        y_pA_min=min(min(Data(:,1,:)));
        y_pA_length=y_pA_max-y_pA_min;
        for j=1:D_z
            if D_z==6
                if j<3
                    xlim_range=[0.5 8.5];
                else
                    xlim_range=[3 11];
                end
                h(j).d=subplot(ceil(D_z/3).*2,3,ceil(j/3).*6-6+j-3.*ceil(j/3)+3);
                plot([1:D_x]*si*1e-6,Data(:,1,j),'Color',[0.3 0.3 0.3],'LineWidth',1.2);
                ylim([y_pA_min-0.01*y_pA_length y_pA_max+0.01*y_pA_length])
                xlim(xlim_range)
                set(gca,'visible','off')
                h(j).a=subplot(ceil(D_z/3).*2,3,ceil(j/3).*6-6+j-3.*ceil(j/3)+6);
                ylim([-0.04 0.04])
                xlim(xlim_range)
                set(gca,'visible','off')
            else
                h(j).d=subplot(D_z*2,1,2*j-1);
                plot([1:D_x]*si*1e-6,Data(:,1,j),'Color',[0.3 0.3 0.3],'LineWidth',1);
                h(j).a=subplot(D_z*2,1,2*j);
            end
            
            hold on;
            color='rgb';
            for i=2:D_y
                plot([1:D_x]*si*1e-6,Data(:,i,j)-mean(Data(:,i,j)),'Color',color(i-1),'LineWidth',2);
            end
            %hold off;
        end
        if D_z==6
            plot([10,11],[-0.04,-0.04],'Color','k','LineWidth',2)
            plot([11,11],[-0.04,-0.02],'Color','k','LineWidth',2)
            text(11.1,-0.02,{[num2str(round(y_pA_length/4)) ' ' header.recChUnits{1}],'0.02 g'},...
                'FontSize',20)
            text(10,-0.05,'1s','FontSize',20)
        else
            samexaxis('abc','xmt','on','ytac','join','yld',1);
        end
    end
    title(F1.Children(end),f_name,'interpreter','none');
end