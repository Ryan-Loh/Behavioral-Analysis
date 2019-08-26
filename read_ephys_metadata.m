function [Data] = read_ephys_metadata(Data)

%% Preallocate
y = size(Data.Ephys_MetaData_File_List,1);
Data.Ephys_Metadata.Num_Channels_Raw = num2cell(zeros(y,1));
Data.Ephys_Metadata.File_Time_Raw = num2cell(zeros(y,1));
Data.Ephys_Metadata.Sample_Rate_Raw = num2cell(zeros(y,1));
channel_mask = num2cell(zeros(y,1));
file_time_mask = num2cell(zeros(y,1));
samp_rate_mask = num2cell(zeros(y,1));

%% Process Data
    for ii=1:size(Data.Ephys_MetaData_File_List,1)
        fid=tdfread(Data.Ephys_MetaData_File_List{ii});
        y=struct2cell(fid);
        y=cellstr(y{1,1});
        Data.Ephys_Metadata.All_Raw{ii} = y;
        
        channel_mask{ii}=~cellfun(@isempty, strfind(y, 'nSavedChans'));
        Data.Ephys_Metadata.Num_Channels_Raw{ii} = y(channel_mask{ii});
        yf=cell2mat(isstrprop(Data.Ephys_Metadata.Num_Channels_Raw{ii} ,'digit'));
        xx=cell2mat(Data.Ephys_Metadata.Num_Channels_Raw{ii});
        Data.Ephys_Metadata.Channel_Num_Tot(1,ii)=str2double(xx(yf));
        
        file_time_mask{ii}=~cellfun(@isempty, strfind(y, 'fileTimeSecs'));
        Data.Ephys_Metadata.File_Time_Raw{ii} = y(file_time_mask{ii});
        yf=cell2mat(isstrprop(Data.Ephys_Metadata.File_Time_Raw{ii} ,'digit'));
        tf=cell2mat(isstrprop(Data.Ephys_Metadata.File_Time_Raw{ii} ,'punct'));
        zf=yf|tf;
        xx=cell2mat(Data.Ephys_Metadata.File_Time_Raw{ii});
        Data.Ephys_Metadata.File_Time(1,ii)=(str2double(xx(zf)))';        
        
        samp_rate_mask{ii}=~cellfun(@isempty, strfind(y, 'niSampRate'));
        Data.Ephys_Metadata.Sample_Rate_Raw{ii} = y(samp_rate_mask{ii});
        yf=cell2mat(isstrprop(Data.Ephys_Metadata.Sample_Rate_Raw{ii} ,'digit'));
        xx=cell2mat(Data.Ephys_Metadata.Sample_Rate_Raw{ii});
        Data.Ephys_Metadata.Samp_Rate(1,ii)=(str2double(xx(yf)))';  
        
        channel_count_mask{ii}=~cellfun(@isempty, strfind(y, 'snsMnMaXaDw'));
        Data.Ephys_Metadata.Channel_Count_Raw{ii} = y(channel_count_mask{ii});
        yf=cell2mat(isstrprop(Data.Ephys_Metadata.Channel_Count_Raw{ii} ,'digit'));
        tf=cell2mat(isstrprop(Data.Ephys_Metadata.Channel_Count_Raw{ii} ,'punct'));
        zf=yf|tf;
        xx=cell2mat(Data.Ephys_Metadata.Channel_Count_Raw{ii});
        tmp=(double(split(xx(zf),',')))';
        Data.Ephys_Metadata.Channel_Num_Spike(ii,1) = tmp(1,1);
        Data.Ephys_Metadata.Channel_Num_Aux(ii,1) = tmp(1,2);
        
        file_trigger_mask{ii}=~cellfun(@isempty, strfind(y, 'syncNiChan='));
        Data.Ephys_Metadata.File_Trigger_Raw{ii} = y(file_trigger_mask{ii});
        yf=cell2mat(isstrprop(Data.Ephys_Metadata.File_Trigger_Raw{ii} ,'digit'));
        xx=cell2mat(Data.Ephys_Metadata.File_Trigger_Raw{ii});
        Data.Ephys_Metadata.Channel_File_Trig(1,ii)=str2double(xx(yf));
              
    end
Data.Ephys_Metadata.Samp_Rate=Data.Ephys_Metadata.Samp_Rate';
Data.Ephys_Metadata.File_Time=Data.Ephys_Metadata.File_Time';
Data.Ephys_Metadata.Channel_Num_Tot=Data.Ephys_Metadata.Channel_Num_Tot';
Data.Ephys_Metadata.All_Raw=Data.Ephys_Metadata.All_Raw';
Data.Ephys_Metadata.Channel_Count_Raw=Data.Ephys_Metadata.Channel_Count_Raw';
Data.Ephys_Metadata.Channel_File_Trig=Data.Ephys_Metadata.Channel_File_Trig';


end