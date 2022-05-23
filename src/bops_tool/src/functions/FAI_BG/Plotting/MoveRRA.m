% script to move RRA from "[Dir.RRA fp trialName fp 'RRA']" to "[Dir.RRA fp
% trialName]"

function MoveRRA(SubjectFoldersElaborated, sessionName,suffix)

fp = filesep;
warning off

for ff = 1:length(SubjectFoldersElaborated)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersElaborated{ff},sessionName,suffix);

    if isempty(Trials.Dynamic) || isempty(fields(SubjectInfo)) || length(dir(Dir.RRA))<3
        continue
    end
    
    trials = dir(Dir.RRA);
    trials = trials([trials.isdir]);
    
    for ii= 3:length(trials)
        trialName = trials(ii).name;
        [osimFiles] = getosimfilesFAI(Dir,trialName); % also creates the directories

         if exist([Dir.RRA fp trialName fp 'RRA'])  
             copyMultipleFiles ([Dir.RRA fp trialName fp 'RRA'],[Dir.RRA fp trialName],2)
         end
             
    end
    
   
    
end
