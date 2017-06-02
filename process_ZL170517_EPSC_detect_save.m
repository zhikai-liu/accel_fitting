f_abf = dir('ZL170517_*.abf');
amp_thre = 6; diff_gap = 240; diff_thre =-8;
poi_all = cell(length(f_abf),1);
poi_table = readtable('ZL170517_fish03a_poi.xlsx');
for i = 1:length(poi_table.Filenames)
    poi_all{poi_table.Filenames(i)+1}= {poi_table.Poi1_start(i):poi_table.Poi1_end(i)};
end
% poi_all{2} = {2:9}; poi_all{3} = {3:10}; poi_all{4} = {5:15};
% poi_all{6} = {3:15};poi_all{7} = {3:7}; poi_all{8} = {2.5:6.5};
% poi_all{9} = {3:10};poi_all{10} = {3:10};poi_all{11} = {1:14};
% poi_all{12} = {3:8};poi_all{13} = {1:9};poi_all{14} = {3:10};
% poi_all{15} = {1:14};poi_all{16} = {1:5};poi_all{17} = {2:10};
% poi_all{18} = {4:11};poi_all{23} = {2:6};poi_all{24} = {2:6};
% poi_all{25} = {1:9};poi_all{26} = {2:10};poi_all{27} = {2:7}; poi_all{28} = {2:5};
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

function isEPSC = isVC_accelrecording(h)
    isEPSC = (h.nADCNumChannels == 4)&(strcmp(h.recChUnits{1},'pA'));
end