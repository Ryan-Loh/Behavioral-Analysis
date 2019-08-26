function [vlt, aux] = data_seperate(M, num_total, num_spike, triger)
%DATA_SEPERATE    Seperate the data to voltage channels and aux channels.
%   
%   [vlt_chan, aux_chan] = DATA_SEPEATE(M, num_total, num_spike, triger)
%   VLT_CHAN  - Voltage channels
%   AUX_CHAN  - Aux channels
%   M         - Data to be seperated
%   NUM_TOTAL - Number of channels
%   NUM_SPIKE - How many channel contain spikes
%   TRIGER    - The sequence of trigger channels

disp('Separating volt and aux channels');
channelReshaped = reshape(M, num_total, length(M)/num_total)';
trig_chan = channelReshaped(:, triger);

vlt = channelReshaped(:,1:num_spike);
aux = (trig_chan - mean(trig_chan)) / (std(trig_chan));
std(trig_chan)