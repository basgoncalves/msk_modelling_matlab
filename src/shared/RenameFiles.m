
%% This function removes participant ID from the c3d file name
function RenameFiles (Dir, subtring,newsubstring,Extension)

destination = (sprintf('%s\\%s',Dir));
cd(Dir)

if ~contains(Extension,'*')
    Extension = ['*' Extension];
end

Files= dir(sprintf('%s\\%s',Dir,Extension)); % get files from directory

for  k=1:length(Files)
     
    if contains(Files(k).name,subtring)&& ~contains(Files(k).name,newsubstring)
     
        FileName = Files(k).name;       
        NewFilename = strrep(FileName,subtring,newsubstring);
        source = Files(k).name;
        movefile (source, [destination NewFilename]);
    end
end

