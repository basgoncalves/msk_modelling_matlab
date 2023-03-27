function folders = getfolders(directory, contianing_string)

folders = dir (directory);
folders(1:2) =[];                                           % delete "../" and "./"
folders = folders([folders.isdir]);                         % select only rows that contain folders 

if nargin > 1
    folders = folders(contains({folders.name},contianing_string));
end
