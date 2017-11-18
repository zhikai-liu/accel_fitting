% .mda file are from algorithm called mountainsort3.
% ms3 uses threshold event detection while we use a differnet strategy
% This code is generating a "truth" event index to compare to ms3 event detection performance

function mda_event_detect(filename)
    Data=readmda(filename);
    Data=Data';
    si=20;amp_thre = 6; diff_gap = 240; diff_thre =-8;if_2der=1;event_duration = 640;
    [event_index,amps] = EPSC_detection(Data,si,amp_thre,if_2der,diff_gap,diff_thre,event_duration);
    save(['truth-' filename(1:end-4) '.mat'],'Data','si','event_index','amps');
end