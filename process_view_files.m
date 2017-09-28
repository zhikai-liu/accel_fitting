function process_view_files(filename_h,varargin)
    f_abf = dir([filename_h '*.abf']);
    if_fit = 0;
    F = figure('KeyPressFcn',{@file_move_by_key,f_abf,if_fit});
    if ~isempty(varargin)
        start=varargin{1};
    else
        start=1;
    end
        setappdata(F,'f_num',start);
end