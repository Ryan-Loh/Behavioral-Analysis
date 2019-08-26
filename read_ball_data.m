function [Data] = read_ball_data(Data)
%% Initialize
    Data.Ephys_Aux_Data_Raw = cell(size(Data.Ephys_File_List,1),1);
    Aux_Scale = ((10./(2.^16))./0.25);
    Aux_Data_Channels = [66,98:102]; %Aux Channels (66=MCU, 70=Camera Trigger, 98-101=X0 Y0 X1 Y1, 102=Laser)
%% Read Data
    for ii=1:size(Data.Ephys_File_List,1)
        Raw_Data=zeros(Data.Ephys_Metadata.Channel_Num_Tot(ii), round(Data.Ephys_Metadata.Samp_Rate(ii)*Data.Ephys_Metadata.File_Time(ii)));
        fid = fopen(Data.Ephys_File_List{ii, 1},'r');
        Raw = fread(fid,inf,'int16');
        fclose(fid);
        Data.Ephys_Data_Raw=Raw;
        for jj=1:Data.Ephys_Metadata.Channel_Num_Tot(ii)
            tmp=Data.Ephys_Data_Raw(jj:Data.Ephys_Metadata.Channel_Num_Tot(ii):size(Data.Ephys_Data_Raw,1));
            Raw_Data(jj,:)=tmp;
        end
        if Data.Ephys_Metadata.Channel_Num_Aux(ii)>0
            disp(['Working on aux data file: ' num2str(ii)]);
            for kk = 1:size(Aux_Data_Channels,2)
                Data.Ephys_Aux_Data_Raw{ii,1}(kk,1:size(Raw_Data,2)) = Raw_Data(Aux_Data_Channels(kk), :);
            end
        else
            disp(['No aux channels for file: ' num2str(ii)]);
        end
        clear Raw_Data tmp Raw
        Data = rmfield(Data, 'Ephys_Data_Raw');
    end
 
%% Scale Voltages and Reduce Noise in MCU Clock channel
    for ii=1:size(Data.Ephys_Aux_Data_Raw,1)
        Data.Ephys_Aux_Data_Raw{ii,1} = Data.Ephys_Aux_Data_Raw{ii,1}.*Aux_Scale;
        for jj = 1:size(Data.Ephys_Aux_Data_Raw{ii,1},2)
            if Data.Ephys_Aux_Data_Raw{ii,1}(1,jj)>0.760
                Data.Ephys_Aux_Data_Raw{ii,1}(1,jj)=0.760;
            end
        end
    end
%% Resample Voltage at 500Hz, only when MCU clock is HIGH
    for ii=1:size(Data.Ephys_Aux_Data_Raw,1)
        Data.Resamp_Ball_Data{ii,1} = NaN(size(Data.Ephys_Aux_Data_Raw{ii,1}));
        MCU_Diff = diff(Data.Ephys_Aux_Data_Raw{ii,1}(1,:));
        for jj = 1:size(MCU_Diff,2)
            if MCU_Diff(jj) > 10
                Data.Resamp_Ball_Data{ii,1}([1,3:6],jj+1) = Data.Ephys_Aux_Data_Raw{ii,1}([1,3:6],jj+1);
            end
        end
        Data.Resamp_Ball_Data{ii,1}(2,:) = Data.Ephys_Aux_Data_Raw{ii,1}(2,:);
    end
    
%% Change File Trigger Clock from VOLTAGE to Trial Time
    for ii=1:size(Data.Resamp_Ball_Data,1)
        disp(['Working on file: ' num2str(ii)])
        x=diff(Data.Resamp_Ball_Data{ii,1}(2,:));
        Trig_On = find(x>0.5);
        if size(Trig_On,2)>1
            Trig_On(2:end)=[];
        end
        for jj=1:size(Data.Resamp_Ball_Data{ii,1}(2,:),2)
            Data.Resamp_Ball_Data{ii,1}(7,jj) = round(((jj-Trig_On)*(1/Data.Ephys_Metadata.Samp_Rate(ii))),5);
        end
        clear x Trig_On
    end
    
        
        



















end