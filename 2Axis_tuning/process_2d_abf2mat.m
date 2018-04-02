%{ 
When recordings are automated, a section of 8 or more recordings goes into
the same file.
This function is used to separate these recordings into individual files
so they can be analyzed the same way as the previous recordings.
%}

function process_2d_abf2mat(filename_h)
    f_abf = dir([filename_h '*.abf']);
    poi_2d=generate_poi();
    for i=1:length(f_abf)
        [~,abf_name,~] = fileparts(f_abf(i).name);
        if f_abf(i).bytes>20*1024*1024
        [Data_all,si,header] = abfload(f_abf(i).name);
        [~,~,z]=size(Data_all);
            stim_label='2d_accel';
            switch type_of_rec(header,Data_all(:,:,1)) 
                case 1
                    type={'EPSC',stim_label};
                case 2
                    type={'IPSC',stim_label};
                case 4
                    type={'EPSP',stim_label};
            end
            for j=1:6
                poi=poi_2d{j};
                Data=Data_all(:,:,j);
                name=[abf_name '_' num2str(j)];
                save([type{1} '_' stim_label '_' name '.mat'],'name','type','Data','si','header','poi');
            end
        end
    end
end

function poi=generate_poi()
    poi=cell(6,1);
    for i=1:6
        poi{i}={1:9};
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