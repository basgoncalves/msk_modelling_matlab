
function selectedSessions = selectSession(SelectAll)

bops = load_setup_bops;

if nargin < 1; SelectAll = 0; end

if SelectAll == 0                                                                                                   % if SelectAll is false (or 0)

    prompt = ['Do you want to select a new set of sessions? currently selected subjects: ' bops.sessions];          % check if you want to continue with the previous used sessions
    answer = questdlg(prompt);
    if contains(answer,'No')
        selectedSessions = bops.sessions;
        return

    else

        selectedSessions = find_sessions_all_subjects(bops);
        msg = 'select sessions:';
        [indx,~] = listdlg('PromptString',msg,'ListString',selectedSessions);                                       % select the sessions to use from all available

        selectedSessions = selectedSessions(indx);
    end

else
    selectedSessions = find_sessions_all_subjects(bops);

end

bops.sessions = selectedSessions;                                                                                   % save bops settings
xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);

% --------------------------------------------------------------------------------------------------------------- %
function selectedSessions = find_sessions_all_subjects(bops)

subjects = bops.subjects;
selectedSessions = {};

for i = 1:length(subjects)
    try   
        subjectSessions  = dir([bops.directories.InputData fp subjects{i}]);            % check InputData sessions
    catch
        subjectSessions = dir([bops.directories.ElaboratedData fp subjects{i}]);        % check ElaboratedData sessions
    end

    selectedSessions = unique([selectedSessions,{subjectSessions(3:end).name}]);        % remove repeats
end