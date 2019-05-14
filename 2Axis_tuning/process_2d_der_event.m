function process_2d_der_event(filename_h)
f_abf = dir([filename_h '*.mat']);
orien={'X','Y','XpYp','XpYn'};
for i =1:length(f_abf)
    clearvars S cycle_index amps_cycle
    for h=1:length(orien)
    Sf = load(f_abf(i).name);
    S=Sf.(orien{h});
    S.der=event_detect(S);
    end

end
end
function der=event_detect(S)
     der=struct();
     if isfield(S,'type')
         istype_EPSC=strcmp(S.type{1},'EPSC');
         istype_EPSP=strcmp(S.type{1},'EPSP');
     end
    if istype_EPSC
        amp_thre = 6; diff_gap = 240; diff_thre =-8;if_2der=1;event_duration = 640;
        if isfield(S,'Data')
            [der.event_index,der.event_peak,der.amps,der.der_index] = EPSC_detection(S.Data(:,1),S.si,amp_thre,if_2der,diff_gap,diff_thre,event_duration);
        elseif isfield(S,'data_pad')
            [der.event_index,der.event_peak,der.amps,der.der_index] = EPSC_detection(S.data_pad,S.si,amp_thre,if_2der,diff_gap,diff_thre,event_duration);
        else
            warning('No data in the file. ')
        end
    end
    if istype_EPSP
        amp_thre = 0; diff_gap = 480; diff_thre =6;event_duration =1200;
        [der.event_index,der.event_peak,der.amps] = EPSP_detection(S.Data(:,1),S.si,amp_thre,diff_gap,diff_thre,event_duration);
    end
end