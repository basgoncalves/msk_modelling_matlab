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

% get all the data, if it does not exist just make it NaN
%% Start Fucntion
function [DirElaborated,Joints,IndivData,Labels] = MeanAllResults_1to14 (SubjectFoldersElaborated,sessionName, Joints,Parameter)
%% create directories and variables

fp = filesep;

if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
    SubjectFoldersElaborated  = uigetmultiple('','Select all the subject folders in the elaborated folder to run kinematics');
end

if ~exist ('sessionName')|| isempty(sessionName)
    sessionPath = split(uigetdir('','Select the session folder name of one of the subjects'),filesep);
    sessionName = sessionPath{end};
end

%generate the first subject
folderParts = split(SubjectFoldersElaborated{1},fp);
Subject = folderParts{end};
DirC3D = [strrep(SubjectFoldersElaborated{1},'ElaboratedData','InputData') filesep sessionName];
OrganiseFAI;

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

if ~exist('Parameter') || isempty(Parameter)||length(Parameter)>1
    Variables = fields(Run.(Joints{1}));
    [idx,~] = listdlg('PromptString',{'Choose the trial to plot'},'ListString',Variables);
    Parameter = Variables (idx);
end


%% generate the first subject
Parts = split(SubjectFoldersElaborated{1},filesep);
Subject = Parts{end};

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
LabelsAll ={};
for ff = 1:length(SubjectFoldersElaborated)
    Parts = split(DirElaborated,filesep);

    OldSubject = Parts{end-1};
    Parts = split(SubjectFoldersElaborated{ff},filesep);
    Subject = Parts{end};
    DirC3D = strrep(strrep(DirElaborated,'ElaboratedData','InputData'),OldSubject,Subject);
    OrganiseFAI
    
    LRFAI           % load results results FAI
    
    Joints = cleanOSName (Joints);          %remove _l or _r from the names 
    Variables = fields(Run);
    Joints = Variables(contains(fields(Run),Joints));
    
    AllNames = {'Run_baselineA1' 'Run_baselineB1' 'RunA1' 'RunB1' 'RunC1' 'RunD1' 'RunE1' 'RunF1' ...
        'RunG1' 'RunH1' 'RunI1' 'RunJ1' 'RunK1' 'RunL1'};
%     SubjecTrialNames = findClosedText (Labels,TrialNames,AllNames);
    
    % sample frequency
    data = btk_loadc3d([DirC3D filesep Labels{1} '.c3d']);
    fs = data.marker_data.Info.frequency;
    idxOriginal = contains(Labels,AllNames);
    idxIIndivData = find(contains(AllNames,Labels));
    IndivData.MaxVel(ff,idxIIndivData)=velocityMax(idxOriginal);
    
    IndivData.ContacTime(ff,idxIIndivData)= Run.ContactTime(idxOriginal);
    IndivData.FootContacts(ff,idxIIndivData)=Run.GaitCycle.PercentageHeelStrike(idxOriginal);
    for jj = 1: length(Joints)
        for pp = 1:length(Parameter)
                Newdata = Run.(Joints{jj}).(Parameter{pp});             % find data for each joint and parameter
                    Newdata = Newdata(:,idxOriginal);
      
                NrowsNew = size(Newdata,1);
                JointName = cleanOSName (Joints);
                OldData = IndivData.(JointName{jj}).(Parameter{pp});
                                                                                                 
                AllData =[];
                AllData(1:NrowsNew,idxIIndivData) = Newdata;            % assign the columns bases on the names of the trials 
                AllData (AllData==0) =NaN;
                sOld = size(OldData);                           
                sAll = size(AllData);
               
                a = max(sOld(1),sAll(1));
                AllData =[[OldData;zeros(abs([a 0]-sOld))],[AllData;zeros(abs([a,0]-sAll))]];           % combine all the trials
                
                IndivData.(JointName{jj}).(Parameter{pp})= AllData;
               
         
        end
        
    end
     LabelsAll (end+1,idxIIndivData)= Labels(idxOriginal);
end

%% mean data and split into trials
N = length(AllNames);

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
            NrowsNew = size(TimeNormalizedData,1); 
            IndivData.(JointName{jj}).(Parameter{pp}).Mean(1:NrowsNew,end+1) = nanmean(TimeNormalizedData,2);
            IndivData.(JointName{jj}).(Parameter{pp}).SD(1:NrowsNew,end+1) =  nanstd(TimeNormalizedData,0,2);
        end
        
    end
end


IndivData.Labels = NewLabels;




