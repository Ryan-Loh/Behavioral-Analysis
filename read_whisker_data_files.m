function [Data] = read_whisker_data_files(Data)
    for ii=size(Data.Whisker_File_List,1):-1:1
        fid=tdfread(Data.Whisker_File_List{ii}, ',');
        fid=struct2cell(fid);
        
        for jj=1:11 
            Dat(:,jj)=fid{jj,1};
            Data.Whisker_Trial_Data_Raw{ii,1} = Dat;
        end
        clear Dat;
    end
end