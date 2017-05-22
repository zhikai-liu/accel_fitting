function [event_index, amps] = EPSC_detection(W,si,amp_thre,diff_gap,diff_thre)
%% calculate the difference with 240us as "1st derivative" to detect event
diff_gap = diff_gap/si;
data_s = smooth(W(:,1));  %smooth the data 
diff_ = data_s(1+diff_gap:end)-data_s(1:end-diff_gap)-diff_thre; % caculate the difference between 240us
crossing_ = diff_(1:end-1).*diff_(2:end)<=0;% find the crossing for -8pA
r_index = find(crossing_.*(diff_(1:end-1)>0)); % find the on-rise crossing point
f_index = find(crossing_.*(diff_(1:end-1)<0)); % find the on-fall crossing point
if length(r_index) ~= length(f_index)
    warning('rising and falling not match')
end

%% calculate 2nd derivative and find zero crossing between diff_crossing pair
extra_index= [];
for i = 1:length(r_index)
    der_ = diff(diff_(r_index(i):f_index(i))); %calculate derivative
    zero_ = der_(1:end-1).*der_(2:end)<=0; % find zero crossing
    infle_ = find(zero_.*(der_(1:end-1)>0)); %find inflection point
    if ~isempty(infle_)
    extra_index = [extra_index;infle_+r_index(i)]; % find extra index to add for overlapped EPSCs
    end
end
%% calculate amplitude for each events detected
raw_index = sort([r_index;extra_index]);
raw_l = length(raw_index);
amp_raw = zeros(1,raw_l);
for i = 1:raw_l
    if i == raw_l
        duration = 32; % the last EPSC duration is 640us
    else
    duration = min(raw_index(i+1)-raw_index(i),32);%duration of EPSC is the smaller one of either 640us or before next EPSC comes
    end
    amp_raw(i) = min(data_s(raw_index(i):raw_index(i)+duration))-data_s(raw_index(i));
end

%% set amplitudes threshold for EPSC detection
amps = amp_raw(amp_raw<-amp_thre);
event_index = raw_index(amp_raw<-amp_thre);
end