% SubjectsToCopy (optional) = cell with the names of subjects. Default ==
% all subjects in "bopsSettings.xml"
% 
function Visual3DtoMotoNMS

bops = load_setup_bops;
files = dir(bops.directories.mainData);

SubjectsToCopy = selectSubjects;

idx_visual3d = find(contains({files.name}, 'visual3D'));
if  idx_visual3d==0                                                                                                 % if visual3D folder does not exist
    dir_visual3d = uigetdir(maindir,'please select the folder containing visual3D subjects');                       % ask the user to select it
else
    dir_visual3d = [files(idx_visual3d).folder fp files(idx_visual3d).name];
end

subjectfolders = dir(dir_visual3d);
if nargin == 0                                                                                                      % if "SubjectsToCopy" is an input
    SubjectsToCopy = selectSubjects(1,'Select subject to convert folder structure');
end
idx_keep = contains({subjectfolders.name},SubjectsToCopy);
subjectfolders = subjectfolders(idx_keep);                                                                          % delete the subject files that are not containied in "SubjectsToCopy"


disp(['copying files to "' bops.directories.InputData '" :'])
for i = 1:length(subjectfolders)
    
    subjectName = subjectfolders(i).name;
    disp([subjectName '...'])
    sessionfolders = getfolders([subjectfolders(i).folder fp subjectName]);                                         % get only names that are folders/directories
    
    for  ii = 1:length(sessionfolders)
        
        
        sessionName = sessionfolders(ii).name;
        if contains(sessionName, subjectName)                                                                       % remove "_Subject" from the sessionName to keep only date
            sessionName_dest = strrep(sessionName,['_' subjectName],'');
        else
            sessionName_dest = sessionName;
        end
        
        sourceFolder = [sessionfolders(ii).folder fp sessionName fp 'Data\TREATED\C3D'];                            % define sorce folder
        destinationFolder = strrep([sessionfolders(ii).folder fp sessionName_dest],'visual3D', 'InputData');        % define desitination folder
        
        if ~exist(sourceFolder,'dir')
            warning (['folder ' sourceFolder ' does not exist'])                                                    % if folder does not exist warn
            continue
        end
        
        ext = '.c3d';
        copyMultipleFiles (sourceFolder,destinationFolder,1,ext)                                                 % copy all .c3d files to "InputData"
        
        
        nameParts = split(bops.dataStructure.c3dFileStructure,'_');
        idx_task = find(contains(nameParts,'task'));
        idx_condition = find(contains(nameParts,'condition'));
        idx_date = find(contains(nameParts,{'year' 'month' 'day'}));
        StringToRemove = [join(nameParts(1:idx-1),'_')];
         
        RenameTrials_condition (destinationFolder, StringToRemove,' ',ext)
        
        trialNames = strrep(selectTrialNames(sourceFolder,ext,1),'.c3d','');
        
        condition = {}; task = {}; date = {};
        for t = 1:length(trialNames)
            nameParts = split(trialNames(t,:),'_');
            condition{t,1} = nameParts{idx_condition};
            task{t,1} = nameParts{idx_task};
            date{t,1} = char(join(nameParts(idx_date),'_'));
        end
        
        [sessions,~,idx_condition] = unique(condition);
        
        for c = 1:length(condition)                                                                                 % [UNDER CONTRSUCTION]automate the session assignment
            for t = 1:length(trialNames)
                
                
            end
        end
        
       
    end
end

disp(['Done!'])