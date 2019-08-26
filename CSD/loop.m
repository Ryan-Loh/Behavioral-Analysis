path = 'C:\Users\ryanloh2\Desktop\XX'; %replace with full directory path

base_dir = dir(path);
filenames = {base_dir.name};
current_files = filenames;

while true
  dir_content = dir(path);
  filenames = {dir_content.name};
  new_files = setdiff(filenames,current_files);
  if ~isempty(new_files)
      while ~isempty(new_files)
        temp = dir(fullfile(path,'*.dat')); %adjust file extension as needed
        temp = temp(~cellfun(@isdir,{temp(:).name}));
        times = [temp.datenum];
        [~,idx] = max(times);
        latestFile = sprintf('%s', new_files{end});
        new_files(end) = [];
        f_name = fullfile(path, latestFile);
        CSD(f_name);
        current_files = filenames;
      end
  else
    fprintf('no new files\n');
    pause(5.0); %pause between each new file check, in seconds, adjust as needed

  end
end