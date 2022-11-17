
function subjects = selectSubjects(SelectAll,msg)

bops = load_setup_bops;

if isfolder(bops.directories.InputData) && ~isempty(getfolders(bops.directories.InputData))
    subjects = ls(bops.directories.InputData);
    subjects = cellstr(subjects); subjects(1:2) =[];  % delete rows '.' and '..'
    subjectDataExist = 1;

elseif isfolder(bops.directories.ElaboratedData) && ~isempty(getfolders(bops.directories.ElaboratedData))
    subjects = ls(bops.directories.ElaboratedData);
    subjects = cellstr(subjects); subjects(1:2) =[];  % delete rows '.' and '..'
    subjectDataExist = 1;

else
    subjectDataExist = 0;
end

if subjectDataExist == 1
    answer = questdlg(['Do you want to analyse ONLY the currently selected subjects: ' bops.subjects]);
    if contains(answer,'Yes')
        subjects = bops.subjects;
        return
    end

else
    disp('no subject data exist in "InputData" or "ElaboratedData" folders, generating paths')                      % auto generate generic paths          
    pause(1.2)
    

end


csv_dir = [bops.directories.subjectInfoCSV];
subjects_csv = table2struct(readtable(csv_dir));

if ~isequal({subjects_csv.ID},subjects)
    for i = 1:length(subjects)
        subjects_csv(i).ID = subjects{i};
    end
    warning on
    warning(['subjectinfo.csv was updated to match the names of the subjects in ' bops.directories.mainData])
end

writetable(struct2table(subjects_csv),csv_dir)

if nargin < 1
    SelectAll = 0;
end

if nargin < 2
    msg = 'select subjects:';
end

if SelectAll == 0
    [indx,~] = listdlg('PromptString',msg,'ListString',subjects);                                              % select subjects
    subjects = subjects(indx);
end

if isempty(subjects)
    bops.subjects = struct;
else
    bops.subjects = subjects;
end

xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);                                                          % save settings

