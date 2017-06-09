function process_EPSC_detect(filename_h)
f_abf = dir([filename_h '*.abf']);
poi_all = cell(length(f_abf),1);
poi_table = readtable([filename_h '_poi.xlsx']);
for i = 1:length(poi_table.file_num)
    poi_all{poi_table.file_num(i)+1}= eval(poi_table.poi{i});
end
for i =1:length(f_abf)
    clearvars name Data si header event_index amps poi type
    [~,name,~] = fileparts(f_abf(i).name);
    [Data,si,header] = abfload(f_abf(i).name);
    poi = poi_all{str2double(name(end-3:end))+1};
    if isVC_accelrecording(header) && ~isempty(poi)
        type = 'voltage clamp+accel';
        amp_thre = 6; diff_gap = 240; diff_thre =-8;if_2der=1;event_duration = 640;
        [event_index,amps] = EPSC_detection(Data,si,amp_thre,if_2der,diff_gap,diff_thre,event_duration);
        save(['VC_accel_' name '.mat'],'name','type','Data','si','header','event_index','amps','poi');
    end
    if isCC_accelrecording(header) && ~isempty(poi)
        type = 'current clamp+accel';
        amp_thre = 3; diff_gap = 140; diff_thre =6;if_2der=0;event_duration =1200;
        [event_index,amps] = EPSC_detection(Data,si,amp_thre,if_2der,diff_gap,diff_thre,event_duration);
        save(['CC_accel_' name '.mat'],'name','type','Data','si','header','event_index','amps','poi');
    end
end
end
function isEPSC = isVC_accelrecording(h)
    isEPSC = (h.nADCNumChannels == 4)&(strcmp(h.recChUnits{1},'pA'));
end
function isEPSP = isCC_accelrecording(h)
    isEPSP = (h.nADCNumChannels == 4)&(strcmp(h.recChUnits{1},'mV'));
end