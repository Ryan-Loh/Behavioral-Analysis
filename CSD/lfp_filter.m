function lfp_smoothed = lfp_filter(lfp, vlt, range, filter, resolution)
%LFP_FILTER    Filtering and smoothing traces across trigger window.
%
%   avg_lfp_smoothed = LFP_FILTER(avg_lfp, vlt_chan, range, filter, resolution)
%   AVG_LFP_SMOOTHED - Smoothed and averaged Long field potential
%   AVG_LFP          - Averaged local field potential
%   VLT_CHAN         - Voltage channels
%   RANGE            - Length of time to take in samples
%   FILTER           - Filter used for spike filtering
%   RESOLUTION       - The recording resolution

lfp_smoothed = lfp;

for i_ch = 1:size(vlt,2)
    tmp = lfp(:,i_ch) * 1.525878906250000e-04;
    tmp = timeseries(tmp, length(range));
    
    tmp = idealfilter(tmp, filter, 'pass');
    lfp_smoothed(:,i_ch) = tmp.data;
end
