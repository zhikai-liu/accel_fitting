function pad_multi_mat(filename_h,range)
f_mat = dir([filename_h '*.mat']);
S = load(f_mat(1).name);
if strcmp(range,'all')
    range=1:length(f_mat);
end
x=length(range);
[y,~]=size(S.Data);
data_raw=zeros(y,x);
test_pulse_l=35000;
for i=1:x
    clearvars S
    S = load(f_mat(range(i)).name);
    data_raw(:,i)=S.Data(:,1);
end

data_pad=reshape(data_raw,1,[]);
data_pad(1:test_pulse_l)=mean(data_pad(test_pulse_l+1:test_pulse_l+100));


for j=1:x-1
    left_pad=mean(data_pad(j*y-100:j*y));
    right_pad=mean(data_pad(j*y+test_pulse_l:j*y+test_pulse_l+100));
    data_pad(j*y+1:j*y+test_pulse_l)=linspace(left_pad,right_pad,test_pulse_l);
end
%% plot concatenated data to see the results
figure;
plot(data_pad)
title(filename_h,'interpreter','none');
save('all_traces_padded.mat','data_pad')
end