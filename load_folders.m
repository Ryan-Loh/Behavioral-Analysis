function [Folders] = load_folders(animal_num)

Folders.base_dir = fullfile('D:\Projects\Users\Ryan\Data', animal_num);
Folders.Beh_F = fullfile(Folders.base_dir,'Behavior');
Folders.Ephys_F = fullfile(Folders.base_dir, 'Ephys');
Folders.Whisk_F = fullfile(Folders.base_dir,'Whisker');

end

