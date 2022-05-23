%% Description - Goncalves, BM (2019)
% plot Kniematics, Kinetics and Power for single trial
%
%INPUT
%   DirElaborated = [1xN char]
%                   Directory of the elaborated data (including the session)
%                   as a result of MOToNMS
%
%   Joint =         [1XN char] (optional)
%                   Name of the joint to plot (e.g. 'ankle')
%
%   TrialNames =     [NX1 cell] (optional)
%                   Each cell is the name of trial
%
%   Parameter =        [1X1 cell] (optional)
%                   1= name of the; 2 = frontal plane; 3 = transverse plane

%
%% Start Fucntion
function [DirElaborated,Joints,TrialNames,IndivData,Labels] = MeanAllResults (SubjectFoldersElaborated,Joints,TrialNames,Parameter)
%% create directories and variables


smfai% select multiple
LRFAI

if ~exist('Joints') || sum(contains(fields(IDresults),Joints))==0
    Variables = fields(Run);
    % select only one Joint
    [idx,~] = listdlg('PromptString',{'Choose the joint to plot'},'ListString',Variables);
    Joints = Variables (idx);
else
    Variables = fields(Run);
    Joints = Variables(contains(fields(IDresults),Joints));
end

FieldNames = cleanOSName(Joints);

if ~exist('TrialNames') || isempty(TrialNames)||...
        sum(contains(Labels,TrialNames))~=length (TrialNames)
    Variables = Run.Labels;
    [idx,~] = listdlg('PromptString',{'Choose the trial to plot'},'ListString',Variables);
    TrialNames = Variables (idx);
end

if ~exist('Parameter') || isempty(Parameter)||length(Parameter)>1
    Variables = fields(Run.(Joints{1}));
    [idx,~] = listdlg('PromptString',{'Choose the trial to plot'},'ListString',Variables);
    Parameter = Variables (idx);
end



%% generate the first subject
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};

IndivData = struct;
NewLabels={};

for ff = 1:length(SubjectFoldersElaborated)
    for jj = 1: length(Joints)
        for pp = 1:length(Parameter)
            JointName = cleanOSName (Joints);
            IndivData.(JointName{jj}).(Parameter{pp})=[];
        end
    end
end
IndivData.MaxVel= [];
IndivData.ContacTime=[];
IndivData.FootContacts =[];

%% loop through subjects
for ff = 1:length(SubjectFoldersElaborated)
    
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{ff},filesep);
    Subject = folderParts{end};
    DirElaborated = strrep(DirElaborated,OldSubject,Subject);
    
    LRFAI           % load results results FAI
    
    Joints = cleanOSName (Joints);
    Variables = fields(Run);
    Joints = Variables(contains(fields(Run),Joints));
    
    AllNames = {'Run_baselineA1' 'Run_baselineB1' 'RunA1' 'RunB1' 'RunC1' 'RunD1' 'RunE1' 'RunF1' ...
        'RunG1' 'RunH1' 'RunI1' 'RunJ1' 'RunK1' 'RunL1'};
    SubjecTrialNames = findClosedText (Labels,TrialNames,AllNames);
    
    % sample frequency
    DirC3D = strrep(DirElaborated,'ElaboratedData','InputData');
    data = btk_loadc3d([DirC3D filesep SubjecTrialNames{1} '.c3d']);
    fs = data.marker_data.Info.frequency;
    idx = contains(AllNames,SubjecTrialNames);
    IndivData.MaxVel(ff,:)=velocityMax(idx);
    
    idx = contains(Labels,SubjecTrialNames);
    IndivData.ContacTime(ff,:)= Run.ContactTime(idx);
    IndivData.FootContacts(ff,:)=Run.GaitCycle.PercentageHeelStrike(idx);
    for jj = 1: length(Joints)
        for pp = 1:length(Parameter)
            data = Run.(Joints{jj}).(Parameter{pp});
            dataCut = findData (data,Labels,SubjecTrialNames);
            for col = 1:size(SubjecTrialNames,2)
                JointName = cleanOSName (Joints);
                Nrows = size(data,1);
                IndivData.(JointName{jj}).(Parameter{pp})(1:Nrows,end+1)= dataCut(:,col);
                NewLabels(ff,:) = SubjecTrialNames;
            end
        end
        
    end
end

% mean data and split into trials
N = length(TrialNames);

for jj = 1: length(Joints)
    for pp = 1:length(Parameter)
        data = IndivData.(JointName{jj}).(Parameter{pp});
        data (data ==0) = NaN;              % create a temporary data variable
        IndivData.(JointName{jj}).(Parameter{pp})=struct;
        IndivData.(JointName{jj}).(Parameter{pp}).Mean = [];
        IndivData.(JointName{jj}).(Parameter{pp}).SD =  [];
        for col = 1:N
            T = sprintf('trial_%.f',col);
            splitData = data(:,col:N:size(data,2));
            IndivData.(JointName{jj}).(Parameter{pp}).(T) = splitData;
            TimeNormalizedData = TimeNorm (splitData,fs);
            TimeNormalizedData(1,:)=TimeNormalizedData(2,:);
            Nrows = size(TimeNormalizedData,1); 
            IndivData.(JointName{jj}).(Parameter{pp}).Mean(1:Nrows,end+1) = mean(TimeNormalizedData,2);
            IndivData.(JointName{jj}).(Parameter{pp}).SD(1:Nrows,end+1) =  std(TimeNormalizedData,0,2);
        end
        
    end
end


IndivData.Labels = NewLabels;




