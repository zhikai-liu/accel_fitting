function process_cell_opening(filename_h)
f_mat = dir([filename_h '*.mat']);
opening_all=zeros(length(f_mat),1);
for i =1:length(f_mat)
    clearvars S
    S = load(f_mat(i).name);
    data = S.Data(16700:16800,1);
    cell_opening = mean(data(1:20))-min(data);
    opening_all(i)=cell_opening;
    save(f_mat(i).name,'cell_opening','-append');
end
figure;
plot(opening_all);
hold on;
plot(1:length(opening_all),0.8*max(opening_all).*ones(length(opening_all),1),':r');
text(length(opening_all),0.8*max(opening_all),'80%')
end