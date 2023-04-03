function folders = getfolders(directory, contianing_string, IgnoreCase)

folders = dir (directory);
folders(1:2) =[];                                           % delete "../" and "./"
folders = folders([folders.isdir]);                         % select only rows that contain folders 

if nargin > 1
    if IgnoreCase == 0
        folders = folders(contains({folders.name},contianing_string));
    else
        folders = folders(contains({folders.name},contianing_string,"IgnoreCase",true));
    end
end
