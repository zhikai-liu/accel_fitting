%{
  This funtion is used to convert .abf to .mat
  The .mat file stores all data in a structure with fields like:

  name: name of the original file
  type: what kind of recording it is (EPSC, EPSP, IPSC, 'auto' 'man')
  Data: recording data
  si: Sampling intervals
  header: header of the file
  poi: periods of interest

  Usage: A _poi.xlsx file is needed to tell which recording is useful and
  which time is the period of interest. The algorithm will only analyze the
  recordings that is noted in the .xlsx file.
%}

function process_accel_abf2mat(filename_h)
f_abf = dir([filename_h '*.abf']);
poi_all = cell(length(f_abf),1);
stim_type = cell(length(f_abf),1);
poi_table = readtable([filename_h '_poi.xlsx']);
for i = 1:length(poi_table.file_num)
    poi_all{poi_table.file_num(i)+1}= eval(poi_table.poi{i});
    stim_type{poi_table.file_num(i)+1}=poi_table.stim_type{i};
end
for i =1:length(f_abf)
    clearvars name Data si header event_index amps poi type
    [~,name,~] = fileparts(f_abf(i).name);
    [Data,si,header] = abfload(f_abf(i).name);
    poi = poi_all{str2double(name(end-3:end))+1};
    stim_label=stim_type{str2double(name(end-3:end))+1};
    if type_of_rec(header,Data) ==1 && ~isempty(poi)
        type = {'EPSC',[stim_label '_accel']};
        save(['EPSC_' stim_label '_accel_' name '.mat'],'name','type','Data','si','header','poi');
    end
    if type_of_rec(header,Data) ==2 && ~isempty(poi)
        type = {'IPSC',[stim_label '_accel']};
        save(['IPSC_' stim_label '_accel_' name '.mat'],'name','type','Data','si','header','poi');
    end
    if type_of_rec(header,Data) ==4 && ~isempty(poi)
        type = {'EPSP',[stim_label '_accel']};
        save(['EPSP_' stim_label '_accel_' name '.mat'],'name','type','Data','si','header','poi');
    end
end
end
function rec_type = type_of_rec(h,data)
    rec_type = 0;
    if (h.nADCNumChannels == 4)&&(strcmp(h.recChUnits{1},'pA'))
        if median(data(:,1))>mean(data(:,1)) % spikes are down, EPSC
            rec_type = 1;
        else % spikes are up, IPSC
            rec_type = 2;
        end
    elseif (h.nADCNumChannels == 4)&&(strcmp(h.recChUnits{1},'mV'))
        if median(data(:,1))>mean(data(:,1)) % spikes are down, IPSP
            rec_type = 3;
        else % spikes are up, EPSP
            rec_type = 4;
        end 
    end
end