function folders = getfolders(directory)

folders = dir (directory);
folders(1:2) =[];                                           % delete "../" and "./"
folders = folders([folders.isdir]);                         % select only rows that contain folders 