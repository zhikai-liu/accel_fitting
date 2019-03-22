%{ 
When recordings are automated, a section of more than one recording goes into
the same file.
This function is used to separate these recordings into individual files
so they can be analyzed the same way as the previous recordings.
%}

function process_batch_abf2mat(filename_h)
    f_abf = dir([filename_h '*.abf']);
    for i=1:length(f_abf)
        [~,abf_name,~] = fileparts(f_abf(i).name);
        [Data_all,si,header] = abfload(f_abf(i).name);
            switch type_of_rec(header,Data_all(:,:,1)) 
                case 1
                    type={'EPSC'};
                case 2
                    type={'IPSC'};
                case 3
                    type={'IPSP'};
                case 4
                    type={'EPSP'};
            end
            for j=1:size(Data_all,3)
                Data=Data_all(:,:,j);
                name=[abf_name '_' num2str(j,'%.2d')];
                save([name '.mat'],'name','type','Data','si','header');
            end
    end
end

function rec_type = type_of_rec(h,data)
    rec_type = 0;
    if (strcmp(h.recChUnits{1},'pA'))
        if median(data(:,1))>mean(data(:,1)) % spikes are down, EPSC
            rec_type = 1;
        else % spikes are up, IPSC
            rec_type = 2;
        end
    elseif (strcmp(h.recChUnits{1},'mV'))
        if median(data(:,1))>mean(data(:,1)) % spikes are down, IPSP
            rec_type = 3;
        else % spikes are up, EPSP
            rec_type = 4;
        end 
    end
end