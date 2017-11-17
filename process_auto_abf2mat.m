%{ 
When recordings are automated, a section of 8 or more recordings goes into
the same file.
This function is used to separate these recordings into individual files
so they can be analyzed the same way as the previous recordings.
%}

function process_auto_abf2mat(filename_h)
    f_abf = dir([filename_h '*.abf']);
    poi_auto=generate_poi();
    for i=1:length(f_abf)
        [~,name,~] = fileparts(f_abf(i).name);
        if f_abf(i).bytes>20*1024*1024
        [Data_all,si,header] = abfload(f_abf(i).name);
        [~,~,z]=size(Data_all);
        max_diff=max(Data_all(:,2,5))-min(Data_all(:,2,5));
        if max_diff>0.11
            poi=poi_auto{i};
            type
            for j=1:z
                Data=Data_all(:,:,j);
                save(['EPSP_' stim_label '_accel_' name '_' num2str(i) '.mat'],'name','type','Data','si','header','poi');
            end
        end
        end
    end
end

function poi=generate_poi()
    poi{1}={1:15};
    poi{2}={1:8,8:15};
    poi{3}={1:7,7:14};
    poi{4}={1:15};
    poi{5}={1:8,8:15};
    poi{6}={1:7,7:14};
    poi{7}={1:2,3:4,5.3:6.3,7.6:8.6,10:11,12:13};
    poi{8}={1:2,3:4,5.3:6.3,7.6:8.6,10:11,12:13};
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