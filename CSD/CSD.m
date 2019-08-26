function CSD(fileIn)

%fileIn = 'DATA\cont48.dat';
resolution = 16;
scale = 200*2*5/2^16/200; %?
freqSampling = 30000; %%% 19531.25 20833.33 30000;
channels.num_total = 78; %Total channels recorded including Aux/ADC
channels.trig = 71; %define AUX-trigger channel
channels.num_spike = 32; %Total channels containing spike data
filter_range = [300, 6000]; %Filter used for Spike filtering
window_range = [-60:240]; %Length of time to take in samples/ 30 samples/ms
remove_stimulation = [90, 132]; %samples that occur during stimulation
channels.artifact = [];
%Channel order correct as of 6/11/19 for a32->a32om32->Whisper
channel_order = 1 + [3 4 12 5 11 10 14 6 1 7 9 8 13 2 15 0 16 31 18 29 24 19 23 28 25 20 22 27 17 21 26 30];

matrixRaw = data_read(fileIn);
[data.vlt_chan, data.aux_chan] = data_seperate(matrixRaw, channels.num_total, channels.num_spike, channels.trig);
onset_time = get_onset(data.aux_chan);
data.trig_chan = concatenate(data.vlt_chan, window_range, onset_time);
avg_lfp = data_avg(data.trig_chan, channels.num_spike, window_range, onset_time);
avg_lfp = lfp_sorter(avg_lfp, remove_stimulation);
avg_lfp_smoothed = lfp_filter(avg_lfp, data.vlt_chan, window_range, filter_range, scale);
csdi = csd_caculator(avg_lfp_smoothed, channel_order, channels.artifact);

%plot
figure(1)
clf(1)
imagesc((window_range/(freqSampling/1000)),1+[1 size(avg_lfp_smoothed,1)],avg_lfp_smoothed);
hold on
plot([0 0],[-2 size(csdi,1)+4],'LineStyle',':','Color','k')
xlabel('Time (ms)')
ylabel('Electrode number')
set(gca, 'Layer', 'top')
set(gca, 'box', 'on')
colorbar;
    