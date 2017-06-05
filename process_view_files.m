function process_view_files(filename_h)
f_abf = dir([filename_h '*.abf']);
if_fit = 0;
F = figure('KeyPressFcn',{@file_move_by_key,f_abf,if_fit});
setappdata(F,'f_num',1);
end