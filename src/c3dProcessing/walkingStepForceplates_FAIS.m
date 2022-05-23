

function [AcqTrial,TimeWindow,FramesWindow]=walkingStepForceplates_FAIS(SubjectID,trialType,trialNumber,AcqTrial)

[Dir,~,~,~]=getdirFAI(SubjectID);
data=importParticipantData(Dir.WakingEvents,'events');
rows = find(contains(data(:,1),SubjectID));
if isempty(rows)
    return
end
if ~exist('AcqTrial') || isempty(fields(AcqTrial))
    k = 1;
else
    k = length([AcqTrial])+1;
end
iRow = rows(str2num(trialNumber));
leg = data(iRow,4:7);
StanceOnFP =  struct('Forceplatform',split(cellstr(sprintf('%d ',1:4)),' ')', 'leg',leg);
AcqTrial(k).Type = trialType;
AcqTrial(k).RepetitionNumber = trialNumber;
AcqTrial(k).MotionDirection=data{iRow,8};
AcqTrial(k).StancesOnForcePlatforms.StanceOnFP = StanceOnFP;
FramesWindow(k,:) = [data{iRow,2:3}];
TimeWindow(k,:) = [data{iRow,2:3}]./200;
