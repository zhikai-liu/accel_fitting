function process_ampsALL_hist_plot(filename_h)
S=load(filename_h);
filenames=fieldnames(S.Amp_all);
A=[];
for i = 1:length(filenames)
    A=[A;getfield(S.Amp_all,filenames{i})];
end
figure('units','normal','position',[0 0 1 1]);
nhist(A,'binfactor',20,'separate','noerror')
print([filename_h '_ALLampsHIST.jpg'],'-r300','-djpeg');
