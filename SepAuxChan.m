%% Load File
disp(['Loading File']);
clear all
close all
drawnow
base_dir = 'D:\Projects\Users\Ryan\Data\714\Ephys\714_2018-08-29_16-28-01_5.0exp\experiment1\recording1\continuous'; %Full filepath of "run" file
new_aux_file = 'D:\Projects\Users\Ryan\Data\714\Ephys\714_2018-08-29_16-28-01_5.0exp\experiment1\recording1\continuous\Rhythm_FPGA-100.0\continuous_aux.dat';
new_timestamps_file = 'D:\Projects\Users\Ryan\Data\714\Ephys\714_2018-08-29_16-28-01_5.0exp\experiment1\recording1\continuous\Rhythm_FPGA-100.0\continuous_timestamps.csv';
f_name = ['continuous']; %actual filename
ch_ids.num_tot = 78; %Total channels recorded including Aux/ADC 
ch_ids.num_spike = 64; %Total channels containing spike data
ch_ids.aux = [1]; %Total number of aux channels 
freqSampling = 30000;
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
    TimeStamps = (0 : size(vlt_chan, 1)-1)/freqSampling;
    trig_chan = ch_all_raw(:,[71]);
disp(['Completed']);
%% Saving Aux File
disp(['Saving New Files']);
fid=fopen(new_aux_file,'w');
fwrite(fid,trig_chan,'int16');
fclose(fid);
fid=fopen(new_timestamps_file,'w');
fwrite(fid,TimeStamps,'int16');
fclose(fid);
disp(['Completed']);
    