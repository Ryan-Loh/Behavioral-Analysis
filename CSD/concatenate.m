function trig = concatenate(vlt, range, onset)
%CONCATENATE    Extract the trigger channel.
%   
%   trig = CONCATENATE(vlt_chan, window_range, onset_time)
%   TRIG       - The trigger channel
%   VLT_CHAN   - Voltage channels
%   RANGE      - Length of time to take in samples
%   ONSET_TIME - Time of laser onsets

concat_samples = onset + range;
concat_samples = reshape(concat_samples,[],1);
concat_samples = sort(concat_samples);
    
trig = zeros(length(concat_samples),size(vlt,2));

for col = 1:size(vlt,2)
    trig(:, col) = vlt(concat_samples(:), col);
end