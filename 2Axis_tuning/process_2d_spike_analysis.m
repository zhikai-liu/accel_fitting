function process_2d_spike_analysis(filename,range)
process_2d_abf2mat(filename)
process_event_detect('EPSP_2d');
fNames=dir(['EPSP_2d_accel_' filename '*']);
merge_name=process_2d_fit_linear({fNames.name},range);
process_2d_spikes_fit(merge_name)
end
