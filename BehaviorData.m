% PROCESS VOLTAGE TRACES
clear all; drawnow;
global Analyze
%% Load Data Folders
animal_num = input('Input Animal ID:', 's'); %input animal number
[Folders] = load_folders(animal_num);

%% Read data from Folders
disp('reading data');
[Data] = read_folders(Folders);

%% Extract Data from Ephys Files
if Analyze.Ephys ~= 0
    disp('extracting Ephys data');
    [Data] = read_ephys_metadata(Data);
    [Data] = read_ball_data(Data);
    %[Data] = read_ephys_data(Data);
end
%% Extract Whisker Trial Data from files
if Analyze.Whisker ~= 0
    disp('extracting whisker data');
    [Data] = read_whisker_data_files(Data);
end
%% Extract and Plot Ball Data from Ephys Files
if ~isempty(Data.Ephys_Ball_Data)
    disp('extracting ball data');
    [Data] = calc_ball_data(Data);
    plot_ball_data(Data);
end


%%% Take Ball Values and Output Mouse position graphs
% % Conversion of Camera signals to ball motion;
% % Ball_Chan = raw voltage data from 4 ball channels (Vx0, Vy0, Vx1, Vy1) in that order;
% 
% disp('Calculating ball velocity');
% 
% scale_adjust = 1.6;  % Account for whisper camera voltages resting ~4.0V instead of 2.5V;
% avg_factor = 100;    % Number of samples to average over for final graphs
% zero_V=[3.8255, 4.0086, 4.0647, 4.0958]; % Avg voltage of non-moving ball from whisper (divided by scale_adjust).
% Ball_Chan=ball_channels(:,1:4);  
% Ball_Chan=Ball_Chan./1000;  % Ball voltages in V
% step_V=0.145;               % Step value in V
% cam_vel_steps=round((Ball_Chan-zero_V)./step_V)./scale_adjust; %Calculating voltage step values from raw
% A_calib={[-.3440, 5.4480, 0.2265, -0.3738] [0.2564, -0.1580, 0.1903, -4.5241]}; %Calibration values given
% disp('Completed');
% 
% %% Smooth all ball channels using sgolay filter over 501 samples
% disp('Smoothing ball channel data using sgolay filter');
% for ii=1:4
%     tmp=smooth(cam_vel_steps(:,ii),501,'sgolay'); 
%     Ball_Chan(:,ii)=tmp;
% end
% %take cumulative sum over samples and multiply by calibration values
% for_ball_motion=A_calib{1}.*cumsum(Ball_Chan);
% lat_ball_motion=A_calib{2}.*cumsum(Ball_Chan);
% for_ball_vel=A_calib{1}.*(Ball_Chan);
% lat_ball_vel=A_calib{2}.*(Ball_Chan);
% 
% BallVelocity=sqrt((lat_ball_vel(:,2)).^2+(for_ball_vel(:,4)).^2);
% BallAngle=rad2deg(atan(lat_ball_vel(:,2))./(for_ball_vel(:,4)));
% 
% %take average values over (avg_factor) number of samples and apply to
% %forward and lateral ball movement.
% for col=1:4
%     S=numel(for_ball_motion(:,col));
%     xx=reshape(for_ball_motion(1:S - mod(S,avg_factor), col), avg_factor, (S-mod(S,avg_factor))/avg_factor);
%     y=squeeze(sum(xx,1)/avg_factor);
%    Avg_For_Ball_Chan(:,col)=y; 
% end
% for kk=1:4
%     T=numel(lat_ball_motion(:,kk));
%     xxx=reshape(lat_ball_motion(1:T - mod(T,avg_factor), kk), avg_factor, (T-mod(T,avg_factor))/avg_factor);
%     yy=squeeze(sum(xxx,1)/avg_factor);
%    Avg_Lat_Ball_Chan(:,col)=yy; 
% end
% 
% clear('ans', 'col', 'fid', 'ii', 'jj', 'kk', 'row', 'S', 'T', 'tmp', 'xx', 'xxx', 'y', 'yy');
% 
% %Plot 
% figure(1); plot(Avg_For_Ball_Chan(:,2),Avg_Lat_Ball_Chan(:,4));
% disp('Completed');
% 
% %% Display individual and averaged traces over trial time
% % Detect File Triggers
% disp('Detecting File Triggers');
%     trial_onset_times = find(trial_trig_chan(:) > 3000);
%         if length(trial_onset_times) > 1
%             rmv_ind = diff(trial_onset_times) <= 1; % takes only one onset time per trigger 
%             rmv_ind =[false;rmv_ind];         % instance per onset time
%             trial_onset_times(rmv_ind) = [];        
%         end
%         wcamera_onset_times = find(cam_trig_chan(:) > 3000);
%         if length(wcamera_onset_times)>1
%             rmv_ind = diff(wcamera_onset_times) <=1;
%             rmv_ind = [false;rmv_ind];
%             wcamera_onset_times(rmv_ind) = [];
%         end
% disp('Completed');
% 
% %% Take ball data around each trial 
% disp('Taking ball data +/- 0.5s around trial');
% trial_window=[-6250:STS+6249];
% trial_samples=(trial_onset_times+trial_window).';
% trial_samples=reshape(trial_samples, [], 1);
% ball_trial_data=zeros(size(trial_samples,1),size(cam_vel_steps,2));
% for col=1:size(cam_vel_steps,2)
%     ball_trial_data(:,col)=for_ball_motion(trial_samples,col);
% end
% ball_trial_data=ball_trial_data.*SecPerSamp;
% Ball_Channel_Trials.x0 = reshape(ball_trial_data(:,1),size(trial_window,2),length(trial_onset_times));
% Ball_Channel_Trials.y0 = reshape(ball_trial_data(:,2),size(trial_window,2),length(trial_onset_times));
% Ball_Channel_Trials.x1 = reshape(ball_trial_data(:,3),size(trial_window,2),length(trial_onset_times));
% Ball_Channel_Trials.y1 = reshape(ball_trial_data(:,4),size(trial_window,2),length(trial_onset_times));
% disp('Completed');
% figure(2); plot(Ball_Channel_Trials.y0, Ball_Channel_Trials.y1);
% 
% %% Removing low-velocity trials
% disp('Getting Trial-average Velocity and removing trials under threshold');
% trial_velocity = zeros(SPS, length(bin_file_list));
% for col = 1:size(trial_velocity,2)
%     tmp=BallVelocity(col*SPS-SPS+1:col*SPS);
%     trial_velocity(:,col)=tmp;
% end
% trial_avg_velocity = mean(trial_velocity);
% velocitythresh=0.05;
% velocitylog=trial_avg_velocity<velocitythresh;
% 
% Filt_Ball_Channel_Trials.x0 = Ball_Channel_Trials.x0(:,~velocitylog);
% Filt_Ball_Channel_Trials.y0 = Ball_Channel_Trials.y0(:,~velocitylog);
% Filt_Ball_Channel_Trials.x1 = Ball_Channel_Trials.x1(:,~velocitylog);
% Filt_Ball_Channel_Trials.y1 = Ball_Channel_Trials.y1(:,~velocitylog);
% figure(3); plot(Filt_Ball_Channel_Trials.y0, Filt_Ball_Channel_Trials.y1);
% disp('Completed');
% 
% %% Calculating Hypot for each trial 
% disp('Calculating Hypoteneuse for each trial');
% Hypot_Ball_Channels=zeros(1,size(Ball_Channel_Trials.y0,2));
% for col=1:size(Ball_Channel_Trials.y0,2)
%     A=Ball_Channel_Trials.y0(end,col)-Ball_Channel_Trials.y0(1,col);
%     B=Ball_Channel_Trials.y1(end,col)-Ball_Channel_Trials.y1(1,col);
%     tmp=hypot(A,B);
%     Hypot_Ball_Channels(1,col)=tmp;
% end
% hypot_thresh = 3.0;
% hypotlog = Hypot_Ball_Channels>hypot_thresh;
% 
% Hypot_Ball_Channel_Trials.x0 = Ball_Channel_Trials.x0(:,(hypotlog & ~velocitylog));
% Hypot_Ball_Channel_Trials.y0 = Ball_Channel_Trials.y0(:,(hypotlog & ~velocitylog));
% Hypot_Ball_Channel_Trials.x1 = Ball_Channel_Trials.x1(:,(hypotlog & ~velocitylog));
% Hypot_Ball_Channel_Trials.y1 = Ball_Channel_Trials.y1(:,(hypotlog & ~velocitylog));
% 
% disp('Completed');
% 
% %% Placing trial ball data on single plot
% disp('Plotting Ball trial data');
% Ball_Plot = zeros(size(Hypot_Ball_Channel_Trials.y0,1),2*size(Hypot_Ball_Channel_Trials.y0,2));
% figure(4);
% for col=1:size(Hypot_Ball_Channel_Trials.x0,2)
%     tmp=Hypot_Ball_Channel_Trials.y0(:,col)-Hypot_Ball_Channel_Trials.y0(1,col);
%     Ball_Plot(:,(2*col)-1)=tmp;
%     tmp=Hypot_Ball_Channel_Trials.y1(:,col)-Hypot_Ball_Channel_Trials.y1(1,col);
%     Ball_Plot(:,(2*col))=tmp;
%     hold on
%     plot(Ball_Plot(:,(2*col)-1),Ball_Plot(:,2*col));
% end
% disp('Completed');
% %% Averaging ball trial data
% disp('Averaging ball trial data and graphing');
% names=fieldnames(Ball_Channel_Trials);
% 
% for ii=1:numel(names)
%     for col=1:length(bin_file_list)
%         S=numel(Ball_Channel_Trials.(names{ii})(:,col));
%         xx=reshape(Ball_Channel_Trials.(names{ii})(1:S - mod(S,avg_factor), col), avg_factor, S/avg_factor);
%         y=squeeze(sum(xx,1)/avg_factor);
%         Avg_Ball_Channel_Trials.(names{ii})(:,col)=y; 
%     end
% end
% disp('Completed')
% 
% %% Getting Whisker Data from .xlsx file
% % First need to load metadata into Excel via Data>From Text/CSV>SaveAs>
% disp('Reading Whisker Excel File');
% whisker_data_raw=xlsread(whisker_data_file);
% wdata(:,1)=wcamera_onset_times;
% wdata(:,2:3)=whisker_data_raw(:,[2 9]);
% w_angle_smoothed=smooth(wdata(:,3),501,'sgolay');
% w_angle_filtered=lowpass(w_angle_smoothed,25,25e3);
% w_angle_hilbert=hilbert(w_angle_filtered);
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% disp('Completed');
