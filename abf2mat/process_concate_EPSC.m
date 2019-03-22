%{
    This function is to concatenate the EPSC traces of several different
    recordings. After concatenation, EPSC trace will be processed by the
    sparse deconvolution method for EPSC detection.
%}

function process_concate_EPSC(filename)
%% Load the filename, which contains info about f_mat and range
F=load(filename);
n_f=length(F.mat_fhead);


% Load the first file to get parameters

x=0;
for i=1:n_f
    filename_h=F.mat_fhead{i};
    range=F.range{i};
    f_mat = dir([filename_h '*.mat']);
    if strcmp(range,'all')
        range=1:length(f_mat);
    end
    S = load(f_mat(range(i)).name);

    x=x+length(range);
end
% set or initiate all the variables
si=20;
f_name=cell(x,1);
[y,~]=size(S.Data);
data_size=[y,x];
data_raw=zeros(data_size);
test_pulse_l=35000;
k=0;

%% For each file, load and obtain the Data
for i=1:n_f
    clearvars S
    filename_h=F.mat_fhead{i};
    range=F.range{i};
    if strcmp(range,'all')
        range=1:length(f_mat);
    end
    f_mat = dir([filename_h '*.mat']);
    for j=1:length(range)
        k=k+1;
        f_name{k}=f_mat(range(j)).name; % save each file name
        S = load(f_name{k});
        data_raw(:,k)=S.Data(:,1)-mean(S.Data(:,1)); % baseline subtracted
    end
end

% concatenate all the traces into a long trace, test pulse period is
% omitted
data_pad=reshape(data_raw,1,[]);
data_pad(1:test_pulse_l)=mean(data_pad(test_pulse_l+1:test_pulse_l+100));

%% To smooth the transition from one trace to the next, a "pad" period is added between traces
for j=1:x-1
    left_pad=mean(data_pad(j*y-100:j*y));
    right_pad=mean(data_pad(j*y+test_pulse_l:j*y+test_pulse_l+100));
    data_pad(j*y+1:j*y+test_pulse_l)=linspace(left_pad,right_pad,test_pulse_l);
end

save(filename,'data_pad','f_name','data_size','si','-append')
%% plot concatenated data to see the results
figure;
plot(data_pad)
title(filename_h,'interpreter','none');
end