function process_fista_main(filename)
%% See cell access before concatenate them together
process_cell_opening(filename);
%% Concatenate recordings together for events detection
pad_multi_mat(filename,range);
%% Events detection using a two-template sparse deconvolution method(fista_2tem)
process_fista_2tem_detect(filename);
%% Clustering events
process_fista_clust(filename);
%% Calculate the amplitude of events 
process_fista_get_amps(filename)
%% Plot the results from fista and clustering
process_plot_fista_results(filename);
%% Merge or remove cluster, also mark the clusters that are clean on autocorrelogram
process_merge_cluster(filename,m_clusters);
%% Mark mixed synapses/ chemical EPSCs
process_fista_IDmixed(fielname,clust)
%% Redistribute fista results back to individual recording files
process_fista_redist(filename)

process_2d_fit_linear()
process_2d_linear_polar_plot()
process_2d_CW_CCW_plot()
end
