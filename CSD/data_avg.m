function lfp = data_avg(vlt, num_spike, range, onset)
%DATA_AVG    Averaging voltage traces across Trigger window.
%
%   avg_lfp = DATA_AVG(vlt_chan, num_spike, range, onset_time)
%   AVG_LFP    - Local field potential
%   VLT_CHAN   - Voltage channels
%   NUM_SPIKE  - How many channel contain spikes
%   RANGE      - Length of time to take in samples
%   ONSET_TIME - Time of laser onsets

lfp = zeros(length(range),num_spike);
size(lfp)
for col = 1:size(lfp,2)
    z = reshape(vlt(:,col), length(range), length(onset));
    for row = 1:size(lfp,1)
       q = mean(z(row,:));
       lfp(row,col) = q;
    end
end
    