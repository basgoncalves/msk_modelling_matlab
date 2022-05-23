% plotIndividualWork 
% Plot work for one participant

cd(DirResults)
load('JointWorks.mat')
load([DirResults filesep 'MaxRuningVelocity.mat']);
% JointMotion = fields(JointWorks);

JointMotion = {'hip_flexion','knee','ankle'};
Nmoments = length(JointMotion);
fs = 200;

idxSubject = str2double(Subject);

variables = fields(JointWorks.(JointMotion{1}));

AvgVelocityMax = MaxRuningVelocity (:,idxSubject);
StdVelocityMax = AvgVelocityMax*0;
MeanWorkPercentage=struct;
IndividualJointWork = struct;
for vv = 1:length(variables)
    VarName = variables{vv};
    PreviousVar = 0;
    for mm = 1:Nmoments                                        % hip flexion, knee and ankle
        MomentName = JointMotion{mm};
        CurrentVar = JointWorks.(MomentName).(VarName);
        CurrentVar(isnan(CurrentVar))= 0;
    
        IndividualJointWork.(VarName)(:,mm) = CurrentVar (:,idxSubject);
        TotalWork.(VarName) =  CurrentVar (:,idxSubject)+PreviousVar;           % total positive/negative/net work 
        PreviousVar = TotalWork.(VarName);
    end

    %Mean work in percentage
    for  mm = 1:Nmoments
        MomentName = JointMotion{mm};
        CurrentVar = JointWorks.(MomentName).(VarName);
        CurrentVar(isnan(CurrentVar))= 0;

        MeanWorkPercentage.(VarName)(:,mm) = CurrentVar(:,idxSubject)  ./ TotalWork.(VarName)*100;
       
    end
    
end

%% positive relative work

NormalizedWork = MeanWorkPercentage.PosWork;           
stdWork = MeanWorkPercentage.PosWork*0;
TitleName = 'relative positive work';
Ylabel = 'Work (% of total)';
plotBarWork (NormalizedWork, stdWork,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)
yyaxis left 

cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));  

%% negative relative work

NormalizedWork = MeanWorkPercentage.NegWork;           
stdWork = MeanWorkPercentage.NegWork*0;
TitleName = 'relative negative work';
Ylabel = 'Work (% of total)';
plotBarWork (NormalizedWork, stdWork,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)
yyaxis left 

cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));  