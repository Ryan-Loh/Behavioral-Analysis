function m = data_read(filename)
%DATA_READ    Read the raw data.
%
%   m = DATA_READ(filename)
%   M   - Content of the file.

disp(['    Reading file: ',filename]);
fileID = fopen(filename);
m = fread(fileID,Inf,'int16');
fclose(fileID);