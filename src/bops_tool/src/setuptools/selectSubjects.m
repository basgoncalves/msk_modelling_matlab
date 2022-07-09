
function subjects = selectSubjects(SelectAll,msg)

bops = load_setup_bops;

subjects = ls(bops.directories.InputData);
if isempty(subjects)
    subjects = ls(bops.directories.ElaboratedData);
end
subjects = cellstr(subjects);
subjects(1:2) =[];                                                                                                  % delete rows '.' and '..'

answer = questdlg(['Do you want to select a new set of subjects? currently selected subjects: ' bops.subjects]);
if contains(answer,'No')
    subjects = bops.subjects;
    return
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

