function [Data] = calc_ball_data(Data)
%% Initialize Variables and preallocate

global Analyze

Calib_For = [-.3440 5.4480 0.2265 -0.3738];
Calib_Lat = [0.2564 -0.1580 0.1903 -4.5241];
Zero_V = [2.325;2.441;2.477;2.493];
step_V = 0.145;

Data.BallV_Data.VBallRawFor = cell(size(Data.Ephys_File_List,1), 1);
Data.BallV_Data.VBallRawLat = cell(size(Data.Ephys_File_List,1), 1);
Data.BallV_Data.VBallFor_Filt = cell(size(Data.Ephys_File_List,1), 1);
Data.BallV_Data.VBallLat_Filt = cell(size(Data.Ephys_File_List,1), 1);
Data.BallV_Data.BallHyp = cell(size(Data.Ephys_File_List,1), 1);
Data.Left_Turns = zeros(size(Data.Ephys_File_List,1),1);
Data.Right_Turns = zeros(size(Data.Ephys_File_List,1),1);
Data.Centered = zeros(size(Data.Ephys_File_List,1),1);

%% Convert Ball data into cm/s
    for ii=1:size(Data.Ephys_Ball_Data,1)
        Data.Ephys_Ball_Data{ii,1}=Data.Ephys_Ball_Data{ii,1};
        cam_vel_steps{ii,1}=round((Data.Ephys_Ball_Data{ii,1} - Zero_V)./step_V);
        Data.BallV_Data.VBallRawFor{ii,1}=Calib_For*cam_vel_steps{ii,1};
        Data.BallV_Data.VBallRawLat{ii,1}=Calib_Lat*cam_vel_steps{ii,1};
    end
    
%% Filter Ball Trials by average forward velocity
    for ii=1:size(Data.Ephys_Ball_Data,1)
        avfor(ii,1) = mean(Data.BallV_Data.VBallRawFor{ii,1}(:));
        ind_av = avfor > 0;
        Data.BallV_Data.VBallFor_Filt = Data.BallV_Data.VBallRawFor(ind_av);
        Data.BallV_Data.VBallLat_Filt = Data.BallV_Data.VBallRawLat(ind_av);
    end

%% Separate Left Turn, Right Turn, and Centered Trials
    if Analyze.Wall==1
        Data.Wall_Trial_Data_Filt = Data.Wall_Trial_Data(ind_av, 1:3);
        for ii=1:size(Data.Wall_Trial_Data_Filt,1)

            if Data.Wall_Trial_Data_Filt(ii,2) == 35
                tmp = Data.Wall_Trial_Data_Filt(ii,1);
                Data.Left_Turns(ii) = tmp;
            end
            if Data.Wall_Trial_Data_Filt(ii,3) == 35
                tmp = Data.Wall_Trial_Data_Filt(ii,1);
                Data.Right_Turns(ii) = tmp;
            end
            if Data.Wall_Trial_Data_Filt(ii,2) == Data.Wall_Trial_Data_Filt(ii,3)
                tmp = Data.Wall_Trial_Data_Filt(ii,1);
                Data.Centered(ii) = tmp;
            end
            x=Data.Left_Turns ~= 0;
            y=Data.Right_Turns ~= 0;
            z=Data.Centered ~= 0;
            Data.Left_Turns = Data.Left_Turns(x);
            Data.Right_Turns = Data.Right_Turns(y);
            Data.Centered = Data.Centered(z)';
        end
    end
%% Resample Ball Data from 25Khz to original 500hz
    Curr_Samp = 25000;
    Orig_Samp = 500;
    Resamp = Curr_Samp/Orig_Samp;
    for ii=1:size(Data.BallV_Data.VBallRawFor,1)
        vals=size(Data.BallV_Data.VBallRawFor{ii,1},2);
        rows=Resamp;
        modu=mod(vals,rows);
        cols=(vals-modu)/50;
        VBallReshapedFor = Data.BallV_Data.VBallRawFor{ii,1}(1,1:vals-modu);
        VBallReshapedFor = reshape(VBallReshapedFor,rows,cols);
        avg=mean(VBallReshapedFor,1);
        Data.BallV_Data.VBallReshapedFor{ii,1}=avg.*.002;
    end
    for ii=1:size(Data.BallV_Data.VBallRawLat,1)
        vals=size(Data.BallV_Data.VBallRawLat{ii,1},2);
        rows=Resamp;
        modu=mod(vals,rows);
        cols=(vals-modu)/50;
        VBallReshapedLat = Data.BallV_Data.VBallRawLat{ii,1}(1,1:vals-modu);
        VBallReshapedLat = reshape(VBallReshapedLat,rows,cols);
        avg=mean(VBallReshapedLat,1);
        Data.BallV_Data.VBallReshapedLat{ii,1}=avg.*.002;
    end
end

% Extract Velocity and Angle
%         round/smooth
%             tmp=smooth(cam_vel_steps(:,ii),501,'sgolay');
% BallVelocity=sqrt((lat_ball_vel(:,2)).^2+(for_ball_vel(:,4)).^2);
% BallAngle=rad2deg(atan(lat_ball_vel(:,2))./(for_ball_vel(:,4)));
% Plot
%     Raw
%         for_ball_vel=(Ball_Chan);
%         lat_ball_vel=(Ball_Chan);
%     Cumulative
%         for_ball_motion=cumsum(Ball_Chan);
%         lat_ball_motion=cumsum(Ball_Chan);
