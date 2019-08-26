%% Load File
disp(['Loading File']);
clear all
close all
drawnow
base_dir = 'D:\Projects\Users\Ryan\Data\714\Ephys\714_2018-08-29_16-34-54_10.0exp\experiment1\recording1\continuous'; %Full filepath of "run" file
f_name = ['continuous']; %actual filename
scale = 200*2*5./2.^16/200;
ch_common_noise = [1:64];
freqSampling = 30000; %%% 19531.25 20833.33 30000;
ch_ids.num_tot = 78; %Total channels recorded including Aux/ADC 
ch_ids.num_spike = 64; %Total channels containing spike data
ch_ids.aux = [1]; %Total number of aux channels 
f_name_full = fullfile(base_dir,'Rhythm_FPGA-100.0',[f_name '.dat']);
disp(['Completed']);
%% PROCESS RAW VOLTAGE
disp(['Processing Raw Voltage']);
    disp(['Reading file ',f_name_full]);
    fid = fopen(f_name_full,'r');
    matrixRaw=fread(fid,inf,'int16');
    fclose(fid);
disp(['Completed']);
%% Convert to double and scale voltage    
disp(['Reshaping Raw Voltage']);
      matrixVol = double(10*(matrixRaw-(sign(matrixRaw-2^15)+1)*2^15)/2^16);
      matrixVol = double(matrixRaw);
      ch_all_raw = reshape(matrixVol,ch_ids.num_tot,(size(matrixVol,1)./ch_ids.num_tot))';
disp(['Completed']);
%% Separate voltage chanels from trigger channel, Z-score trigger
disp(['Separating volt and aux channels']);
    vlt_chan = ch_all_raw(:,1:ch_ids.num_spike);
    trig_chan = ch_all_raw(:,[71]);
    TimeStamps = (0 : size(vlt_chan, 1)-1)/freqSampling;
    z_trig_chan = (trig_chan-mean(trig_chan))/(std(trig_chan));
disp(['Completed']);
%% smooth 60hz
disp(['reducing 60hz noise']);
filt_vlt_chan=zeros(size(vlt_chan));
[row col]=size(vlt_chan);
for i=1:col
    filt=sgolayfilt(vlt_chan(:,i),1,17);
    filt_vlt_chan(:,i)=filt;
end
disp(['Completed']);
%% reshape samples and resave as .dat file
tic
disp(['Unreshaping samples and saving as .dat file']);
filt_vlt_chan(:,65)=ch_all_raw(:,71);
filt_vlt_chan=reshape(filt_vlt_chan,1,647096320);
dlmwrite('filtered.dat',filt_vlt_chan);
disp(['Completed']);
toc
    