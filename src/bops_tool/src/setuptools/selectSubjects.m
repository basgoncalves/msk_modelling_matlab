
function subjects = selectSubjects(SelectAll,msg)

if nargin < 1; SelectAll = 0; end

if nargin < 2; msg = 'select subjects:'; end

bops = load_setup_bops;

[subjects,subjectDataExist] = check_subjects(bops);                                                                 % check if subjectsb in the settings file exist in data folder

if subjectDataExist == 1    
    answer = questdlg(['Do you want to analyse ONLY the currently selected subjects: ' bops.subjects]);
    if contains(answer,'Yes')
        subjects = bops.subjects;
        return
    end

else
    disp('no subject data exist in "InputData" or "ElaboratedData" folders, generating paths')                      % auto generate generic paths

    subjects = create_InputData_folder(bops);

    % make this variable '1' so it doesnt ask again
    SelectAll = 1;
end


% check if the subject names in the subject CSV file are the same as selected
csv_dir = [bops.directories.subjectInfoCSV];
subjects_csv = table2struct(readtable(csv_dir));
if ~isequal({subjects_csv.ID}',subjects)
    for i = 1:length(subjects)
        subjects_csv(i).ID = subjects{i};
    end
    warning on
    warning(['subjectinfo.csv was updated to match the names of the subjects in ' bops.directories.mainData])
    writetable(struct2table(subjects_csv),csv_dir)
end

if SelectAll == 0
    [indx,~] = listdlg('PromptString',msg,'ListString',subjects);                                                   % select subjects
    subjects = subjects(indx);
end

if isempty(subjects)
    bops.subjects = struct;
else
    bops.subjects = subjects;
end

xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);                                                  % save settings

% --------------------------------------------------------------------------------------------------------------- %
function [subjects,subjectDataExist] = check_subjects(bops)

if isfolder(bops.directories.InputData) && ~isempty(getfolders(bops.directories.InputData))                         % check the 'InputData' folder firstr
    subjects = ls(bops.directories.InputData);
    subjects = cellstr(subjects); subjects(1:2) =[];  % delete rows '.' and '..'
    subjectDataExist = 1;

elseif isfolder(bops.directories.ElaboratedData) && ~isempty(getfolders(bops.directories.ElaboratedData))           % if doesn't exist check 'ElaboratedData' folder
    subjects = ls(bops.directories.ElaboratedData);
    subjects = cellstr(subjects); subjects(1:2) =[];  % delete rows '.' and '..'
    subjectDataExist = 1;

else
    subjects = [];
    subjectDataExist = 0;
end


% --------------------------------------------------------------------------------------------------------------- %
function subjects = create_InputData_folder(bops)

% select subject folders containing sessions and c3d files
prompt = 'Select your subject folders (i.e. folders containing sessions as per vicon format)';
subject_folders = uigetmultiple(bops.directories.mainData,prompt);
mkdir([bops.directories.InputData])

for iFolder = subject_folders
    parts = split(iFolder{1},fp);
    subject = parts{end};
    sessions = getfolders(iFolder{1});

    for iSession = {sessions.name}
        viconFolder = [iFolder{1} fp iSession{1}];
        inputFolder = [bops.directories.InputData fp subject fp iSession{1}];
        mkdir([bops.directories.InputData fp subject fp iSession{1}])

        % copy c3d files to the new Input folder
        c3dFiles = getfiles([viconFolder fp '*.c3d']);
        for iFile = c3dFiles
            copyfile(iFile{1},inputFolder)
        end
    end
end

[subjects,~] = check_subjects(bops);