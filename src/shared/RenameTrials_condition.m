
%% This function removes participant ID from the c3d file name
function RenameTrials_condition (Dir, StringToRemove,strNOTToRemove,Extension)

destination = (sprintf('%s\\%s',Dir));
cd(Dir)
Files= dir(sprintf('%s\\%s',Dir,Extension)); % get files from directory
if isempty(strNOTToRemove)
    strNOTToRemove ={' '};
end

% remove from string
for  k=1:length(Files)
     
    if contains(Files(k).name,StringToRemove)&& ~contains(Files(k).name,strNOTToRemove)
     
        FileName = Files(k).name;
        for ii = 1:length(StringToRemove)
            idx = strfind(FileName,StringToRemove{ii});
            if ~isempty(idx)
                idx = ii;
                break
            end
        end
        
        
        NewFilename = strrep(FileName,StringToRemove{idx},'');
        NewFilename = strrep(NewFilename,strrep(Extension,'*',''),'');
        source = Files(k).name;
        if contains(source,NewFilename) && length(source)~= length(NewFilename)
            copyfile (source, [destination NewFilename strrep(Extension,'*','')]);
            delete (source)
        end
    end
end

