function CSDI = csd_caculator(lfp, ch_order, af)
%CSD_CACULATOR    Visualize and standardize to channels average of first 10
%timestamps, then make and smooth CSD Matrix.
%
%   csdi = CSD_CACULATOR(avg_lfp_smoothed, channel_order, artifact)
%   CSDI             - Smoothed CSD matrix
%   AVG_LFP_SMOOTHED - Smoothed and averaged local field potential
%   CHANNEL_ORDER    - Order of the channels
%   ARTIFACT         - Artifact channels

reordered_avg = lfp(:, ch_order);
reordered_avg(:,33:64)= [];
reordered_avg(:, af)= [];
        
reordered_avg = (reordered_avg');
for row = 1:size(reordered_avg,1)
    reordered_avg(row,:) = reordered_avg(row,:) - mean(reordered_avg(row,1:30));
end

CSDI = zeros(size(reordered_avg));
for col = 1:size(reordered_avg,2)
    tmp = reordered_avg(:,col);
    tmp = csaps(1:size(reordered_avg,1),tmp,0.1);
    tmp = fnder(tmp,2);
    tmp = fnval(1:size(reordered_avg,1),tmp);
    CSDI(:,col) = tmp;
end