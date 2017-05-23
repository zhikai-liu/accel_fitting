function file_move_by_key(varargin)
    F1 = gcf;
    f_abf = varargin{3};
    if_fit = varargin{4};
    [f_size,~] = size(f_abf);
    update_file_index(varargin{2}.Key,f_size);
    f_num = getappdata(F1,'f_num');
    header = show_data(F1,f_abf(f_num).name);
    poi_x = varargin{5};
    if if_fit && header.nADCNumChannels~=1
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
    else
        [D_x,D_y] = size(Data);
        for i=1:D_y
            subplot(D_y,1,i);
            plot([1:D_x]*si*1e-6,Data(:,i));
        end
        samexaxis('abc','xmt','on','ytac','join','yld',1);  
    end
    title(F1.Children(end),f_name,'interpreter','none');
end