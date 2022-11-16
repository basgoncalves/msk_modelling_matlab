function generateBopsStructure(subjects,sessions)

bops = load_setup_bops;

if nargin < 1
    subjects = {'s001'};
end

if nargin < 2
    sessions = {'session1'};
end

for i = 1:length(subjects)
    for ii = length(sessions)
        mkdir([bops.directories.InputData fp subjects{i} fp sessions{ii}])
        mkdir([bops.directories.ElaboratedData fp subjects{i} fp sessions{ii}])
    end
end
