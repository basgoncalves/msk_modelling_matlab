

function SubjectsToCheck = GaitEventsMultiple(Subjects)
tic
fp = filesep;

SubjectsToCheck ={};
for ff = 1:length(Subjects)
  
     [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});

    Out = CheckGaitEvents (Dir.Input,Trials.Dynamic,SubjectInfo.TestedLeg);
    if sum(Out) ~= length(Out) || isempty(Out)
        warning  on
        warning(['Check gait events for ' SubjectInfo.ID])
        SubjectsToCheck{1,end+1}= SubjectInfo.ID;
        n = length(Trials.Dynamic(find(~Out))')+1;
        badTrials = Trials.Dynamic(find(~Out));
        for k = 2:n
            SubjectsToCheck{k,end} = badTrials{k-1};
        end

    else 
        disp('')
        disp(['All events are fine for ' SubjectInfo.ID])
        disp('')
    end
    
end

toc