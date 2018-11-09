%{
  This funtion is used to convert .abf to .mat
  The .mat file stores all data in a structure with fields like:

  name: name of the original file
  Data: recording data
  si: Sampling intervals
  header: header of the file
%}

function process_abf2mat(filename_h)
f_abf = dir([filename_h '*.abf']);
for i =1:length(f_abf)
    clearvars name Data si header
    [~,name,~] = fileparts(f_abf(i).name);
    [Data,si,header] = abfload(f_abf(i).name);
    save([name '.mat'],'name','Data','si','header');
end
end