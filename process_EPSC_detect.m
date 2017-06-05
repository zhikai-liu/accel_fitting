function process_EPSC_detect(filename_h)
f_abf = dir([filename_h '*.abf']);
amp_thre = 6; diff_gap = 240; diff_thre =-8;
poi_all = cell(length(f_abf),1);
poi_table = readtable([filename_h '_poi.xlsx']);
for i = 1:length(poi_table.Filenames)
    poi_all{poi_table.Filenames(i)+1}= {poi_table.Poi1_start(i):poi_table.Poi1_end(i)};
end
for i =1:length(f_abf)
    clearvars name Data si event_index amps poi type
    [~,name,~] = fileparts(f_abf(i).name);
    [Data,si,h] = abfload(f_abf(i).name);
    if isVC_accelrecording(h) && ~isempty(poi_all{i})
        type = 'EPSC';
        [event_index,amps] = EPSC_detection(Data,si,amp_thre,diff_gap,diff_thre);
        poi = poi_all{i};
        save([name '.mat'],'name','type','Data','si','event_index','amps','poi');
    end
end
end
function isEPSC = isVC_accelrecording(h)
    isEPSC = (h.nADCNumChannels == 4)&(strcmp(h.recChUnits{1},'pA'));
end