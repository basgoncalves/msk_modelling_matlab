
function selectedSessions = selectSession(SelectAll)

bops = load_setup_bops;

if nargin < 1
    SelectAll = 0;
end

answer = questdlg(['Do you want to select a new set of sessions? currently selected subjects: ' bops.sessions]);
if contains(answer,'No')
    selectedSessions = bops.sessions;
    return 
end

subjects = bops.subjects;

selectedSessions = {};
for i = 1:length(subjects)
    subjectSessions = dir([bops.directories.InputData fp subjects{i}]);
    selectedSessions = unique([selectedSessions,{subjectSessions(3:end).name}]);
end

if SelectAll == 0
    msg = 'select sessions:';
    [indx,~] = listdlg('PromptString',msg,'ListString',selectedSessions);
    selectedSessions = selectedSessions(indx);
end

if isempty(subjects)
    bops.sessions = struct;
else
    bops.sessions = selectedSessions;
end

xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);