function process_cell_opening(filename_h)
f_mat = dir([filename_h '*.mat']);
for i =1:length(f_mat)
    clearvars S
    S = load(f_mat(i).name);
    data = S.Data(16700:16800,1);
    cell_opening = mean(data(1:20))-min(data);
    save(f_mat(i).name,'cell_opening','-append');
end
end