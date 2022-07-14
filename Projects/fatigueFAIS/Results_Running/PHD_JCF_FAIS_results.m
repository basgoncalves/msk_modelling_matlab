%% Results PHD_JCF_FAIS_results - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Joint contact forces baseline for FAIS,FAIM and CON
% updatde = subject index to update
%-------------------------------------------------------------------------
% see also:
%   splitGroupsFAI.m
%   plotExternalBiomech.m

% updated April 2021

%% Load subjects and directories
function DataDir = PHD_JCF_FAIS_results(update,ReRunSubjects,Task)
fp = filesep;
[Dir,~,~,~] = getdirFAI; [Subjects,Groups,Weights,~] = splitGroupsFAI(Dir.Main,'JCFFAI');

cd(Dir.Results_JCFFAI)

%% Import data

if contains(Task,'run')
    TrialList = {'RunStraight1','RunStraight2','walking1','walking2','walking3','walking4','walking5'};
    savedir = [Dir.Results_JCFFAI fp 'CEINMSbackupResults.mat'];            % directory to save data in
elseif contains(Task,'cut')
    TrialList = {'CutTested1','CutTested2','CutOposite1','CutOposite2'};
    savedir = [Dir.Results_JCFFAI fp 'CEINMSbackupResults_cut.mat'];            % directory to save data in
end
[CEINMSData,JointWork,ST,Error,BestGammaPerTrial] = Convert_HCF_results2Mat(Subjects,TrialList,update,ReRunSubjects,savedir);

%participant groups
CEINMSData.participantsGroups =[];
CEINMSData.participantsGroups(find(contains(CEINMSData.participants,Groups.FAIS))) = 1;
CEINMSData.participantsGroups(find(contains(CEINMSData.participants,Groups.CAM))) = 2;
CEINMSData.participantsGroups(find(contains(CEINMSData.participants,Groups.Control))) = 3;

CEINMSData.GroupNames = {'FAIS'; 'CAM'; 'control'};

%participant mass
CEINMSData.participantsMass =[];
CEINMSData.participantsMass(find(contains(CEINMSData.participants,Groups.FAIS))) = cell2mat(Weights.FAIS);
CEINMSData.participantsMass(find(contains(CEINMSData.participants,Groups.CAM))) = cell2mat(Weights.CAM);
CEINMSData.participantsMass(find(contains(CEINMSData.participants,Groups.Control))) = cell2mat(Weights.Control);
%participant weight
CEINMSData.participantsWeight = CEINMSData.participantsMass.* 9.81;

% % bad participants
% ParticipantsWithBadData = {'037'};
% CEINMSData.GoodData(contains(CEINMSData.participants,ParticipantsWithBadData)) = 0;
% CEINMSData.GoodData(~contains(CEINMSData.participants,ParticipantsWithBadData)) = 1;

% average data & Remove zeros
Er = fields(Error);
Er(contains(Er,{'dofName' 'muscleNames'}))=[];
TrialNames = fields(Error.(Er{1}));
for e = 1:length(Er)
    CurrentEr = Er{e};
    %running
    if any(contains(TrialNames,'RunStraight'))
        r1 = Error.(CurrentEr).RunStraight1;
        r2 = Error.(CurrentEr).RunStraight2;
        [Error.(CurrentEr).MeanRunStraight,~] = MeanMatrices (2,r1,r2);
    end
    % walking
    if any(contains(TrialNames,'walking'))
        w1 = Error.(CurrentEr).walking1;
        w2 = Error.(CurrentEr).walking2;
        w3 = Error.(CurrentEr).walking3;
        w4 = Error.(CurrentEr).walking4;
        w5 = Error.(CurrentEr).walking5;
        [Error.(CurrentEr).Meanwalking,~] = MeanMatrices (2,w1,w2,w3,w4,w5);
    end
    
    if any(contains(TrialNames,'CutTested'))
        r1 = Error.(CurrentEr).CutTested1;
        r2 = Error.(CurrentEr).CutTested2;
        [Error.(CurrentEr).MeanCutTested,~] = MeanMatrices (2,r1,r2);
    end
    
    if any(contains(TrialNames,'CutOposite'))
        r1 = Error.(CurrentEr).CutOposite1;
        r2 = Error.(CurrentEr).CutOposite2;
        [Error.(CurrentEr).MeanCutOposite,~] = MeanMatrices (2,r1,r2);
    end
end

for e = 1:length(Er)
    for t = 1:length(TrialNames)
        currentError = Er{e};
        idx = Error.(Er{e}).(TrialNames{t})==0;
        Error.(Er{e}).(TrialNames{t})(idx)=NaN;     % Remove zeros
    end
end

[Dir,~,SubjectInfo,Trials] = getdirFAI(Subjects{1});
Demographics = fields(SubjectInfo)';

for Subj = 1:length(Subjects)
    [Dir,~,SubjectInfo,Trials] = getdirFAI(Subjects{Subj});
    Demographics(Subj+1,:)=struct2cell(SubjectInfo)';
end

VariableNames = Demographics(1,:);VariableNames{2} = 'ExcelRow';
Demographics = cell2table(Demographics(2:end,:));
Demographics.Properties.VariableNames = VariableNames;

flds = fields(CEINMSData);
CEINMSData.units = struct;
for ifld = flds'
    CEINMSData.units.(ifld{1}) = '';
end
CEINMSData.units.AdjustedEmgs           = 'ratio to max emg';
CEINMSData.units.ankle_angle            = 'metre';
CEINMSData.units.knee_angle             = 'metre';
CEINMSData.units.hip_adduction          = 'metre';
CEINMSData.units.hip_flexion            = 'metre';
CEINMSData.units.hip_rotation           = 'metre';
CEINMSData.units.CEINMSmuscles          = 'names';
CEINMSData.units.CEINMSmuscles_perDOF   = 'names ';
CEINMSData.units.ContactForces          = 'metre';

cd(Dir.Results_JCFFAI)
if contains(Task,'run')
    save Paper4results CEINMSData JointWork Error Groups Weights Subjects BestGammaPerTrial ST Demographics
    DataDir = [Dir.Results_JCFFAI fp 'Paper4results.mat'];
    copyfile(DataDir,[Dir.Paper_JCFFAI fp 'Results']);
    cd([Dir.Paper_JCFFAI fp 'Results'])
elseif contains(Task,'cut')
    save Paper4results_cutting CEINMSData JointWork Error Groups Weights Subjects BestGammaPerTrial ST Demographics
    DataDir = [Dir.Results_JCFFAI fp 'Paper4results_cutting.mat'];
    copyfile(DataDir,[Dir.Paper_JCFFAI_cut fp 'Results']);
    cd([Dir.Paper_JCFFAI_cut fp 'Results'])
end


cmdmsg(['Mat data saved in ' Dir.Results_JCFFAI '  and copied to ' Dir.Paper_JCFFAI fp 'Results'])
