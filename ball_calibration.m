function [A_calib, Zero_V, Step_V] = ball_calibration()

% Load Directory
    direct=uigetdir('Select directory containing Ball Calibration Ephys Recordings');
    bin_file_list = dir(fullfile(direct,'*.bin'));
    metadata_file_list = dir(fullfile(direct,'*.meta'));
    bin_file_list = fullfile({bin_file_list.folder},{bin_file_list.name});
    metadata_file_list = fullfile({metadata_file_list.folder},{metadata_file_list.name});
    
% Load and Shape Data
    % PreAllocate
    sizebin=size(bin_file_list,2);
    Data.Raw = cell(sizebin, 1);
    %Load file and get file time
    for ii=1:sizebin
        fid=tdfread(metadata_file_list{1,ii});
        y=struct2cell(fid);
        y=cellstr(y{1,1});
        Data.Filetime_Raw{1,ii} = y;
        file_time_mask{ii}=~cellfun(@isempty, strfind(y, 'fileTimeSecs'));
        Data.Filetime_Raw{ii} = y(file_time_mask{ii});
        yf=cell2mat(isstrprop(Data.Filetime_Raw{ii} ,'digit'));
        tf=cell2mat(isstrprop(Data.Filetime_Raw{ii} ,'punct'));
        zf=yf|tf;
        xx=cell2mat(Data.Filetime_Raw{ii});
        Data.metadata_filetime(1,ii)=(str2double(xx(zf)))';
    %Get and shape raw data
        Data.Raw{ii,1}=zeros(8, int32(25000*Data.metadata_filetime(ii)));
        fid = fopen(bin_file_list{1,ii},'r');
        Raw = fread(fid,inf,'int16');
        fclose(fid);
        Data.Unshaped{ii,1}=Raw;
        for jj=1:8
            tmp=Data.Unshaped{ii,1}(jj:8:size(Data.Unshaped{ii,1},1));
            Data.Raw{ii,1}=bin_file_list{1,ii};
            Data.Raw{ii,2}(jj,:)=tmp;
        end
        clear Raw;
        Data.Raw{ii,2}(1:4,:)=[];
    end
% Scale voltage
    Volt_Max = 5;
    Volt_Min = -5;
    ADC_bits = 16;
    gain = 0.25;
    scale = ((Volt_Max-Volt_Min)./(2.^ADC_bits))./gain;
    for ii=1:sizebin
        Data.Raw{ii, 2} = Data.Raw{ii, 2}.*scale;
    end

% Calculate Zero_V
    X0mean = mean(Data.Raw{4,2}(1,:));
    Y0mean = mean(Data.Raw{4,2}(2,:));
    X1mean = mean(Data.Raw{4,2}(3,:));
    Y1mean = mean(Data.Raw{4,2}(4,:));
    Zero_V = [X0mean, Y0mean, X1mean, Y1mean];
    
%Visually inspect graphs, determine step voltage
    Step_V = 0.145;
    
% Calculate A_Calib
    % Calculate Pitch (Fwd/Backward) Roll (Lateral) and Yaw (Rotate around
    % x axis)
        %Move ball as close to straight forward for 10 times, sum and
        %divide by 10. 
    Ball_C = 39.37*pi; %Ball circumference in cm 
    for ii=1:size(Data.Raw{1,2},1)
        for jj = 1:size(Data.Raw{1,2},1)
            cam_vel_steps{ii,1} = Data.Raw{ii,1};
            tmp = round((Data.Raw{ii,2}(jj,:)-Zero_V(jj))./0.145);
            cam_vel_steps{ii,2}(jj,:) = tmp;
        end
    end

    A_Calib.Pitch = [0, 0.04, 0, 0]; 
    A_Calib.Roll = [0, 0, 0, -1]; 
    A_Calib.Yaw = [1, 1, 1, 1];
        
end
    

