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
    [D_x,D_y] = size(Data);   
    %% smoothing data
    for i = 1:D_y
        Data(:,i) = smooth(Data(:,i));
    end
    
    clf;
    
    if header.nADCNumChannels==1
        for i=1:D_y
        hold on;
        plot([1:D_x]*si*1e-6,Data(:,i));
        end
        hold off;
    elseif header.nADCNumChannels==4
        [D_x,D_y,D_z] = size(Data);
        h=struct();
        for j=1:D_z
            if D_z==6
                h(j).d=subplot(ceil(D_z/3).*2,3,ceil(j/3).*6-6+j-3.*ceil(j/3)+3);
                plot([1:D_x]*si*1e-6,Data(:,1,j),'Color',[0.3 0.3 0.3],'LineWidth',1);
                %ylim([-150 50])
                xlim([1 10])
                h(j).a=subplot(ceil(D_z/3).*2,3,ceil(j/3).*6-6+j-3.*ceil(j/3)+6);
                ylim([-0.04 0.04])
                xlim([1 10])
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
            hold off;
        end
        if D_z~=6
            samexaxis('abc','xmt','on','ytac','join','yld',1);
        end
    end
    title(F1.Children(end),f_name,'interpreter','none');
end