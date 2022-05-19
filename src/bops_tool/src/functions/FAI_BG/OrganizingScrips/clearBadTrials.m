% check the bad trials from the excel log file and delete from all the
% analysis folders (input data .c3d, dynamic elaborations, IK, ID etc)

function clearBadTrials(DirMocap,DirElaborated,Subject)

cd(DirMocap)
fp = filesep;
% check if an excel with the participant data exists (demographics and
% other data)
%    copyfile('C:\Users\s5109036\Downloads\ParticipantData and Labelling.xlsx',DirMocap)
Labelling = importParticipantData('ParticipantData and Labelling.xlsx', 'Labelling');
[GoodTrials,BadTrials] = findGoodTrials (Labelling,Subject);

for k = 1: length(BadTrials)
    warning off
    
    badtrialDir = [DirElaborated fp 'badtrials'];
    mkdir(badtrialDir)
    tn = BadTrials{k}; % trial name
    folders = {'dynamicElaborations' 'inverseKinematics' 'inverseDynamics' ...
        'muscleAnalysis' 'residualRedudctionAnalysis'};
    for kk = 1:length (folders)
        if exist([DirElaborated fp folders{kk} fp tn])
            movefile([DirElaborated fp folders{kk} fp tn],[badtrialDir fp tn])
        end
    end 
   
    % bad c3d trials
    badtrialDir = [fileparts(strrep(DirElaborated,'ElaboratedData','InputData')) fp 'badtrials'];
    mkdir(badtrialDir)
    if exist([strrep(DirElaborated,'ElaboratedData','InputData') fp tn '.c3d'])
        movefile([strrep(DirElaborated,'ElaboratedData','InputData') fp tn '.c3d'],...
            [badtrialDir fp tn '.c3d'])
    end
end
