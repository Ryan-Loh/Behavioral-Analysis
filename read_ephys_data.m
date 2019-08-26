function [Data] = read_ephys_data(Data)
    
%% PreAllocate
    Data.Ephys_Data_Raw = cell(size(Data.Ephys_File_List,1), 1);
    Data.Ephys_Spike_Data_Raw = cell(size(Data.Ephys_File_List,1),1);
    Data.Ephys_Aux_Data_Raw = cell(size(Data.Ephys_File_List,1),1);
    Aux_Scale = ((10./(2.^16))./0.25);
    Data_Scale = ((10./(2.^16))./200);
%% Read Data
    for ii=1:size(Data.Ephys_File_List,1)
        Data.Ephys_Data_Raw{ii,1}=zeros(Data.Ephys_Metadata.Channel_Num_Tot(ii), round(Data.Ephys_Metadata.Samp_Rate(ii)*Data.Ephys_Metadata.File_Time(ii)));
        fid = fopen(Data.Ephys_File_List{ii, 1},'r');
        Raw = fread(fid,inf,'int16');
        fclose(fid);
        Data.Ephys_Data_Raw{ii,1}=Raw;
        for jj=1:Data.Ephys_Metadata.Channel_Num_Tot(ii)
            tmp=Data.Ephys_Data_Raw{ii,1}(jj:Data.Ephys_Metadata.Channel_Num_Tot(ii):size(Data.Ephys_Data_Raw{ii,1},1));
            Data.Ephys_Data_Raw_Shaped{ii,1}(jj,:)=tmp;
        end
        clear Raw;
    end
%% Separate Spike from Aux Data
    for ii=1:size(Data.Ephys_File_List,1)
        if Data.Ephys_Metadata.Channel_Num_Spike(ii)>0
            Data.Ephys_Spike_Data_Raw{ii,1}(1:Data.Ephys_Metadata.Channel_Num_Spike(ii),:) = Data.Ephys_Data_Raw_Shaped{ii,1}(1:Data.Ephys_Metadata.Channel_Num_Spike(ii), :);
            Data.Ephys_Spike_Data_Raw{ii,1} = Data.Ephys_Spike_Data_Raw{ii,1}.*Data_Scale;
        else
            disp(['No spike data in file: ' num2str(ii)]);
        end
        if Data.Ephys_Metadata.Channel_Num_Aux(ii)>0
            Data.Ephys_Aux_Data_Raw{ii,1}(1:Data.Ephys_Metadata.Channel_Num_Aux(ii),:) = Data.Ephys_Data_Raw_Shaped{ii,1}(Data.Ephys_Metadata.Channel_Num_Spike(ii)+1:Data.Ephys_Metadata.Channel_Num_Spike(ii)+Data.Ephys_Metadata.Channel_Num_Aux(ii), :);
        else
            disp(['No aux data in file: '  num2str(ii)]);
        end
    end
    
    for ii=1:size(Data.Ephys_Spike_Data_Raw,1)
        Data.Ephys_Spike_Data_Raw{ii,1}=Data.Ephys_Spike_Data_Raw{ii,1}.*Data_Scale;
    end
    for ii=1:size(Data.Ephys_Aux_Data_Raw,1)
        Data.Ephys_Aux_Data_Raw{ii,1}=Data.Ephys_Aux_Data_Raw{ii,1}.*Aux_Scale;
    end
%% Separate Ball, File Trigger, Camera Trigger, Laser Trigger 
    Ball_Trig_Chans = input('Input AUX index of ball channels: ');
    File_Trig_Chan = input('Input AUX index of file trigger channel: ');
    Cam_Trig_Chan = input('Input AUX index of camera trigger channel: ');
    Laser_Trig_Chan = input('Input AUX index of laser trigger channel: ');
    Data.Ephys_Ball_Data = cell(size(Data.Ephys_File_List,1), 1);
    Data.Ephys_File_Trig = cell(size(Data.Ephys_File_List,1), 1);
    Data.Ephys_Cam_Trig = cell(size(Data.Ephys_File_List,1), 1);
    Data.Ephys_Laser_Trig = cell(size(Data.Ephys_File_List,1), 1);   
    for ii=1:size(Data.Ephys_Metadata.Channel_Num_Aux,1)
        if Ball_Trig_Chans > 0
            Data.Ephys_Ball_Data{ii,1} = Data.Ephys_Data_Raw_Shaped{ii,1}(Ball_Trig_Chans,:);
            Data.Ephys_Ball_Data{ii,1} = Data.Ephys_Ball_Data{ii,1}.*Aux_Scale;
        elseif ii==size(Data.Ephys_Metadata.Channel_Num_Aux,1) && isempty(Data.Ephys_Ball_Data{ii,1})
            disp('No ball channel(s) identified');
            clear Data.Ephys_Ball_Data;
        end
        if File_Trig_Chan > 0 
            Data.Ephys_File_Trig{ii,1} = Data.Ephys_Data_Raw_Shaped{ii,1}(File_Trig_Chan,:);
            %Data.Ephys_File_Trig{ii,1} = Data.Ephys_File_Trig{ii,1}.*Aux_Scale;
        elseif ii==size(Data.Ephys_Metadata.Channel_Num_Aux,1) && isempty(Data.Ephys_File_Trig{ii,1})
            disp('No file trigger channel identified');
            clear Data.Ephys_File_Trig;
        end
        if Cam_Trig_Chan > 0 
            Data.Ephys_Cam_Trig{ii,1} = Data.Ephys_Data_Raw_Shaped{ii,1}(Cam_Trig_Chan,:);
            %Data.Ephys_Cam_Trig{ii,1} = Data.Ephys_Cam_Trig{ii,1}.*Aux_Scale;
        elseif ii==size(Data.Ephys_Metadata.Channel_Num_Aux,1) && isempty(Data.Ephys_Cam_Trig{ii,1})
            disp('No camera trigger channel identified');
            clear Data.Ephys_Cam_Trig;
        end
        if Laser_Trig_Chan > 0
            Data.Ephys_Laser_Trig{ii,1} = Data.Ephys_Data_Raw_Shaped{ii,1}(Laser_Trig_Chan,:);
            %Data.Ephys_Laser_Trig{ii,1} = Data.Ephys_Laser_Trig{ii,1}.*Aux_Scale;
        elseif ii==size(Data.Ephys_Metadata.Channel_Num_Aux,1) && isempty(Data.Ephys_Laser_Trig{ii,1})
            disp('No laser trigger channel identified');
            clear Data.Ephys_Laser_Trig;
        end
    end
end