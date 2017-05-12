f_abf = dir('ZL*.abf');
%filename = sprintf('ZL170511_fish01b_%.4d.abf',file_number);
F = figure('KeyPressFcn',{@file_move,f_abf});
setappdata(F,'f_num',1);



function file_move(varargin)
    F = gcf;
    f_abf = varargin{3};
    f_num = getappdata(F,'f_num');
    [f_size,~] = size(f_abf);
    switch varargin{2}.Key
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
    [Data,si,header] = abfload(f_abf(f_num).name);
    [D_x,D_y] = size(Data);
    clf;
    
    if header.nADCNumChannels==1
        for i=1:D_y
        hold on;
        plot([1:D_x]*si*1e-6,Data(:,i));
        end
        hold off;
    else
        for i=1:D_y
            subplot(D_y,1,i);
            plot([1:D_x]*si*1e-6,Data(:,i));
        end
        samexaxis('abc','xmt','on','ytac','join','yld',1);
    end   
    title(F.Children(end),f_abf(f_num).name,'interpreter','none');
end