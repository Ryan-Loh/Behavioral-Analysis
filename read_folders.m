function [Data] = read_folders(Folders)
global Analyze

%%
Wall_File = uigetfile(Folders.Beh_F, 'Select .csv Wall file');

if Wall_File~=0
    Wall_File = fullfile(Folders.Beh_F, Wall_File);
    Wall_Trial_Data = csvread(Wall_File);
    Header = {'Trial', 'Pattern', 'LW Dist', 'RW Dist', 'Wall Vel'};
    Data.Wall_Trial_Data = Wall_Trial_Data(:,[1 3 4]);
    Data.Wall_Trial_Data_Labeled = [Header; num2cell(Wall_Trial_Data)];
    Analyze.Wall = 1;
elseif Wall_File==0
    disp('No Wall File Selected');
    Analyze.Wall = 0;
end

%%

direct=uigetdir(Folders.Ephys_F, 'Select directory containing Ephys Recording(s)');
if direct~=0
    bin_file_list = dir(fullfile(direct,'*.bin'));
    metadata_file_list = dir(fullfile(direct,'*.meta'));
    bin_file_list = fullfile({bin_file_list.folder},{bin_file_list.name});
    metadata_file_list = fullfile({metadata_file_list.folder},{metadata_file_list.name});
    Data.Ephys_File_List = natsortfiles(bin_file_list);
    Data.Ephys_MetaData_File_List = natsortfiles(metadata_file_list);
    Data.Ephys_MetaData_File_List = Data.Ephys_MetaData_File_List';
    Data.Ephys_File_List = Data.Ephys_File_List';
    Analyze.Ephys = 1;
elseif direct == 0 
    disp('No Ephys Directory Selected');
    Analyze.Ephys = 0;
end
%%
direct = uigetdir(Folders.Whisk_F,'Select folder containing .txt whisker angle files');
if direct ~=0
    Whisk_File_List = dir(fullfile(direct,'*.txt'));
    Whisk_File_List = fullfile({Whisk_File_List.folder},{Whisk_File_List.name});
    Data.Whisker_File_List = natsortfiles(Whisk_File_List);
    Data.Whisker_File_List = Data.Whisker_File_List';
    Analyze.Whisker = 1;
elseif direct == 0
    disp('No Whisker File Directory Selected');
    Analyze.Whisker = 0;
end

if Analyze.Ephys==0 && Analyze.Wall==0 && Analyze.Whisker==0
    disp('No data selected');
    Data=0;
end