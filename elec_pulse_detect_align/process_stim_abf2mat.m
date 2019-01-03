function process_stim_abf2mat(filename_h)

f_abf = dir([filename_h '*.abf']);
for i =1:length(f_abf)
    clearvars name Data si header
    [~,name,~] = fileparts(f_abf(i).name);
    [Data,si,header] = abfload(f_abf(i).name);
    [D_x,D_y,D_z]=size(Data);
    if header.nADCNumChannels==2 && D_z>=100
    save(['stim_' name '.mat'],'name','Data','si','header');
    end
end

end