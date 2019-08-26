%% PROCESS VOLTAGE TRACES

%input file location of behavioral data trials
base_dir = 'Z:\Projects\Users\Ryan\Data\114\Ephys\Run_01'; %Full filepath .bin files
wall_folder = 'Z:\Projects\Users\Ryan\Data\114\Behavior'; %Full filepath of .xlsx files
%search for specified file type in base_dir
wall_file_list=dir(fullfile(wall_folder,'*.xlsx'));
bin_file_list=dir(fullfile(base_dir,'*.bin'));
f_name_full = fullfile(base_dir,{bin_file_list.name});
w_name_full = fullfile(wall_folder,{wall_file_list.name});
init_wall_distance = 35; %starting wall distance defined in MATLAB BPOD script
% Define channels, trial/trigger time, and sampling rate
freqSampling = 25000; %Sampling Rate
SecPerSamp = 1/freqSampling;
ch_ids.num_tot = 39; %Total channels recorded including Aux/ADC 
ch_ids.num_spike = 32; %Total channels containing spike data
ch_ids.file_trigger = [34]; %Number of channel that IDs file trigger
ch_ids.aux = 8; %Total number of aux channels 
ch_ids.artifact = []; %Any dead channels
ind_file_time = 8.50; %individual file time in seconds + 10ms buffer
trial_time = 8.50; %Total trial time of saved files
trigger_time = 6; %Total time of file trigger

SPS = trial_time*freqSampling;
STS = trigger_time*freqSampling;

%% PROCESS RAW VOLTAGE
disp('Processing Raw Voltage');
TrialsAllChanRaw=zeros(round(ch_ids.num_tot*freqSampling*ind_file_time),length(bin_file_list));
    for ii=1:length(bin_file_list)
        fid = fopen(char(f_name_full{ii}),'r');
        % Read a full file
        Raw=fread(fid,inf,'int16');
        fclose(fid);
        TrialsAllChanRaw(1:length(Raw),ii)=Raw;
    end
for ii=1:size(TrialsAllChanRaw,2)
    n(ii)=find(TrialsAllChanRaw(:,ii),1,'last');
    m=min(n);
end
TrialsAllChanRaw(m+1:end,:)=[];
clear('ii', 'm', 'n', 'Raw');
disp('Completed');

%% Generate wall data from final wall position
disp('Generating wall files');
WallRaw=zeros(length(wall_file_list), 1);
for ii=1:length(w_name_full)
    Raw=xlsread(w_name_full{ii});
    WallRaw(1:length(Raw),ii)=Raw;
    WallRaw=50-WallRaw;
end


disp('Completed');
%% Convert to double and reshape voltage
disp('Reshaping Raw Voltage');
ChanAllTrialsRaw=zeros(SPS*size(TrialsAllChanRaw,2),ch_ids.num_tot);
    for col=1:size(TrialsAllChanRaw,2)
        for row=1:ch_ids.num_tot
            tmp=TrialsAllChanRaw(row:ch_ids.num_tot:end,col);
            ChanAllTrialsRaw((SPS*col)-(SPS-1):size(tmp,1),col)=tmp;
        end
    end
disp('Completed');

%% Separate voltage chanels from trigger channel, Z-score trigger
disp('Separating volt and aux channels');
    spike_channels = ChanAllTrialsRaw(:,1:ch_ids.num_spike);
    aux_channels = ChanAllTrialsRaw(:,ch_ids.num_spike+1:end);
    trig_chan = ChanAllTrialsRaw(:,ch_ids.file_trigger);
    TimeStamps = (0:size(spike_channels, 1)-1)./freqSampling;
    z_trig_chan = (trig_chan-mean(trig_chan))/(std(trig_chan));
    ball_channels = ChanAllTrialsRaw(:,35:38);
    clock_channel = ChanAllTrialsRaw(:,34); 
disp('Completed');

%% Take Ball Values and Output Mouse position graphs
% Conversion of Camera signals to ball motion;
% Ball_Chan = raw voltage data from 4 ball channels (Vx0, Vy0, Vx1, Vy1) in that order;

disp('Calculating ball velocity from ball voltage and graphing');

scale_adjust = 1.6;  % Account for whisper camera voltages resting ~4.0V instead of 2.5V;
avg_factor = 100;    % Number of samples to average over for final graphs
zero_V=[3.8255, 4.0086, 4.0647, 4.0958]; % Avg voltage of non-moving ball from whisper (divided by scale_adjust).
Ball_Chan=ball_channels(:,1:4);  
Ball_Chan=Ball_Chan./1000;  % Ball voltages in V
step_V=0.145;               % Step value in V
cam_vel_steps=round((Ball_Chan-zero_V)./step_V)./scale_adjust; %Calculating voltage step values from raw
A_calib={[-.3440, 5.4480, 0.2265, -0.3738] [0.2564, -0.1580, 0.1903, -4.5241]}; %Calibration values given

%% Smooth all ball channels using sgolay filter over 501 samples
for ii=1:4
    tmp=smooth(cam_vel_steps(:,ii),501,'sgolay'); 
    Ball_Chan(:,ii)=tmp;
end
%take cumulative sum over samples and multiply by calibration values
for_ball_motion=A_calib{1}.*cumsum(Ball_Chan);
lat_ball_motion=A_calib{2}.*cumsum(Ball_Chan);
for_ball_vel=A_calib{1}.*(Ball_Chan);
lat_ball_vel=A_calib{2}.*(Ball_Chan);

BallVelocity=sqrt((lat_ball_vel(:,2)).^2+(for_ball_vel(:,4)).^2);
BallAngle=rad2deg(atan(lat_ball_vel(:,2))./(for_ball_vel(:,4)));

%take average values over (avg_factor) number of samples and apply to
%forward and lateral ball movement.
for col=1:4
    S=numel(for_ball_motion(:,col));
    xx=reshape(for_ball_motion(1:S - mod(S,avg_factor), col), avg_factor, S/avg_factor);
    y=squeeze(sum(xx,1)/avg_factor);
   Avg_For_Ball_Chan(:,col)=y; 
end
for kk=1:4
    T=numel(lat_ball_motion(:,kk));
    xxx=reshape(lat_ball_motion(1:T - mod(T,avg_factor), kk), avg_factor, T/avg_factor);
    yy=squeeze(sum(xxx,1)/avg_factor);
   Avg_Lat_Ball_Chan(:,col)=yy; 
end

clear('ans', 'col', 'fid', 'ii', 'jj', 'kk', 'row', 'S', 'T', 'tmp', 'xx', 'xxx', 'y', 'yy');

%Plot 
figure(1); plot(Avg_For_Ball_Chan(:,2),Avg_For_Ball_Chan(:,4));
disp('Completed');

%% Display individual and averaged traces over trial time
% Detect File Triggers
disp('Detecting File Triggers');
    onset_times = find(trig_chan(:) > 3000);
        if length(onset_times) > 1
            rmv_ind = diff(onset_times) <= 1; % takes only one onset time per trigger 
            rmv_ind =[false;rmv_ind];         % instance per onset time
            onset_times(rmv_ind) = [];        
        end
disp('Completed');

%% Take ball data around each trial 
disp('Taking ball data +/- 0.5s around trial');
trial_window=[-6250:STS+6249];
trial_samples=(onset_times+trial_window).';
trial_samples=reshape(trial_samples, [], 1);
ball_trial_data=zeros(size(trial_samples,1),size(cam_vel_steps,2));
for col=1:size(cam_vel_steps,2)
    ball_trial_data(:,col)=for_ball_motion(trial_samples,col);
end
ball_trial_data=ball_trial_data.*SecPerSamp;
Ball_Channel_Trials.x0 = reshape(ball_trial_data(:,1),size(trial_window,2),length(bin_file_list));
Ball_Channel_Trials.y0 = reshape(ball_trial_data(:,2),size(trial_window,2),length(bin_file_list));
Ball_Channel_Trials.x1 = reshape(ball_trial_data(:,3),size(trial_window,2),length(bin_file_list));
Ball_Channel_Trials.y1 = reshape(ball_trial_data(:,4),size(trial_window,2),length(bin_file_list));
disp('Completed');
figure(2); plot(Ball_Channel_Trials.y0, Ball_Channel_Trials.y1);

%% Removing low-velocity trials
disp('Getting Trial-average Velocity and removing trials under threshold');
trial_velocity = zeros(SPS, length(bin_file_list));
for col = 1:size(trial_velocity,2)
    tmp=BallVelocity(col*SPS-SPS+1:col*SPS);
    trial_velocity(:,col)=tmp;
end
trial_avg_velocity = mean(trial_velocity);
velocitythresh=0.10;
velocitylog=trial_avg_velocity<velocitythresh;

Filt_Ball_Channel_Trials.x0 = Ball_Channel_Trials.x0(:,~velocitylog);
Filt_Ball_Channel_Trials.y0 = Ball_Channel_Trials.y0(:,~velocitylog);
Filt_Ball_Channel_Trials.x1 = Ball_Channel_Trials.x1(:,~velocitylog);
Filt_Ball_Channel_Trials.y1 = Ball_Channel_Trials.y1(:,~velocitylog);
figure(3); plot(Filt_Ball_Channel_Trials.y0, Filt_Ball_Channel_Trials.y1);
disp('Completed');

%% Calculating Hypot for each trial 
disp('Calculating Hypoteneuse for each trial');
Hypot_Ball_Channels=zeros(1,size(Ball_Channel_Trials.y0,2));
for col=1:size(Ball_Channel_Trials.y0,2)
    A=Ball_Channel_Trials.y0(end,col)-Ball_Channel_Trials.y0(1,col);
    B=Ball_Channel_Trials.y1(end,col)-Ball_Channel_Trials.y1(1,col);
    tmp=hypot(A,B);
    Hypot_Ball_Channels(1,col)=tmp;
end
hypot_thresh = 5.0;
hypotlog = Hypot_Ball_Channels>hypot_thresh;

Hypot_Ball_Channel_Trials.x0 = Ball_Channel_Trials.x0(:,(hypotlog & ~velocitylog));
Hypot_Ball_Channel_Trials.y0 = Ball_Channel_Trials.y0(:,(hypotlog & ~velocitylog));
Hypot_Ball_Channel_Trials.x1 = Ball_Channel_Trials.x1(:,(hypotlog & ~velocitylog));
Hypot_Ball_Channel_Trials.y1 = Ball_Channel_Trials.y1(:,(hypotlog & ~velocitylog));

disp('Completed');

%% Placing trial ball data on single plot
disp('Plotting Ball trial data');
Ball_Plot = zeros(size(Hypot_Ball_Channel_Trials.y0,1),2*size(Hypot_Ball_Channel_Trials.y0,2));
figure(4);
for col=1:size(Hypot_Ball_Channel_Trials.x0,2)
    tmp=Hypot_Ball_Channel_Trials.y0(:,col)-Hypot_Ball_Channel_Trials.y0(1,col);
    Ball_Plot(:,(2*col)-1)=tmp;
    tmp=Hypot_Ball_Channel_Trials.y1(:,col)-Hypot_Ball_Channel_Trials.y1(1,col);
    Ball_Plot(:,(2*col))=tmp;
    hold on
    plot(Ball_Plot(:,(2*col)-1),Ball_Plot(:,2*col));
end
disp('Completed');
%% Averaging ball trial data
disp('Averaging ball trial data and graphing');
names=fieldnames(Ball_Channel_Trials);

for ii=1:numel(names)
    for col=1:length(bin_file_list)
        S=numel(Ball_Channel_Trials.(names{ii})(:,col));
        xx=reshape(Ball_Channel_Trials.(names{ii})(1:S - mod(S,avg_factor), col), avg_factor, S/avg_factor);
        y=squeeze(sum(xx,1)/avg_factor);
        Avg_Ball_Channel_Trials.(names{ii})(:,col)=y; 
    end
end
disp('Completed')
