function [Data] = read_ephys_data(Data)
%% Scale Aux Data
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