function [event_index, amps] = EPSC_detection(W,si,amp_thre,if_2der,diff_gap,diff_thre,event_duration)
%% calculate the difference with 240us as "1st derivative" to detect event
diff_gap = diff_gap/si;
event_duration =event_duration/si;
data_s = smooth(W);  %smooth the data 
diff_ = data_s(1+diff_gap:end)-data_s(1:end-diff_gap)-diff_thre; % caculate the difference between 240us
crossing_ = diff_(1:end-1).*diff_(2:end)<0;% find the crossing for -8pA
r_index = find(crossing_.*(diff_(1:end-1)>0)); % find the on-rise crossing point
f_index = find(crossing_.*(diff_(1:end-1)<0)); % find the on-fall crossing point
if length(r_index) ~= length(f_index)
    warning('rising and falling not match')
    if length(r_index) == length(f_index)+1
        r_index(end)=[];
    elseif length(f_index) == length(r_index)+1
        f_index(1)=[];
    end
end

%% calculate 2nd derivative and find zero crossing between diff_crossing pair
if if_2der
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
else
    raw_index = sort(r_index);
end
raw_l = length(raw_index);
amp_raw = zeros(raw_l,1);
for i = 1:raw_l
    if i == raw_l
        duration = event_duration; % the last EPSC duration is 640us
    else
    duration = min(raw_index(i+1)-raw_index(i),32);%duration of EPSC is the smaller one of either 640us or before next EPSC comes
    end
    amp_raw(i) = max(abs(data_s(raw_index(i):raw_index(i)+duration)-data_s(raw_index(i))));
end

%% set amplitudes threshold for EPSC detection
amps = amp_raw(amp_raw>amp_thre);
event_index = raw_index(amp_raw>amp_thre);
end