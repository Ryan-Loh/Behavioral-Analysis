    %% Define frames/trials for comparison
    num_bins = 20; %INPUT number of bins to consider for a trial
    num_trials_av = 100; %INPUT number of trials to average across
    trials = 100; %INPUT total number of trials (number of files)
    %% Preallocate
    base_files = cell(1,trials);
    isi_files = cell(1,trials);
    base_data = cell(1,trials);
    isi_data_raw = cell(1,trials);
    base_averaged = cell(1,trials);
    isi_data_calc = cell(1,trials);
    ISI_Frames = cell(1,num_bins);
    %% Load and Separate Matrices
    directory = uigetdir();
    directory_list = dir(fullfile(directory,'*.mat'));
    for ii=size(directory_list,1):-1:1
        trial_files{ii} = fullfile(directory_list(ii).folder, directory_list(ii).name);
    end
    trial_files=natsortfiles(trial_files);
    for ii=100:-1:1
        base_files{ii}=trial_files{ii};
        isi_files{ii}=trial_files{100+ii};
    end
    clear trial_files
    for ii=100:-1:1
       disp(['Working on File:', num2str(ii)]);
       x=load(base_files{ii});
       y=load(isi_files{ii});
       base_data{ii} = double(x.tmp);
       base_data{ii} = base_data{ii}./2^16-1;
       isi_data_raw{ii} = double(y.tmp);
       isi_data_raw{ii} = isi_data_raw{ii}./2^16-1;
       clear x y;
    end
    clear base_files isi_files
    %% Average Base Down to 2D Matrix
    for ii=1:size(base_data,2)
        base_averaged{ii} = mean(base_data{1,ii},3);
    end
    clear base_data
    %% Perform ISI calculation on frame-by-frame
    for ii=1:size(isi_data_raw,2)
        for jj=1:size(isi_data_raw{ii},3)
            calc=isi_data_raw{ii}(:,:,jj);
            %***MAIN CALCULATION***
            isi_data_calc{ii}(:,:,jj) = (calc-base_averaged{ii}); 
            %***MAIN CALCULATION***
        end
        disp(['Calculating ISI on file:', num2str(ii)]);
    end
    clear a b c calc directory directory_list ii isi_data_raw jj 
    %% Average all images across given number of trials
    [a, b, c]=(size(isi_data_calc{1,1}));
    x=zeros(a,b,c,num_trials_av);
    for ii=1:num_trials_av
       x(:,:,:,ii)=isi_data_calc{1,ii};
       disp(['Averaging File:', num2str(ii)]);
    end
    isi_trial_av = mean(x,4);
    clear x;
    %% Bin frames into desired bins, and present images
    num_frames = size(isi_trial_av,3);
    div=num_frames/num_bins;
    if rem(num_frames, num_bins) == 0
        for ii = 1:num_bins
            disp(['Working on Bin', num2str(ii)]);
            x=isi_trial_av(:,:,div*ii-(div-1):div*ii);
            x=mean(x,3);
            ISI_Frames{ii} = x;
            clear x;
        end
    else
        error('Total number of frames not divisible by num_bins');
    end
    clear a b c calc ii jj;
    clc;
    %% Run this to play frames as movie jj times
    
    for jj=1:10
        for ii=1:num_bins
        x=(ISI_Frames{1,ii});
        %imgaussfilt(x,2);
        imshow(x)
        caxis([mean2(x)-4e-4 mean2(x)+4e-4]);
        title(['frame', num2str(ii)]);
        pause(0.1);
        end
    end






